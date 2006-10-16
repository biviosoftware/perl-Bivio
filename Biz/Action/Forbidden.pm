# Copyright (c) 2004 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Action::Forbidden;
use strict;
$Bivio::Biz::Action::Forbidden::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Biz::Action::Forbidden::VERSION;

=head1 NAME

Bivio::Biz::Action::Forbidden - handle forbidden redirects

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::Biz::Action::Forbidden;

=cut

=head1 EXTENDS

L<Bivio::Biz::Action>

=cut

use Bivio::Biz::Action;
@Bivio::Biz::Action::Forbidden::ISA = ('Bivio::Biz::Action');

=head1 DESCRIPTION

C<Bivio::Biz::Action::Forbidden>

=cut

#=IMPORTS
use Bivio::Ext::ApacheConstants;

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="execute"></a>

=head2 static execute(Bivio::Agent::Request req) : boolean

Always returns true.  Sets forbidden output in text/html.

=cut

sub execute {
    my($proto, $req) = @_;
    my($reply) = $req->get('reply');
    $reply->set_http_status(Bivio::Ext::ApacheConstants->FORBIDDEN)
	if $reply->can('set_http_status');
    $reply->set_output(\(<<'EOF'));
<!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML 2.0//EN">
<HTML><HEAD>
<TITLE>403 Forbidden</TITLE>
</HEAD><BODY>
<H1>Forbidden</H1>
<P>You do not have permission to access this request on this server.</P>
</BODY></HTML>
EOF
    $reply->set_output_type('text/html');
    return 1;
}

#=PRIVATE SUBROUTINES

=head1 COPYRIGHT

Copyright (c) 2004 bivio Software, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
