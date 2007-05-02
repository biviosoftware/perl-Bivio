# Copyright (c) 2001-2007 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::UI::ViewShortcuts;
use strict;
$Bivio::UI::ViewShortcuts::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::UI::ViewShortcuts::VERSION;

=head1 NAME

Bivio::UI::ViewShortcuts - common helper routines for Views and Widgets

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::UI::ViewShortcuts;

=cut

=head1 EXTENDS

L<Bivio::UI::ViewShortcutsBase>

=cut

use Bivio::UI::ViewShortcutsBase;
@Bivio::UI::ViewShortcuts::ISA = ('Bivio::UI::ViewShortcutsBase');

=head1 DESCRIPTION

C<Bivio::UI::ViewShortcuts> is a collection of common helper routines.  Typical
applications will subclass this class.

=cut

#=IMPORTS
use Bivio::UI::Text;
use Bivio::UI::HTML;
use Bivio::UI::ViewLanguage;

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="vs_call"></a>

=head2 vs_call(string method, any arg, ...) : any

Calls I<method> as it would be called from a I<bview> file.  Only works when
called within views.

=cut

sub vs_call {
    my(undef, $method, @args) = @_;
    # Fake an AUTOLOAD
    local($Bivio::UI::ViewLanguage::AUTOLOAD) = $method;
    return Bivio::UI::ViewLanguage->AUTOLOAD(@args);
}

=for html <a name="vs_constant"></a>

=head2 static vs_constant(string label) : array_ref

Splits I<tag> and I<prefix>es into its base parts, checking for syntax.

=cut

sub vs_constant {
    return _fc(\@_, qw(Constant ->get_value));
}

=for html <a name="vs_fe"></a>

=head2 vs_fe(string item) : string

Calls L<Bivio::UI::FormError::field_value|Bivio::UI::FormError/"field_value">.

=cut

sub vs_fe {
    shift;
    return Bivio::UI::FormError->field_value(@_);
}

=for html <a name="vs_html"></a>

=head2 static vs_html(string attr) : array_ref

Returns a widget value to retrieve I<attr> using
L<Bivio::UI::HTML::get_value|Bivio::UI::HTML/"get_value">.

=cut

sub vs_html {
    return _fc(\@_, qw(HTML ->get_value));
}

=for html <a name="vs_mail_host"></a>

=head2 vs_mail_host() : array_ref

Returns a widget value for mail_host.

=cut

sub vs_mail_host {
    return _fc(\@_, qw(mail_host));
}

=for html <a name="vs_model"></a>

=head2 vs_model(any model, any field_name) : array_ref

=head2 vs_model(any model_field) : array_ref

Returns widget value to return field_name of model on the request.  If
model_field is passed or returned by the widget value model_field,
(e.g. RealmUserList.RealmOwner.display_name), the first part of the name
will be stripped off and looked up as the model.

=cut

sub vs_model {
    return shift->vs_req(sub {
        my($req, $model, $field) = @_;
	($model, $field) = $model =~ /^(\w+)\.(.+)/
	    unless defined($field);
	return $req->get_nested("Model.$model", $field);
    }, @_);
}

=for html <a name="vs_realm"></a>

=head2 vs_realm(any field_name) : array_ref

Returns widget value to return field_name value for this realm owner. field_name defaults to display_name.

=cut

sub vs_realm {
    return shift->vs_req(qw(auth_realm owner), shift || 'display_name');
}

=for html <a name="vs_realm_type"></a>

=head2 vs_realm_type(any type) : array_ref

Returns a widget value to test realm type against I<type>

=cut

sub vs_realm_type {
    return shift->vs_req(qw(auth_realm type ->equals_by_name), @_);
}

=for html <a name="vs_req"></a>

=head2 vs_req(any type) : array_ref

Returns a widget value pulled from the request..

=cut

sub vs_req {
    shift;
    return [['->get_request'], @_];
}

=for html <a name="vs_site_name"></a>

=head2 vs_site_name() : array_ref

Returns a widget value that returns Text.site_name.

=cut

sub vs_site_name {
    return shift->vs_text('site_name');
}

=for html <a name="vs_task_has_uri"></a>

=head2 vs_task_has_uri(any task) : array_ref

Returns true if task has uri.

=cut

sub vs_task_has_uri {
    return _fc(\@_, qw(Task ->has_uri));
}

=for html <a name="vs_text"></a>

=head2 static vs_text(any tag_part, ...) : array_ref

Splits I<tag> and I<prefix>es into its base parts, checking for syntax.

=cut

sub vs_text {
    my($proto, @tag) = @_;
    return _fc([$proto], 'Text', [sub {shift; @_}, @tag]);
}

=for html <a name="vs_text_as_prose"></a>

=head2 vs_text_as_prose(string tag) : Widget::Prose

Prefixes "Prose." onto I<tag> and passes to Prose widget.

=cut

sub vs_text_as_prose {
    my($proto, $tag) = @_;
    Bivio::Die->die($tag, ': must not be reference')
        if ref($tag);
    return $proto->vs_call(Prose => $proto->vs_text("prose.$tag"));
}

#=PRIVATE METHODS

sub _fc {
    my($args) = shift;
    return shift(@$args)->vs_req('Bivio::UI::Facade', @_, @$args);
}

=head1 COPYRIGHT

Copyright (c) 2001-2007 bivio Software, Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
