# Copyright (c) 2000-2013 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::IO::File;
use strict;
use Bivio::Base 'Bivio.UNIVERSAL';
use Cwd ();
use File::Basename ();
use File::Path ();
use File::Spec ();
use File::Find ();
use IO::File ();
b_use('IO.ClassLoader')->require_external_module_quietly('IO::Dir');

our($_TRACE);
b_use('IO.Trace');
my($_DT) = b_use('Type.DateTime');
my($_FP) = b_use('Type.FilePath');
my($_D) = b_use('Bivio.Die');
my($_R) = b_use('Biz.Random');
b_use('IO.Config')->register(my $_CFG = {
    tmp_dir => '/tmp',
});

sub DO_FIND_PRUNE {
    return \&DO_FIND_PRUNE;
}

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
    b_die('no directory supplied')
        unless defined($directory) && length($directory);
    b_die('chdir(', $directory, "): $!")
        unless Cwd::chdir($directory);
    _trace($directory) if $_TRACE;
    return $directory;
}

sub chmod {
    my(undef, $perms,  @file) = @_;
    # Changes permissions of I<file>s to I<perms>.  Dies on first error.
    foreach my $file (@file) {
        CORE::chmod($perms, $file)
            or b_die($file, ": unable to set permissions: $!");
    }
    return;
}

sub chown_by_name {
    my(undef, $owner, $group, @file) = @_;
    # Changes ownership of I<file>s to I<owner> AND I<group>.  Looking up with
    # getpwnam first.  Dies on first error.
    my($o) = (CORE::getpwnam($owner))[2];
    b_die($owner, ': no such user')
        unless defined($o);
    my($g) = (CORE::getgrnam($group))[2];
    b_die($group, ': no such group')
        unless defined($g);
    foreach my $file (@file) {
        CORE::chown($o, $g, $file)
            or b_die($file, ": unable to set owner: $!");
    }
    return;
}

sub do_find {
    my($proto, $op, $dirs, $options) = @_;
    my($terminate);
    File::Find::find(
        {
            no_chdir => 1,
            follow => 0,
            wanted => sub {
                if ($terminate) {
                    $File::Find::prune = 1;
                    return;
                }
                my($res) = $op->($_);
                if (!$res) {
                    $terminate = 1;
                    $File::Find::prune = 1;
                    return;
                }
                return
                    if $res eq '1';
                if ($res eq $proto->DO_FIND_PRUNE) {
                    $File::Find::prune = 1;
                    return;
                }
                b_die($res, ': unknown result from op');
                # DOES NOT RETURN
            },
            $options ? %$options : (),
        },
        @$dirs,
    );
    return;
}

sub do_in_dir {
    my($proto, $dir, $op) = @_;
    # Change to to I<dir> and call I<op>.  Goes back to previous dir,
    # and then returns result (always array context) or throws exception
    # if that's what happened.
    my($pwd) = $proto->pwd;
    $proto->chdir($dir);
    return $_D->catch_and_rethrow(
        $op,
        sub {$proto->chdir($pwd)},
    );
}

sub do_lines {
    my(undef, $file_name, $op) = @_;
    my($file) = _open($file_name, 'r');
    while (1) {
        undef($!);
        last
            if eof($file);
        my $line = readline($file);
        unless (defined($line)) {
            _err('readline', $file, $file_name)
                if $!;
            last;
        }
        $line =~ s/[\r\n]+$//s;
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
        last
            if eof($file);
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
    b_die('no path supplied')
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
    b_die('no path supplied')
        unless defined($child) && length($child);
    return $proto->mkdir_p(File::Basename::dirname($child), $permissions);
}

sub get_modified_date_time {
    my($proto, $file) = @_;
    return $_DT->from_unix((stat($file))[9]);
}

sub handle_config {
    my(undef, $cfg) = @_;
    $_CFG = $cfg;
    return;
}

sub pwd {
    return Cwd::getcwd() || b_die("couldn't get cwd");
}

sub read {
    my(undef, $file_name, $unused) = @_;
    # Returns the contents of the file.  If the file name is '-',
    # input is read from STDIN (new handle)
    #
    # If I<file> is supplied, must be a IO::File to an open file and
    # file_name must be supplied.
    b_die($unused, ': pass IO::File as first parameter')
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
    b_die('missing args')
        unless defined($new) && length($new)
        && defined($old) && length($old);
    b_die('rename(', $old, ',', $new, "): $!")
        unless rename($old, $new);
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
#TODO: piped_exec
    system('rm', '-rf', $path = _assert_not_root($path));
    return $path;
}

sub set_modified_date_time {
    my($proto, $file, $date_time) = @_;
    my($mtime) = $_DT->to_unix($date_time);
    utime($mtime, $mtime, $file)
        || b_die('error setting timestamp: ', $file, ' ', $!);
    return;
}

sub symlink {
    my(undef, $old, $new) = @_;
    symlink($old, $new)
        || b_die("symlink($old, $new): $!");
    return;
}

sub temp_file {
    return shift->tmp_path(@_);
}

sub tmp_path {
    my($proto, $req, $suffix) = @_;
    my($path) = $_FP->join(
        $_CFG->{tmp_dir},
        $_DT->local_now_as_file_name
            . '-'
            . $$
            . '-'
            . $_R->string
            . (defined($suffix) ? $suffix : ''),
    );
    $req->push_process_cleanup(
            sub {
                _trace('removing ', $path) if $_TRACE;
                $proto->rm_rf($path);
                return;
            },
    ) if $req;
    return $path;
}

sub unique_name_for_process {
    # Unique file name for (host/process).
    return $$ . '#' . b_use('Bivio.BConf')->bconf_host_name;
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
    b_die($path, ': file name unacceptable, must be absolute')
        unless File::Spec->file_name_is_absolute($path)
        && $path ne File::Spec->rootdir;
    return $path;
}

sub _err {
    my($op, $file, $file_name) = @_;
    my($err) = "$!";
    close($file)
        if $file;
    b_die(IO_ERROR => {
        message => $err,
        method => __PACKAGE__->my_caller,
        operation => $op,
        entity => ref($file_name) ? $file_name . '' : $file_name,
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
