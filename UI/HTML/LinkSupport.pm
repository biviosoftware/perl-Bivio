# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::HTML::LinkSupport;
use strict;
$Bivio::UI::HTML::LinkSupport::VERSION = sprintf('%d.%02d', q$Revision$ =~ /+/g);

=head1 NAME

Bivio::UI::HTML::LinkSupport - An "interface" for link access

=head1 SYNOPSIS

    use Bivio::UI::HTML::LinkSupport;
    Bivio::UI::HTML::LinkSupport->new();

=cut

use Bivio::UNIVERSAL;
@Bivio::UI::HTML::LinkSupport::ISA = qw(Bivio::UNIVERSAL);

=head1 DESCRIPTION

C<Bivio::UI::HTML::LinkSupport> is really a placeholder for the interface
between a UI::HTML::Presentation and its active child. Presentation won't
use this interface directly, but instead will see if the View supports the
interface using UNIVERSAL::can().

=cut

=head1 CONSTANTS

=cut

#=IMPORTS
use Bivio::IO::Config;
use Bivio::IO::Trace;

#=VARIABLES
use vars ($_TRACE);
Bivio::IO::Trace->register;
my($_PACKAGE) = __PACKAGE__;
Bivio::IO::Config->register;

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::UI::HTML::LinkSupport



=cut

sub new {
    my($self) = &Bivio::UNIVERSAL::new(@_);
    $self->{$_PACKAGE} = {};
    return $self;
}

=head1 METHODS

=cut

=for html <a name="configure"></a>

=head2 static configure(hash cfg)

=over 4

=item name : type [default]

=back

=cut

sub configure {
    my(undef, $cfg) = @_;
    return;
}

=for html <a name="get_action_links"></a>

=head2 abstract get_action_links(Model target, Request req) : array

Returns a set of named action links to be rendered in the presentation's
action bar.

=cut

sub get_action_links {
    die("abstract method");
}

=for html <a name="get_nav_links"></a>

=head2 abstract get_nav_links(Model target, Request req) : array

Returns a set of named navigation links to be rendered with the view's
menu.

=cut

sub get_nav_links {
    die("abstract method");
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
