# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::Model::MGFSDownload;
use strict;
$Bivio::Biz::Model::MGFSDownload::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Biz::Model::MGFSDownload - records MGFS file download stats

=head1 SYNOPSIS

    use Bivio::Biz::Model::MGFSDownload;
    my($download) = Bivio::Biz::Model::MGFSDownload->new();
    $download->load_from_ftp('qspvsd99.zip');
    if ($download->has_changed) {
        $download->save;
    }

=cut

=head1 EXTENDS

L<Bivio::Biz::PropertyModel>

=cut

use Bivio::Biz::PropertyModel;
@Bivio::Biz::Model::MGFSDownload::ISA = ('Bivio::Biz::PropertyModel');

=head1 DESCRIPTION

C<Bivio::Biz::Model::MGFSDownload> records MGFS file download stats.

=cut

#=IMPORTS

use Bivio::SQL::Connection;
use Bivio::SQL::Constraint;
use Bivio::Type::Amount;
use Bivio::Type::Date;
use Bivio::Type::Name;
use HTTP::Request ();
use LWP::UserAgent ();

#=VARIABLES
my($_FTP_DIR) = 'ftp://bivio:crabtree@ftp.mgfs.com/ftpout/pub071/bivio/';
my($_DATE_WINDOW) = 80;

=head1 METHODS

=cut

=for html <a name="has_changed"></a>

=head2 has_changed() : boolean

Returns true if the current state is different than the database entry.

=cut

sub has_changed {
    my($self) = @_;
    my($other) = $self->new($self->get_request);
    if ($other->unauth_load(
	    file_name => $self->get('file_name'),
	    file_date => $self->get('file_date'),
	    file_size => $self->get('file_size'))) {
	return 0;
    }
    return 1;
}

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : hash_ref

B<FOR INTERNAL USE ONLY>

=cut

sub internal_initialize {
    return {
	version => 1,
	table_name => 'mgfs_download_t',
	columns => {
	    file_name => ['Name', 'PRIMARY_KEY'],
	    file_date => ['Date', 'PRIMARY_KEY'],
	    file_size => ['Amount', 'PRIMARY_KEY'],
	    download_date => ['Date', 'NOT_NULL'],
        },
    };
}

=for html <a name="load_from_ftp"></a>

=head2 load_from_ftp(string file_name)

Loads the current file stats from the MGFS ftp site.

=cut

sub load_from_ftp {
    my($self, $file_name) = @_;

    my($request) = HTTP::Request->new(GET => $_FTP_DIR);
    my($agent) = LWP::UserAgent->new();
    my($response) = $agent->request($request);

    my($found_it) = 0;
    if ($response->is_success) {
	my(@content) = split("\n", $response->content);
	foreach my $line (@content) {
	    # format is like:
	    #  12-29-99  10:24PM    13753141 qspvsd99.zip
	    die("invalid format $line")
		    unless $line =~ /^(\S+)\s+(\S+)\s+(\S+)\s+(\S+)$/;
	    my($date, $time, $size, $name) = ($1, $2, $3, $4);

	    if ($name eq $file_name) {
		die("two entries for $file_name found") if ($found_it);
		$found_it = 1;
		my($properties) = $self->internal_get;
		$properties->{file_name} = $name;
		$properties->{file_size} = $size;
		$properties->{download_date} = Bivio::Type::Date->now;

		# date format 12-29-99, use date windowing for century
		die("invalid date $date")
			unless $date =~ /(\d+)\-(\d+)\-(\d+)/;
		my($month, $day, $year) = ($1, $2, $3);
		if ($year < $_DATE_WINDOW) {
		    $year += 2000;
		}
		else {
		    $year += 1900;
		}
		$properties->{file_date} = Bivio::Type::Date->date_from_parts(
			$day, $month, $year);
	    }
	}
    }
    else {
	die("error getting ftp dir: ".$response->status_line);
    }
    die("file $file_name not found") unless $found_it;
    return;
}

=for html <a name="save"></a>

=head2 save()

Saves the contents of the file to disk in the current directory. If the
file is a 'zip' file, then it will be unzipped as well.
Creates a new database record from the current state loaded from ftp.
Download date is set to the current date.
The create() is committed, as the file download can't be rolled back.

=cut

sub save {
    my($self) = @_;

    my($file) = $self->get('file_name');

    open(OUT, '>'.$file) || die("couldn't open $file for writing\n");

    # download the file from the ftp site
    my($request) = HTTP::Request->new(GET => $_FTP_DIR.$file);
    $request->header(Accept => "text/html, */*;q=0.1");

    my($agent) = LWP::UserAgent->new();
    my($response) = $agent->request($request);

    if ($response->is_success) {
	# save it to disk
	print(OUT $response->content);
	close(OUT);

	# unzip it if necessary
	if ($file =~ /\.zip$/i) {
	    my($out) = `unzip -o $file`;

	    # check unzip return code, anything except 0 is an error
	    die("error occurred while unzipping\n".$out) unless ($? == 0);
	}
    }
    else {
	die($response->status_line);
    }

    # save a corresponding database entry
    $self->create({
	file_name => $file,
	file_date => $self->get('file_date'),
	file_size => $self->get('file_size'),
	download_date => $self->get('download_date'),
    });
    # commit it, there is no rollback on the file
    Bivio::SQL::Connection->commit;
    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
