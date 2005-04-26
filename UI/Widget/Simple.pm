# Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::Widget::Simple;
use strict;
$Bivio::UI::Widget::Simple::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::UI::Widget::Simple::VERSION;

=head1 NAME

Bivio::UI::Widget::Simple - executes sub-widget

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::UI::Widget::Simple;

=cut

=head1 EXTENDS

L<Bivio::UI::Widget>

=cut

use Bivio::UI::Widget;
@Bivio::UI::Widget::Simple::ISA = ('Bivio::UI::Widget');

=head1 DESCRIPTION

C<Bivio::UI::Widget::Simple> is a usuable base class for simple widgets.
Can serve as a placeholder.

=head1 ATTRIBUTES

=over 4

=item value : any (required)

Is a or returns a widget to render.

=back

=cut

#=IMPORTS

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="initialize"></a>

=head2 initialize()

Initializes I<value>.

=cut

sub initialize {
    return shift->initialize_attr('value');
}

=for html <a name="internal_new_args"></a>

=head2 static internal_new_args(any value, hash_ref attributes) : hash_ref

Implements positional argument parsing for L<new|"new">.  I<attributes> is
optional.

=cut

sub internal_new_args {
    my(undef, $value, $attributes) = @_;
    return '"value" must be defined'
	unless defined($value);
    return {
	value => $value,
	($attributes ? %$attributes : ()),
    };
}

=for html <a name="render"></a>

=head2 render(any source, string_ref buffer)

Renders I<value>.

=cut

sub render {
    return shift->render_attr('value', @_);
}

#=PRIVATE SUBROUTINES

=head1 COPYRIGHT

Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
