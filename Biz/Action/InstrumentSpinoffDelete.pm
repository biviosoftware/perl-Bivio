# Copyright (c) 2001 bivio Inc.  All rights reserved.
# $Id$
package Bivio::Biz::Action::InstrumentSpinoffDelete;
use strict;
$Bivio::Biz::Action::InstrumentSpinoffDelete::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Biz::Action::InstrumentSpinoffDelete::VERSION;

=head1 NAME

Bivio::Biz::Action::InstrumentSpinoffDelete - deletes global spin-off info

=head1 SYNOPSIS

    use Bivio::Biz::Action::InstrumentSpinoffDelete;

=cut

=head1 EXTENDS

L<Bivio::Biz::Action>

=cut

use Bivio::Biz::Action;
@Bivio::Biz::Action::InstrumentSpinoffDelete::ISA = ('Bivio::Biz::Action');

=head1 DESCRIPTION

C<Bivio::Biz::Action::InstrumentSpinoffDelete> deletes global spin-off info

=cut

#=IMPORTS
use Bivio::Agent::TaskId;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

=head1 METHODS

=cut

=for html <a name="execute"></a>

=head2 execute(Bivio::Agent::Request req)

Deletes the instrument, then redirects to the investment list.

=cut

sub execute {
    my($self, $req) = @_;
    $req->get('Bivio::Biz::Model::InstrumentSpinoff')->delete;
    $req->client_redirect(Bivio::Agent::TaskId::ADM_SPINOFFS(), undef, undef);
    # DOES NOT RETURN
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2001 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
