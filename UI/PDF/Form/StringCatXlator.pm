# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::PDF::Form::StringCatXlator;
use strict;
$Bivio::UI::PDF::Form::StringCatXlator::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::PDF::Form::StringCatXlator - 

=head1 SYNOPSIS

    use Bivio::UI::PDF::Form::StringCatXlator;
    Bivio::UI::PDF::Form::StringCatXlator->new($pdf_field_name, $request_field_name [, $separator_text, $request_field_name]...);
    Bivio::UI::PDF::Form::StringCatXlator->add_value($req, $output_values_ref);

=cut

=head1 EXTENDS

L<Bivio::UI::PDF::Form::Xlator>

=cut

use Bivio::UI::PDF::Form::Xlator;
@Bivio::UI::PDF::Form::StringCatXlator::ISA = ('Bivio::UI::PDF::Form::Xlator');

=head1 DESCRIPTION

C<Bivio::UI::PDF::Form::StringCatXlator> translates an input value, or values,
from a Request into a value for a PDP field.

=cut

#=IMPORTS
use Bivio::IO::Trace;

#=VARIABLES
use vars ('$_TRACE');
Bivio::IO::Trace->register;
my($_PACKAGE) = __PACKAGE__;


=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(string pdf_field_name, string request_field_name [, string separator_text, string request_field_name]...) : Bivio::UI::PDF::Form::StringCatXlator

Creates a StringCatXlator with a given PDF field name, one or more Request
field names, and separator text to put between the values of the Request field
values if there is more than one Request field given.

=cut

sub new {
    my($self) = Bivio::UI::PDF::Form::Xlator::new(@_);
    my(undef, @args) = @_;
    $self->{$_PACKAGE} = {
	'output_field' => $args[0],
	'separators_ref' => [],
	'get_widget_value_array_ref' => []
    };
    my($fields) = $self->{$_PACKAGE};
    push(@{$fields->{'separators_ref'}}, '');
    push(@{$fields->{'get_widget_value_array_ref'}}, $args[1]);
    for (my($indx) = 2; $indx <= $#args; $indx += 2) {
	push(@{$fields->{'separators_ref'}}, $args[$indx]);
	push(@{$fields->{'get_widget_value_array_ref'}}, $args[$indx + 1]);
    }
    return $self;
}

=head1 METHODS

=cut

=for html <a name="add_value"></a>

=head2 add_value(Bivio::Agent::Request req, hash output_values) : 

Gets the data from the Request for the fields this object was created with,
format the data into a string, and store it in the given hash using the PDF
field name this object was created with as a key.  The formatting consists of
inserting the separator text between the appropriate field data, changing new
line characters to '\r\n', and eliminating any blank lines.

=cut

sub add_value {
    my($self, $req, $output_values_ref) = @_;
    my($fields) = $self->{$_PACKAGE};
    my($output_value) = '';

    _trace("field \"", $fields->{'output_field'},
	    "\"") if $_TRACE;
    for (my($indx) = 0; $indx <= $#{$fields->{'separators_ref'}}; $indx++) {
	my($value) = $req->get_widget_value(
		${$fields->{'get_widget_value_array_ref'}}[$indx]);
	unless (defined($value)) {
	    # Skip undefined value.
	    _trace("\t<undefined value>") if $_TRACE;
	    next;
	}

	# Don't print blank fields.
	if ($value =~ /^\s*$/) {
	    _trace("\t<blank value>") if $_TRACE;
	    next;
	}
	_trace("\tinput value is \"", $value, "\"") if $_TRACE;

	$output_value .= ${$fields->{'separators_ref'}}[$indx];
	$output_value .= $value;
    }

    # Remove blank lines.
    $output_value =~ s/^[ \t]*\n//gm;

    # Change new lines to carriage return, new line pairs.
    $output_value =~ s/\n/\\r\\n/g;

    # Create a StringParen object and add a reference to it to the output
    # values hash.
    ${$output_values_ref}{$fields->{'output_field'}} = $output_value;

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
