# Copyright (c) 2000 bivio Inc.  All rights reserved.
# $Id$
package Bivio::UI::HTML;
use strict;
$Bivio::UI::HTML::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::UI::HTML::VERSION;

=head1 NAME

Bivio::UI::HTML - named html components

=head1 SYNOPSIS

    use Bivio::UI::HTML;

=cut

=head1 EXTENDS

L<Bivio::UI::FacadeComponent>

=cut

use Bivio::UI::FacadeComponent;
use Bivio::UI::Widget;
@Bivio::UI::HTML::ISA = ('Bivio::UI::FacadeComponent');

=head1 DESCRIPTION

C<Bivio::UI::HTML> manages the HTML widgets and bits of pieces for
the HTML part of a Facade.

=cut

=head1 CONSTANTS

=cut

=for html <a name="UNDEF_CONFIG"></a>

=head2 UNDEF_CONFIG() : string

Returns C<undef> which is uninterpreted
by L<internal_initialize_value|"internal_initialize_value">.

Some configuration can't be C<undef> and will be checked
in L<initialize_complete|"initialize_complete">.

=cut

sub UNDEF_CONFIG {
    return undef;
}

#=IMPORTS
use Bivio::Die;
use Bivio::UI::Facade;

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="get_value"></a>

=head2 get_value(string name, Bivio::Collection::Attributes facade_or_req) : any

Returns the value which may be a widget or a string.

Values MUST be found or the request terminates.

=cut

sub get_value {
    my($proto, $name, $req) = @_;

    # Lookup name
    my($v) = $proto->internal_get_value($name, $req);
    Bivio::Die->die('unable to find: ', $name) unless $v;

    return $v->{value};
}

=for html <a name="handle_register"></a>

=head2 static handle_register()

Registers with Facade.

=cut

sub handle_register {
    my($proto) = @_;
    Bivio::UI::Facade->register($proto, ['Icon', 'Color', 'Font']);
    return;
}

=for html <a name="internal_initialize_value"></a>

=head2 internal_initialize_value(hash_ref value)

There are three types of values at this time: strings,
subs, and widgets.  Widgets are initialized by this module.
They do not have parents. subs are executed and either return
a string or a widget, which becomes the value.

We check to make sure that the "widget" is truly a widget.

=cut

sub internal_initialize_value {
    my($self, $value) = @_;

    my($v) = $value->{config};

    if (ref($v)) {
	# If is code, call with $self as param
	$v = &$v($self) if ref($v) eq 'CODE';

	# If result of sub is widget or config is widget, call initialize.
	$v->initialize if UNIVERSAL::isa($v, 'Bivio::UI::Widget');
    }
    $value->{value} = $v;
    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2000 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
