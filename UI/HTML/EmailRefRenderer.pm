# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::HTML::EmailRefRenderer;
use strict;
$Bivio::UI::HTML::EmailRefRenderer::VERSION = sprintf('%d.%02d', q$Revision$ =~ /+/g);

=head1 NAME

Bivio::UI::HTML::EmailRefRenderer - renders email references

=head1 SYNOPSIS

    use Bivio::UI::HTML::EmailRefRenderer;
    use Bivio::Agent::TestRequest;
    my($req) = Bivio::Agent::TestRequest->new('club');
    my($renderer) = Bivio::UI::HTML::EmailRefRenderer->new();
    $renderer->render(['Paul Moeller', 'moeller@uswest.net',
            'Re: cat fight'], $req);

=cut

=head1 EXTENDS

L<Bivio::UI::Renderer>

=cut

use Bivio::UI::Renderer;
@Bivio::UI::HTML::EmailRefRenderer::ISA = qw(Bivio::UI::Renderer);

=head1 DESCRIPTION

C<Bivio::UI::HTML::EmailRefRenderer> renders an html link from
(name, address, subject) of an email element.

=cut

#=IMPORTS
use Apache::Util();
use Bivio::IO::Trace;

#=VARIABLES
use vars qw($_TRACE);
Bivio::IO::Trace->register;
my($_PACKAGE) = __PACKAGE__;

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::UI::HTML::EmailRefRenderer

Creates a new email renderer.

=cut

sub new {
    my($self) = &Bivio::UI::Renderer::new(@_);
    return $self;
}

=head1 METHODS

=cut

=for html <a name="render"></a>

=head2 render(array email_ref, Request req)

Draws an email link for (name, email, subject).

=cut

sub render {
    my($self, $email, $req) = @_;

    my($name) = $email->[0];
    my($address) = $email->[1];
    my($subject) = $email->[2];

    if ($subject =~ /^Re:/i) {
    }
    else {
	$subject = 'Re: '.$subject;
    }
# <a href="mailto:CbereJacki@aol.com?subject=Re:%20YahooClubs">CbereJacki</a>

    $subject = Apache::Util::escape_uri($subject);
    $req->print('<a href="mailto:'.$address.'?subject='.$subject.'">'
	    .$name.'</a>');
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
