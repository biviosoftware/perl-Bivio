# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::IO::Zip;
use strict;
use Bivio::Base 'Bivio::UNIVERSAL';
use Archive::Zip ();
use Bivio::IO::File;
use Bivio::IO::Trace;
use IO::File ();

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_IDI) = __PACKAGE__->instance_data_index;

sub add_file {
    # Adds the named file to the archive. This is the preferable way to add a
    # file because it is not brought into memory.
    my($self, $path, $name) = @_;
    my($fields) = $self->[$_IDI];
    _trace($path, ' ', $name) if $_TRACE;
    Bivio::Die->die('file not found for zip: ', $path)
        unless -r $path;
    $fields->{zip}->addFile($path, $name);
    return $self;
}

sub add_string {
    # Adds the in-memory file contents to the archive.
    my($self, $contents, $name) = @_;
    my($fields) = $self->[$_IDI];
    _trace($name) if $_TRACE;
    $fields->{zip}->addString($contents, $name)
        ->desiredCompressionMethod(Archive::Zip::COMPRESSION_DEFLATED);
    return $self;
}

sub get_member_count {
    my($self) = @_;
    my($fields) = $self->[$_IDI];
    return $fields->{zip}->numberOfMembers;
}

sub iterate_members {
    # Iterates each member of the zip file, calling
    # handler->(member, contents).
    # Stops iteratation if handler returns false.
    my($self, $handler) = @_;
    my($fields) = $self->[$_IDI];

    foreach my $member ($fields->{zip}->members) {
        last unless $handler->($member->fileName,
            $fields->{zip}->contents($member));
    }
    return $self;
}

sub new {
    my($proto) = shift;
    my($self) = $proto->SUPER::new(@_);
    $self->[$_IDI] = {
        zip => Archive::Zip->new,
    };
    Archive::Zip::setErrorHandler(sub {Bivio::Die->die(shift)});
    return $self;
}

sub read_zip_from_string {
    # Loads the instance from an in-memory value.
    my($self, $zip_contents) = @_;
    my($fields) = $self->[$_IDI];
    my($file) = Bivio::IO::File->temp_file(Bivio::Agent::Request->get_current);
    Bivio::IO::File->write($file, $zip_contents);
    $fields->{zip} = Archive::Zip->new;
    Bivio::Die->die('failed to read zip from string')
	unless $fields->{zip}->read($file) == Archive::Zip::AZ_OK();
    return $self;
}

sub send_zip_to_client {
    # Saves the zip file to disk, sets the file handle for the request output.
    my($self, $req) = @_;
    my($file_name) = Bivio::IO::File->temp_file($req);
    $self->write_to_file($file_name);
    $req->get('reply')->set_output(IO::File->new($file_name, 'r')
	|| Bivio::Die->die('file open failed: ', $file_name))
	->set_output_type('application/zip');
    return $self;
}

sub write_to_file {
    my($self, $filename) = @_;
    my($fields) = $self->[$_IDI];
    Bivio::Die->die('failed to write zip file')
        unless $fields->{zip}->writeToFileNamed($filename)
            == Archive::Zip::AZ_OK();
    return $self;
}


1;
