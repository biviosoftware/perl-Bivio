# Copyright (c) 2000 bivio Inc.  All rights reserved.
# $Id$
package Bivio::IO::File;
use strict;
$Bivio::IO::File::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::IO::File::VERSION;

=head1 NAME

Bivio::IO::File - file utilities

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::IO::File;

=cut

use Bivio::UNIVERSAL;
@Bivio::IO::File::ISA = ('Bivio::UNIVERSAL');

=head1 DESCRIPTION

C<Bivio::IO::File> is a collection of file utilities.

=cut

#=IMPORTS
use Bivio::Die;
use Bivio::IO::Trace;
use File::Path ();

#=VARIABLES
use vars ('$_TRACE');
Bivio::IO::Trace->register;
my($_PACKAGE) = __PACKAGE__;

=head1 METHODS

=cut

=for html <a name="chdir"></a>

=head2 static chdir(string directory) : string

Change to I<directory> or die.  Returns I<directory>.

=cut

sub chdir {
    my(undef, $directory) = @_;
    Bivio::Die->die('no directory supplied')
	    unless defined($directory) && length($directory);
    Bivio::Die->die('chdir(', $directory, "): $!")
		unless chdir($directory);
    _trace($directory) if $_TRACE;
    return $directory;
}

=for html <a name="ls"></a>

=head2 static ls(string directory) : array_ref

Returns list of files in I<directory> (only regular files,
no directories or specials)

=cut

sub ls {
    my(undef, $directory) = @_;
    $directory = '.' unless defined($directory);
    my($op) = 'opendir';
 TRY: {
        my($file) = \*Bivio::IO::File::IN;
        opendir($file, $directory) || last TRY;
        my(@files) = grep(-f, readdir($file));
	$op = 'closedir';
        closedir($file) || last TRY;
        return \@files;
    }
    Bivio::Die->throw_die('IO_ERROR', {
	message => "$!",
	operation => $op,
	entity => $directory,
    });
    # DOES NOT RETURN
}

=for html <a name="mkdir_p"></a>

=head2 static mkdir_p(string path) : string

=head2 static mkdir_p(string path, int permissions) : string

Creates I<path> including parent directories.  Returns I<path>.

=cut

sub mkdir_p {
    my(undef, $path, $permissions) = @_;
    Bivio::Die->die('no path supplied')
	    unless defined($path) && length($path);
    File::Path::mkpath($path, 0, defined($permissions) ? ($permissions) : ());
    _trace($path) if $_TRACE;
    return $path;
}

=for html <a name="pwd"></a>

=head2 static pwd() : string

Returns the current working directory.  dies if can't get pwd.

=cut

sub pwd {
    my($pwd) = `pwd 2>&1`;
    die('unable to get pwd') unless $? == 0;
    chomp($pwd);
    return $pwd;
}

=for html <a name="read"></a>

=head2 static read(string file_name) : string_ref

=head2 static read(string file_name, glob_ref file) : string_ref

Returns the contents of the file.  If the file name is '-',
input is read from STDIN (new handle)

If I<file> is supplied, must be a glob_ref to an open file and
file_name must be supplied.

=cut

sub read {
    my(undef, $file_name, $file) = @_;
    my($op) = 'open';
 TRY: {
	unless ($file) {
	    $file = \*Bivio::IO::File::IN;
	    open($file, $file_name eq '-' ? '-' : '< '.$file_name) || last TRY;
	}
	$op = 'read';
	my($offset, $read, $buf) = (0, 0, '');
	$offset += $read
		while $read = CORE::read($file, $buf, 0x1000, $offset);
	defined($read) || last TRY;
	$op = 'close';
        close($file) || last TRY;
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

=for html <a name="rename"></a>

=head2 static rename(string old, string new) : string

Renames I<old> to I<new> and returns I<new>.  Dies on errors.

=cut

sub rename {
    my(undef, $old, $new) = @_;
    Bivio::Die->die('missing args')
	    unless defined($new) && length($new)
		    && defined($old) && length($old);
    rename($old, $new)
	    || Bivio::Die->die('rename(', $old, ',', $new, "): $!");
    return $new;
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
