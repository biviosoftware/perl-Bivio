# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::PDF::Form::RadioBtnXlator;
use strict;
$Bivio::UI::PDF::Form::RadioBtnXlator::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::PDF::Form::RadioBtnXlator - 

=head1 SYNOPSIS

    use Bivio::UI::PDF::Form::RadioBtnXlator;
    Bivio::UI::PDF::Form::RadioBtnXlator->new();

=cut

=head1 EXTENDS

L<Bivio::UI::PDF::Form::Xlator>

=cut

use Bivio::UI::PDF::Form::Xlator;
@Bivio::UI::PDF::Form::RadioBtnXlator::ISA = ('Bivio::UI::PDF::Form::Xlator');

=head1 DESCRIPTION

C<Bivio::UI::PDF::Form::RadioBtnXlator>

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

=head2 static new() : Bivio::UI::PDF::Form::RadioBtnXlator



=cut

sub new {
    my($self) = Bivio::UI::PDF::Form::Xlator::new(@_);
    my(undef, @args) = @_;
    $self->{$_PACKAGE} = {
	'get_widget_value_array_ref' => $args[0],
	'hash' => {}
    };
    my($fields) = $self->{$_PACKAGE};

    for (my($indx) = 1; $indx <= $#args; $indx+= 2) {
	${$fields->{'hash'}}{$args[$indx]} = $args[$indx + 1];
    }

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
	die(__FILE__, ", ", __LINE__,
		": no input value for input field \"",
		$fields->{'input_field'},
		"\"\n");
    }
    _trace("input value is \"", $input_value, "\"");

    my($button_ref) = ${$fields->{'hash'}}{$input_value};

    unless (defined($button_ref)) {
	# Just ignore this field.
	_trace("\tno button") if $_TRACE;
	return;
    }

    $button_ref->add_value($req, $output_values_ref);

    return;
}

=for html <a name="get_pdf_field_names"></a>

=head2 get_pdf_field_names() : 



=cut

sub get_pdf_field_names {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    my($key, $value);
    my(@names);
    while (($key, $value) = each(%{$fields->{'hash'}})) {
	push(@names, $value->get_pdf_field_names());
    }
    return(@names);
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
