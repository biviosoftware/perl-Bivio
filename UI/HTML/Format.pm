# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Format;
use strict;
$Bivio::UI::HTML::Format::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::HTML::Format - superclass of widget value formatters

=head1 SYNOPSIS

    use Bivio::UI::HTML::Format;
    Bivio::UI::HTML::Format->get_widget_value($source, @params);

=cut

=head1 EXTENDS

L<Bivio::UNIVERSAL>

=cut

use Bivio::UNIVERSAL;
@Bivio::UI::HTML::Format::ISA = ('Bivio::UNIVERSAL');

=head1 DESCRIPTION

C<Bivio::UI::HTML::Format> is the superclass of HTML widget value formatters.
Typically, this class sits first the the L<get_widget_value|"get_widget_value">
parameter list, e.g.

    value => [Bivio::UI::HTML::Format::DateTime =>
              request => 'start_time'];

Formatters transform widget values into something "renderable".  This may
involve querying user preferences to determine how the user likes to
see things, e.g. date/time format.

=cut

#=IMPORTS
use Bivio::Die;
use Bivio::IO::ClassLoader;
use Bivio::HTML;

#=VARIABLES



=head1 FACTORIES

=cut

=for html <a name="get_instance"></a>

=head2 static get_instance() : Bivio::UI::HTML::Format

=head2 static get_instance(any class) : Bivio::UI::HTML::Format

Returns a usable instance (or class).  The name will be prefixed
if necessary.  The class will be loaded dynamically.

=cut

sub get_instance {
    my($proto, $class) = @_;
    if (defined($class)) {
	$class = ref($class) if ref($class);
	$class = 'Bivio::UI::HTML::Format::'.$class unless $class =~ /::/;
	# Make sure the class is loaded.
	Bivio::IO::ClassLoader->simple_require($class);
    }
    else {
	$class = ref($proto) || $proto;
	Bivio::Die->die('invalid class; cannot be ', __PACKAGE__)
		    if $class eq __PACKAGE__;
    }
    Bivio::Die->die($class, ': not a ', __PACKAGE__)
		unless UNIVERSAL::isa($class, __PACKAGE__);
    return $class;
}

=head1 METHODS

=cut

=for html <a name="get_widget_value"></a>

=head2 abstract static get_widget_value(string source, any arg1, ...) : any

Calls C<$source->get_widget_value(arg1, ...)>, formats the result,
and returns it.

=cut

sub get_widget_value {
    die('abstract method');
}

=for html <a name="result_is_html"></a>

=head2 result_is_html() : boolean

Returns true if the result is html.

False by default.

=cut

sub result_is_html {
    return 0;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
