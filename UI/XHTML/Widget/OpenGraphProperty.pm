# Copyright (c) 2018 Bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::XHTML::Widget::OpenGraphProperty;
use strict;
use Bivio::Base 'UI.Widget';
b_use('UI.ViewLanguageAUTOLOAD');

our($VERSION) = sprintf('%d.%02d', q$Revision: 0.0$ =~ /\d+/g);

sub NEW_ARGS {
    return [qw(value property)];
}

sub SUPPORTED_PROPERTIES {
    return [qw(description title)];
}

sub REQ_KEY {
    return shift->package_name . '.properties';
}

sub initialize {
    my($self) = @_;
    $self->initialize_attr('value');
    my($p) = $self->get('property');
    unless (grep($p eq $_, @{$self->SUPPORTED_PROPERTIES})) {
        $self->die($p, ': unsupported op:<property>');
    }
    return shift->SUPER::initialize(@_);
}

sub render {
    my($self, $source, $buffer) = @_;
    my($res) = $self->render_simple_attr('value', $source);
    b_debug($res, $self->get('property'));
    if (length($res)) {
        my($h) = $source->req->get_if_exists_else_put($self->REQ_KEY, {});
        $h->{$self->get('property')} ||= $res;
    }
    $$buffer .= $res;
    return;
}

1;
