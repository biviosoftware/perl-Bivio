# Copyright (c) 2000 bivio Inc.  All rights reserved.
# $Id$
package Bivio::IO::File;
use strict;
$Bivio::IO::File::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::IO::File::VERSION;

=head1 NAME

Bivio::IO::File - file utilities

=head1 SYNOPSIS

    use Bivio::IO::File;

=cut

use Bivio::UNIVERSAL;
@Bivio::IO::File::ISA = ('Bivio::UNIVERSAL');

=head1 DESCRIPTION

C<Bivio::IO::File> is a collection of file utilities.

=cut

#=IMPORTS
use Bivio::IO::Trace;
use File::Path ();
use Bivio::Die;
use Bivio::Type::DateTime;

#=VARIABLES
use vars ('$_TRACE');
Bivio::IO::Trace->register;
my($_PACKAGE) = __PACKAGE__;

=head1 METHODS

=cut

=for html <a name="mkdir_p"></a>

=head2 static mkdir_p(string path)

=head2 static mkdir_p(string path, int permissions)

Creates I<path> including parent directories.

=cut

sub mkdir_p {
    my(undef, $path, $permissions) = @_;
    File::Path::mkpath($path, 0, defined($permissions) ? ($permissions) : ());
    return;
}

=for html <a name="read"></a>

=head2 static read(string file_name) : string_ref

Returns the contents of the file.  If the file name is '-',
input is read from STDIN.

=cut

sub read {
    my(undef, $file_name) = @_;
    my($op) = 'open';
 TRY: {
	open(IN, $file_name eq '-' ? '-' : '< '.$file_name) || last TRY;
	$op = 'read';
	my($offset, $read, $buf) = (0, 0, '');
	$offset += $read while $read = CORE::read(IN, $buf, 0x1000, $offset);
	defined($read) || last TRY;
	$op = 'close';
        close(IN) || last TRY;
	_trace('Read ', length($buf), ' bytes from ', $file_name) if $_TRACE;
	return \$buf;
    }
    Bivio::Die->throw_die('IO_ERROR', {
	message => "$!",
	operation => $op,
	entity => $file_name,
    });
    # DOES NOT RETURN
}

=for html <a name="write"></a>

=head2 static write(string file_name, string_ref contents)

Creates a file with I<file_name> and writes I<contents> to it.
Dies with an IO_ERROR on errors.

If the file name is '-', writes to C<STDOUT>.

=cut

sub write {
    my(undef, $file_name, $contents) = @_;
    my($op) = 'open';
 TRY: {
	open(OUT, $file_name eq '-' ? '>-' : '> '.$file_name) || last TRY;
	$op = 'print';
	(print OUT $$contents) || last TRY;
	$op = 'close';
        close(OUT) || last TRY;
	_trace('Wrote ', length($$contents), ' bytes to ', $file_name)
		if $_TRACE;
	return;
    }

    Bivio::Die->throw_die('IO_ERROR', {
	message => "$!",
	operation => $op,
	entity => $file_name,
    });
    # DOES NOT RETURN
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2000 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
