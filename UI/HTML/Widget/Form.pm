# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Widget::Form;
use strict;
$Bivio::UI::HTML::Widget::Form::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::HTML::Widget::Form - renders an HTML form

=head1 SYNOPSIS

    use Bivio::UI::HTML::Widget::Form;
    Bivio::UI::HTML::Widget::Form->new($attrs);

=cut

=head1 EXTENDS

L<Bivio::UI::HTML::Widget>

=cut

use Bivio::UI::HTML::Widget;
@Bivio::UI::HTML::Widget::Form::ISA = qw(Bivio::UI::HTML::Widget);

=head1 DESCRIPTION

C<Bivio::UI::HTML::Widget::Form> is an HTML C<FORM> tag surrounding
a widget, which is usually a
L<Bivio::UI::HTML::Widget::Join|Bivio::UI::HTML::Widget::Join>,
but might be a
L<Bivio::UI::HTML::Widget::Grid|Bivio::UI::HTML::Widget::Grid>.
The widget or its children should be a
L<Bivio::UI::HTML::Widget::Submit|Bivio::UI::HTML::Widget::Submit>.

No special formatting is implemented.  For layout, use, e.g.

=head1 ATTRIBUTES

=over 4

=item action : string (required)

Literal text to use as
the C<ACTION> attribute of the C<FORM> tag.
Will be passed to L<Bivio::Util::escape_html|Bivio::Util/"escape_html">
before rendering.

=item action : array_ref (required)

Dereferenced, passed to C<$source-E<gt>get_widget_value>, and
used as the C<ACTION> attribute of the C<FORM> tag.
Will be passed to L<Bivio::Util::escape_html|Bivio::Util/"escape_html">
before rendering.

=item form_method : string [POST] (inherited)

The value to be passed to the C<METHOD> attribute of the C<FORM> tag.

=item value : Bivio::UI::Widget (required)

How to render the form.  Usually a
L<Bivio::UI::HTML::Widget::Join|Bivio::UI::HTML::Widget::Join>
or
L<Bivio::UI::HTML::Widget::Grid|Bivio::UI::HTML::Widget::Grid>.

=back

=cut

#=IMPORTS

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;
my($_DEFAULT_METHOD) = 'POST';

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(hash_ref attributes) : Bivio::UI::HTML::Widget::Form

Creates a new Form widget.

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

Initializes static information.

=cut

sub initialize {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    return if $fields->{prefix};
    my($p) = '<form method=';
    $p .= $self->ancestral_get('form_method', $_DEFAULT_METHOD);
    my($action);
    ($action, $fields->{value}) = $self->get('action', 'value');
    $p .= ' action="';
    if (ref($action)) {
	$fields->{action} = $action;
    }
    else {
	$p .= Bivio::Util::escape_html($action) . "\">\n";
    }
    $fields->{prefix} = $p;
    $fields->{value}->put(parent => $self);
    $fields->{value}->initialize;
    return;
}

=for html <a name="render"></a>

=head2 render(string_ref buffer)

=cut

sub render {
    my($self, $source, $buffer) = @_;
    my($fields) = $self->{$_PACKAGE};
    $$buffer .= $fields->{prefix};
    $$buffer .= Bivio::Util::escape_html(
	    $source->get_widget_value(@{$fields->{action}})) . "\">\n"
		    if $fields->{action};
    $fields->{value}->render($source, $buffer);
    $$buffer .= '</form>';
    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
