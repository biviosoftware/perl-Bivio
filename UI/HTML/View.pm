# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::HTML::View;
use strict;
$Bivio::UI::HTML::View::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::HTML::View - 

=head1 SYNOPSIS

    use Bivio::UI::HTML::View;
    Bivio::UI::HTML::View->new();

=cut

=head1 EXTENDS

L<Bivio::Collection::Attributes>

=cut

use Bivio::Collection::Attributes;
#TODO: Remove this.  Needed for TaskId
use Bivio::UI::View;
@Bivio::UI::HTML::View::ISA = qw(Bivio::Collection::Attributes
Bivio::UI::View);

=head1 DESCRIPTION

C<Bivio::UI::HTML::View>

=cut

=head1 CONSTANTS

=cut

#=IMPORTS
use Bivio::IO::Config;
use Bivio::IO::Trace;

#=VARIABLES
use vars qw($_TRACE);
Bivio::IO::Trace->register;
my($_PACKAGE) = __PACKAGE__;
#Bivio::IO::Config->register;

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::UI::HTML::View


=cut

sub new {
    my($self) = &Bivio::Collection::Attributes::new(@_);
    $self->{$_PACKAGE} = {};
    return $self;
}

=head1 METHODS

=cut

=for html <a name="execute"></a>

=head2 abstract execute(Bivio::Agent::Request req)

=cut

sub execute {
    die('abstract method');
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
