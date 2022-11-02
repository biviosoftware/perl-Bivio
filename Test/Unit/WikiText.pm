# Copyright (c) 2007-2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Test::Unit::WikiText;
use strict;
use Bivio::Base 'TestUnit.Widget';


sub new_unit {
    my($proto, $class_name, $args) = @_;
    my($default_wiki_args) = {
        is_public => 0,
        die_on_validate_error => 1,
        map(
            exists($args->{$_}) ? (die_on_validate_error => delete($args->{$_}))
                : (),
            qw(die_on_validate_error is_public),
        ),
    };
    my($create_params);
    $class_name = b_use('XHTMLWidget.WikiText');
    return $proto->SUPER::new_unit(
        $class_name,
        {
            task_id => 'FORUM_WIKI_VIEW',
            realm => 'bunit_wiki',
            user => b_use('ShellUtil.TestUser')->ADM,
            class_name => $class_name,
            create_object => sub {
                my($case, $params) = @_;
                $create_params = $params;
                return $class_name;
            },
            view_class_map => 'XHTMLWidget',
            view_shortcuts => 'Bivio::UI::XHTML::ViewShortcuts',
            compute_params => sub {
                my($p) = $create_params->[0];
                my($req) = b_use('Test.Request')->get_instance;
                return [{
                    %$default_wiki_args,
                    ref($p) eq 'HASH' ? %$p : (value => $create_params->[0]),
                    req => $req,
                }];
            },
            check_return => sub {
                my(undef, undef, $expect) = @_;
                return ref($expect) eq 'Regexp' ? $expect
                    : [$proto->builtin_trim_space($expect->[0])];
            },
            method_to_test => 'render_html',
            $args ? %$args : (),
        },
    );
}

sub wiki_create {
    return _wiki_create(0, @_);
}

sub wiki_data_create {
    return _wiki_create(1, @_);
}

sub wiki_data_delete_all {
    my($self) = @_;
    $self->builtin_model('RealmFile')->delete_all;
    return;
}

sub wiki_uri_to_req {
    my($self, $name) = @_;
    return $self->builtin_req->put(uri => $self->builtin_req->format_uri({
        realm => $self->builtin_req(qw(auth_realm owner_name)),
        task_id => 'FORUM_WIKI_VIEW',
        path_info => $name,
    }));
}

sub _wiki_create {
    my($is_wiki_data, $self, $name, $is_public, $content) = @_;
#TODO: just pass in the type
    my($type) = b_use($is_wiki_data ? 'Type.WikiDataName' : 'Type.WikiName');
    return $self->builtin_model('RealmFile')->create_with_content({
        path => $type->to_absolute($name, $is_public),
    }, ref($content) ? $content : \$content);
}

1;
