# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Widget::DateField;
use strict;
$Bivio::UI::HTML::Widget::DateField::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::HTML::Widget::DateField - a date field for forms

=head1 SYNOPSIS

    use Bivio::UI::HTML::Widget::DateField;
    Bivio::UI::HTML::Widget::DateField->new();

=cut

=head1 EXTENDS

L<Bivio::UI::HTML::Widget>

=cut

use Bivio::UI::HTML::Widget;
@Bivio::UI::HTML::Widget::DateField::ISA = ('Bivio::UI::HTML::Widget');

=head1 DESCRIPTION

C<Bivio::UI::HTML::Widget::DateField> is a date field for forms.

=head1 ATTRIBUTES

=over 4

=item field : string (required)

Name of the form field.

=item form_model : array_ref (required, inherited)

Which form are we dealing with.

=back

=cut

#=IMPORTS
use Bivio::Type::DateTime;
use Bivio::Type::Date;
use Bivio::UI::DateTimeMode;
use Bivio::UI::HTML::Format::DateTime;
use Bivio::UI::HTML::Widget::DateTime;
use Bivio::UI::HTML::Widget::JavaScript;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;
my($_MODE_INT) = Bivio::UI::DateTimeMode->DATE->as_int;
# Share functions with DateTime
my($_FN) = Bivio::UI::HTML::Widget::DateTime->JAVASCRIPT_FUNCTION_NAME;
my($_FUNCS) = Bivio::UI::HTML::Widget::DateTime->JAVASCRIPT_FUNCTIONS;

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::UI::HTML::Widget::DateField

Creates a Date widget.

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

Initializes from configuration attributes.

=cut

sub initialize {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    return if $fields->{model};
    $fields->{model} = $self->ancestral_get('form_model');
    $fields->{field} = $self->get('field');
    return;
}

=for html <a name="render"></a>

=head2 render(any source, string_ref buffer)

Draws the date field on the specified buffer.

=cut

sub render {
    my($self, $source, $buffer) = @_;
    my($fields) = $self->{$_PACKAGE};
    my($form) = $source->get_widget_value(@{$fields->{model}});
    my($field) = $fields->{field};

    # first render initialization
    unless ($fields->{initialized}) {
	my($type) = $form->get_field_type($field);
	# Might be a subclass of Bivio::Type::Date
	my($width) = $type->get_width();
	$fields->{prefix} = '<input name='
		.$form->get_field_name_for_html($field)
		." type=text size=$width maxlength=$width value=\"";
	$fields->{suffix} = '">';
	$fields->{initialized} = 1;
    }

    # Default is now
    my($value) = $form->get($field);
    $value = Bivio::Type::DateTime->now unless defined($value);

    # What to render if javascript not available.  Must be acceptable
    # to Date::from_literal.
    my($gmt) = Bivio::Type::Date->to_literal($value);

    # Share functions with DateTime
    Bivio::UI::HTML::Widget::JavaScript->render($source, $buffer,
	    $_FN,
	    $_FUNCS,
	    # script
	    "document.write('".$fields->{prefix}."');\n"
	    # Must not begin dates with 0 (netscape barfs, so have to
	    # print as decimals
	    ."$_FN(".sprintf('%d,%d,%d,%s', $_MODE_INT,
		    split(' ', $value), "'$gmt'").');'
	    ."document.write('".$fields->{suffix}."');",
	    # noscript
	    $fields->{prefix}.$gmt.$fields->{suffix});
    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
