# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Test::Reload;
use strict;
use Bivio::Base 'Bivio::UNIVERSAL';
use File::Find ();

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_LAST_TIME) = time;
my($_WATCH) = [grep(s{/BConf.pm$}{}, @{[values(%INC)]})];
# File::Find doesn't put '.' in the Path
#TODO: Use "relative_path", which I think File::Find uses
my($_INC) = [map($_ eq '.' ? '' : "$_/", @INC)];
Bivio::IO::Alert->info('Watching: ', $_WATCH);
my($_HANDLERS) = b_use('Biz.Registrar')->new;
my($_DDL);
my($_CL) = b_use('IO.ClassLoader');

sub handler {
    if (my $modified = _modified_pm()) {
	map($_HANDLERS->call_fifo(handle_unload_class => [$_]), @$modified);
	_do(delete_require => $modified);
	_do(simple_require => $modified);
	map($_HANDLERS->call_fifo(handle_reload_class => [$_]), @$modified);
	$_LAST_TIME = time;
    }
    my($req);
    foreach my $modified (@{_modified_ddl()}) {
	my($realm, $path, $file) = @$modified;
	b_use('ShellUtil.RealmFile')->main(
	    '-realm', $realm,
	    '-input', $file,
	    create_or_update => $path,
	);
    }
    $req->clear_current
	if $req;
    return 1;
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

sub _modified_ddl {
    return []
	unless -d
        ($_DDL ||= Bivio::UI::Facade->get_default->get_local_file_name('DDL', ''));
    my($res) = [];
    File::Find::find({
	no_chdir => 1,
	wanted => sub {
	    my($p) = $File::Find::name;
	    if ($p =~ m{(?:^|/)(?:\.|CVS$)}) {
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
    }, $_DDL);
    return $res;
}

sub _modified_ddl_file {
    my($realm, $path, $file) = @_;
    return _newer($file) ? Bivio::IO::Alert->debug([$realm, $path, $file]) : ();
}

sub _modified_pm {
    my($res) = [];
    File::Find::find({
	no_chdir => 1,
	wanted => sub {
	    push(@$res, _modified_pm_path($_))
		unless $File::Find::prune
	        = $_ =~ m{(?:^|/)(?:Test|files|CVS|t|\..*)$}s;
	    return;
	},
    }, @$_WATCH);
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
