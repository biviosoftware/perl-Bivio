# Copyright (c) 2000-2007 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::IO::File;
use strict;
use Bivio::Base 'Bivio::UNIVERSAL';
use Bivio::Die;
use Bivio::IO::Trace;
use Cwd ();
use File::Basename ();
use File::Path ();
use File::Spec ();
use IO::File ();
use IO::Dir ();

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
our($_TRACE);

sub absolute_path {
    my(undef, $file_name, $base) = @_;
    # Makes I<file_name> absolute relative to I<base> (default: pwd)
    return File::Spec->rel2abs($file_name, $base);
}

sub append {
    # Appends to a file with I<file_name> and appends I<contents> to it.
    # Dies with an IO_ERROR on errors.  Turns on binmode.
    #
    # If the file name is '-', appends to C<STDOUT>.
    return shift->write(_open(shift, 'a'), @_);
}

sub chdir {
    my(undef, $directory) = @_;
    # Change to I<directory> or die.  Returns I<directory>.
    Bivio::Die->die('no directory supplied')
        unless defined($directory) && length($directory);
    Bivio::Die->die('chdir(', $directory, "): $!")
	unless Cwd::chdir($directory);
    _trace($directory) if $_TRACE;
    return $directory;
}

sub chmod {
    my(undef, $perms,  @file) = @_;
    # Changes permissions of I<file>s to I<perms>.  Dies on first error.
    foreach my $file (@file) {
	CORE::chmod($perms, $file)
	    or Bivio::Die->die($file, ": unable to set permissions: $!");
    }
    return;
}

sub chown_by_name {
    my(undef, $owner, $group, @file) = @_;
    # Changes ownership of I<file>s to I<owner> AND I<group>.  Looking up with
    # getpwnam first.  Dies on first error.
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

sub do_in_dir {
    my($proto, $dir, $op) = @_;
    # Change to to I<dir> and call I<op>.  Goes back to previous dir,
    # and then returns result (always array context) or throws exception
    # if that's what happened.
    my($pwd) = $proto->pwd;
    my($die);
    $proto->chdir($dir);
    my(@res) = Bivio::Die->catch($op, \$die);
    $proto->chdir($pwd);
    $die->throw
	if $die;
    return @res;
}

sub do_lines {
    my(undef, $file_name, $op) = @_;
    my($file) = _open($file_name, 'r');
    while (1) {
	undef($!);
	my $line = readline($file);
	unless (defined($line)) {
	    _err('readline', $file, $file_name)
		if $!;
	    last;
	}
	chomp($line);
	last unless $op->($line);
    }
    close($file)
	or _err('close', $file, $file_name);
    return;
}

sub do_read_write {
    my($proto, $file_name, $op) = @_;
    # Calls read() then write() on the results.  If $op returns undef, does
    # not write.  op->() must return a scalar ref or scalar.
    my($res) = $op->($proto->read($file_name));
    $proto->write($file_name, $res)
	if defined($res);
    return;
}

sub map_lines {
    my(undef, $file_name, $op) = @_;
    unless ($op) {
	$op = sub {shift};
    }
    elsif (ref($op) eq 'Regexp') {
	my($qr) = $op;
	$op = sub {[split($qr, shift)]};
    }
    my($file) = _open($file_name, 'r');
    my($res) = [];
    while (1) {
	undef($!);
	my $line = readline($file);
	unless (defined($line)) {
	    _err('readline', $file, $file_name)
		if $!;
	    last;
	}
	chomp($line);
	push(@$res, $op->($line));
    }
    close($file)
	or _err('close', $file, $file_name);
    return $res;
    return;
}

sub mkdir_p {
    my(undef, $path, $permissions) = @_;
    # Creates I<path> including parent directories.  Returns I<path>.
    Bivio::Die->die('no path supplied')
	unless defined($path) && length($path);
    File::Path::mkpath($path, 0, defined($permissions) ? ($permissions) : ());
    _trace($path) if $_TRACE;
    return $path;
}

sub mkdir_parent_only {
    my($proto, $child, $permissions) = @_;
    # Creates parent directories of I<child> if they don't exist.
    # Doesn't create I<child>.
    #
    # Returns parent directory.
    Bivio::Die->die('no path supplied')
	    unless defined($child) && length($child);
    return Bivio::IO::File->mkdir_p(
	File::Basename::dirname($child), $permissions);
}

sub get_modified_date_time {
    my($proto, $file) = @_;
    return $proto->use('Type.DateTime')->from_unix((stat($file))[9]);
}

sub pwd {
    my($dir) = Cwd::getcwd();
    # Returns the current working directory.  dies if can't get pwd.
    Bivio::Die->die("couldn't get cwd") unless $dir;
    return $dir;
}

sub read {
    my(undef, $file_name, $unused) = @_;
    # Returns the contents of the file.  If the file name is '-',
    # input is read from STDIN (new handle)
    #
    # If I<file> is supplied, must be a IO::File to an open file and
    # file_name must be supplied.
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

sub rename {
    my(undef, $old, $new) = @_;
    # Renames I<old> to I<new> and returns I<new>.  Dies on errors.
    Bivio::Die->die('missing args')
	    unless defined($new) && length($new)
		    && defined($old) && length($old);
    rename($old, $new)
	    || Bivio::Die->die('rename(', $old, ',', $new, "): $!");
    return $new;
}

sub rm_children {
    my($proto, $path) = @_;
    return
	unless my $dh = IO::Dir->new(_assert_not_root($path));
    while (defined(my $d = $dh->read)) {
	my($p) = File::Spec->catfile($path, $d);
	next if $d =~ /^\.\.?$/;
	if (-l $p) {
	    unlink($p) || die($p, ": unlink failed: $!");
	}
	else {
	    $proto->rm_rf($p);
	}
    }
    return $path;
}

sub rm_rf {
    my(undef, $path) = @_;
    system('rm', '-rf', $path = _assert_not_root($path));
    return $path;
}

sub temp_file {
    my($proto, $req) = @_;
    # Returns the name of a temp file. If a request is passed, the file
    # is automatically removed when the request is completed.
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

sub unique_name_for_process {
    # Unique file name for (host/process).
    return $$ . '#' . Sys::Hostname::hostname();
}

sub write {
    my(undef, $file_name, $data, $data_offset) = @_;
    # Creates a file with I<file_name> and writes I<data> to it.
    # Dies with an IO_ERROR on errors.  I<data_offset> defaults to 0.
    #
    # If the file name is '-', writes to C<STDOUT>.  Calls C<binmode> just after
    # opening file.  If you don't want this, pass I<file> as a glob_ref.
    #
    # Returns its first argument.
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

sub _assert_not_root {
    my($path) = @_;
    $path = File::Spec->canonpath($path);
    Bivio::Die->die($path, ': file name unacceptable, must be absolute')
	unless File::Spec->file_name_is_absolute($path)
	    && $path ne File::Spec->rootdir;
    return $path;
}

sub _err {
    my($op, $file, $file_name) = @_;
    # close $file if defined, and dies.
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

1;
