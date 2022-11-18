# Copyright (c) 2005-2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::FacadeComponent::FormError;
use strict;
use Bivio::Base 'FacadeComponent.Text';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($_IN_EVAL);
my($_W) = b_use('UI.Widget');

sub field_value {
    my(undef, $item) = @_;
    b_die($item, ': FormError not evaluating')
        unless $_IN_EVAL;
    b_die($item, ': no such FormError attribute')
        unless exists($_IN_EVAL->{$item});
    return $_IN_EVAL->{$item};
}

sub to_widget_value {
    my($proto, $source, $form, $field, $label, $error) = @_;
    my($self) = $proto->internal_get_self($source->get_request);
    $error ||= $form->get_field_error($field);
    my($detail) = $form->get_field_error_detail($field);
    $detail = String($detail, {hard_newlines => 1})
        if $detail && !$_W->is_blesser_of($detail);
    my($v) = $self->unsafe_get_value(
        $form->simple_package_name,
        $field,
        $error->get_name,
    );
    if (defined($v)) {
        my($buf) = '';
        local($_IN_EVAL) = {
            label => $label,
            error => $error,
            detail => $detail,
        };
        my($die) = b_catch(
            sub {
                Prose($v)
                    ->initialize_with_parent(undef)
                    ->render($source, \$buf);
                return;
            },
        );
        return Simple($buf)
            unless $die;
        b_warn('Error interpolating: ', $v, ': ', $die);
    }
    return Join([
#TODO: use Enum widget (can't now, b/c defaults to short_desc)
        String($error->get_long_desc),
        $detail
            ? (
                $self->get_facade->get('Text')
                    ->get_widget_value('FormError.prose.detail_prefix'),
                $detail,
            )
            : (),
    ]);
}

1;
