# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::PDF::Form::ButtonXlator;
use strict;
$Bivio::UI::PDF::Form::ButtonXlator::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::PDF::Form::ButtonXlator - translates a PDF button.

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
use Bivio::IO::Trace;

#=VARIABLES
use vars ('$_TRACE');
Bivio::IO::Trace->register;
my($_PACKAGE) = __PACKAGE__;


=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::UI::PDF::Form::ButtonXlator



=cut

sub new {
    my($self) = Bivio::UI::PDF::Form::Xlator::new(@_);
    my(undef, $output_field, $yes_value) = @_;
    $self->{$_PACKAGE} = {
	'output_field' => $output_field,
	'yes_value' => $yes_value
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

    # Create a StringParen object and add a reference to it to the output
    # values hash.
    _trace("field \"", $fields->{'output_field'},
	    "\": yes value is \"", $fields->{'yes_value'}, "\"");
    ${$output_values_ref}{$fields->{'output_field'}} = $fields->{'yes_value'};

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

# sub set_value {
#     my($self, $value) = @_;
#     my($fields) = $self->{$_PACKAGE};
#     $fields->{'value'} = $value;
#     return;
# }

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
