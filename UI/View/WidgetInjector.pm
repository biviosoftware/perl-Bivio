# Copyright (c) 2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::View::WidgetInjector;
use strict;
use Bivio::Base 'View.Base';
use Bivio::UI::ViewLanguageAUTOLOAD;

my($_WI) = b_use('JavaScriptWidget.WidgetInjector');
my($_ULF) = b_use('Model.UserLoginForm');

sub public_xhtml_widget_js {
    my($self) = @_;
    return $self->internal_body(
        WidgetInjector($self->simple_package_name, 'public', 'xhtml_widget'));
}

sub internal_query_value {
    return [sub {$_WI->internal_query_value(shift)}];
}

sub public_login_form_xhtml_widget {
    view_pre_execute(sub {
        $_ULF->new(shift->req)->process;
        return;
    });
    return shift->internal_body(Form(
        'UserLoginForm',
        Join([
            map(
                {
                    my($field) = $_;
                    my($class) = $field =~ /(\w+)$/;
                    DIV(
                        Join([
                            SPAN_b_label(Join([
                                vs_text_as_prose("WidgetInjector.UserLoginForm.$field"),
                                ': ',
                            ])),
                            Text({
                                field => $field,
                                size => 15,
                                class => 'b_field',
                            }),
                        ]),
                        "b_$class",
                    );
                } qw(login RealmOwner.password),
            ),
        ]),
        {
            want_hidden_fields => 0,
        },
    ));
}

1;
