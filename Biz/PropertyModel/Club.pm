# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::PropertyModel::Club;
use strict;
$Bivio::Biz::PropertyModel::Club::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Biz::PropertyModel::Club - a club

=head1 SYNOPSIS

    use Bivio::Biz::PropertyModel::Club;
    Bivio::Biz::PropertyModel::Club->new($req);

=cut

=head1 EXTENDS

L<Bivio::Biz::PropertyModel>

=cut

use Bivio::Biz::PropertyModel;
@Bivio::Biz::PropertyModel::Club::ISA = qw(Bivio::Biz::PropertyModel);

=head1 DESCRIPTION

C<Bivio::Biz::PropertyModel::Club>

=cut

#=IMPORTS
use Bivio::Biz::FieldDescriptor;
use Bivio::SQL::Support;

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="get_outgoing_emails"></a>

=head2 get_outgoing_emails() : array

Returns an array of email addresses (string) for all members of the club.
If an error occurs during processing, then undef is returned.

=cut

sub get_outgoing_emails {
    my($self) = @_;

    my($conn) = Bivio::SQL::Connection->get_connection();

    # a 4 table join
    my($statement) = $conn->prepare_cached(
	    'select user_email_t.email '
	    .'from user_email_t, user_t, club_t, club_user_t '
	    .'where club_t.club_id=? '
	    .'and club_t.club_id=club_user_t.club_id '
	    .'and club_user_t.user_id=user_t.user_id '
	    .'and user_t.user_id=user_email_t.user_id');

    Bivio::SQL::Connection->execute($statement, $self, $self->get('club_id'));

    my($result) = [];
    my($row);
    while($row = $statement->fetchrow_arrayref()) {
	push(@$result, $row->[0]);
    }
#TODO: Do we need statement->finish here?
#    $statement->finish();
    return $result;
}

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : (array_ref, Bivio::SQL::Support)

=cut

sub internal_initialize {
    my($property_info) = {
	'club_id' => ['Internal ID',
		Bivio::Biz::FieldDescriptor->lookup('NUMBER', 16)],
	'name' => ['Club Name',
		Bivio::Biz::FieldDescriptor->lookup('STRING', 32)],
	'full_name' => ['Full Name',
		Bivio::Biz::FieldDescriptor->lookup('STRING', 128)],
	'bytes_in_use' => ['Space Used',
		Bivio::Biz::FieldDescriptor->lookup('NUMBER', 9)],
	'bytes_max' => ['Space Allowed',
		Bivio::Biz::FieldDescriptor->lookup('NUMBER', 9)]
    };
    return [$property_info,
	    Bivio::SQL::Support->new('club_t', keys(%$property_info)),
	    ['club_id']];
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
