# Copyright (c) 2011-2012 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Widget::WYSIWYGEditor;
use strict;
use Bivio::Base 'HTMLWidget.ControlBase';
use File::stat ();
use Bivio::UI::ViewLanguageAUTOLOAD;

my($_F) = b_use('UI.Facade');
my($_FP) = b_use('Type.FilePath');
my($_IOF) = b_use('IO.File');
my($_HTML) = b_use('Bivio.HTML');
my($_DT) = b_use('Type.DateTime');
my($_PUBLIC) = b_use('Type.WikiDataName')->to_absolute(undef, 1);
my($_PRIVATE) = b_use('Type.WikiDataName')->to_absolute;

sub control_on_render {
    my($self, $source, $buffer) = @_;
    my($html_attrs) = '';
    $self->SUPER::control_on_render($source, \$html_attrs);
    my($form) = $self->resolve_ancestral_attr('form_model', $source->req);
    my($field) = $self->render_simple_attr('field', $source);
    my($f) = $_F->get_from_source($source);
    $$buffer .= '<script type="text/javascript" src="'
        . _src_attr($self, $f, $source)
        . '"></script><textarea'
        . $html_attrs
        . join(
            '',
            map(_render_num_attr($self, $_, $source),
                qw(rows cols readonly)),
        )
        . ' name="'
        . $form->get_field_name_for_html($field)
        . '">'
        . $form->get_field_as_html($field)
        . '</textarea><script type="text/javascript">'
        . 'CKEDITOR.replace("'
        . $form->get_field_name_for_html($field)
        . '", {customConfig: "'
        . $f->get_local_file_plain_common_uri('ckeditor/bwiki_config.js')
        . qq["});\n]
        . _image_upload_tab($self, $source)
        . 'CKEDITOR.config.contentsCss='
        . _jscss($source)
        . ';</script>';
    return;
}

sub initialize {
    my($self) = @_;
    $self->initialize_attr('field');
    $self->initialize_attr('cols');
    $self->initialize_attr('rows');
    $self->initialize_attr('readonly', 0);
    $self->initialize_attr('public_image_folder', $_PUBLIC);
    $self->initialize_attr('private_image_folder', $_PRIVATE);
    $self->initialize_attr('use_public_image_folder', 0);
    $self->initialize_attr('show_image_upload_tab', 1);
    return shift->SUPER::initialize(@_);
}

sub _image_upload_tab {
    my($self, $source) = @_;
    return ''
        unless $self->render_simple_attr('show_image_upload_tab', $source);
    my($which) = $self->render_simple_attr('use_public_image_folder', $source)
        ? 'public' : 'private';
    my($query) = {
        public => $self->render_simple_attr('public_image_folder', $source),
        private => $self->render_simple_attr('private_image_folder', $source),
    };
    return 'CKEDITOR.config.filebrowserImageUploadUrl = "'
        . $source->req->format_stateless_uri({
            task_id => 'FORUM_FILE_UPLOAD_FROM_WYSIWYG',
            path_info => delete($query->{$which}),
            query => $query,
            no_context => 1,
        })
        . qq{";\n};
}

sub _jscss {
    my($source) = @_;
    my($css) = '';
    RealmCSS()
        ->initialize_with_parent(undef)
        ->render_tag_value($source->req, \$css);
    return q{['} . join("'\n+'", split(/\n/, $css)) . q{']};
}

sub _render_num_attr {
    my($self, $attr, $source) = @_;
    my($n) = $self->render_simple_attr($attr, $source);
    if ($attr eq 'readonly') {
        return ''
            unless $n;
        $n = 'readonly';
    }
    elsif ($n !~ /^\d+$/s) {
        b_warn($n, ': ', $attr, ' rendered improperly')
            if defined($n);
        return '';
    }
    # Don't need to escape, because syntax of $n checked above.
    return qq{ $attr="$n"};
}

sub _src_attr {
    my($self, $facade, $source) = @_;
    foreach my $i ('ckeditor/ckeditor.js', 'ckeditor/ckeditor_source.js') {
        next
            unless my $mt = $_IOF->get_modified_date_time(
                $facade->get_local_file_name(
                    'PLAIN',
                    my $uri = $facade->get_local_file_plain_common_uri($i),
                ),
            );
        return $_HTML->escape_attr_value(
            $source->req->format_uri({
                no_context => 1,
                uri => $uri,
                query => {
                    mt => $_DT->to_unix($mt),
                },
            }),
        );
    }
    b_die('ckeditor/ckeditor*.js: not found');
    # DOES NOT RETURN
}

1;
