# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::PDF::Form::StringCatXlator;
use strict;
$Bivio::UI::PDF::Form::StringCatXlator::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::PDF::Form::StringCatXlator - 

=head1 SYNOPSIS

    use Bivio::UI::PDF::Form::StringCatXlator;
    Bivio::UI::PDF::Form::StringCatXlator->new();

=cut

=head1 EXTENDS

L<Bivio::UI::PDF::Form::Xlator>

=cut

use Bivio::UI::PDF::Form::Xlator;
@Bivio::UI::PDF::Form::StringCatXlator::ISA = ('Bivio::UI::PDF::Form::Xlator');

=head1 DESCRIPTION

C<Bivio::UI::PDF::Form::StringCatXlator>

=cut

#=IMPORTS

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;


=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::UI::PDF::Form::StringCatXlator



=cut

sub new {
    my($self) = Bivio::UI::PDF::Form::Xlator::new(@_);
    my(undef, @args) = @_;
    $self->{$_PACKAGE} = {
	'output_field' => $args[0],
	'separators_ref' => [],
	'input_fields_ref' => []
    };
    my($fields) = $self->{$_PACKAGE};
    push(@{$fields->{'separators_ref'}}, '');
    push(@{$fields->{'input_fields_ref'}}, $args[1]);
    for (my($indx) = 2; $indx <= $#args; $indx += 2) {
	push(@{$fields->{'separators_ref'}}, $args[$indx]);
	push(@{$fields->{'input_fields_ref'}}, $args[$indx + 1]);
    }
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
    my($output_value) = '';

    for (my($indx) = 0; $indx <= $#{$fields->{'separators_ref'}}; $indx++) {
	$output_value .= ${$fields->{'separators_ref'}}[$indx];
	my($input_field) = ${$fields->{'input_fields_ref'}}[$indx];
	$output_value .= $request_ref->get_input($input_field);
    }

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
