# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Widget::Submit;
use strict;
$Bivio::UI::HTML::Widget::Submit::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::HTML::Widget::Submit - renders a submit button of a form

=head1 SYNOPSIS

    use Bivio::UI::HTML::Widget::Submit;
    Bivio::UI::HTML::Widget::Submit->new($attrs);

=cut

=head1 EXTENDS

L<Bivio::UI::HTML::Widget>

=cut

use Bivio::UI::HTML::Widget;
@Bivio::UI::HTML::Widget::Submit::ISA = qw(Bivio::UI::HTML::Widget);

=head1 DESCRIPTION

C<Bivio::UI::HTML::Widget::Submit> draws a submit button.

=head1 ATTRIBUTES

=over 4

=back image : array_ref

I<Not implemented.>

=item submit_name : string [] (inherited)

The value to be passed to the C<NAME> attribute of the C<INPUT> tag.

=item submit_value : string [] (inherited)

The value to be passed to the C<VALUE> attribute of the C<INPUT> tag.
I<Note: this is also the label on the button>.

=cut

#=IMPORTS
use Bivio::Util;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(hash_ref attributes) : Bivio::UI::HTML::Widget::Submit

Creates a new Submit widget.

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
    return if exists($fields->{value});
    my($name, $value) = $self->unsafe_get(qw(simple_name simple_value));
    my($p) = ('<input type=submit');
    $p .= qq! name="$name"! if defined($name);
    $p .= qq! value="$value"! if defined($value);
    $fields->{value} = $p . '>';
    return;
}

=for html <a name="is_constant"></a>

=head2 is_constant : boolean

Returns true

=cut

sub is_constant {
#TODO: fix when image implemented
    return 1;
}

=for html <a name="render"></a>

=head2 render(any source, submit_ref buffer)

Render the object.

=cut

sub render {
    my($self, $source, $buffer) = @_;
    my($fields) = $self->{$_PACKAGE};
    $$buffer .= $fields->{value};
    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
