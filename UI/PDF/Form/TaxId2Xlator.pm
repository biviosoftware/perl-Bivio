# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::PDF::Form::TaxId2Xlator;
use strict;
$Bivio::UI::PDF::Form::TaxId2Xlator::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::PDF::Form::TaxId2Xlator - an Xlator for the second part of a tax id.

=head1 SYNOPSIS

    use Bivio::UI::PDF::Form::TaxId2Xlator;
    Bivio::UI::PDF::Form::TaxId2Xlator->new();

=cut

=head1 EXTENDS

L<Bivio::UI::PDF::Form::Xlator>

=cut

use Bivio::UI::PDF::Form::Xlator;
@Bivio::UI::PDF::Form::TaxId2Xlator::ISA = ('Bivio::UI::PDF::Form::Xlator');

=head1 DESCRIPTION

C<Bivio::UI::PDF::Form::TaxId2Xlator>

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

=head2 static new() : Bivio::UI::PDF::Form::TaxId2Xlator



=cut

sub new {
    my($self) = Bivio::UI::PDF::Form::Xlator::new(@_);
    my(undef, $output_field, $get_widget_value_array_ref) = @_;
    $self->{$_PACKAGE} = {
	'output_field' => $output_field,
	'get_widget_value_array_ref' => $get_widget_value_array_ref
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

    my($output_value) = 0;
    $input_value =~ s/[^0-9]//g;
    $output_value = substr($input_value, 2);

    # Add the output value to the values hash.
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
