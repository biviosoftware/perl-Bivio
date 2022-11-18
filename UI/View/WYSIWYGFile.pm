# Copyright (c) 2007-2011 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::View::WYSIWYGFile;
use strict;
use Bivio::Base 'View.Method';
use Bivio::UI::ViewLanguageAUTOLOAD;


sub file_upload_from_wysiwyg {
    view_put(xhtml => 
                 Join([
                     HEAD(Join([
                         STYLE(_css(), {
                             TYPE => 'text/css',
                         }),
                         SCRIPT(_javascript(), {
                             TYPE => 'text/javascript',
                         }),
                     ]),
                      ),
                     BODY(Join([
                         _upload_form(),
                         _image_list(),
                     ])),
                 ]),
             );
}

sub pre_compile {
    my($self) = @_;
    view_parent('WYSIWYGFile->xhtml')
        unless $self->get('view_name') eq 'xhtml';
    return;
}

sub xhtml {
    my($self) = @_;
    view_class_map('XHTMLWidget');
    view_shortcuts('UIXHTML.ViewShortcuts');
    view_put(
        xhtml => '',
    );
    view_main(SimplePage(view_widget_value('xhtml')));
    return;
}

sub _css {
    return << 'EOF';
* {
    font-family: "Arial", "Helvetica", "sans-serif";
    font-size: 13px;
}
div.image_preview {
    float: left;
    margin: 5px;
}
div.err_title {
   display: none;
}
div.err_message {
   display: none;
}
div.field_err {
   display: none;
}
EOF
}

sub _image_list {
    return If ([
        sub {
            my($source) = @_;
            return b_use('Model.RealmFileList')->new($source->req)->load_all({
                path_info => $source->req('path_info'),
            })->get_result_set_size;
        }
    ], Join([
        String(Join([
            'Alternatively, you can select on of the images',
            ' shown below that have already been uploaded to ',
            ['path_info'],
            ':'
        ])),
        BR(), BR(),
        List('RealmFileList', [
            If ([
                sub {
                    my($source, $path) = @_;
                    return $path =~ qr{\.(bmp|gif|jpg|png|tif)$}i;
                }, ['RealmFile.path']], 
                DIV_image_previews(Join([
                    DIV_image_preview(
                        IMG({
                            SRC => URI({
                                task_id => 'FORUM_FILE',
                                path_info => ['RealmFile.path'], 
                            }),
                            WIDTH => '100px',
                            TITLE => [b_use('Type.FilePath'), '->get_tail', ['RealmFile.path']],
                            ONCLICK => Join([
                                'select_image("',
                                [b_use('Type.FilePath'), '->get_tail', ['RealmFile.path']],
                                '");',
                            ]),
                        }),
                    ),
                ])),
            ),
        ]),
    ]));
}


sub _javascript {
   return <<'EOF';
<!--
function select_image(name) {
   if (parent.CKEDITOR) {
       parent.CKEDITOR.g_textInput_imageUrl.setValue(name);
       parent.document.getElementById(parent.CKEDITOR.g_tab_info).click();
   }
   return 0;
}

function submit_form(field) {
    document.getElementById("file_form").submit();
    select_image(field.value);
    return 0;
}

function tzf() {
   document.write('<input name="tz" type="hidden" value="' + new Date().getTimezoneOffset() + '" />');
} 
onload = function() {
    var error_field = document.getElementById("error_field");
    if (error_field) {
        alert(error_field.innerHTML);
    }
    return 1;
}

-->
EOF
}

sub _upload_form {
    return vs_simple_form(FileChangeForm => [
        Join([
            String([
                sub {
                    my($source) = @_;
                    my($query) = $source->req('query') || {};
                    my($path_info) = $source->req('path_info');
                    return 'Uploaded image will'
                        . ($query->{public}
                               ? ' not'
                               : ''
                          )
                        . " be publically accessible ($path_info) ";
                }
            ]),
            Link('change', [
                sub {
                    my($source) = @_;
                    my($query) = $source->req('query') || {};
                    my($path_info) = $source->req('path_info');
                    if (my $public = delete($query->{public})) {
                        $query->{private} = $path_info;
                        $path_info = $public;
                    }
                    else {
                        $query->{public} = $path_info;
                        $path_info = delete($query->{private});                        
                    }
                    return $source->format_uri({
                        task_id => 'FORUM_FILE_UPLOAD_FROM_WYSIWYG',
                        query => $query,
                        path_info => $path_info,
                    })
                }]),
        ]),
        BR(),
        DIV_err_message(
            FormFieldError('RealmFile.path_lc')->put(
                ID => 'error_field',
            ),
        ),                             
        ['FileChangeForm.file', {
            size => 30,
            ONCHANGE => 'submit_form(this);',
        }],
    ], 1)->put(form_name => 'file_form');
}

1;
