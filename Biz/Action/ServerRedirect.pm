# Copyright (c) 2003 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Action::ServerRedirect;
use strict;
$Bivio::Biz::Action::ServerRedirect::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Biz::Action::ServerRedirect::VERSION;

=head1 NAME

Bivio::Biz::Action::ServerRedirect - in server redirect to a task

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::Biz::Action::ServerRedirect;

=cut

=head1 EXTENDS

L<Bivio::Biz::Action>

=cut

use Bivio::Biz::Action;
@Bivio::Biz::Action::ServerRedirect::ISA = ('Bivio::Biz::Action');

=head1 DESCRIPTION

C<Bivio::Biz::Action::ServerRedirect>

=cut

#=IMPORTS

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="execute_next"></a>

=head2 execute_next(Bivio::Agent::Request req)

Server redirect to I<next> task.

=cut

sub execute_next {
    return 'server_redirect.next';
}

#=PRIVATE SUBROUTINES

=head1 COPYRIGHT

Copyright (c) 2003 bivio Software, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
