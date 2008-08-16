# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::XHTML::Widget::StandardSubmit;
use strict;
use Bivio::Base 'XHTMLWidget.Tag';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_WF) = b_use('Bivio::UI::HTML::WidgetFactory');
my($_CB) = b_use('Type.CancelButton');
my($_M) = b_use('Biz.Model');
my($_A) = b_use('IO.Alert');

sub initialize {
    my($self) = @_;
    return
	if $self->unsafe_get('value');
    my($b) = $self->get_if_exists_else_put('buttons', 'ok_button cancel_button');
    if (ref($b) eq 'ARRAY') {
	$_A->warn_deprecated(
	    $self->ancestral_get('form_class'),
	    ': buttons must be Widget or string');
	$self->put(buttons => join(' ', @$b));
    }
    $self->put_unless_exists(
	class => 'standard_submit',
	tag => 'div',
	value => _buttons($self),
    );
    $self->initialize_attr(labels => {});
    $self->initialize_attr('buttons');
    return $self->SUPER::initialize;
}

sub internal_new_args {
    return shift->internal_compute_new_args([qw(buttons)], \@_);
}

sub _buttons {
    my($self) = @_;
    my($form) = $_M->get_instance($self->ancestral_get('form_class'));
    return [sub {
	my($source) = @_;
	my($labels) = $self->resolve_attr('labels', $source);
	return Join([
	    map(
		$_WF->create(
		    $form->simple_package_name . ".$_",
		    {
			($form->get_field_type($_)->isa($_CB)
			     ? (attributes => 'onclick="reset()"') : ()),
			label => vs_text(
			    $form->simple_package_name,
			    $labels->{$_} || $_,
			),
			class => 'submit',
			map(($_ => $self->ancestral_get($_)),
			    qw(form_class form_model)),
		    },
		),
		split(' ', ${$self->render_attr('buttons', $source)}),
	    ),
	]);
    }];
}

1;
