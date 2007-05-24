# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::ImageUploadForm;
use strict;
use Bivio::Base 'Bivio::Biz::FormModel';
use Image::Magick ();
use Bivio::Biz::Random;
use Bivio::Biz::Action;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_IFN) = Bivio::Type->get_instance('ImageFileName');

sub execute_ok {
    my($self) = @_;
    $self->validate
	unless $self->unsafe_get('image_magick');
    return if $self->in_error || !$self->unsafe_get('image_file');
    my($im) = $self->get('image_magick');
    return _e($self, FILE_NAME => 'internal_image_path failed')
	unless my $path = $self->internal_image_path;
    $im->Set(magick => ($path =~ /\.(w+)$/)[0]);
    $self->internal_image_scale($im);
    my($blob) = $im->ImageToBlob;
    my($rf) = $self->new_other('RealmFile');
    my($p) = $self->internal_image_properties($path);
    my($m) = $self->get_request->get('Type.FormMode')->eq_edit
	&& $rf->unsafe_load({path => $p->{path}})
	? 'update_with_content'
	: 'create_with_content';
    $self->internal_catch_field_constraint_error(
	image_file => sub {
	    $rf->$m($p, \$blob);
	    return;
	},
    );
    return;
}

sub internal_image_is_required {
    return 1;
}

sub internal_image_max_height {
    return 480;
}

sub internal_image_max_width {
    return 640;
}

sub internal_image_path {
    return $_IFN->to_absolute(
	$_IFN->get_clean_tail(shift->get('image_file')->{filename}));
}

sub internal_image_properties {
    my($self, $path) = @_;
    return {path => $path};
}

sub internal_image_scale {
    my($self, $im) = @_;
    my($w) = $im->Get('width');
    my($h) = $im->Get('height');
    return unless $w > $self->internal_image_max_width
	|| $h > $self->internal_image_max_height;
    my($ratio) = $w/$self->internal_image_max_width;
    $ratio = $h/$self->internal_image_max_height
	if $ratio < $h/$self->internal_image_max_height;
    $im->Resize(
	width => int($w / $ratio),
	height => int($h / $ratio),
	filter => 'Cubic',
#TODO: do we change the depth?
	depth => 8,
    );
    return;
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	visible => [
	    {
		name => 'image_file',
		type => 'FileField',
		constraint => 'NONE',
	    },
	],
	other => [
	    {
		name => 'image_magick',
		type => 'BLOB',
	    },
	],
    });
}

sub validate {
    my($self) = @_;
    shift->SUPER::validate(@_);
    return if $self->get_field_error('image_file');
    my($f) = $self->unsafe_get('image_file');
    unless ($f) {
	return $self->internal_put_error(image => 'NULL')
	    if $self->internal_image_is_required;
	return;
    }
    my($im) = Image::Magick->new;
    my($e);
    return _e($self, 'SYNTAX_ERROR', $e || 'unknown format')
	if $e = $im->BlobToImage(${$f->{content}}) or !$im->Get('magick');
    my($w) = $im->Get('width');
    my($h) = $im->Get('height');
    return _e($self, TOO_MANY => scalar(@$im), ' images in file')
	if @$im > 1;
    $self->internal_put_field(image_magick => $im);
    return;
}

sub _e {
    my($self, $err, @msg) = @_;
    Bivio::IO::Alert->warn($self->get('image_file')->{filename}, ': ', @msg);
    $self->internal_put_error(image_file => $err);
    return;
}

1;
