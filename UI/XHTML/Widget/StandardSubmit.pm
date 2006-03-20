# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::XHTML::Widget::StandardSubmit;
use strict;
use base 'Bivio::UI::HTML::Widget::Tag';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub initialize {
    my($self) = @_;
    return if $self->unsafe_get('value');
    my($form) = Bivio::Biz::Model->get_instance(
	    $self->ancestral_get('form_class'));
    my($labels) = $self->get_or_default('labels', {});
    my($buttons) = $self->get_or_default(
	'buttons', ['ok_button', 'cancel_button']);
    $self->put_unless_exists(class => 'standard_submit')
	->put(
	    tag => 'div',
	    value => Join([
	    map(
		Bivio::IO::ClassLoader->simple_require(
		    'Bivio::UI::HTML::WidgetFactory'
		)->create(
		    $form->simple_package_name . ".$_",
		    {
			($form->get_field_type($_)->isa(
			    'Bivio::Type::CancelButton'
			) ? (attributes => 'onclick="reset()"') : ()),
			label => vs_text(
			    $form->simple_package_name,
			    $labels->{$_} || $_,
			),
			class => 'submit',
		    },
		),
		ref($buttons) ? @$buttons : $buttons,
	    ),
	]));
    return $self->SUPER::initialize;
}

sub internal_new_args {
    return shift->internal_compute_new_args([qw(buttons)], \@_);
}

1;
