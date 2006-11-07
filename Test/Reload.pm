# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Test::Reload;
use strict;
use base 'Bivio::UNIVERSAL';
use Bivio::IO::ClassLoader;
use File::Find ();

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_LAST_TIME) = time;
my($_WATCH) = [grep(s{/BConf.pm$}{}, @{[values(%INC)]})];
# File::Find doesn't put '.' in the Path
#TODO: Use "relative_path", which I think File::Find uses
my($_INC) = [map($_ eq '.' ? '' : "$_/", @INC)];
Bivio::IO::Alert->info('Watching: ', $_WATCH);

sub handler {
    if (my $modified = _modified()) {
	_do(delete_require => $modified);
	_do(simple_require => $modified);
	$_LAST_TIME = time;
    }
    return 1;
}

sub _do {
    my($method, $modules) = @_;
    foreach my $m (@$modules) {
	Bivio::IO::Alert->info($method, ': ', $m);
	Bivio::IO::ClassLoader->$method($m);
    }
    return;
}

sub _modified {
    my($res) = [];
    File::Find::find({
	no_chdir => 1,
	wanted => sub {
	    push(@$res, _modified_path($_))
		unless $File::Find::prune
	        = $_ =~ m{(?:^|/)(?:Test|files|CVS|t|\..*)$}s;
	    return;
	},
    }, @$_WATCH);
    return @$res ? $res : undef;
}

sub _modified_path {
    my($path) = @_;
    return unless $path =~ /\.pm$/ and my $t = (stat($path))[9];
    return unless $t > $_LAST_TIME
	and $path = (map($path =~ m{^$_(.*)\.pm$}, @$_INC))[0];
    $path =~ s{/}{::}g;
    return $path;
}

1;
