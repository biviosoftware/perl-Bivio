# Copyright (c) 2002 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::t::Action::T1;
use strict;
$Bivio::Biz::t::Action::T1::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Biz::t::Action::T1::VERSION;

=head1 NAME

Bivio::Biz::t::Action::T1 - tests Action

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::Biz::t::Action::T1;

=cut

=head1 EXTENDS

L<Bivio::Biz::Action>

=cut

use Bivio::Biz::Action;
@Bivio::Biz::t::Action::T1::ISA = ('Bivio::Biz::Action');

=head1 DESCRIPTION

C<Bivio::Biz::t::Action::T1>

=cut

#=IMPORTS

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="execute"></a>

=head2 static execute(Bivio::Agent::Request req) : any

Tests simple which puts itself on request.

Always returns false.

=cut

sub execute {
    my($proto, $req) = @_;
    $proto->new({
	loaded => 1,
    })->put_on_request($req);
    return 0;
}

=for html <a name="execute_dev"></a>

=head2 static execute_dev(Bivio::Agent::Request req) : any

Tries to put self.

=cut

sub execute_dev {
    my($self, $req) = @_;
    $self->put_on_request($req);
    return 0;
}

#=PRIVATE SUBROUTINES

=head1 COPYRIGHT

Copyright (c) 2002 bivio Software, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
