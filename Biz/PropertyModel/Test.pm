# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::PropertyModel::Test;
use strict;
$Bivio::Biz::PropertyModel::Test::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Biz::PropertyModel::Test - a parameterized testing model

=head1 SYNOPSIS

    use Bivio::Biz::PropertyModel::Test;
    Bivio::Biz::PropertyModel::Test->new($req);

=cut

=head1 EXTENDS

L<Bivio::Biz::Model>

=cut

use Bivio::Biz::Model;
@Bivio::Biz::PropertyModel::Test::ISA = qw(Bivio::Biz::Model);

=head1 DESCRIPTION

C<Bivio::Biz::PropertyModel::Test>

=cut

=head1 CONSTANTS

=cut

#=VARIABLES

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(Bivio::Agent::Request req) : Bivio::Biz::PropertyModel::Test

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
