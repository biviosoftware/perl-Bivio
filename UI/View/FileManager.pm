# Copyright (c) 2008-2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::View::FileManager;
use strict;
use Bivio::Base 'View.Base';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_FP) = b_use('Type.FilePath');
my($_FILEMANAGER_ROOT) = b_use('Action.FileManagerAjax')->get_root;

sub file_manager {
    my($self, $model) = @_;
# from src/javascript/simogeofm/index.html
    return shift->internal_body(
	DIV_filemanager(Join([
	    _css(
		'scripts/jquery.filetree/jqueryFileTree.css',
		'scripts/jquery.contextmenu/jquery.contextMenu-1.01.css',
		'styles/filemanager.css',
	     ),
	    FORM(Join([
		BUTTON(q{}, {
		    ID => 'home',
		    NAME => 'home',
		    TYPE => 'button',
		    VALUE => 'Home',
		}),
		H1(),
		DIV(q{}, {ID => 'uploadresponse'}),
		INPUT({
		    ID => 'mode',
		    NAME => 'mode',
		    TYPE => 'hidden',
		    VALUE => 'add',
		}),
		INPUT({
		    ID => 'currentpath',
		    NAME => 'currentpath',
		    TYPE => 'hidden',
		}),
		DIV(Join([
		DIV(q{}, {
		    ID => 'upload',
		    CLASS => 'loading',
		}),
		DIV_newfile(Join([
		    INPUT({
			ID => 'newfile',
			NAME => 'newfile',
			TYPE => 'file',
			MULTIPLE => 'multiple',
		    }),
		    DIV(Join([
			DIV('Upload', {
			    ID => 'pseudo_upload_button_label',
			}),
		    ]), {
			ID => 'pseudo_upload_button', 
		    }),		    
		    ]), {
			ID => 'newfile_composite',
		}),
		INPUT({
		    ID => 'droppedfiles',
		    NAME => 'droppedfiles',
		    TYPE => 'hidden',		    
		}),		
		BUTTON(q{}, {
		    ID => 'newfolder',
		    NAME => 'newfolder',
		    TYPE => 'button',
		    VALUE => 'New Folder',
		}),
		BUTTON(q{}, {
		    ID => 'grid',
		    CLASS => 'ON',
		    TYPE => 'button',
		}),
		BUTTON(q{}, {
		    ID => 'list',
		    TYPE => 'button',
		}),
		]), {
		    ID => 'controls',
		}),
		
	    ]), {
		ID => 'uploader',
		METHOD => 'POST',
	    }),
	    DIV(Join([
		DIV(q{}, {
		    ID => 'filetree',
		}),
		DIV(Join([
		    H1(),
		    
		]), {
		    ID => 'fileinfo',
		}),		
	    ]), {
		ID => 'splitter',
	    }),
	    UL(Join([
		map(
		    LI(A(q{}, {
			HREF => '#' . $_,
		    }), {
			CLASS => $_ . ' separator',	
		    }),
		    qw(download rename delete),
		),
	    ]), {
		ID => 'itemOptions',
		CLASS => 'contextMenu',
	    }),
	    SCRIPT([
		sub {
		    my($source) = @_;
		    my($can_write) = $source->req->can_user_execute_task(
			    $source->req('task')->get_attr_as_task('write_task'));
		    my($filesystem_root) = $source->req('path_info');
		    my($file_connector) = $source->req->format_uri({
			task_id => 'FORUM_FILE_MANAGER_AJAX',
			path_info => '',
			query => {},
		    });
		    b_debug($file_connector);
		    return 'var b_can_write = '
			   . ($can_write ? 'true' : 'false')
			   . ";\n"
                           . qq{var b_filemanager_root = '$_FILEMANAGER_ROOT/';\n}
			   . qq{var b_filesystem_root = '$filesystem_root';\n}
			   . qq{var b_file_connector = '$file_connector';\n};
		}], {
		    TYPE => 'text/javascript',
		}),	    
	    _script(
		'jquery-1.6.1.min.js',
		'jquery.form-2.63.js',
		'jquery.splitter/jquery.splitter-1.5.1.js',
		'jquery.filetree/jqueryFileTree.js',
		'jquery.contextmenu/jquery.contextMenu-1.01.js',
		'jquery.impromptu-3.1.min.js',
		'jquery.tablesorter-2.0.5b.min.js',
		'filemanager.config.js',
		'filemanager.js',
	    ),
    ]), {
	ID => 'filemanager',
    })
  );
}

sub _css {
    my(@stylesheets) = @_;
    return map(LINK({
	TYPE => 'text/css',
	REL => 'stylesheet',
        HREF =>  $_FILEMANAGER_ROOT . '/' . $_,
	value => undef,
	}), @stylesheets);
}

sub _script {
    my(@scripts) = @_;
    return map(SCRIPT({
	TYPE => 'text/javascript',
        SRC => $_FILEMANAGER_ROOT . '/scripts/' . $_,
	value => q{},
	}), @scripts);
}

1;
