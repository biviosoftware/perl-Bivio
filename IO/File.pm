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
use Cwd ();
use File::Path ();
use File::Basename ();

#=VARIABLES
use vars ('$_TRACE');
Bivio::IO::Trace->register;

=head1 METHODS

=cut

=for html <a name="append"></a>

=head2 static append(string file_name, string_ref contents)

=head2 static append(string file_name, string contents)

Appends to a file with I<file_name> and appends I<contents> to it.
Dies with an IO_ERROR on errors.

If the file name is '-', appends to C<STDOUT>.

=cut

sub append {
    my(undef, $file_name, $contents) = @_;
    my($c) = ref($contents) ? $contents : \$contents;
    my($op) = 'open';
#TODO: Share with write
 TRY: {
	open(OUT, $file_name eq '-' ? '>>-' : '>> '.$file_name) || last TRY;
	$op = 'print';
	(print OUT $$c) || last TRY;
	$op = 'close';
        close(OUT) || last TRY;
	_trace('Wrote ', length($$c), ' bytes to ', $file_name) if $_TRACE;
	return;
    }

    Bivio::Die->throw_die('IO_ERROR', {
	message => "$!",
	operation => $op,
	entity => $file_name,
    });
    # DOES NOT RETURN
}

=for html <a name="chdir"></a>

=head2 static chdir(string directory) : string

Change to I<directory> or die.  Returns I<directory>.

=cut

sub chdir {
    my(undef, $directory) = @_;
    Bivio::Die->die('no directory supplied')
	    unless defined($directory) && length($directory);
    Bivio::Die->die('chdir(', $directory, "): $!")
		unless Cwd::chdir($directory);
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

=for html <a name="mkdir_parent_only"></a>

=head2 static mkdir_parent_only(string child, int permissions) : string

Creates parent directories of I<child> if they don't exist.
Doesn't create I<child>.

Returns parent directory.

=cut

sub mkdir_parent_only {
    my($proto, $child, $permissions) = @_;
    Bivio::Die->die('no path supplied')
	    unless defined($child) && length($child);
    my($parent) = File::Basename::dirname($child);
    Bivio::IO::File->mkdir_p($parent);
    return $parent;
}

=for html <a name="pwd"></a>

=head2 static pwd() : string

Returns the current working directory.  dies if can't get pwd.

=cut

sub pwd {
    my($dir) = Cwd::getcwd();
    Bivio::Die->die("couldn't get cwd") unless $dir;
    return $dir;
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

=head2 static write(string file_name, string_ref contents, boolean binmode)

=head2 static write(string file_name, string contents, boolean binmode)

Creates a file with I<file_name> and writes I<contents> to it.
Dies with an IO_ERROR on errors.

If the file name is '-', writes to C<STDOUT>.  If I<binmode> is true, calls
C<binmode> just after opening file.

=cut

sub write {
    my(undef, $file_name, $contents, $binmode) = @_;
    my($c) = ref($contents) ? $contents : \$contents;
    my($op) = 'open';
 TRY: {
	open(OUT, $file_name eq '-' ? '>-' : '> '.$file_name) || last TRY;
	binmode(OUT);
	$op = 'print';
	(print OUT $$c) || last TRY;
	$op = 'close';
        close(OUT) || last TRY;
	_trace('Wrote ', length($$c), ' bytes to ', $file_name)
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
