# Copyright (c) 2001 bivio Inc.  All rights reserved.
# $Id$
package Bivio::UI::HTML::WidgetFactory;
use strict;
$Bivio::UI::HTML::WidgetFactory::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::UI::HTML::WidgetFactory::VERSION;

=head1 NAME

Bivio::UI::HTML::WidgetFactory - creates widgets from model and field info

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::UI::HTML::WidgetFactory;

=cut

=head1 EXTENDS

L<Bivio::Delegator>

=cut

use Bivio::Delegator;
@Bivio::UI::HTML::WidgetFactory::ISA = ('Bivio::Delegator');

=head1 DESCRIPTION

C<Bivio::UI::HTML::WidgetFactory> creates widgets for model fields.

=head1 ATTRIBUTES

=over 4

=item wf_class : string []

Name of the widget class to use.  Overrides dynamic lookups.

=item wf_list_link : hash_ref []

Must contain a I<query> attribute which is a
L<Bivio::Biz::QueryType|Bivio::Biz::QueryType> and
the widget will be wrapped in a link whose I<href> is
a call to
L<Bivio::Biz::ListModel::format_uri|Bivio::Biz::ListModel/"format_uri">
with I<wf_list_link> as the query type.

If I<task> is specified, it will be passed as a second argument to
I<format_uri>.

If I<uri> is specified, it will be passed as a second argument to
I<format_uri>.

The rest of the attributes are passed to the link directly, e.g. control.
I<control_off_value> is set to be the widget (i.e. the name).

=item wf_want_display : boolean []

If true, the field will be rendered as a display only widget.

=item wf_want_select : boolean []

If true, will force a widget to a be a select, if it can.

=back

=cut

#=IMPORTS
use Bivio::IO::ClassLoader;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

=head1 METHODS

=cut

=for html <a name="create"></a>

=head2 abstract static create(string field) : Bivio::UI::Widget

=head2 abstract static create(string field, hash_ref attrs) : Bivio::UI::Widget

Creates a widget for the specified field. 'field' should be of the form:
  '<model name>.<field name>'

Form model properties receive editable widgets, other models receive
display-only widgets.

=cut

$_ = <<'}'; # emacs
sub create {
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2001 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
