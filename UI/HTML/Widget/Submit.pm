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

=item form_model : array_ref (required, inherited)

Which form are we dealing with.

=item has_next : boolean [false]

If true, then a Next button will appear instead of the OK button.

=back

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

Initializes static information.

=cut

sub initialize {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    return if $fields->{model};
    $fields->{model} = $self->ancestral_get('form_model');
    return;
}

=for html <a name="is_constant"></a>

=head2 is_constant : boolean

Will return true if always renders exactly the same way.

=cut

sub is_constant {
    my($fields) = shift->{$_PACKAGE};
    Carp::croak('can only be called after first render')
		unless $fields->{initialized};
    return 1;
}

=for html <a name="render"></a>

=head2 render(any source, submit_ref buffer)

Render the object.

=cut

sub render {
    my($self, $source, $buffer) = @_;
    my($fields) = $self->{$_PACKAGE};
    $$buffer .= $fields->{value}, return if $fields->{initialized};
    my($form) = $source->get_widget_value(@{$fields->{model}});
    my($name) = $form->SUBMIT();
    $fields->{value} = '<input type=submit name='.$name.' value="'
	    .($self->unsafe_get('has_next') ? $form->SUBMIT_NEXT()
		    : $form->SUBMIT_OK())
	    .'">&nbsp;<input type=submit name='.$name.' value="'
	    .$form->SUBMIT_CANCEL().'">';
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
