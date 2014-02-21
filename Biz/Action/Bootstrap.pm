# Copyright (c) 2014 Bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Action::Bootstrap;
use strict;
use Bivio::Base 'Biz.Action';
b_use('IO.ClassLoaderAUTOLOAD');

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_TIME_SIG);

sub execute_generate_css {
    my($proto, $req) = @_;
    $req->with_realm(
	undef,
	sub {
	    my($old_sig) = $_TIME_SIG || '';
	    my($new_sig) = _time_sig($req);
	    if ($old_sig ne $new_sig) {
		ShellUtil_Project()->generate_bootstrap_css;
		$_TIME_SIG = $new_sig;
	    }
	},
    );
    return $proto->get_instance('LocalFilePlain')
	->execute($req, ShellUtil_Project()->bootstrap_css_path);
}

sub _time_sig {
    my($req) = @_;
    return join(
	' ',
	map({
	    IO_File()->get_modified_date_time($_) => $_;
	} glob(Type_FilePath()->join(
	    $req->req('UI.Facade')->get_local_file_name(UI_LocalFileType()->PLAIN),
	    ShellUtil_Project()->bootstrap_less_path,
	))),
    );
}

1;
