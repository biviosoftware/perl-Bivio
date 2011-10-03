# Copyright (c) 2007-2011 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::View::WysiwygFile;
use strict;
use Bivio::Base 'View.Method';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

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
			 vs_simple_form(FileChangeForm => [
				    
                             Link([
				 sub {
				     my($source) = @_;
				     return $source->unsafe_get('path_info') =~ qr{^/Public/} ?
						'Not publically available images' : 'Publically available images';
				 }],
				  [
				      sub {
					  my($source) = @_;
					  my($path_info) =  $source->unsafe_get('path_info');
					  my($private) = $path_info;
					  $private =~ s/^\/Public//;
					  return $source->format_uri({
					      task_id => 'FORUM_FILE_UPLOAD_FROM_WYSIWYG',
					      path_info => $path_info eq $private ?
						  '/Public' . $path_info : $private,
					      no_context => 1,
					  })
				      }]),				     
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
			 ], 1)->put(form_name => 'file_form'),
			 [
			     sub {
				 my($source) = @_;
				 b_use('Model.RealmFileList')->new($source)->load_all({
				     path_info => $source->get('path_info'),
				 });
				 return;
			     }
			 ],
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
		     ])),
		 ]));
}

sub pre_compile {
    my($self) = @_;
    view_parent('WysiwygFile->xhtml')
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

1;
