# Copyright (c) 2003-2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::IO::Log;
use strict;
use Bivio::Base 'Bivio.UNIVERSAL';
use File::Spec ();
use IO::File ();

my($_IOF) = b_use('IO.File');
my($_D) = b_use('Bivio.Die');
my($_C) = b_use('IO.Config');
$_C->register(my $_CFG = {
    directory => $_C->REQUIRED,
    directory_mode => 0750,
    file_mode => 0640,
});

sub file_name {
    my($proto, $base_name, $req) = @_;
    return $base_name
	if File::Spec->file_name_is_absolute($base_name);
    return File::Spec->catfile($_CFG->{directory}, $base_name);
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
    my($proto, $base_name, $req) = @_;
    # Reads the log file.  If an error occurs, throws an exception.  If
    # I<base_name> ends in C<.gz>, converts file with C<gunzip>.  If
    # I<base_name> is not absolute, prefixes with L<directory|"directory">.
    $base_name = $proto->file_name($base_name, $req);
    local($?);
    my($contents) = $_IOF->read(
	$base_name =~ /\.gz$/
	    ? IO::File->new("gunzip -c '$base_name' 2>/dev/null |")
	: $base_name,
    );
    $_D->throw_die('IO_ERROR', {
	entity => $base_name,
	operation => 'gunzip',
	message => "non-zero exit status ($?)",
    }) if $?;
    return $contents;
}

sub write {
    my($proto, $base_name, $contents, $req) = @_;
    # Writes the log file.  If an error occurs, throws an exception.  If
    # I<base_name> ends in C<.gz>, creates file with C<gzip>.  If I<base_name>
    # is not absolute, prefixes with L<directory|"directory">.
    $_IOF->mkdir_parent_only(
	$base_name = $proto->file_name($base_name, $req),
	$_CFG->{directory_mode},
    );
    local($?);
    $_IOF->write(
	$base_name =~ /\.gz$/
	    ? IO::File->new(
		"| gzip --best --stdout - > '$base_name' 2>/dev/null")
	    : $base_name,
	ref($contents) ? $contents : \$contents);
    $_D->throw_die('IO_ERROR', {
	entity => $base_name,
	operation => 'gzip',
	message => "non-zero exit status ($?)",
    }) if $?;
    $_IOF->chmod($_CFG->{file_mode}, $base_name);
    return;
}

sub write_compressed {
    my($self, $base, @rest) = @_;
    return $self->write("$base.gz", @rest);
}

1;
