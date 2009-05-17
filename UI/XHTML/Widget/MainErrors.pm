# Copyright (c) 2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::XHTML::Widget::MainErrors;
use strict;
use Bivio::Base 'HTMLWidget.Tag';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_HANDLERS) = b_use('Biz.Registrar')->new;
b_use('XHTMLWidget.Page')->register_handler(__PACKAGE__);
b_use('IO.ClassLoader')->map_require_all(__PACKAGE__->simple_package_name);

sub CLASSLOADER_MAP_NAME {
    return 'XHTMLWidget';
}

sub NEW_ARGS {
    return [];
}

sub handle_page_render_end {
    my($proto, $source, $buffer) = @_;
    return
	unless my $self = $proto->unsafe_self_from_req($source->req);
    $$buffer =~ s/\Q$self/_render($self, $source)/es;
    return;
}

sub initialize {
    return shift->put_unless_exists(
	tag => 'div',
	value => '',
	class => 'b_main_errors',
	tag_if_empty => 0,
    )->SUPER::initialize(@_);
}

sub register_handler {
    shift;
    $_HANDLERS->push_object(@_);
    return;
}

sub render {
    my($self, $source, $buffer) = @_;
#TODO: Generalize backpatching.
    $self->put_on_req($source->req);
    $$buffer .= "$self";
    return;
}

sub render_tag_value {
    my($self, $source, $buffer) = @_;
    $_HANDLERS->do_filo(handle_render_main_errors => [$source, $buffer]);
    return;
}

sub _render {
    my($self, $source) = @_;
    my($b) = '';
    $self->SUPER::render($source, \$b);
    return $b;
}

1;
