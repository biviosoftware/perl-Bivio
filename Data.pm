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

# The ending to $_Home; Must end in /
sub _REL_HOME { '/../data/' }

# Cached data
my $_Cache = {};

# &lookup $file $proto $br -> $value | undef
#
#    Finds $file in cache or reads from disk and puts in cache.  Checks mtime
#    to make sure cache isn't out of date.  If the value is read and $proto is
#    defined, $proto->init($file, $br) is called to, for example, bless a
#    reference,Returns undef if the file doesn't exist.
#
sub lookup ($$$)
{
    my($file, $proto, $br) = @_;
    $file =~ tr/A-Z/a-z/;                                	  # be friendly
    my($cache) = $_Cache->{$file};
    defined($cache) && 	     			     # in cache and up to date?
	$cache->{mtime} == -M $cache->{absfile} && return $cache->{value};
    # Check length and chars to avoid accesses to files located outside
    # the (_REL_HOME) tree.  A user could type "foo/../../../anyfile" to
    # screw up this package...
    length($file) > &MAX_FILE_LENGTH &&
	$br->not_found(substr($file, 0, &MAX_FILE_LENGTH),
		      '...: file too long (', length($file), ' chars)');
    $file =~ m<[^\w/]> &&
	$br->not_found($file, ': file contains invalid characters');
    defined($_Home) || ($_Home = $br->r->document_root . &_REL_HOME);
    my($absfile) = $_Home . $file . '.pl';
    local($SIG{__WARN__}) = sub { die @_ }; 		# perl be quiet, please
    my($value) = do $absfile;
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
    defined($proto) && $proto->init($value, $br); 			# bless
    $_Cache->{$file} = {
	'absfile' => $absfile,
	'mtime' => $mtime,
	'value' => $value,
    };
    return $value;
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
