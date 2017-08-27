# Copyright (c) 2006-2017 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Test::Reload;
use strict;
use Bivio::Base 'Bivio.UNIVERSAL';
use File::Find ();

my($_CL) = b_use('IO.ClassLoader');
my($_R) = b_use('Agent.Request');
my($_LAST_TIME) = time;
my($_LESS_SIG);
my($_WATCH) = [grep(s{/BConf.pm$}{}, @{[values(%INC)]})];
# File::Find doesn't put '.' in the Path
#TODO: Use "relative_path", which I think File::Find uses
my($_INC) = [map($_ eq '.' ? '' : "$_/", @INC)];
Bivio::IO::Alert->info('Watching: ', $_WATCH);
my($_HANDLERS) = b_use('Biz.Registrar')->new;
my($_DDL);
use attributes ();
Bivio::Die->eval(q{use attributes __PACKAGE__, \&handler, 'handler'});
my($_DONE) = b_use('Ext.ApacheConstants')->OK;

sub handler {
    if (my $modified = _modified_pm()) {
	map($_HANDLERS->call_fifo(handle_unload_class => [$_]), @$modified);
	_do(delete_require => $modified);
	_do(simple_require => $modified);
	map($_HANDLERS->call_fifo(handle_reload_class => [$_]), @$modified);
    }
    foreach my $modified (@{_modified_ddl()}) {
	my($realm, $path, $file) = @$modified;
	b_use('ShellUtil.RealmFile')->main(
	    '-realm', $realm,
	    '-input', $file,
	    create_or_update => $path,
	);
    }
    b_use('UI.Facade')->map_iterate_with_setup_request(
	$_R->get_current_or_new,
	sub {
	    my($facade) = @_;
	    return $facade->if_2014style(sub {
		if (my $less_sig = _modified_less($facade)) {
		    b_use('ShellUtil.Project')->generate_bootstrap_css;
		    $_LESS_SIG->{$facade->as_string} = $less_sig;
		}
		return;
	    });
	},
    );
    $_LAST_TIME = time;
    $_R->clear_current;
    return $_DONE;
}

sub register_handler {
    shift;
    $_HANDLERS->push_object(@_);
    return;
}

sub _do {
    my($method, $modules) = @_;
    foreach my $m (@$modules) {
	Bivio::IO::Alert->info($method, ': ', $m);
	$_CL->$method($m);
    }
    return;
}

sub _less_sig {
    my($facade) = @_;
    my($req) = $_R->get_current_or_new;
    return join(
	' ',
	map({
	    b_use('IO.File')->get_modified_date_time($_) => $_;
	} glob($facade->get_local_plain_file_name(
	    b_use('ShellUtil.Project')->bootstrap_less_path,
	))),
    );
}

sub _modified_ddl {
    return []
	unless -d
        ($_DDL ||= Bivio::UI::Facade->get_default->get_local_file_name('DDL', ''));
    my($res) = [];
    my($vc_re) = b_use('Util.VC')->CONTROL_DIR_RE;
    File::Find::find({
	no_chdir => 1,
	wanted => sub {
	    my($p) = $File::Find::name;
	    if ($p =~ $vc_re || $p =~ m{(?:^|/)(?:\.)}) {
		$File::Find::prune = 1;
		return;
	    }
	    return
		if $p =~ m{[\~\#]$}s
		|| -d $p;
	    push(@$res, _modified_ddl_file($1, $2, $p))
		if $p =~ m{ddl/([\w-]+)(/Public/.*)}is;
	    return;
	},
    }, "$_DDL/");
    return $res;
}

sub _modified_ddl_file {
    my($realm, $path, $file) = @_;
    return _newer($file) ? Bivio::IO::Alert->debug([$realm, $path, $file]) : ();
}

sub _modified_less {
    my($facade) = @_;
    my($new_sig) = _less_sig($facade);
    return $new_sig ne ($_LESS_SIG->{$facade->as_string} || '')
	? $new_sig : undef;
}

sub _modified_pm {
    my($res) = [];
    my($vc_re) = b_use('Util.VC')->CONTROL_DIR_RE;
    File::Find::find({
	no_chdir => 1,
	wanted => sub {
	    push(@$res, _modified_pm_path($_))
		unless $File::Find::prune
	        = ($_ =~ m{(?:^|/)(?:Test|files|t|\..*)$}s
		  || $_ =~ $vc_re);
	    return;
	},
    }, map($_ ? "$_/" : $_, @$_WATCH));
    return @$res ? $res : undef;
}

sub _modified_pm_path {
    my($path) = @_;
    return
	unless $path =~ /\.pm$/ and _newer($path)
	and $path = (map($path =~ m{^$_(.*)\.pm$}, @$_INC))[0];
    $path =~ s{/}{::}g;
    return $path;
}

sub _newer {
    my($file) = @_;
    return ((stat($file))[9] || 0) > $_LAST_TIME;
}

1;
