# Copyright (c) 2000-2006 bivio Software, Inc.  All rights reserved.
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

=for html <a name="absolute_path"></a>

=head2 static absolute_path(string file_name, string base) : string

Makes I<file_name> absolute relative to I<base> (default: pwd)

=cut

sub absolute_path {
    my(undef, $file_name, $base) = @_;
    return File::Spec->rel2abs($file_name, $base);
}

=for html <a name="append"></a>

=head2 static append(string file_name, any contents, int offset)

=head2 static append(IO::File file, string contents, int offset)

Appends to a file with I<file_name> and appends I<contents> to it.
Dies with an IO_ERROR on errors.  Turns on binmode.

If the file name is '-', appends to C<STDOUT>.

=cut

sub append {
    return shift->write(_open(shift, 'a'), @_);
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
    my($g) = (CORE::getgrnam($group))[2];
    Bivio::Die->die($group, ': no such group')
	unless defined($g);
    foreach my $file (@file) {
	CORE::chown($o, $g, $file)
	    or Bivio::Die->die($file, ": unable to set owner: $!");
    }
    return;
}

=for html <a name="do_in_dir"></a>

=head2 static do_in_dir(string dir, code_ref op)

Change to to I<dir> and call I<op>.  Goes back to previous dir,
and then returns result (always array context) or throws exception
if that's what happened.

=cut

sub do_in_dir {
    my($proto, $dir, $op) = @_;
    my($pwd) = $proto->pwd;
    my($die);
    $proto->chdir($dir);
    my(@res) = Bivio::Die->catch($op, \$die);
    $proto->chdir($pwd);
    $die->throw
	if $die;
    return @res;
}

=for html <a name="do_lines"></a>

=head2 static do_lines(string file_name, code_ref op)

=head2 static do_lines(IO::File file, code_ref op)

Call I<op> for each line in I<file>.  Lines are "chomped" before I<op> is
called. If I<op> returns false, stops iterating, and closes file.  Dies on
errors.

=cut

sub do_lines {
    my(undef, $file_name, $op) = @_;
    my($file) = _open($file_name, 'r');
    while (defined(my $line = readline($file))) {
	_err('readline', $file, $file_name)
	    if $!;
	chomp($line);
	last unless $op->($line);
    }
    close($file)
	or _err('close', $file, $file_name);
    return;
}

=for html <a name="do_read_write"></a>

=head2 static do_read_write(string file_name, code_ref op)

Calls read() then write() on the results.  If $op returns undef, does
not write.  op->() must return a scalar ref or scalar.

=cut

sub do_read_write {
    my($proto, $file_name, $op) = @_;
    my($res) = $op->($proto->read($file_name));
    $proto->write($file_name, $res)
	if defined($res);
    return;
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
    return Bivio::IO::File->mkdir_p(
	File::Basename::dirname($child), $permissions);
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

=head2 static read(IO::File file) : string_ref

Returns the contents of the file.  If the file name is '-',
input is read from STDIN (new handle)

If I<file> is supplied, must be a IO::File to an open file and
file_name must be supplied.

=cut

sub read {
    my(undef, $file_name, $unused) = @_;
    Bivio::Die->die($unused, ': pass IO::File as first parameter')
	if ref($unused);
    my($file) = _open($file_name, 'r');
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

=for html <a name="temp_file"></a>

=head2 static temp_file() : string

=head2 static temp_file(Bivio::Agent::Request req) : string

Returns the name of a temp file. If a request is passed, the file
is automatically removed when the request is completed.

=cut

sub temp_file {
    my($proto, $req) = @_;
    my($name) = '/tmp/' . Bivio::Type::DateTime->local_now_as_file_name
        . '-' . $$ . '-' . rand();

    if ($req) {
        $req->put(process_cleanup => [])
            unless $req->unsafe_get('process_cleanup');
        push(@{$req->get('process_cleanup')},
            sub {
                _trace('removing ', $name) if $_TRACE;
                unlink($name);
            });
    }
    return $name;
}

=for html <a name="write"></a>

=head2 static unique_name_for_process() : string

Unique file name for (host/process).

=cut

sub unique_name_for_process {
    return $$ . '#' . Sys::Hostname::hostname();
}

=for html <a name="write"></a>

=head2 static write(string file_name, any data, int data_offset) : any

=head2 static write(IO::File file, any data, int data_offset) : any

Creates a file with I<file_name> and writes I<data> to it.
Dies with an IO_ERROR on errors.  I<data_offset> defaults to 0.

If the file name is '-', writes to C<STDOUT>.  Calls C<binmode> just after
opening file.  If you don't want this, pass I<file> as a glob_ref.

Returns its first argument.

=cut

sub write {
    my(undef, $file_name, $data, $data_offset) = @_;
    my($c) = ref($data) ? $data : \$data;
    my($file) = _open($file_name, 'w');
    if (defined($data_offset)) {
	my($length) = length($$c) - $data_offset;
	while ($length > 0) {
	    my $l = syswrite($file, $$c, $length, $data_offset)
		or _err('syswrite', $file, $file_name);
	    $data_offset += $l;
	    $length -= $l;
	}
    }
    else {
	print($file $$c)
	     or _err('print', $file, $file_name);
    }
    close($file)
	or _err('close', $file, $file_name);
    _trace('Wrote ', length($$c), ' bytes to ', $file_name)
	if $_TRACE;
    return $file_name;
}

#=PRIVATE METHODS

# _err(string op, IO::File file, string file_name)
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
	method => __PACKAGE__->my_caller,
	operation => $op,
	entity => ref($file_name) ? "$file_name" : $file_name,
    });
    return;
}

sub _open {
    my($file_name, $mode, $is_text) = @_;
    return $file_name
	if ref($file_name);
    my $file = IO::File->new(
	$file_name eq '-' ? $mode eq 'r' ? '<-' : '>-' : ($file_name, $mode),
    ) or _err('open', undef, $file_name);
    binmode($file)
	if $is_text;
    return $file;
}

=head1 COPYRIGHT

Copyright (c) 2000-2006 bivio Software, Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
