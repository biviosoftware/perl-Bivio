# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::PDF::Form::ButtonXlator;
use strict;
$Bivio::UI::PDF::Form::ButtonXlator::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::PDF::Form::ButtonXlator - 

=head1 SYNOPSIS

    use Bivio::UI::PDF::Form::ButtonXlator;
    Bivio::UI::PDF::Form::ButtonXlator->new();

=cut

=head1 EXTENDS

L<Bivio::UI::PDF::Form::Xlator>

=cut

use Bivio::UI::PDF::Form::Xlator;
@Bivio::UI::PDF::Form::ButtonXlator::ISA = ('Bivio::UI::PDF::Form::Xlator');

=head1 DESCRIPTION

C<Bivio::UI::PDF::Form::ButtonXlator>

=cut

#=IMPORTS

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;


=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::UI::PDF::Form::ButtonXlator



=cut

sub new {
    my($self) = Bivio::UI::PDF::Form::Xlator::new(@_);
    my(undef, $output_field, $input_field) = @_;
    $self->{$_PACKAGE} = {
	'output_field' => $output_field,
	'input_field' => $input_field,
	'value' => undef
    };
    return $self;
}

=head1 METHODS

=cut

=for html <a name="add_value"></a>

=head2 add_value() : 



=cut

sub add_value {
    my($self, $request_ref, $output_values_ref) = @_;
    my($fields) = $self->{$_PACKAGE};
    my($input_value);
    if (defined($fields->{'input_field'})) {
	$input_value = $request_ref->get_input($fields->{'input_field'});
    }
    elsif (defined($fields->{'value'})) {
	$input_value = $fields->{'value'};
    }
    else {
	die(__FILE__, ", ", __LINE__, ": no value\n");
    }

    # Create a StringParen object and add a reference to it to the output
    # values hash.
    ${$output_values_ref}{$fields->{'output_field'}} = $input_value;

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

=for html <a name="set_value"></a>

=head2 set_value() : 



=cut

sub set_value {
    my($self, $value) = @_;
    my($fields) = $self->{$_PACKAGE};
    $fields->{'value'} = $value;
    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
