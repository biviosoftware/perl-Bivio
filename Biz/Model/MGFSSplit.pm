# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::Model::MGFSSplit;
use strict;
$Bivio::Biz::Model::MGFSSplit::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Biz::Model::MGFSSplit - provide split format

=head1 SYNOPSIS

    use Bivio::Biz::Model::MGFSSplit;
    Bivio::Biz::Model::MGFSSplit->new();

=cut

=head1 EXTENDS

L<Bivio::Biz::Model::MGFSBase>

=cut

use Bivio::Biz::Model::MGFSBase;
@Bivio::Biz::Model::MGFSSplit::ISA = ('Bivio::Biz::Model::MGFSBase');

=head1 DESCRIPTION

C<Bivio::Biz::Model::MGFSSplit>

=cut

#=IMPORTS
use Bivio::Data::MGFS::Amount;
use Bivio::Data::MGFS::Date;
use Bivio::Data::MGFS::Id;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;
my($_DATES) = 'a9' x 10;
my($_FACTORS) = 'a7' x 10;

=head1 METHODS

=cut

=for html <a name="from_mgfs"></a>

=head2 from_mgfs(string record, string file) : boolean

Overrides MGFSBase.from_mgfs to deal with the one-to-many format for
MGFS splits.

=cut

sub from_mgfs {
    my($self, $record, $file) = @_;
    my($fields) = $self->{$_PACKAGE};

    my($id) = substr($record, 44, 8);
    my(@dates) = unpack($_DATES, substr($record, 420, 90));
    my(@factors) = unpack($_FACTORS, substr($record, 510, 70));

    foreach my $date (@dates) {
	if ($date eq '+00000000' || $date eq '         ') {
	    $date = undef;
	}
	else {
	    $date = Bivio::Data::MGFS::Date->from_mgfs($date);
	    # not interested in anything before 1989
	    my(@parts) = Bivio::Data::MGFS::Date->to_parts($date);
	    if ($parts[5] < 1989) {
		$date = undef;
	    }
	}
    }
    _add_decimal(\@factors);

    my($values) = {mg_id => $id};
    for (my($i) = 0; $i < 10; $i++) {
	next unless defined($dates[$i]);
	$values->{date_time} = $dates[$i];
	$values->{factor} = $factors[$i];

	my($die) = $self->try_to_update_or_create($values,
		$file eq 'chgdb01');
	if ($die) {
	    $self->write_reject_record($die, $record);
	    return 0;
	}
    }
    return 1;
}

=for html <a name="internal_get_mgfs_import_format"></a>

=head2 internal_get_mgfs_import_format() : hash_ref

Returns the defintion of the models MGFS import format.

=cut

sub internal_get_mgfs_import_format {
    return {
	file => {
	    indb01 => [0, Bivio::Biz::Model::MGFSBase::CREATE_ONLY()],
	    chgdb01 => [0, Bivio::Biz::Model::MGFSBase::CREATE_OR_UPDATE()],
	},
	format => [
	    {
		# handled internally by this class
	    },
	],
    };
}

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : hash_ref

B<FOR INTERNAL USE ONLY>

=cut

sub internal_initialize {
    return {
	version => 1,
	table_name => 'mgfs_split_t',
	columns => {
	    mg_id => ['Bivio::Data::MGFS::Id', 'PRIMARY_KEY'],
	    date_time => ['Bivio::Data::MGFS::Date', 'PRIMARY_KEY'],
	    factor => ['Bivio::Data::MGFS::Amount', 'NOT_NULL'],
	},
    };
}

#=PRIVATE METHODS

# _add_decimal(array_ref values)
#
# Iterates each value and inserts a '.' before the third-to-last digit.
#
sub _add_decimal {
    my($values) = @_;
    foreach my $value (@$values) {
	$value =~ s/^(.*)(...)$/$1\.$2/;
    }
}

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
