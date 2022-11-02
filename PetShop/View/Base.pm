# Copyright (c) 2007-2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::PetShop::View::Base;
use strict;
use Bivio::Base 'View.ThreePartPage';
use Bivio::UI::ViewLanguageAUTOLOAD;

sub IS_PETSHOP_KEY {
    return __PACKAGE__ . 'is_petshop';
}

sub internal_xhtml_adorned {
    my($self) = @_;
    my(@res) = shift->SUPER::internal_xhtml_adorned(@_);
    view_unsafe_put(
        is_petshop => [
            sub {
                my($source, $value) = @_;
                $source->req->put($self->IS_PETSHOP_KEY => $value);
                return $value;
            },
            ['Bivio::UI::View', '->isa', 'Bivio::PetShop::View::PetShop'],
        ],
    );
    view_unsafe_put(
        _groupware_only([
            ['xhtml_title'],
            ['xhtml_dock_left'],
            [xhtml_dock_center => Link(String('PetShop'), 'SITE_ROOT')],
            ['xhtml_dock_right'],
            [xhtml_footer_center => MobileToggler()],
            [xhtml_head_tags => MobileDetector()],
        ]),
        xhtml_header_center => If(
            view_widget_value('is_petshop'),
            b_use('Bivio::PetShop::Widget::Search')->new({}),
            IfWiki(
                '/StartPage',
                WikiText('@h2 inline WikiText btest'),
                IfWiki(
                    '/WikiValidator_NOT_OK',
                    WikiText('@invalidwikitag'),
                ),
            ),
        ),
        xhtml_header_right => If(
            view_widget_value('is_petshop'),
            TaskMenu([
                XLink('SITE_WIKI_VIEW'),
                'CART',
                If(['auth_user'], XLink('LOGOUT')),
                If(['auth_user'], XLink('USER_ACCOUNT_EDIT')),
                If(['!', 'auth_user'], XLink('LOGIN')),
            ]),
            view_get('xhtml_header_right'),
        ),
        xhtml_footer_left => Join([
            XLink('back_to_top'),
            IfMobile(
                '',
                DIV_pet_task_info(TaskInfo({})),
            ),
        ]),
    );
    return @res;
}

sub _groupware_only {
    my($values) = @_;
    my(@res);

    foreach my $info (@$values) {
        my($key, $value) = @$info;
        push(@res,
             $key,
             If(view_widget_value('is_petshop'),
                '',
                $value || view_get($key),
             ),
        );
    }
    return @res;
}

1;
