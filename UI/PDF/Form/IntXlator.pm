# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::PDF::Form::IntXlator;
use strict;
$Bivio::UI::PDF::Form::IntXlator::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::PDF::Form::IntXlator - 

=head1 SYNOPSIS

    use Bivio::UI::PDF::Form::IntXlator;
    Bivio::UI::PDF::Form::IntXlator->new();

=cut

=head1 EXTENDS

L<Bivio::UI::PDF::Form::Xlator>

=cut

use Bivio::UI::PDF::Form::Xlator;
@Bivio::UI::PDF::Form::IntXlator::ISA = ('Bivio::UI::PDF::Form::Xlator');

=head1 DESCRIPTION

C<Bivio::UI::PDF::Form::IntXlator>

=cut

#=IMPORTS

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

my($_INT_REGEX) = Bivio::UI::PDF::Regex::INT_REGEX();

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::UI::PDF::Form::IntXlator



=cut

sub new {
    my($self) = Bivio::UI::PDF::Form::Xlator::new(@_);
    my(undef, $output_field, $input_field) = @_;
    $self->{$_PACKAGE} = {
	'output_field' => $output_field,
	'input_field' => $input_field
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
    my($input_value) = $request_ref->get_input($fields->{'input_field'});
    my($output_value) = 0;
    if ($input_value =~ /$_INT_REGEX/) {
	if (defined($1)) {
	    # We found an integer part.
	    $output_value = $1;
	}
	else {
	    die(__FILE__, ", ", __LINE__, ": no value returned\n");
	}
    }

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
