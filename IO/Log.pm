# Copyright (c) 2003 bivio Software Artisans, Inc.  All Rights Reserved.
# $Id$
package Bivio::IO::Log;
use strict;
$Bivio::IO::Log::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::IO::Log::VERSION;

=head1 NAME

Bivio::IO::Log - write and read log files

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::IO::Log;

=cut

use Bivio::UNIVERSAL;
@Bivio::IO::Log::ISA = ('Bivio::UNIVERSAL');

=head1 DESCRIPTION

C<Bivio::IO::Log>

=cut

#=IMPORTS
use Bivio::IO::Config;
use Bivio::IO::File;
use File::Spec ();
use IO::File ();

#=VARIABLES
Bivio::IO::Config->register(my $_CFG = {
    directory => Bivio::IO::Config->REQUIRED,
    directory_mode => 0750,
    file_mode => 0640,
});

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="file_name"></a>

=head2 static file_name(string base_name) : string

Returns the absolute file name of I<base_name> if
I<base_name> is not already absolute.

=cut

sub file_name {
    my(undef, $base_name) = @_;
    return File::Spec->file_name_is_absolute($base_name)
	? $base_name
	: File::Spec->catfile($_CFG->{directory}, $base_name);
}

=for html <a name="handle_config"></a>

=head2 static handle_config(hash cfg)

=over 4

=item directory : string (required)

Root directory of logs.

=item directory_mode : int [0750]

Mode for directories created by module.

=item file_mode : int [0640]

Mode for files created by module.

=back

=cut

sub handle_config {
    my(undef, $cfg) = @_;
    $_CFG = $cfg;
    $_CFG->{directory} = File::Spec->rel2abs($_CFG->{directory});
    return;
}

=for html <a name="read"></a>

=head2 static read(string base_name) : string_ref

Reads the log file.  If an error occurs, throws an exception.  If I<base_name>
ends in C<.gz>, converts file with C<gunzip>.  If I<base_name> is not absolute,
prefixes with L<directory|"directory">.

=cut

sub read {
    my($proto, $base_name) = @_;
    $base_name = $proto->file_name($base_name);
    local($?);
    my($contents) = Bivio::IO::File->read(
	$base_name =~ /\.gz$/
	    ? IO::File->new("gunzip -c '$base_name' |") : $base_name,
    );
    Bivio::Die->throw_die('IO_ERROR', {
	entity => $base_name,
	operation => 'gunzip',
	message => "non-zero exit status ($?)",
    }) if $?;
    return $contents;
}

=for html <a name="write"></a>

=head2 static write(string base_name, any contents)

Writes the log file.  If an error occurs, throws an exception.  If I<base_name>
ends in C<.gz>, creates file with C<gzip>.  If I<base_name> is not absolute,
prefixes with L<directory|"directory">.

=cut

sub write {
    my($proto, $base_name, $contents) = @_;
    Bivio::IO::File->mkdir_parent_only(
	$base_name = $proto->file_name($base_name),
	$_CFG->{directory_mode},
    );
    local($?);
    Bivio::IO::File->write(
	$base_name =~ /\.gz$/
	    ? IO::File->new("| gzip --best --stdout - > '$base_name'")
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

#=PRIVATE SUBROUTINES

=head1 COPYRIGHT

Copyright (c) 2003 bivio Software Artisans, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
