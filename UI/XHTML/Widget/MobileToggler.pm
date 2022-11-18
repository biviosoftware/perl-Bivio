# Copyright (c) 2011 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::XHTML::Widget::MobileToggler;
use strict;
use Bivio::Base 'XHTMLWidget.Simple';
use Bivio::UI::ViewLanguageAUTOLOAD;

my($_MD) = b_use('XHTMLWidget.MobileDetector');

sub NEW_ARGS {
    return [qw(?class)];
}

sub initialize {
    my($self) = @_;
    $self->put(
        value => [
            sub {
                my($source, $class) = @_;
                my($req) = $source->req;
                return TaskMenu({
                    task_map => [
                        map(
                            {
                                my($uri_args) = $_MD->uri_args_for($_, $req);
                                my($x) = [
                                    If($uri_args->{control}, Link(
                                        vs_text_as_prose('MobileToggler', $_),
                                        URI($uri_args),
                                    )),
                                    SPAN_selected(
                                        vs_text_as_prose('MobileToggler', $_)),
                                ];
                                {
                                     xlink => IfMobile(
                                         $_ eq 'mobile' ? reverse(@$x) : @$x),
                                     label => vs_text_as_prose(
                                         'MobileToggler', $_),
                                };
                            }
                            qw(desktop mobile),
                        ),
                    ],
                    class => $class || 'b_mobile_toggler',
                });
            },
            $self->unsafe_get('class'),
        ],
    );
    return shift->SUPER::initialize(@_);
}

1;
