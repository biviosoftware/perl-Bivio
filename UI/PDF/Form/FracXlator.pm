# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::PDF::Form::FracXlator;
use strict;
$Bivio::UI::PDF::Form::FracXlator::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::PDF::Form::FracXlator - 

=head1 SYNOPSIS

    use Bivio::UI::PDF::Form::FracXlator;
    Bivio::UI::PDF::Form::FracXlator->new();

=cut

=head1 EXTENDS

L<Bivio::UI::PDF::Form::Xlator>

=cut

use Bivio::UI::PDF::Form::Xlator;
@Bivio::UI::PDF::Form::FracXlator::ISA = ('Bivio::UI::PDF::Form::Xlator');

=head1 DESCRIPTION

C<Bivio::UI::PDF::Form::FracXlator>

=cut

#=IMPORTS

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

my($_FRAC_REGEX) = Bivio::UI::PDF::Regex::FRAC_REGEX();

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::UI::PDF::Form::FracXlator



=cut

sub new {
    my($self) = Bivio::UI::PDF::Form::Xlator::new(@_);
    my(undef, $output_field, $input_field, $digit_count) = @_;
    $self->{$_PACKAGE} = {
	'output_field' => $output_field,
	'input_field' => $input_field,
	'digit_count' => $digit_count
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
    if ($input_value =~ /$_FRAC_REGEX/) {
	if (defined($1)) {
	    # We found a fractional part.
	    $output_value = $1;
	}
	else {
	    die(__FILE__, ", ", __LINE__, ": no value returned\n");
	}
    }

    # Create a StringParen object and add a reference to it to the output
    # values hash.
    my($digit_count) = $fields->{'digit_count'};
    unless ($digit_count == length($output_value)) {
	my($format) = '%-' . $digit_count . '.' . $digit_count . 's';
	$output_value = sprintf($format, $output_value);
	# sprintf doesn't do right padding with zeros, so do the following
	# instead.
	$output_value =~ s/ /0/g;
    }
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
