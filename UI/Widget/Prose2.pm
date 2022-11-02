# Copyright (c) 2014 Bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::Widget::Prose2;
use strict;
use Bivio::Base 'Widget.Simple';
b_use('UI.ViewLanguageAUTOLOAD');


sub control_on_render {
    my($self) = @_;
    return;
}

sub initialize {
    my($self, $source) = @_;
    $self->put(_prose2_join => _parse($self, $self->get('value'), $source))
        unless ref($self->get('value'));
    return shift->SUPER::initialize(@_);
}

sub render {
    my($self, $source, $buffer) = @_;
    $self->get_or_default(
        '_prose2_join',
        sub {
            return _parse($self, ${$self->render_attr('value', $source)}, $source);
        },
    )->render($source, $buffer);
    return;
}

sub _parse {
    my($self, $value, $source) = @_;
    return Join([
        map(
            $_ =~ s/^\<\{// ? _parse_code($self, $_, $source) : $_,
            split(/(?=\<\{)|(?<=\}\>)/, $value),
        ),
    ])->initialize_with_parent($self, $source);
}

sub _parse_code {
    my($self, $code, $source) = @_;
    $self->die($code, $source, 'missing Prose program terminator "}>"')
        unless $code =~ s/\}\>$//s;
    return UI_ViewLanguage()->eval(\$code);
}

1;
