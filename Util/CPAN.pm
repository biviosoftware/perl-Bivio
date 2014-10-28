# Copyright (c) 2012 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Util::CPAN;
use strict;
use Bivio::Base 'Bivio.ShellUtil';
b_use('IO.ClassLoaderAUTOLOAD');
b_use('IO.Trace');

our($_TRACE);
my($_SUFFIX_RE) = qr{\.tar\.gz}is;
# COUPLED to _module_map_version
my($_VERSION_RE) = qr{-v?[\d\.]+(?:b|ii)?}is;
b_use('IO.Config')->register(my $_CFG = {
    cvs_dir => 'external/perl-modules-5.16',
    uri_lookaside_map => {
	'MD5' => 'http://search.cpan.org/CPAN/authors/id/G/GA/GAAS/MD5-2.03.tar.gz',
	'MRO-Compat' => 'http://search.cpan.org/CPAN/authors/id/B/BO/BOBTFISH/MRO-Compat-0.12.tar.gz',
        'Perl4-CoreLibs' => 'http://search.cpan.org/CPAN/authors/id/Z/ZE/ZEFRAM/Perl4-CoreLibs-0.003.tar.gz',
	'Razor2-Client-Agent' => 'http://search.cpan.org/CPAN/authors/id/T/TO/TODDR/Razor2-Client-Agent-2.83.tar.gz',
	'Return-Value' => 'http://search.cpan.org/CPAN/authors/id/R/RJ/RJBS/Return-Value-1.666002.tar.gz',
	'Try-Tiny' => 'http://search.cpan.org/CPAN/authors/id/D/DO/DOY/Try-Tiny-0.11.tar.gz',
	'Version-Requirements' => 'http://search.cpan.org/CPAN/authors/id/R/RJ/RJBS/Version-Requirements-0.101022.tar.gz',
    },
});

sub USAGE {
    return <<'EOF';
usage: bivio CPAN [options] command [args..]
commands
  module_to_cvs_import module... -- download latest version and import
  module_to_uri module... -- latest version URIs to cpan.org modules
EOF
}

sub handle_config {
    my(undef, $cfg) = @_;
    $_CFG = $cfg;
    return;
}

sub module_to_cvs_import {
    my($self) = shift;
    my($uris) = $self->module_to_uri(@_);
    IO_File()->do_in_dir(
	IO_File()->mkdir_p(
	    IO_File()->tmp_path($self->req),
	),
	sub {
	    foreach my $uri (@$uris) {
		_cvs_import(_get_and_untar($self, $uri));
	    }
	    return;
	},
    );
    return;
}

sub module_to_uri {
    sub MODULE_TO_URI {[[qw(+module Line)]]}
    my($self, $bp) = shift->parameters(\@_);
    my($map) = _module_map($self);
    return [map(
	$map->{$_}
	    || $_CFG->{uri_lookaside_map}->{$_}
	    || b_die($_, ': not found'),
	@{$bp->{module}},
    )];
}

sub version_to_float {
    sub VERSION_TO_FLOAT {[[qw(uri Text)]]}
    my($self, $bp) = shift->parameters(\@_);
    return _module_map_version($bp->{uri});
}

sub _cvs_import {
    my($self, $tar) = @_;
    my($pkg, $name) = $tar =~ m{((^.+?)$_VERSION_RE)$_SUFFIX_RE}os;
    (my $tag = $pkg) =~ s/\W+/_/g;
    # PlRPC doesn't do this right
    IO_File()->rename($name, $pkg)
	if -d $name;
    IO_File()->do_in_dir(
	$pkg,
	sub {
	    $self->if_option_execute(
		sub {
		    $self->piped_exec([
			# Treat everything as a binary, since we don't know, and
			# we aren't editing much (cvs stores binaries as blobs)
			qw(cvs -Q import -kb -m),
		        "$pkg from CPAN",
			"$_CFG->{cvs_dir}/$name",
			'CPAN',
			$tag,
		    ]);
		    return;
		},
	    );
	    return;
	},
    );
    return;
}

sub _get_and_untar {
    my($self, $uri) = @_;
    my($tar) = Type_FilePath()->get_tail($uri);
    $self->print($tar, "\n");
    IO_File()->write(
	$tar,
	Ext_LWPUserAgent()->bivio_http_get($uri),
    );
    $self->piped_exec([qw(tar xzf), $tar]);
    unlink($tar);
    return ($self, $tar);
}

sub _module_map {
    my($self) = @_;
    return $self->get_if_exists_else_put(
	__PACKAGE__ . '._module_map',
	sub {
	    my($uri) = 'http://www.cpan.org/modules/01modules.index.html';
	    my($html) = Ext_LWPUserAgent()
		->bivio_http_get($uri);
	    $uri =~ s{[^/]+/[^/]+$}{};
	    return _module_map_sort(
		$self,
		[map($uri . $_, $$html =~ m{"\.\./(authors/.+?$_SUFFIX_RE)"}omg)],
	    );
	},
    );
}

sub _module_map_compare {
    my($old, $new) = @_;
    return $new
	unless $old;
    return $old
	if _module_map_version($old) >= _module_map_version($new);
    return $new;
}

sub _module_map_sort {
    my($self, $uris) = @_;
    my($map) = {};
    foreach my $uri (@$uris) {
	unless ($uri =~ m{([^/]+)$_VERSION_RE$_SUFFIX_RE}os) {
	    _trace($uri, ': no match') if $_TRACE;
	    next;
	}
	my($name) = $1;
	$map->{$name} = _module_map_compare($map->{$name}, $uri);
    }
    return $map;
}

sub _module_map_version {
    my($uri) = @_;
    b_die($uri, ': unable to parse version')
	unless $uri =~ m{($_VERSION_RE)$_SUFFIX_RE};
    my($v) = $1;
    # COUPLED TO $_VERSION_RE
    $v =~ s/^-//;
    $v =~ s/^v//i;
    $v =~ s/b$/.1/i;
    my($parts) = [map(
	$_ =~ /^0+(\d+)$/ ? $1 : $_,
	split(/\./, $v),
    )];
    my($first) = shift(@$parts) || 0;
    return $first
	. '.'
	. join(
	    '',
	    map(
		sprintf('%06d', $_),
		@$parts ? @$parts : 0,
	    ),
	);
}

1;
