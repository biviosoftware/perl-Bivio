# Copyright (c) 2002 bivio Software Artisans, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Action::MailReceiveStatus;
use strict;
$Bivio::Biz::Action::MailReceiveStatus::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Biz::Action::MailReceiveStatus::VERSION;

=head1 NAME

Bivio::Biz::Action::MailReceiveStatus - sets http error status

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::Biz::Action::MailReceiveStatus;

=cut

=head1 EXTENDS

L<Bivio::Biz::Action>

=cut

use Bivio::Biz::Action;
@Bivio::Biz::Action::MailReceiveStatus::ISA = ('Bivio::Biz::Action');

=head1 DESCRIPTION

C<Bivio::Biz::Action::MailReceiveStatus> sets http status and
output to empty.

=cut

#=IMPORTS
use Bivio::Ext::ApacheConstants;

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="execute"></a>

=head2 static execute(Bivio::Agent::Request req, int status) : boolean

Sets status of the request and sets reply to empty.

=cut

sub execute {
    my($proto, $req, $status) = @_;
    my($reply) = $req->get('reply');
    $reply->set_http_status($status || Bivio::Ext::ApacheConstants->HTTP_OK);
    my($buffer) = '';
    $reply->set_output(\$buffer);
    return 0;
}

=for html <a name="execute_no_resources"></a>

=head2 static execute_no_resources(Bivio::Agent::Request req) : boolean

Sets HTTP_SERVICE_UNAVAILABLE.

=cut

sub execute_no_resources {
    return shift->execute(shift,
	Bivio::Ext::ApacheConstants->HTTP_SERVICE_UNAVAILABLE);
}

=for html <a name="execute_not_found"></a>

=head2 static execute_not_found(Bivio::Agent::Request req) : boolean

Sets NOT_FOUND.

=cut

sub execute_not_found {
    return shift->execute(shift, Bivio::Ext::ApacheConstants->NOT_FOUND);
}

#=PRIVATE SUBROUTINES

=head1 COPYRIGHT

Copyright (c) 2002 bivio Software Artisans, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
