# Copyright (c) 2000 bivio Inc.  All rights reserved.
# $Id$
package Bivio::Type::Notice;
use strict;
$Bivio::Type::Notice::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Type::Notice::VERSION;

=head1 NAME

Bivio::Type::Notice - list of standard RealmNotices

=head1 SYNOPSIS

    use Bivio::Type::Notice;

=cut

=head1 EXTENDS

L<Bivio::Type::Enum>

=cut

use Bivio::Type::Enum;
@Bivio::Type::Notice::ISA = ('Bivio::Type::Enum');

=head1 DESCRIPTION

C<Bivio::Type::Notice> is a list of standard
L<Bivio::Biz::Model::RealmNotice|Bivio::Biz::Model::RealmNotice>.

=cut

#=IMPORTS

#=VARIABLES
__PACKAGE__->compile([
    TEMPLATE => [1],
    EMAIL_INVALID => [2],
    ACCOUNT_SYNC => [3],
]);

=head1 METHODS

=cut

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2000 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
