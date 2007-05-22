# Copyright (c) 2001-2005 bivio Software, Inc.  All Rights reserved.
# $Id$
package Bivio::UI::HTML::Widget::YesNo;
use strict;
$Bivio::UI::HTML::Widget::YesNo::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::UI::HTML::Widget::YesNo::VERSION;

=head1 NAME

Bivio::UI::HTML::Widget::YesNo - Boolean widget

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::UI::HTML::Widget::YesNo;

=cut

=head1 EXTENDS

L<Bivio::UI::Widget>

=cut

use Bivio::UI::Widget;
@Bivio::UI::HTML::Widget::YesNo::ISA = ('Bivio::UI::Widget');

=head1 DESCRIPTION

C<Bivio::UI::HTML::Widget::YesNo> displays a Boolean field as Yes/No
radios.

=head1 ATTRIBUTES

=over 4

=item field : string (required)

Name of the form field.

=item form_model : array_ref (required, inherited, get_request)

Which form are we dealing with.

=back

=cut

#=IMPORTS

#=VARIABLES
my($_IDI) = __PACKAGE__->instance_data_index;


=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(hash_ref attributes) : Bivio::UI::HTML::Widget::YesNo

Creates a YesNo widget.

=cut

sub new {
    my($self) = shift->SUPER::new(@_);
    $self->[$_IDI] = {};
    return $self;
}

=head1 METHODS

=cut

=for html <a name="initialize"></a>

=head2 initialize()

Startup initialization for the widget.

=cut

sub initialize {
    my($self) = @_;
    my($fields) = $self->[$_IDI];
    return if $fields->{yes_widget};
    foreach my $name (qw(yes no)) {
	$fields->{$name.'_widget'} = Bivio::UI::HTML::Widget::String->new(
	    ucfirst($name), 'radio'
	)->put_and_initialize(parent => $self);
    }
    return;
}

=for html <a name="render"></a>

=head2 render(any source, string_ref buffer)

=cut

sub render {
    my($self, $source, $buffer) = @_;
    my($fields) = $self->[$_IDI];
    my($form) = $source->get_request->get_widget_value(
	$self->ancestral_get('form_model'));
    foreach my $name (qw(yes no)) {
	my($value) = $name eq 'yes' ? 1 : 0;
	$$buffer .= '<input name="'
	    . $form->get_field_name_for_html($self->get('field'))
	    . qq{" type=radio value="$value"};

	if (($form->get($self->get('field')) || 0) eq $value) {
	    $$buffer .= ' checked';
	}

	$$buffer .= ' />&nbsp;';
	$fields->{$name . '_widget'}->render($source, $buffer);
    }
    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2001-2005 bivio Software, Inc.  All Rights reserved.

=head1 VERSION

$Id$

=cut

1;
