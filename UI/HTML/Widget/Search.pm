# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Widget::Search;
use strict;
$Bivio::UI::HTML::Widget::Search::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::HTML::Widget::Search - search field

=head1 SYNOPSIS

    use Bivio::UI::HTML::Widget::Search;
    Bivio::UI::HTML::Widget::Search->new($attrs);

=cut

=head1 EXTENDS

L<Bivio::UI::HTML::Widget>

=cut

use Bivio::UI::HTML::Widget;
@Bivio::UI::HTML::Widget::Search::ISA = qw(Bivio::UI::HTML::Widget);

=head1 DESCRIPTION

C<Bivio::UI::HTML::Widget::Search> draws a C<INPUT> tag with
attribute C<TYPE=TEXT>. Adds a C<SUBMIT> button labeled "Search"
to the right.

=head1 ATTRIBUTES

=over 4

=item list_model : array_ref (required, inherited, get_request)

Which search list are we dealing with.

=item size : int (required)

How wide is the field represented.

=back

=cut

#=IMPORTS
use Bivio::HTML;
use Bivio::SQL::ListQuery;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;
use vars qw($_TRACE);
Bivio::IO::Trace->register;

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(hash_ref attributes) : Bivio::UI::HTML::Widget::Search

Creates a new Search widget.

=cut

sub new {
    my($self) = &Bivio::UI::HTML::Widget::new(@_);
    $self->{$_PACKAGE} = {};
    return $self;
}

=head1 METHODS

=cut

=for html <a name="initialize"></a>

=head2 initialize()

Initializes static information.  In this case, prefix and suffix
field values.

=cut

sub initialize {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    return if $fields->{model};
    $fields->{list} = $self->ancestral_get('list_model');
    $fields->{size} = $self->get('size');
    return;
}

=for html <a name="render"></a>

=head2 render(any source, Text_ref buffer)

Render the input field.  First render is special, because we need
to extract the field's type and can only do that when we have a form.

=cut

sub render {
    my($self, $source, $buffer) = @_;
    my($fields) = $self->{$_PACKAGE};
    my($req) = $source->get_request;
    my($list) = $req->get_widget_value(@{$fields->{list}});

    my($action);
    # Public search?
    if ($req->get('auth_id') == Bivio::Auth::RealmType::GENERAL()->as_int) {
        $action = $req->format_stateless_uri(
                Bivio::Agent::TaskId::GENERAL_SEARCH());
    }
    else {
        $action = $req->format_stateless_uri(
                Bivio::Agent::TaskId::CLUB_SEARCH());
    }
    #TODO: Assuming the font needs to be set inside the FORM
    $fields->{prefix} = '<form method=get action="'.$action.'">';
    #TODO: We don't have a type for the query 'search' field, or do we?
    $fields->{prefix} .= '<input type=text size=' . $fields->{size}
            . ' maxlength=' . Bivio::Type::Line->get_width();
    $fields->{prefix} .= ' name=' . Bivio::SQL::ListQuery->to_char('search');

    my($p, $s) = Bivio::UI::Font->format_html('search_field', $req);
    my($v) = Bivio::Type::String->to_html($list->get_query->get('search'));
    _trace('v=', $v);
    $$buffer .= $p.$fields->{prefix} . ' value="' . $v . '">';
    $$buffer .= '<input type=submit value="Search">' . $s . '</form>';

    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
