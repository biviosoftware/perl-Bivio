# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Widget::Select;
use strict;
$Bivio::UI::HTML::Widget::Select::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::HTML::Widget::Select - select from a list of several items

=head1 SYNOPSIS

    use Bivio::UI::HTML::Widget::Select;
    Bivio::UI::HTML::Widget::Select->new($attrs);

=cut

=head1 EXTENDS

L<Bivio::UI::HTML::Widget>

=cut

use Bivio::UI::HTML::Widget;
@Bivio::UI::HTML::Widget::Select::ISA = ('Bivio::UI::HTML::Widget');

=head1 DESCRIPTION

C<Bivio::UI::HTML::Widget::Select> allows user to select from
a list of choices.

=head1 ATTRIBUTES

=over 4

=item field : string (required)

Name of the form field.

=item form_model : array_ref (required, inherited)

Which form are we dealing with.

=item choices : Bivio::Type::Enum (required)

List of choices will be constructed from the Enum's values.

=back

=cut

#=IMPORTS
use Bivio::Util;
use Bivio::Type::Enum;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(hash_ref attributes) : Bivio::UI::HTML::Widget::Text

Creates a new Select widget.

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
    $fields->{model} = $self->ancestral_get('form_model');
    ($fields->{field}, $fields->{enum}) = $self->get('field', 'choices');
    my(@list) = sort {
	# Always put "0" (unknown) first.
	return -1 if $a->as_int == 0;
	return 1 if $b->as_int == 0;
	$a->get_name cmp $b->get_name
    } $fields->{enum}->get_list;
    my(@choices);
    foreach my $choice (@list) {
	push(@choices, $choice->as_int,
		Bivio::Util::escape_html($choice->get_short_desc));
    }
    $fields->{choices} = \@choices;
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
    my($form) = $source->get_widget_value(@{$fields->{model}});
    my($field) = $fields->{field};
    unless ($fields->{initialized}) {
	my($type) = $fields->{type} = $form->get_field_type($field);
	$fields->{prefix} = '<select name='
		.$form->get_field_name_for_html($field)
		." size=1>\n";
	$fields->{initialized} = 1;
    }
    $$buffer .= $fields->{prefix};
    my($choices) = $fields->{choices};
    my($field_value) = $form->get($field);
    $field_value = defined($field_value) ? $field_value->as_int : 'x';
    for (my($i) = 0; $i < int(@$choices); $i += 2) {
	my($v) = $choices->[$i];
	$$buffer .= '<option value='.$v;
	$$buffer .= ' selected' if $field_value eq $v;
	$$buffer .= '>'.$choices->[$i+1]."\n";
    }
    # No newline, don't know what follows.
    $$buffer .= '</select>';
    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
