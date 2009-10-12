# Copyright (c) 2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::XHTML::Widget::WikiText::Macro;
use strict;
use Bivio::Base 'XHTMLWidget.WikiTextTag';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_PKG) = __PACKAGE__;
my($_P) = b_use('Bivio.Parameters');

sub ACCEPTS_CHILDREN {
    return 1;
}

sub handle_register {
    return [qw(b-def b-call)];
}

sub parse_tag_start {
    my(undef, $args) = @_;
    (my $op = $args->{tag}) =~ s/^b-/_op_/;
    return (\&{$op})->(@_);
}

sub _ident {
    my($name, $state) = @_;
    $name = lc($name);
    return $state->{proto}->render_error(
	$name,
	'names must contain at least one underscore and composed of letters and numbers',
	$state,
    ) unless $name && $name =~ /^\w+_\w+$/;
    return $state->{proto}->render_error(
	$name,
	'names must not begin with b_',
	$state,
    ) if $name =~ /^b_/ && $name ne 'b_content';
    return $name;
}

sub _lines {
    my($args, $state, $line) = @_;
    return [$line]
	if defined($line) && length($line);
    my($end_tag) = qr{^\@/$args->{tag}\s*$};
    my($end) = 0;
    my($lines) = [];
    $state->{proto}->do_parse_lines(
	$state,
	sub {
	    my($line) = @_;
	    return $end++
		if $line =~ $end_tag;
	    push(@$lines, $line);
	    return 1;
	},
    );
    return $state->{proto}->render_error(
	$args->{attrs}->{name},
	"\@/$args->{tag} not found",
	$state
    ) unless $end;
    return $lines;
}

sub _op_call {
    my($proto, $args) = @_;
    my($state) = $args->{state};
    my($attrs) = $args->{attrs};
    return $proto->render_error(
	$attrs->{name},
	'macro definition not found',
	$state,
    ) unless my $def = $state->{$_PKG}->{$attrs->{name} || ''};
    my($values) = {map(
	(_ident($_, $state) => $attrs->{$_}),
	grep($_ ne 'name', keys(%$attrs)),
    )};
    if ($def->{call_content}) {
	$values->{'b_content'}
	    = join("\n", @{_lines($args, $state, $args->{line}) || []})
	    unless defined($values->{'b_content'});
    }
    elsif (defined($args->{line}) && length($args->{line})) {
	$proto->render_error($args->{line}, "\@b-def $def->{name} must specify b_content in params to include content", $state);
    }
    $values = $proto->parameters($values, $def->{params}, my $error = {});
    return $proto->parameters_error($error, $args)
	if %$error;
    (my $content = $def->{content}) =~ s{
        \@(\w+)
    }{
	defined($values->{$1}) ? $values->{$1} : "\@$1"
    }exsg;
    $state->{proto}->include_content($content, $def->{calling_context}, $state);
    return;
}

sub _op_def {
    sub _OP_DEF {[qw(name ?params)]};
    my($proto, $args, $attrs) = shift->parameters(@_);
    return
	unless $proto;
    my($state) = $args->{state};
    my($cc) = $state->{proto}->parse_calling_context($state);
    return
	unless my $lines = _lines($args, $state, $args->{line});
    return
	unless my $name = _ident($attrs->{name}, $state);
    my($def) = $state->{$_PKG}->{$name} ||= {};
    return $proto->render_error($name, 'macro already defined', $state)
	if %$def;
    %$def = (
	calling_context => $cc,
	name => $name,
	content => join("\n", @$lines),
	params => [sort(
	    map(_ident($_, $state),
		split(/[,;\s:]+/, $attrs->{params} || '')),
	)],
    );
    $def->{call_content} = grep('b_content' eq $_, @{$def->{params}}) ? 1 : 0;
    $def->{params} = $_P->new([map(
	[$_, 'String', ''],
	@{$def->{params}},
    )]);
    return;
}

1;
