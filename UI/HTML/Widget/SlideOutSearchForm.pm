# Copyright (c) 2013 Bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::HTML::Widget::SlideOutSearchForm;
use strict;
use Bivio::Base 'XHTMLWidget.SearchForm';
use Bivio::UI::ViewLanguageAUTOLOAD;


sub initialize {
    my($self) = @_;
    $self->put_unless_exists(
        value => sub {
            my($field_id, $container_id, $b_realm_id)
                = map(JavaScript()->unique_html_id, 1 .. 3);
            my($ids) = "'$field_id', ['$container_id'";
            $ids .= ", '$b_realm_id'"
                if $self->req('auth_realm')->has_owner;
            $ids .= "]";
            return Join([
                Script('common'),
                Script('b_slide_out_search_form'),
                DIV_b_sosf_container(
                    Join([
                        Text({
                            id => $field_id,
                            field => 'search',
                            size => $self->get_or_default(text_size => 30),
                            class => 'b_sosf_field',
                            ONFOCUS => "b_sosf_focus($ids)",
                            ONBLUR => "b_sosf_blur($ids)",
                        }),
                        $self->get_or_default(
                            image_form_button =>
                                ImageFormButton(qw(ok_button magnifier go))
                                    ->put(
                                        ONMOUSEOVER =>
                                            "b_sosf_focus($ids)",
                                    ),
                        ),
                        DIV_b_realm_only(
                            Checkbox({
                                field => 'b_realm_only',
                                label => Prose(vs_text(qw(SearchForm b_realm_only))),
                                control => [[qw(->req auth_realm)], '->has_owner'],
                                ONCLICK => "b_sosf_focus($ids)",
                            }),
                            {
                                id => $b_realm_id,
                                control => $self->get_or_default(
                                    'show_b_realm_only',
                                    [qw(auth_realm type ->is_group)],
                                ),
                            },
                        ),
                    ]),
                    {
                        id => $container_id,
                    },
                ),
            ]);
        },
    );
    return shift->SUPER::initialize(@_);
}

1;
