# Copyright (c) 2003 bivio Software Artisans, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::HTML::Widget::JoinHandler;
use strict;
$Bivio::UI::HTML::Widget::JoinHandler::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::UI::HTML::Widget::JoinHandler::VERSION;

=head1 NAME

Bivio::UI::HTML::Widget::JoinHandler - joins javascript handlers into one script.

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::UI::HTML::Widget::JoinHandler;

=cut

=head1 EXTENDS

L<Bivio::UI::Widget>

=cut

use Bivio::UI::HTML::Widget::JavaScript;
@Bivio::UI::HTML::Widget::JoinHandler::ISA = ('Bivio::UI::HTML::Widget::JavaScript');

=head1 DESCRIPTION

C<Bivio::UI::HTML::Widget::JoinHandler>

=cut

#=IMPORTS

#=VARIABLES
my($_IDI) = __PACKAGE__->instance_data_index;


#  my($_FUNCS) = Bivio::UI::HTML::Widget::JavaScript->strip(<<"EOF");

#  // calls multiple math routines
#  function @{[_function_name]}(field)
#  {

#  }

#  EOF


=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::UI::HTML::Widget::JoinHandler

creates a new JoinHandler

=cut

sub new {
    my($proto) = shift;
    my($self) = $proto->SUPER::new(@_);
    $self->[$_IDI] = {};
    return $self;
}

=head1 METHODS

=cut

=for html <a name="get_html_field_attributes"></a>

=head2 get_html_field_attributes()



=cut

sub get_html_field_attributes {
    my($self, $field_name, $source) = @_;
    my($fields) = $self->[$_IDI];
    my($field_namefound) = $self->ancestral_get('field');
    return ' onBlur="'. $self->_function_name($fields, $source) . '(this)"';
}

=for html <a name="initialize"></a>

=head2 initialize() : 



=cut

sub initialize {
    my($self, $source) = @_;
    my($fields) = $self->[$_IDI];

    # Already initialized?
    return if $fields->{values};

    my($name) = 0;
    $fields->{values} = $self->get('values');
    foreach my $v (@{$fields->{values}}) {
	$self->initialize_value($name++, $v);
    }
    return;
}

=for html <a name="internal_new_args"></a>

=head2 internal_new_args() : 



=cut

sub internal_new_args {
    my(undef, $values, $attributes) = @_;
    return '"values" attribute must be an array_ref'
	unless ref($values) eq 'ARRAY';
    return {
	values => $values,
	($attributes ? %$attributes : ()),
    };
}

=for html <a name="render"></a>

=head2 render(Bivio::UI::WidgetValueSource source, string_ref buffer)

Renders this instance into I<buffer> using I<source> to evaluate
widget values.

=cut

sub render {
    my($self, $source, $buffer) = @_;
    my($fields) = $self->[$_IDI];
    my($name) = 0;
    foreach my $v (@{$fields->{values}}) {
	$self->unsafe_render_value($name++, $v, $source, $buffer);
    }
    my($functions) = _function_names($fields, $source);
    Bivio::UI::HTML::Widget::JavaScript->render(
	$source, $buffer, $self->_function_name($fields, $source),
	"function @{[$self->_function_name($fields, $source)]}(field) {$functions}");

    return;
}

#=PRIVATE SUBROUTINES

# _function_name(fields, source) : 
#
#
#
sub _function_name {
    my($self, $fields, $source) = @_;
    my($form_name) = $self->ancestral_get('form_name');
    my($field_name) = $self->ancestral_get('field');
    return 'jh_multmath' . $form_name . '_' . $source->get_field_name_for_html($field_name);
}

# _function_names(hash_ref fields) : string
#
#
#
sub _function_names {
    my($fields, $source) = @_;
    my($buffer) = "\n"; 
    foreach my $v (@{$fields->{values}}) {
	    $buffer .= "\n    "
	    . $v->_function_name($source)
	    . "(field);";
    }
    return $buffer . "\n";
}


=head1 COPYRIGHT

Copyright (c) 2003 bivio Software Artisans, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
