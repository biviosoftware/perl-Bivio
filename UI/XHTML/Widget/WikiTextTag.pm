# Copyright (c) 2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::XHTML::Widget::WikiTextTag;
use strict;
use Bivio::Base 'Bivio::UNIVERSAL';


sub ACCEPTS_CHILDREN {
    return 0;
}

sub parameters {
    my($proto, $args) = @_;
    return shift->SUPER::parameters(@_)
        if @_ > 2;
    my(undef, $attrs) = shift->SUPER::parameters(
        $args->{attrs},
        undef,
        $args->{state} ? (my $error = {}) : undef,
        (caller(1))[3],
    );
    return $proto->parameters_error($error, $args)
        if %$error;
    return ($proto, $args, $attrs);
}

sub parameters_error {
    my($proto, $error, $args) = @_;
    my($te) = $error->{type_error};
    return $proto->render_error(
        $error->{param_name},
        (!defined($error->{param_value}) && $te->eq_not_found
            ? 'unexpected attribute'
#TODO: look up errors in facade
            : "invalid attribute value (@{[$te->get_long_desc]})"
        ) . " passed to \@$args->{tag}",
        $args->{state},
    );
}

sub parse_lines_till_end_tag {
    my(undef, $args) = @_;
    my($state) = $args->{state};
    my($line) = $args->{line};
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

sub pre_parse {
    return;
}

sub render_error {
    shift;
    my(undef, undef, $args) = @_;
    return $args->{proto}->render_error(@_);
}

sub render_html {
    return;
}

sub render_plain_text {
    return;
}

1;
