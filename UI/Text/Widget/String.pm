# Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::Text::Widget::String;
use strict;
$Bivio::UI::Text::Widget::String::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::UI::Text::Widget::String::VERSION;

=head1 NAME

Bivio::UI::Text::Widget::String - x

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::UI::Text::Widget::String;

=cut

=head1 EXTENDS

L<Bivio::UI::Widget::Join>

=cut

use Bivio::UI::Widget::Join;
@Bivio::UI::Text::Widget::String::ISA = ('Bivio::UI::Widget::Join');

=head1 DESCRIPTION

C<Bivio::UI::Text::Widget::String>

=cut

#=IMPORTS

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="initialize"></a>

=head2 initialize()

=cut

sub initialize {
    my($self) = @_;
    $self->put(values => [$self->get('value')]);
    return shift->SUPER::initialize(@_);
}

=for html <a name="internal_new_args"></a>

=head2 static internal_new_args(any arg, ...) : any

Implements positional argument parsing for L<new|"new">.

=cut

sub internal_new_args {
    my(undef, $value, $attributes) = @_;
    return {
	value => $value,
	($attributes ? %$attributes : ()),
    };
}

=for html <a name="unsafe_resolve_widget_value"></a>

=head2 unsafe_resolve_widget_value(any value, any source) : any

Allow scalar refs to render as a string.

=cut

sub unsafe_resolve_widget_value {
    my($self, $value, $source) = @_;
    $value = $self->SUPER::unsafe_resolve_widget_value($value, $source);
    $value = $$value
	if ref($value) eq 'SCALAR';
    return $value;
}

#=PRIVATE SUBROUTINES

=head1 COPYRIGHT

Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
