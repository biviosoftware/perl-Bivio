# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::PDF::Form::FloatXlator;
use strict;
$Bivio::UI::PDF::Form::FloatXlator::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::PDF::Form::FloatXlator - translates a floating point number.

=head1 SYNOPSIS

    use Bivio::UI::PDF::Form::FloatXlator;
    Bivio::UI::PDF::Form::FloatXlator->new();

=cut

=head1 EXTENDS

L<Bivio::UI::PDF::Form::Xlator>

=cut

use Bivio::UI::PDF::Form::Xlator;
@Bivio::UI::PDF::Form::FloatXlator::ISA = ('Bivio::UI::PDF::Form::Xlator');

=head1 DESCRIPTION

C<Bivio::UI::PDF::Form::FloatXlator>

=cut

#=IMPORTS
use Bivio::IO::Trace;

#=VARIABLES
use vars ('$_TRACE');
Bivio::IO::Trace->register;
my($_PACKAGE) = __PACKAGE__;

my($_FLOAT_REGEX) = Bivio::UI::PDF::Regex::FLOAT_REGEX();


=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::UI::PDF::Form::FloatXlator



=cut

sub new {
    my($self) = Bivio::UI::PDF::Form::Xlator::new(@_);
    my(undef, $output_field, $get_widget_value_array_ref, $separator,
	    $digit_count, $show_zero) = @_;
    $self->{$_PACKAGE} = {
	'output_field' => $output_field,
	'get_widget_value_array_ref' => $get_widget_value_array_ref,
	'separator' => $separator,
	'digit_count' => $digit_count,
	show_zero => $show_zero,
    };
    return $self;
}

=head1 METHODS

=cut

=for html <a name="add_value"></a>

=head2 add_value() : 



=cut

sub add_value {
    my($self, $req, $output_values_ref) = @_;
    my($fields) = $self->{$_PACKAGE};
    my($input_value)
	    = $req->get_widget_value($fields->{get_widget_value_array_ref});
    unless (defined($input_value)) {
	# Ignore this field.
	_trace("field \"", $fields->{'output_field'},
		"\": undefined input value") if $_TRACE;
	return;
    }
    _trace("field \"", $fields->{'output_field'},
	    "\": input value is \"", $input_value, "\"") if $_TRACE;

    my($int, $frac);
    if ($input_value =~ /$_FLOAT_REGEX/) {
	if ($1 && $1 != 0) {
	    # There is an integer part.
	    $int = Bivio::UI::PDF::Form::IntXlator
		    ->format_int($1, $fields->{'separator'});
	}
	else {
	    $int = '0';
	}

	if ($2 && $2 != 0) {
	    # There is a fractional part.
	    $frac = $2;
	} else {
	    $frac = 0;

	    # don't render 0
	    return if $int eq '0' && ! $fields->{show_zero};
	}
	$frac = Bivio::UI::PDF::Form::FracXlator
		->format_frac($2, $fields->{'digit_count'});
    }
    else {
	die(__FILE__, ", ", __LINE__, ": no match\n");
    }

    # Add the output value to the values hash.
    ${$output_values_ref}{$fields->{'output_field'}}
	    = $int . '.' . $frac;

    return;
}

=for html <a name="get_pdf_field_names"></a>

=head2 get_pdf_field_names() : 



=cut

sub get_pdf_field_names {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    return($fields->{'output_field'});
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
