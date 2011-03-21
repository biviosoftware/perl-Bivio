# Copyright (c) 1999-2009 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Widget::CKEditor;
use strict;
use Bivio::Base 'HTMLWidget.ControlBase';
use File::stat;
use IO::File;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_IDI) = __PACKAGE__->instance_data_index;
my($_VS) = 'Bivio::UI::HTML::ViewShortcuts';

sub control_on_render {
    my($self, $source, $buffer) = @_;
    $self->SUPER::control_on_render($source, $buffer);
    my($fields) = $self->[$_IDI];
    my($req) = $source->get_request;
    my($form) = $req->get_widget_value(@{$fields->{model}});
    my($field) = $fields->{field};

    my($css) = '';
    b_use('XHTMLWidget.RealmCSS')->new->initialize_with_parent(undef)
	     ->render_tag_value($req, \$css);
    my(@lines) = split('\n', $css);
    my($jscss) = q{['} . join(qq{'\n + '}, @lines) . q{']};

    # need first time initialization to get field name from form model
    unless ($fields->{initialized}) {
	my($type) = $fields->{type} = $form->get_field_type($field);
	my($attributes) = '';
	$self->unsafe_render_attr('edit_attributes', $source, \$attributes);
#TODO: need get_width or is it something else?
	$fields->{prefix} = '<textarea' . $attributes
	    . ($_VS->vs_html_attrs_render($self, $source) || '')
	    . join('', map(qq{ $_="$fields->{$_}"}, qw(rows cols)));
        $fields->{prefix} .= ' readonly="readonly"'
	    if $fields->{readonly};
	$fields->{initialized} = 1;
    }
    my($p, $s) = Bivio::UI::Font->format_html('input_field', $req);

    my($fh, $uri, $lfn);
    EDITOR_SOURCE:
    for my $i ("/b/ckeditor/ckeditor.js", "/b/ckeditor/ckeditor_source.js" ) {
	$lfn = Bivio::UI::Facade->get_local_file_name(
	    Bivio::UI::LocalFileType->PLAIN, $i, $req);
	$uri = $i;
	$fh = IO::File->new($lfn, 'r');
	last EDITOR_SOURCE
	    if (defined $fh);
    }
    $req->throw_die('NOT_FOUND', {entity => $lfn})
       unless (defined $fh);
    my($mt) = stat($fh)->mtime;
    undef $fh;
       
    $$buffer .= '<script type="text/javascript"'
	    . ' src="'
	    . $uri
	    . '?mt='
	    . $mt
	    . '"></script>'
            . $p.$fields->{prefix}
	    . ' name="'
	    . $form->get_field_name_for_html($field)
	    . '">'
	    . $form->get_field_as_html($field)
	    . '</textarea>'
            . '<script type="text/javascript">'
	    . 'CKEDITOR.replace("'
	    . $form->get_field_name_for_html($field)
	    . '", {customConfig: "/b/ckeditor/bwiki_config.js"'
	    . ', filebrowserImageUploadUrl: "/site/change-file/Public"});' . "\n"
	    . 'CKEDITOR.config.contentsCss=' . $jscss. ';'
	    . '</script>'	
	    . $s;
    return;
}

sub initialize {
    my($self) = @_;
    my($fields) = $self->[$_IDI];
    return if $fields->{model};
    $self->unsafe_initialize_attr('edit_attributes');
    $fields->{model} = $self->ancestral_get('form_model');
    ($fields->{field}, $fields->{rows}, $fields->{cols}) = $self->get(
	    'field', 'rows', 'cols');
    $fields->{readonly} = $self->get_or_default('readonly', 0);
    return;
}

sub new {
    my($self) = shift->SUPER::new(@_);
    $self->[$_IDI] ||= {};
    return $self;
}

1;
