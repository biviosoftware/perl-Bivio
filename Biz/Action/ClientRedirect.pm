# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::Action::ClientRedirect;
use strict;
$Bivio::Biz::Action::ClientRedirect::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Biz::Action::ClientRedirect - client redirect to specific task

=head1 SYNOPSIS

    use Bivio::Biz::Action::ClientRedirect;
    Bivio::Biz::Action::ClientRedirect->execute_next($req);
    Bivio::Biz::Action::ClientRedirect->execute_cancel($req);
    Bivio::Biz::Action::ClientRedirect->SOME_TASK($req);

=cut

use Bivio::UNIVERSAL;
@Bivio::Biz::Action::ClientRedirect::ISA = ('Bivio::UNIVERSAL');

=head1 DESCRIPTION

C<Bivio::Biz::Action::ClientRedirect> redirects to the cancel or
next task values.  There is no I<execute>, you must be explicit.

You may also redirect to a specific task:

    Bivio::Biz::Action::ClientRedirect->SOME_TASK($req);

The subroutines are dynamically compiled from the lists of
tasks in L<Bivio::Agent::TaskId|Bivio::Agent::TaskId>.

=cut

#=IMPORTS
use Bivio::Agent::TaskId;

#=VARIABLES
_compile();

=head1 METHODS

=cut

=for html <a name="execute_cancel"></a>

=head2 execute_cancel(Bivio::Agent::Request req)

Redirect to I<cancel> task.

=cut

sub execute_cancel {
    my(undef, $req) = @_;
    $req->client_redirect($req->get('task')->get('cancel'));
    # DOES NOT RETURN
}

=for html <a name="execute_next"></a>

=head2 execute_next(Bivio::Agent::Request req)

Redirect to I<next> task.

=cut

sub execute_next {
    my(undef, $req) = @_;
    $req->client_redirect($req->get('task')->get('next'));
    # DOES NOT RETURN
}

#=PRIVATE METHODS

# _compile()
#
# Create autoredirect functions for all the tasks in TaskId.
#
sub _compile {
    foreach my $t (Bivio::Agent::TaskId->get_list) {
#TODO: Would like to not define subs for for that don't have URIs,
#      but can't do this because Tasks is not fully initialized by
#      the time this module has been called.  It is called during
#      initialization and Location hasn't fully initialized either.
#      Probably want to do two passes in Location.  First setting
#      URIs and second initializing the tasks.
	my($n) = $t->get_name;
	eval(<<"EOF") || die($@);
	    sub $n {
                my(undef, \$req) = \@_;
                \$req->client_redirect(Bivio::Agent::TaskId::$n());
            }
            1;
EOF
    }
    return;
}

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
