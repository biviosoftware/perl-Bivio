# Copyright (c) 2001-2011 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::UI::ViewShortcuts;
use strict;
use Bivio::Base 'UI.ViewShortcutsBase';

my($_A) = b_use('IO.Alert');
my($_W) = b_use('UI.Widget');
my($_DT) = b_use('Type.DateTime');

sub vs_call {
    my(undef, $method, @args) = @_;
    return b_use('UI.ViewLanguageAUTOLOAD')->call_autoload($method, \@args);
}

sub vs_constant {
    # Splits I<tag> and I<prefix>es into its base parts, checking for syntax.
    return _fc(\@_, qw(Constant ->get_value));
}

sub vs_debug {
    shift;
    return [sub {
        shift;
        b_info(@_);
        return shift(@_);
    }, @_];
}

sub vs_fe {
    my($proto) = shift;
    return $proto->vs_call('Prose', b_use('UI.FormError')->field_value(@_));
}

sub vs_form_method_call {
    my(undef, $widget, $method) = @_;
    return [sub {
        my($source) = @_;
        return $widget->resolve_form_model($source)
            ->$method($widget->render_simple_attr('field', $source));
    }];
}

sub vs_ui_forum {
    return shift->vs_text('vs_ui.forum');
}

sub vs_ui_members {
    return shift->vs_text('vs_ui.members');
}

sub vs_ui_wiki {
    return shift->vs_text('vs_ui.wiki');
}

sub vs_html {
    # Returns a widget value to retrieve I<attr> using
    # L<Bivio::UI::HTML::get_value|b_use('FacadeComponent.HTML')/"get_value">.
    return _fc(\@_, qw(HTML ->get_value));
}

sub vs_is_current_facade {
    my($self, $simple_class) = @_;
    return [
        sub {
            my(undef, $sc) = @_;
            return b_use('UI.Facade')
                ->get_from_source(shift)
                ->simple_package_name
                eq $sc
                ? 1 : 0;
        },
        $simple_class,
    ];
}

sub vs_local_file_plain_common_uri {
    my($self, $file) = @_;
    return [
        sub {shift->req('UI.Facade')->get_local_file_plain_common_uri(shift)},
        $file,
    ];
}

sub vs_mail_host {
    # Returns a widget value for mail_host.
    return _fc(\@_, qw(mail_host));
}

sub vs_model {
    # Returns widget value to return field_name of model on the request.  If
    # model_field is passed or returned by the widget value model_field,
    # (e.g. RealmUserList.RealmOwner.display_name), the first part of the name
    # will be stripped off and looked up as the model.
    return shift->vs_req(sub {
        my($req, $model, $field) = @_;
        ($model, $field) = $model =~ /^(\w+)\.(.+)/
            unless defined($field);
        return $req->get_nested("Model.$model", $field);
    }, @_);
}

sub vs_now_as_year {
    return [sub {$_DT->now_as_year}];
}

sub vs_realm {
    # Returns widget value to return field_name value for this realm owner. field_name defaults to display_name.
    return shift->vs_req(qw(auth_realm owner), shift || 'display_name');
}

sub vs_realm_type {
    # Returns a widget value to test realm type against I<type>
    return shift->vs_req(qw(auth_realm type ->equals_by_name), @_);
}

sub vs_render_widget {
    my(undef, $widget, $source) = @_;
    my($b) = '';
    $widget->initialize_and_render($source, \$b);
    return $b;
}

sub vs_req {
    # Returns a widget value pulled from the request..
    shift;
    return [['->get_request'], @_];
}

sub vs_resolve_fully {
    my(undef, $value) = @_;
    return [sub {
        return ref($value) eq 'ARRAY'
            ? $_W->unsafe_resolve_widget_value($value, shift(@_))
            : $value;
    }];
}

sub vs_site_name {
    # Returns a widget value that returns Text.site_name.
    return shift->vs_text('site_name');
}

sub vs_task_has_uri {
    # Returns true if task has uri.
    return _fc(\@_, qw(Task ->has_uri));
}

sub vs_text {
    my($proto, @tag) = @_;
    # Splits I<tag> and I<prefix>es into its base parts, checking for syntax.
    return $proto->is_blesser_of($tag[0], 'Bivio::Agent::Request')
        ? _fc(\@_, 'Text', '->get_widget_value')
        : _fc([$proto], 'Text', [sub {shift; @_}, @tag]);
}

sub vs_text_as_prose {
    my($proto, @tag) = @_;
    # Prefixes "Prose." onto I<tag> and passes to Prose widget.
    splice(@tag, $proto->is_blesser_of($tag[0], 'Bivio::Agent::Request')
               ? 1 : 0, 0, 'prose');
    return $proto->vs_call(Prose => $proto->vs_text(@tag));
}

sub vs_use {
    return shift->use(@_);
}

sub _fc {
    my($args) = shift;
    my($proto) = shift(@$args);
    return $proto->vs_req('Bivio::UI::Facade', @_, @$args)
        unless $proto->is_blesser_of($args->[0], 'Bivio::Agent::Request');
    my($component, $method) = @_;
    my($fc) = shift(@$args)->req('Bivio::UI::Facade', $component);
    $method =~ s/^\-\>// || Bivio::Die->die($method, ': bad method');
    return $fc->$method(@$args);
}

1;
