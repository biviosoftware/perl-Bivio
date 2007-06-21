# Copyright (c) 2005-2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::FormError;
use strict;
use Bivio::Base 'Bivio::UI::Text';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
our($_IN_EVAL);

sub field_value {
    my(undef, $item) = @_;
    Bivio::Die->die($item, ': FormError not evaluating')
        unless $_IN_EVAL;
    Bivio::Die->die($item, ': no such FormError attribute')
	unless exists($_IN_EVAL->{$item});
    return $_IN_EVAL->{$item};
}

sub to_html {
    my($proto, $source, $form, $field, $label, $error) = @_;
    # Returns the error string for this tuple.  If none is found,
    # C<get_long_desc> is called.
    my($self) = $proto->internal_get_self($source->get_request);
    my($form_class) = ref($form) || $form;
    $error ||= $form->get_field_error($field);
    my($v) = $self->unsafe_get_value(
	$form_class->simple_package_name, $field, $error->get_name);
    if (defined($v)) {
	my($buf) = '';
	local($_IN_EVAL) = {
	    label => $label,
	};
	my($die) = Bivio::Die->catch(sub {
	    $proto->use('Bivio::UI::ViewShortcuts')->vs_call('Prose', $v)
		->put_and_initialize(parent => undef)
		->render($source, \$buf);
	    return;
        });
	return $buf
	    unless $die;
	Bivio::IO::Alert->warn(
	    'Error interpolating: ', $v, ': ', $die);
    }
    return Bivio::HTML->escape($error->get_long_desc)
}

1;
