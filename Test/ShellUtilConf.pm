# Copyright (c) 2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Test::ShellUtilConf;
use strict;
use Bivio::Base 'TestUnit.ShellUtil';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_FP) = b_use('Type.FilePath');
my($_F) = b_use('IO.File');

sub generate_cases {
    my($self) = @_;
    return [map(
	$_ =~ m{/(\d+)\.in$} ? ($1 => 0) : (),
	glob(
	    $_FP->join(
		$self->builtin_bunit_base_name,
		'*',
	    ),
	),
    )];
}

sub new_unit {
    my(undef, undef, $attrs) = @_;
    my($setup_case) = $attrs && delete($attrs->{setup_case});
    my($self) = shift->SUPER::new_unit(@_);
    $self->builtin_options({
	compute_params => sub {
	    my(undef, $params) = @_;
	    my($in) = $_F->absolute_path(
		$_FP->join(
		    $self->builtin_bunit_base_name,
		    "$params->[0].in",
		),
	    );
	    $self->builtin_go_dir($self->builtin_bunit_base_name);
	    system("tar xzf $params->[0].tgz")
		if -f "$params->[0].tgz";
	    $self->builtin_go_dir($params->[0]);
	    $setup_case->(@_)
		if $setup_case;
	    return [
		'-input',
		$in,
		'generate',
	    ];
	},
	check_return => sub {
	    my(undef, undef) = @_;
	    my($n) = $_F->pwd =~ /(\d+)$/;
	    my($d) = "$n-out";
	    $_F->do_in_dir(
		'..',
		sub {
		    $_F->rm_rf($_F->absolute_path($d));
		    system("tar xzf $d.tgz") == 0 || die;
		    return;
		},
	    );
	    my($diff) = scalar(
		Bivio::ShellUtil->do_backticks(
		    qq{diff '--ignore-matching-lines=^#' -r '../$d' .}));
	    $_F->chdir('../..');
	    return $diff ? [$diff] : [];
	},
    });
    return $self;
}

1;
