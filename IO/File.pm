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
use File::Spec ();
use IO::File ();

#=VARIABLES
use vars ('$_TRACE');
Bivio::IO::Trace->register;

=head1 METHODS

=cut

=for html <a name="append"></a>

=head2 static append(string file_name, string_ref contents)

=head2 static append(string file_name, string contents)

Appends to a file with I<file_name> and appends I<contents> to it.
Dies with an IO_ERROR on errors.  Turns on binmode.

If the file name is '-', appends to C<STDOUT>.

=cut

sub append {
    my($proto, $file_name, $contents) = @_;
    my($file) = $file_name;
    unless (ref($file_name)) {
	$file = IO::File->new(
	    $file_name eq '-' ? '>>-' : ('>> ' . $file_name));
	binmode($file_name);
    }
    return $proto->write($file, ref($contents) ? $contents : \$contents);
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

=for html <a name="chmod"></a>

=head2 static chmod(int perms, string file, ....)

Changes permissions of I<file>s to I<perms>.  Dies on first error.

=cut

sub chmod {
    my(undef, $perms,  @file) = @_;
    foreach my $file (@file) {
	CORE::chmod($perms, $file)
	    or Bivio::Die->die($file, ": unable to set permissions: $!");
    }
    return;
}

=for html <a name="chown_by_name"></a>

=head2 static chown_by_name(string owner, string group, string file, ...)

Changes ownership of I<file>s to I<owner> AND I<group>.  Looking up with
getpwnam first.  Dies on first error.

=cut

sub chown_by_name {
    my(undef, $owner, $group, @file) = @_;
    my($o) = (CORE::getpwnam($owner))[2];
    Bivio::Die->die($owner, ': no such user')
	unless defined($o);
    my($g) = (CORE::getpwnam($group))[3];
    Bivio::Die->die($group, ': no such group')
	unless defined($g);
    foreach my $file (@file) {
	CORE::chown($o, $g, $file)
	    or Bivio::Die->die($file, ": unable to set owner: $!");
    }
    return;
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

=head2 static read(glob_ref file) : string_ref

Returns the contents of the file.  If the file name is '-',
input is read from STDIN (new handle)

If I<file> is supplied, must be a glob_ref to an open file and
file_name must be supplied.

=cut

sub read {
    my(undef, $file_name, $file) = @_;
    if ($file) {
	Bivio::IO::Alert->warn_deprecated('pass glob_ref as first param');
	$file_name = $file;
    }
    $file = ref($file_name) ? $file_name
	: IO::File->new($file_name eq '-' ? '-' : '< '.$file_name)
		|| _err('open', $file, $file_name);
    my($offset, $read, $buf) = (0, 0, '');
    $offset += $read
	while $read = CORE::read($file, $buf, 0x1000, $offset);
    defined($read)
	or _err('read', $file, $file_name);
    close($file)
	or _err('close', $file, $file_name);
    _trace('Read ', length($buf), ' bytes from ', $file_name) if $_TRACE;
    return \$buf;
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

=for html <a name="rm_rf"></a>

=head2 static rm_rf(string path) : string

Recursively delete all files under I<path>.  Does not accept relative paths or
'/'.  Returns I<path>

Only works on Unix.

=cut

sub rm_rf {
    my(undef, $path) = @_;
    $path = File::Spec->canonpath($path);
    Bivio::Die->die($path, ': file name unacceptable, must be absolute')
	unless File::Spec->file_name_is_absolute($path)
	    && $path ne File::Spec->rootdir;
    system('rm', '-rf', $path);
    return $path;
}

=for html <a name="write"></a>

=head2 static write(string file_name, any contents) : any

=head2 static write(glob_ref file, any contents) : any

Creates a file with I<file_name> and writes I<contents> to it.
Dies with an IO_ERROR on errors.

If the file name is '-', writes to C<STDOUT>.  Calls C<binmode> just after
opening file.  If you don't want this, pass I<file> as a glob_ref.

Returns its first argument.

=cut

sub write {
    my(undef, $file_name, $contents) = @_;
    my($c) = ref($contents) ? $contents : \$contents;
    my($file) = $file_name;
    unless (ref($file)) {
	$file = IO::File->new($file_name eq '-' ? '>-' : '> '.$file_name)
	    or _err('open', $file, $file_name);
	binmode($file);
    }
    (print $file $$c)
	or _err('print', $file, $file_name);
    close($file)
	or _err('close', $file, $file_name);
    _trace('Wrote ', length($$c), ' bytes to ', $file_name)
	if $_TRACE;
    return $file_name;
}

#=PRIVATE METHODS

# _err(string op, glob_ref file, string file_name)
#
# close $file if defined, and dies.
#
sub _err {
    my($op, $file, $file_name) = @_;
    my($err) = "$!";
    # Don't leave the file hanging open
    close($file)
	if $file;
    Bivio::Die->throw_die('IO_ERROR', {
	message => $err,
	operation => $op,
	entity => ref($file_name) ? "$file_name" : $file_name,
    });
    return;
}

=head1 COPYRIGHT

Copyright (c) 2000 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
