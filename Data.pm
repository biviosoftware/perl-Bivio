# Copyright (c) 1999 bivio, LLC.  All Rights Reserved.
#
# $Id$
#
package Bivio::Data;

use strict;

$Bivio::Data::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub MAX_FILE_LENGTH { 128 }

# Will be initialized on first get
my $_Home = undef; 

# Passed as optional parameter to &lookup to indicate special handling
# See &lookup.
sub PERL { 0 }							      # default
sub MHONARC { 1 }
sub ALL_KEYS { 2 }

# The ending to $_Home; Must end in /
sub _REL_HOME { '/../data/' }

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
    $file =~ tr/A-Z/a-z/;                                	  # be friendly
    my($cache) = $_Cache->{$file};
    defined($cache) && 	     			     # in cache and up to date?
	$cache->{mtime} == -M $cache->{absfile} && return $cache->{value};
    local($SIG{__WARN__}) = sub { die @_ };		# perl be quiet, please
    my($absfile, $value, $dont_cache);
    if (!defined($type) || $type == &PERL) {
	# Check length and chars to avoid accesses to files located outside
	# the (_REL_HOME) tree.  A user could type "foo/../../../anyfile" to
	# screw up this package...
	length($file) > &MAX_FILE_LENGTH &&
	    $br->not_found(substr($file, 0, &MAX_FILE_LENGTH),
		      '...: file name too long (', length($file), ' chars)');
	$file =~ m<[^\w/]> &&
	    $br->not_found($file, ': file name contains invalid characters');
	$absfile = &_home($br) . $file . '.pl';
	$value = do $absfile;
    }
    elsif ($type == &MHONARC) {
	# Parse the mhonarc file which is "mostly" perl except for comments
	# by mhonarc that aren't eliminable.  This trick is good enough
	$absfile = &_home($br) . $file;
	my($fh) = \*Bivio::Data::IN;
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
	    $dont_cache = $file =~ /msg\d+.html$/; 		    # see below
	}
	else {
	    $@ = "open failed: $!";
	}
    }
    elsif ($type == &ALL_KEYS) {
	$absfile = &_home($br) . $file;
	-d $absfile ?
	    ($value = [map {s/.pl$//; s,.*/,,; $_} (<$absfile/*.pl>)])
	    : ($@ = 'not a directory')
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
    };
    return $value;
}

sub _home ($) {
    $_Home || ($_Home = shift->r->document_root . &_REL_HOME);
}

sub invalidate_cache {
    my($file) = shift;
    delete $_Cache->{$file};
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
