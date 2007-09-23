# Copyright (c) 2003 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::IO::Log;
use strict;
use Bivio::Base 'Bivio::UNIVERSAL';
use Bivio::IO::Config;
use Bivio::IO::File;
use File::Spec ();
use IO::File ();

# C<Bivio::IO::Log>

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
Bivio::IO::Config->register(my $_CFG = {
    directory => Bivio::IO::Config->REQUIRED,
    directory_mode => 0750,
    file_mode => 0640,
});

#=VARIABLES

sub file_name {
    my(undef, $base_name) = @_;
    # Returns the absolute file name of I<base_name> if
    # I<base_name> is not already absolute.
    return File::Spec->file_name_is_absolute($base_name)
	? $base_name
	: File::Spec->catfile($_CFG->{directory}, $base_name);
}

sub handle_config {
    my(undef, $cfg) = @_;
    # directory : string (required)
    #
    # Root directory of logs.
    #
    # directory_mode : int [0750]
    #
    # Mode for directories created by module.
    #
    # file_mode : int [0640]
    #
    # Mode for files created by module.
    $_CFG = $cfg;
    $_CFG->{directory} = File::Spec->rel2abs($_CFG->{directory})
	if File::Spec->can('rel2abs');
    return;
}

sub read {
    my($proto, $base_name) = @_;
    # Reads the log file.  If an error occurs, throws an exception.  If I<base_name>
    # ends in C<.gz>, converts file with C<gunzip>.  If I<base_name> is not absolute,
    # prefixes with L<directory|"directory">.
    $base_name = $proto->file_name($base_name);
    local($?);
    my($contents) = Bivio::IO::File->read(
	$base_name =~ /\.gz$/
	    ? IO::File->new("gunzip -c '$base_name' 2>/dev/null |")
	: $base_name,
    );
    Bivio::Die->throw_die('IO_ERROR', {
	entity => $base_name,
	operation => 'gunzip',
	message => "non-zero exit status ($?)",
    }) if $?;
    return $contents;
}

sub write {
    my($proto, $base_name, $contents) = @_;
    # Writes the log file.  If an error occurs, throws an exception.  If I<base_name>
    # ends in C<.gz>, creates file with C<gzip>.  If I<base_name> is not absolute,
    # prefixes with L<directory|"directory">.
    Bivio::IO::File->mkdir_parent_only(
	$base_name = $proto->file_name($base_name),
	$_CFG->{directory_mode},
    );
    local($?);
    Bivio::IO::File->write(
	$base_name =~ /\.gz$/
	    ? IO::File->new(
		"| gzip --best --stdout - > '$base_name' 2>/dev/null")
	    : $base_name,
	ref($contents) ? $contents : \$contents);
    Bivio::Die->throw_die('IO_ERROR', {
	entity => $base_name,
	operation => 'gzip',
	message => "non-zero exit status ($?)",
    }) if $?;
    Bivio::IO::File->chmod($_CFG->{file_mode}, $base_name);
    return;
}

1;
