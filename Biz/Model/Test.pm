# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::Model::Test;
use strict;
$Bivio::Biz::Model::Test::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Biz::Model::Test - a parameterized testing model

=head1 SYNOPSIS

    use Bivio::Biz::Model::Test;
    Bivio::Biz::Model::Test->new($req);

=cut

=head1 EXTENDS

L<Bivio::Biz::Model>

=cut

use Bivio::Biz::Model;
@Bivio::Biz::Model::Test::ISA = qw(Bivio::Biz::Model);

=head1 DESCRIPTION

C<Bivio::Biz::Model::Test>

=cut

=head1 CONSTANTS

=cut

#=VARIABLES

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(Bivio::Agent::Request req) : Bivio::Biz::Model::Test

Creates a testing model.

=cut

sub new {
    my($proto, $req) = @_;
    my($self) = &Bivio::Biz::Model::new($proto, $req);
    return $self;
}

=head1 METHODS

=cut

=for html <a name="unsafe_load"></a>

=head2 unsafe_load(hash query)

This is ignored because test model has no state.

=cut

sub unsafe_load {
    #NOP
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
