# Copyright (c) 1999 bivio, LLC.  All Rights Reserved.
#
# $Id$
#
package Bivio::Data;

use strict;
use Fcntl ();
use Data::Dumper ();
use File::Copy ();
use Bivio::Util;
use GD ();

$Bivio::Data::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub MAX_FILE_LENGTH { 128 }

# Will be initialized on first get
my $_Home = undef; 

# Passed as optional parameter to &lookup to indicate special handling
# See &lookup.
sub PERL { 0 }							      # default
sub MHONARC { 1 }
sub ALL_KEYS { 2 }
sub FILE { 3 }
sub GIF_INFO { 4 }

# The ending to $_Home; Must end in /.  Directory relative to the document_root
sub _REL_HOME { '/../data/' }

my(@_TXN_FILES) = ();

my($_TXN_HANDLE) = undef;

# Cached data
my $_Cache = {};

# &lookup $file $proto_or_sub $br [$type] -> $value | undef
#
#   Finds $file in cache or reads from disk and puts in cache.  Checks mtime to
#   make sure cache isn't out of date.  If the value is read and $proto_or_sub
#   is defined, $proto->init($value, $br) is called to, for example, bless a
#   reference or, e.g., $sub($value, $br) is called to replace $value.
#
#   Returns undef if the file doesn't exist.
#
#   If $type is MHONARC, the file will be stripped of html comments and no
#   ".pl" suffix will be appended.  If it is a message, it won't be cached.
#
#   If $type is ALL_KEYS, all the FILE keys in the specified directory will
#   be returned.
#
#   Note: cached values may be deleted at any time.
sub lookup ($$$;$)
{
    my($file, $proto_or_sub, $br, $type) = @_;
    my($cache) = $_Cache->{$file};
    defined($cache) && 	     			     # in cache and up to date?
	$cache->{mtime} == -M $cache->{absfile} && return $cache->{value};
    local($SIG{__WARN__}) = sub { die @_ };		# perl be quiet, please
    my($absfile, $value, $dont_cache);
    $@ = undef;
    if (!defined($type) || $type == &PERL) {
	$type = &PERL;
	&_check_file_name($br, $file);
	$absfile = &_home($br) . $file . '.pl';
	$value = do $absfile;
    }
    elsif ($type == &MHONARC) {
	# Parse the mhonarc file which is "mostly" perl except for comments
	# by mhonarc that aren't eliminable.  This trick is good enough
	$absfile = &_home($br) . $file;
	my($lock) = $absfile;
	$lock =~ s,[^/]+$,.mhonarc.lck,;
	my($retries) = 4;
	while (-e $lock) {
	    --$retries < 0 && $br->server_busy("mhonarc locked: $lock");
	    select(undef, undef, undef, 5 * rand() + 0.01);  # wait 0-5 seconds
	}
	my($fh) = \*Bivio::Data::IN;	   # Use only one handle to avoid leaks
	if (open($fh, $absfile)) {
	    local($/) = undef;
	    local($_);		    # used as scratch variable by mhonarc files
	    $value = <$fh>; 			# slurp it in ignore I/O errors
#RJN: This is risky, because we may be chopping stuff within the body
#of the message (assuming it is html) which looks like: <!-- -->bla<!-- -->
#Unlikely during prototype phase but may be problems if becomes real.
	    $value =~ s/\<\!\-\-.*\-\-\>//g; 	    	    # keep line numbers
	    close($fh);
	    $value = eval $value;
#RJN: We don't cache any mail message information, because it can grow rapidly
#	    $dont_cache = $file =~ /msg\d+.html$/; 		    # see below
            $dont_cache = 1;
	}
	else {
	    $@ = "open failed: $!"; 			   # save error message
	    -e $absfile || return undef; 	     # not found => no messages
	}
    }
    elsif ($type == &ALL_KEYS) {
	$absfile = &_home($br) . $file;
	-d $absfile ?
	    ($value = [map {s/.pl$//; s,.*/,,; $_} (<$absfile/*.pl>)])
	    : ($@ = 'not a directory')
    }
    elsif ($type == &FILE) {
	# Return the file descriptor
	&_check_file_name($br, $file);
	$absfile = &_home($br) . $file;
	my($fh) = \*Bivio::Data::IN;	   # Use only one handle to avoid leaks
	open($fh, $absfile) && return $fh;
	-e $absfile || $br->not_found($absfile);
	$@ = "open failed: $!";
    }
    elsif ($type == &GIF_INFO) {
	# Return the dimensions
	$absfile = $br->document_root . $file;
	my($fh) = \*Bivio::Data::IN;	   # Use only one handle to avoid leaks
	if (open($fh, $absfile)) {
	    my($gif) =  GD::Image->newFromGif($fh);
	    if (defined($gif)) {
		my($w, $h) = $gif->getBounds();
		$value = {
		    'width' => $w,
		    'height' => $h,
		    'uri' => $file,
		};
	    }
	    else {
		$@ = "newFromGif failed";
	    }
	    close($fh);
	}
	else {
	    $@ = "open failed: $!";
	}
    }
    else {
	$br->server_error("$type: unknown type")
    }
    # Save the mtime of the file.  There's no good way to do this, because
    # it can be modified just before or after the "do".  This is "good enough"
    # for now.  $mtime has to be defined or the cache hit detection above
    # will fail with an uninitialized variable error.
    my($mtime) = -M $absfile;
    unless ($value && defined($mtime)) {
	$@ && $br->server_error("$absfile: parse failed: $@");
	-e $absfile && ($br->server_error($absfile, defined($value)
					  ? ": is empty or invalid"
					  : ": do failed: $!"));
	# Don't cache failures, because they can fill up the cache and because
	# they are hard to manage (-M unknown_file is undef and results in
	# uninitialized variables errors in cache hit detection above).
	return undef;
    }
    if (defined($proto_or_sub)) {
	$value = ref($proto_or_sub) eq 'CODE'
	    ? &$proto_or_sub($value, $br) : $proto_or_sub->init($value, $br);
    }
    $dont_cache && return $value; 		    # don't cache mail messages
    $_Cache->{$file} = {
	'absfile' => $absfile,
	'mtime' => $mtime,
	'value' => $value,
	'type' => $type,
    };
    return $value;
}

sub begin_txn ($$) {
    my($file, $proto_or_sub, $br) = @_;
    my($retries) = 4;
    until (@_TXN_FILES) {
	unless (defined($_TXN_HANDLE)) {
	    $_TXN_HANDLE = \*Bivio::Data::TXN;
	    open($_TXN_HANDLE, '> ' . &_home($br) . '.lock') || next;
	}
	flock($_TXN_HANDLE, &Fcntl::LOCK_EX) && last;
    }
    continue {
	--$retries < 0 && $br->server_busy("can't begin transaction: $!");
	select(undef, undef, undef, 5 * rand() + 0.01);  # wait 0-5 seconds
    }
    push(@_TXN_FILES, $file);		       # we hold the lock at this point
    &invalidate_cache($file);
#RJN: BUG: Need to reget club and user, because they are cached in $br!
#     BUT we currently don't modify them in a txn, so ok for now.
    my($res) = &lookup($file, $proto_or_sub, $br);
    return $res;

}

sub end_txn {
    my($br) = shift;
    @_TXN_FILES || $br->server_error("no transaction");
    my($file) = pop(@_TXN_FILES);
    &_update($file, $br);
    @_TXN_FILES || flock($_TXN_HANDLE, &Fcntl::LOCK_UN);
}

sub abort_txn {
    my($br) = shift;
    @_TXN_FILES || return;			      # no transaction to abort
    my($file) = pop(@_TXN_FILES);
    &invalidate_cache($file);
    @_TXN_FILES || flock($_TXN_HANDLE, &Fcntl::LOCK_UN);
}

# check_txn -> @txn_files
#
#   Called by Bivio::Request only!  Aborts all pending transactions.
#   Returns true if there were no pending transactions.
sub check_txn {
    my($br) = shift;
    my(@res) = @_TXN_FILES;
    &abort_txn($br) while (@_TXN_FILES);
    return @res;
}

sub invalidate_cache {
    my($file) = shift;
    delete $_Cache->{$file};
}

sub _check_file_name ($$) {
    my($br, $file) = @_;
    # Check length and chars to avoid accesses to files located outside
    # the (_REL_HOME) tree.  A user could type "foo/../../../anyfile" to
    # screw up this package...
    length($file) > &MAX_FILE_LENGTH &&
	$br->not_found(substr($file, 0, &MAX_FILE_LENGTH),
		    '...: file name too long (', length($file), ' chars)');
    $file =~ m<\.\.> &&
	$br->not_found($file, ': file name contains invalid characters');
}

# &update $file $br
#   Update a data structure.  This must be in the cache and only valid for
#   &PERL types.  You must update the value from disk (call invalidate_cache
#   then lookup) before calling this routine.
sub _update ($) {
    my($file, $br) = @_;
    my($cache) = $_Cache->{$file};
    defined($cache)  	     			     # in cache and up to date?
	&& $cache->{mtime} == -M $cache->{absfile}
	    || $br->server_error("$file: update attempted on stale data");
    $cache->{type} == &PERL
	|| $br->server_error("$file: can only update PERL");
    &_write($cache->{absfile}, $cache->{value}, $br);
}

# &_write $absfile $value
#   Writes $value to $absfile carefully.  Old values are copied to the file
#   name appended with the time.
#
sub _write ($$$) {
    my($absfile, $value, $br) = @_;
    my($dd) = Data::Dumper->new([$value]);
    $dd->Indent(1);
    $dd->Terse(1);
    my($s) = $dd->Dumpxs();
    my($fh) = \*Bivio::Data::OUT;	   # Use only one handle to avoid leaks
    my($timestamp) = &Bivio::Util::timestamp(time);
    my($new) = $absfile . '.tmp' . $timestamp;
    my($old) = $absfile . '.old' . $timestamp;
    open($fh, '> ' . $new) || $br->server_error("open $new: $!");
    (print $fh $s) || $br->server_error("print $new: $!");
    close($fh) || $br->server_error("close $new: $!");
    unlink($old);				# just in case, shouldn't exist
    ! -e $absfile || &_copy($absfile, $old, $br);
    rename($new, $absfile) || $br->server_error("rename $new $absfile: $!");
}

# File::Copy is broken, because it creates a glob of a code reference
# (*syscopy) and when File::Copy is loaded by PerlModule (httpd) and forked
# (just a guess), the test at line 63 (\&syscopy != \&copy) is invalid, i.e.
# the values are not equal, but they are the same and it gets into an
# infinite recursion.
sub _copy ($$$) {
    my($from, $to, $br) = @_;
    open(COPY_TO, '> ' . $to) || goto _copy_error;
    open(COPY_FROM, '< ' . $from) || goto _copy_error;
    for (;;) {
	my($r, $w, $t, $buf);
	defined($r = sysread(COPY_FROM, $buf, 8192)) || goto _copy_error;
	$r || last;
	for ($w = 0; $w < $r; $w += $t) {
	    ($t = syswrite(COPY_TO, $buf, $r - $w, $w)) || goto _copy_error;
	}
    }
    close(COPY_TO) || goto _copy_error;
    close(COPY_FROM) || goto _copy_error;
    return 1;

 _copy_error:
    my($error) = "$!";
    close(COPY_TO);
    close(COPY_FROM);
    $br->server_error("copy($from, $to): $!");
}


sub _home ($) {
    $_Home || ($_Home = shift->document_root . &_REL_HOME);
}


1;
__END__

=head1 NAME

Bivio::Data - Lookup data about users/clubs in perl files

=head1 SYNOPSIS

  use Bivio::Data;

=head1 DESCRIPTION

Data is stored in a directory C<$_HOME> (initialized from $r->document_root)
with subdirectories for particular types of data, e.g. users and clubs.  Data
is stored in a cache which is refreshed if the source file's mtime changes.  A
data file contains a single perl data structure, e.g {} or [].  Data files may
not be empty as Bivio::Data uses undef as a failure indicator.

=head1 AUTHOR

Rob Nagler <nagler@bivio.com>

=head1 SEE ALSO

Bivio::Club

=cut
