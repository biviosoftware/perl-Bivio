# Copyright (c) 2003 bivio Software Artisans, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::LaTeX::Widget::String;
use strict;
$Bivio::UI::LaTeX::Widget::String::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::UI::LaTeX::Widget::String::VERSION;

=head1 NAME

Bivio::UI::LaTeX::Widget::String - string value, provides escaping

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::UI::LaTeX::Widget::String;

=cut

=head1 EXTENDS

L<Bivio::UI::Widget>

=cut

use Bivio::UI::Widget;
@Bivio::UI::LaTeX::Widget::String::ISA = ('Bivio::UI::Widget');

=head1 DESCRIPTION

C<Bivio::UI::LaTeX::Widget::String>

=head1 ATTRIBUTES

=over 4

=item format : Bivio::UI::HTML::Format []

=item format : string []

The name of the formatter to use on I<value> before escaping the value.

=item value : string (required)

The string to render.

=item value : array_ref (required)

The widget value to render.

=item value : Bivio::UI::Widget (required)

The widget to render.

=back

=cut

#=IMPORTS
use Bivio::UI::HTML::Format;

#=VARIABLES
my($_IDI) = __PACKAGE__->instance_data_index;

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(hash_ref attributes) : Bivio::UI::LaTeX::Widget::String

Creates a new String widget with I<attributes>.

=cut

sub new {
    my($proto) = shift;
    my($self) = $proto->SUPER::new(@_);
    $self->[$_IDI] = {};
    return $self;
}

=head1 METHODS

=cut

=for html <a name="initialize"></a>

=head2 initialize()

Initializes static information and child widgets.

=cut

sub initialize {
    my($self) = @_;
    my($fields) = $self->[$_IDI];

    if ($self->unsafe_get('format')) {
        $fields->{format} = Bivio::UI::HTML::Format
            ->get_instance($self->get('format'));
    }
    return;
}

=for html <a name="internal_new_args"></a>

=head2 static internal_new_args(any arg, ...) : any

Implements positional argument parsing for L<new|"new">.

=cut

sub internal_new_args {
    my(undef, $value, $attributes) = @_;
    return '"value" attribute must be defined' unless defined($value);
    return {
        value => $value,
        ($attributes ? %$attributes : ()),
    };
}

=for html <a name="render"></a>

=head2 render(any source, string_ref buffer)

Draws the text within the bounding box.

=cut

sub render {
    my($self, $source, $buffer) = @_;
    my($fields) = $self->[$_IDI];
    my($value) = ${_escape($self, $self->render_attr('value', $source))};

    $value = $fields->{format}->get_widget_value($value)
        if $fields->{format};
    $$buffer .= $value;
    return;
}

#=PRIVATE SUBROUTINES

# _escape(self, string_ref value) : string_ref
#
# Escapes special latex characters.
#
sub _escape {
    my($self, $value) = @_;
    my($str) = $$value;
#TODO: try to escape these?
    $str =~ s/[~^\\]/ /gs;

    $str =~ s/([\$&%#_{}])/\\$1/gs;
    return \$str;
}

=head1 COPYRIGHT

Copyright (c) 2003 bivio Software Artisans, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
