# Copyright (c) 2001-2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::HTML::Widget::TaskInfo;
use strict;
use Bivio::Base 'Widget.Simple';
use Bivio::UI::ViewLanguageAUTOLOAD;

my($_SC);

sub initialize {
    my($self) = @_;
    $self->put(value => PRE(Join([
        B('Control Logic for This Page'),
        '(click on link to see the source code)',
        Join([
            'Name:         ',
            ['task_id', '->get_name'],
        ]),
        Join([
            'Realm:        ',
            ['task', 'realm_type', '->get_name'],
        ]),
        Join([
            'Permissions:  ',
            [
                sub {
                    my(undef, $set) = @_;
                    return join(
                        '&amp;',
                        map(
                            $_->get_name,
                            @{b_use('Auth.PermissionSet')->to_array($set)},
                        ),
                    );
                },
                ['task', 'permission_set'],
            ],
        ]),
        [
            sub {
                my($req, $task) = @_;
                return join(
                    "\n",
                    map({
                        _render_source_link($self, $req, $_);
                    } @{$task->get('items')}),
                );
            },
            ['task'],
        ],
    ], "\n")));
    return shift->SUPER::initialize(@_);
}

sub _render_source_link {
    my($self, $req, $item) = @_;
    my($object, $method, $args) = @$item;
    $object = ref($object)
        if ref($object);
#TODO: Does not handle inline subs
    my($res) = '';
    ($_SC ||= SourceCode({})->package_name)->render_source_link(
        $req,
        $object->isa('Bivio::UI::View::LocalFile')
            ? 'View.' . $args->[0]
            : $object,
        $object . '->'
            . $method
                . (@$args ? '(' . join(', ', @$args) . ')' : ''),
        \$res,
        # View method name as anchor
        $object->isa('Bivio::UI::View::Method')
            ? $args->[0]
            : (),
    );
    return $res;
}

1;
