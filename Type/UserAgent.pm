# Copyright (c) 2000 bivio Inc.  All rights reserved.
# $Id$
package Bivio::Type::UserAgent;
use strict;
$Bivio::Type::UserAgent::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Type::UserAgent::VERSION;

=head1 NAME

Bivio::Type::UserAgent - defines type of the user agent for a request

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::Type::UserAgent;

=cut

=head1 EXTENDS

L<Bivio::Type::Enum>

=cut

use Bivio::Type::Enum;
@Bivio::Type::UserAgent::ISA = ('Bivio::Type::Enum');

=head1 DESCRIPTION

C<Bivio::Type::UserAgent> defines the type of user agent requesting
information.

=head1 VALUES

=over 4

=item UNKNOWN

Could not determine user agent.

=item BROWSER

Modern Netscape, IE, etc.  If we ever go beyond HTML4, there will
be a BROWSER_HTML4 added and any HTML5 features will have to be
supported.

=item BROWSER_HTML3

Older Netscape, IE, etc.

=item MAIL

Mail transfer agent

=item JOB

Background job

=back

=cut

#=IMPORTS

#=VARIABLES
__PACKAGE__->compile([
    UNKNOWN => [0],
    BROWSER => [1],
    MAIL => [2],
    JOB => [3],
    BROWSER_HTML3 => [4],
]);

=head1 METHODS

=cut

=for html <a name="is_browser"></a>

=head2 is_browser() : boolean

=head2 static is_browser(Bivio::Agent::Request req) : boolean

Returns true if I<self> or this package on I<req> is a browser.

=cut

sub is_browser {
    my($self, $req) = @_;
    $self = $req->get(ref($self) || $self) if $req;
    return $self->get_name =~ /^BROWSER/ ? 1 : 0;
}

=for html <a name="put_on_request"></a>

=head2 static put_on_request(string http_user_agent, Bivio::Collection::Attributes req)

Figures out the type of user agent from the I<http_user_agent> string
and puts it on I<req>.

=cut

sub put_on_request {
    my($proto, $ua, $req) = @_;
    # MSIE 5+ is the only modern browser.
#TODO: Test with Netscape 6
    my($self) = $ua =~ /\bMSIE (\d+)/ && $1 >= 5 ? $proto->BROWSER
	: $ua =~ /b-sendmail/i ? $proto->MAIL : $proto->BROWSER_HTML3;
    $req->put_durable(
	ref($self) => $self,
	'Type.'.$self->simple_package_name,
    );
    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2000 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
