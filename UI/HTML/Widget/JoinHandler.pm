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
    my($a) = {};
    foreach my $h (@{$fields->{values}}) {
	my($x) = $h->get_html_field_attributes($field_name, $source);
	while ($x){
	    $x =~ s/^\s+(\w+)="([^"]+)"// or die("invalid pattern");
	    push(@{$a->{lc($1)} ||= []}, $2);
	}
    }
    my($str) = map({
	" $_=\"" . join(';', @{$a->{$_}}) . '"';
    } sort(keys(%$a)));
    return $str;
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
    return;
}



=head1 COPYRIGHT

Copyright (c) 2003 bivio Software Artisans, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
