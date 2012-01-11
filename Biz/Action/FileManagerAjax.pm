# Copyright (c) 2011 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Action::FileManagerAjax;
use strict;

use Bivio::Base 'Biz.Action';
use Bivio::DieCode;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

my($_C) = b_use('IO.Config');
my($_DT) = b_use('Type.DateTime');
my($_FP) = b_use('Type.FilePath');
my($_MJ) = b_use('MIME.JSON');
my($_RF) = b_use('Model.RealmFile');

my($_MODES) = qr{^(add|addfolder|delete|download|getfolder|getinfo|rename)$};

my($_PREVIEW_IMAGES) = {
    map(($_ => $_ . '.png'),
	qw(aac avi bmp chm css def dll doc fla gif htm html ini
	   jar jpe jpg js lasso mdb mov mp3 mpg pdf php png ppt
           py rb real reg rtf sql swf txt vbs wav wma wmv xls
	   xml xsl zip)
    ),
    map(($_ . 'x' => $_ . '.png'),
	qw(doc ppt xls)
    ),    
    map(($_  => 'zip.png'),
	qw(rar tar iso tgz gz bz2 7z)
    ), 
};

$_C->register(my $_CFG = {
    filemanager_root => '/b/simogeofm',
});


sub execute {
    my($proto, $req) = @_;
    my($query) = lc($req->get('r')->method) eq 'post'
	? b_use('Bivio::Agent::HTTP::Form')->parse($req)
	: $req->get('query'); 
    b_die('unknown mode: ' . $query->{mode})
	unless $query->{mode} =~ $_MODES;
    my($handle_mode) = '_handle_mode_' . $query->{mode};
    $proto->$handle_mode($req, $query);
    return;
}

sub get_root {
    return $_CFG->{filemanager_root};
}

sub handle_config {
    my(undef, $cfg) = @_;
    $_CFG = $cfg;
    return;
}

sub _handle_mode_add {
    my($proto, $req, $query) = @_;
    return _set_json_error($req, 'Browse for a local file before uploading', 1)
	if $query->{newfile}->{filename} =~ /^\s*$/;
    my($rf) = $_RF->new($req);
    return _set_json_error($req, 'Unknown folder: '. $query->{currentpath}, 1)
    	unless $rf->unsafe_load({
    	    path_lc => lc($query->{currentpath}),
    	    is_folder => 1,
    	});
     my($folder_id) = $rf->get('realm_file_id');
     my($path) = $_RF->parse_path($_FP->join($query->{currentpath}, $query->{newfile}->{filename}));
     $path =~ s/['-]/_/g;
     $rf->create_or_update_with_content({
     	folder_id => $folder_id,
	user_id => $req->get('auth_user_id'),
	path => $path,
	is_read_only => 0,
	is_folder => 0,
     }, $query->{newfile}->{content});
    _set_json_response($req, {
	Path => $query->{currentpath},
	Name => $query->{newfile}->{filename},
	Error => q{},
	Code => 0,	
    }, 1);
    return;
}

sub _handle_mode_addfolder {
    my($proto, $req, $query) = @_;
    return _set_json_error($req, 'missing file name')
	if $query->{name} =~ /^\s*$/;
    my($rf) = $_RF->new($req);
    return _set_json_error($req, 'Unknown folder: '. $query->{path})
    	unless $rf->unsafe_load({
    	    path_lc => lc($query->{path}),
    	    is_folder => 1,
    	});	    
    my($parent_folder_id) = $rf->get('realm_file_id');
    my($path) =  $_RF->parse_path($_FP->join($query->{path}, $query->{name}));
    return _set_json_error($req, 'Folder already exists: '. $path)
    	if $rf->unsafe_load({
    	    path_lc => lc($path),
	});
    $rf->create({
     	folder_id => $parent_folder_id,
	user_id => $req->get('auth_user_id'),
	path => $path,
	is_read_only => 0,
	is_folder => 1,
    }, $query->{newfile}->{content});        
    _set_json_response($req, {
	Parent => $query->{path},
	Name => $query->{name},
	Error => q{},
	Code => 0,	
    });
    return;
}

sub _handle_mode_delete {
    my($proto, $req, $query) = @_;
    my($rf) = $_RF->new($req);
    my($path) = $_RF->parse_path($query->{path});
    return _set_json_error($req, 'No such file or folder: '. $path)
    	unless $rf->unsafe_load({
    	    path_lc => lc($path),
    	});     
    my($realm_file_id) = $rf->get('realm_file_id');
    return _set_json_error($req, 'Folder not empty: '. $path)
	unless $rf->is_empty;
    $rf->delete;
    _set_json_response($req, {
	Path => $query->{path},
	Error => q{},
	Code => 0,	
    });
    return;
}



sub _handle_mode_download {
    my($proto, $req, $query) = @_;
    my($rf) = $_RF->new($req);
    my($path) = $_RF->parse_path($query->{path});
    return _set_json_error($req, 'no such file: ' . $query->{path})
	unless $rf->unsafe_load({
	    path_lc => lc($path),
	});
    $req->get('reply')->set_output_type('application/x-download')->set_output($rf->get_content);
    return;
}

sub _handle_mode_getfolder {
    my($proto, $req, $query) = @_;
    my($rf) = $_RF->new($req);
    my($path) = $_RF->parse_path($query->{path}); 
    return _set_json_error($req, 'no such folder: ' . $query->{path})
	unless $rf->load({
	    path_lc => lc($path),
	    is_folder => 1,
	});
    my($json) = {};
    $rf->do_iterate(
	sub {
	    $json->{$rf->get('path')} = _json_for_realm_file($req, $rf);
	    return 1;
	},
	'unauth_iterate_start', 'path', {
	    realm_id => $req->get('auth_id'),
	    folder_id => $rf->get('realm_file_id'),
	});
    _set_json_response($req, $json);
    return;
}

sub _handle_mode_getinfo {
    my($proto, $req, $query) = @_;
    my($rf) = $_RF->new($req);
    my($path) = $_RF->parse_path($query->{path}); 
    return _set_json_error($req, 'no such file: ' . $query->{path})
	unless $rf->load({
	    path => $path,
	});
    _set_json_response($req, _json_for_realm_file($req, $rf));
    return;
}

sub _handle_mode_rename {
    my($proto, $req, $query) = @_;
    my($rf) = $_RF->new($req);
    my($old_path) = $_RF->parse_path($query->{old});
    my($new_name) = $query->{new};
    return _set_json_error($req, 'No such file or folder: '. $old_path)
    	unless $rf->unsafe_load({
    	    path_lc => lc($old_path),
    	});        
    return _set_json_error($req, q{New name contains '/': }. $new_name)
    	if $new_name =~ qr{/};
    my(@parts) = split('/', $rf->get('path'));
    my($old_name) = pop(@parts);
    my($new_path) = $_FP->join(@parts, $new_name);
    $rf->update({
	path => $new_path,
    }) unless $old_name eq $new_name;
    _set_json_response($req, {
	'Old Path' => $old_path,
	'Old Name' => $old_name,
	'New Path' => '/' . $new_path,
	'New Name' => $new_name,
	Error => q{},
	Code => 0,	
    });
    return;
}

sub _json_for_realm_file {
    my($req, $realm_file) = @_;
    my($path) = $realm_file->get('path');
    my($is_folder) = $realm_file->get('is_folder');
    my($values) = {map(($_ => $realm_file->unsafe_get($_)), @{$realm_file->get_info('column_names')})};
    my($clean_path) = $path;
    $clean_path =~ s/^\///;
    $clean_path =~ s/\/*$/\//;
    return {
	Error => q{},
	Code => 0,
	Path =>  $is_folder ? $clean_path : $path,
	Filename => $_FP->get_tail($path),
	'File Type' => $is_folder ? 'dir' : $_FP->get_suffix($path),
	Preview => _preview_image($req, $is_folder, $path),
	Properties=> {
	    'Date Modified' => $_DT->to_local_string($realm_file->get('modified_date_time')), 
	    Size => $is_folder ? 0 : $_RF->get_content_length(undef, '', $values),
	    User => b_use('Model.RealmOwner')->new($req)->unauth_load_or_die({
		realm_id => $realm_file->get('user_id'),
	    })->get('display_name'),
	},		
    };
}

sub _preview_image {
    my($req, $is_folder, $path) = @_;
    my($suffix) = lc($_FP->get_suffix($path));
    my($prefix) = $_CFG->{filemanager_root} . '/images/fileicons/';
    return $prefix . '_Open.png'
	if $is_folder;
    return $req->format_uri({
	task_id => 'FORUM_FILE',
	path_info => $path,
	query => {},
    }) if grep({$suffix eq $_} qw(png gif jpg jpeg));
    if (my $img = $_PREVIEW_IMAGES->{$suffix}) {
	return $prefix . $img;
    }
    return $prefix . 'default.png';
}


sub _set_json_error {
    my($req, $msg, $in_textarea) = @_;
    _set_json_response($req, {
	Code => -1,
	Error => $msg,
    }, $in_textarea);
    return;
}

sub _set_json_response {
    my($req, $response, $in_textarea) = @_;
    my($output) =
	($in_textarea ? '<textarea>' : '')
	. ${$_MJ->to_text($response)}
	. ($in_textarea ? '</textarea>' : '');
    $req->get('reply')->set_output(\$output);
    return;
}
    
1;
