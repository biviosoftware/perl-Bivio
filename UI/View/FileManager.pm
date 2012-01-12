# Copyright (c) 2008-2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::View::FileManager;
use strict;
use Bivio::Base 'View.Base';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

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
		H1(),
		DIV(q{}, {ID => 'uploadresponse'}),
		BUTTON(q{}, {
		    ID => "home",
		    NAME => "home",
		    TYPE => "button",
		    VALUE => 'Home',
		}),
		INPUT({
		    ID => "mode",
		    NAME => "mode",
		    TYPE => "hidden",
		    VALUE => "add",
		}),
		INPUT({
		    ID => "currentpath",
		    NAME => "currentpath",
		    TYPE => "hidden",
		}),		
		INPUT({
		    ID => "newfile",
		    NAME => "newfile",
		    TYPE => "file",
		}),
		BUTTON(q{}, {
		    ID => "upload",
		    NAME => "upload",
		    TYPE => "submit",
		    VALUE => 'Upload',
		}),
		BUTTON(q{}, {
		    ID => "newfolder",
		    NAME => "newfolder",
		    TYPE => "button",
		    VALUE => 'New Folder',
		}),
		BUTTON(q{}, {
		    ID => "grid",
		    CLASS => 'ON',
		    TYPE => "button",
		}),
		BUTTON(q{}, {
		    ID => "list",
		    TYPE => "button",
		}),		
		
	    ]), {
		ID => "uploader",
		METHOD => "POST",
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
		    return 'var b_can_write = '
			   . ($can_write ? 'true' : 'false')
			   . ";\n"
                           . qq{var b_filemanager_root = '$_FILEMANAGER_ROOT/';};
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
