# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::Model::ActiveShadowMemberList;
use strict;
$Bivio::Biz::Model::ActiveShadowMemberList::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Biz::Model::ActiveShadowMemberList - lists active shadow member

=head1 SYNOPSIS

    use Bivio::Biz::Model::ActiveShadowMemberList;
    Bivio::Biz::Model::ActiveShadowMemberList->new();

=cut

=head1 EXTENDS

L<Bivio::Biz::ListModel>

=cut

use Bivio::Biz::ListModel;
@Bivio::Biz::Model::ActiveShadowMemberList::ISA = ('Bivio::Biz::ListModel');

=head1 DESCRIPTION

C<Bivio::Biz::Model::ActiveShadowMemberList> lists active shadow member

=cut

#=IMPORTS
use Bivio::Type::Location;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

=head1 METHODS

=cut

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : hash_ref

B<FOR INTERNAL USE ONLY>

=cut

sub internal_initialize {
    return {
	version => 1,
	order_by => [qw(
            RealmOwner.name
	)],
	primary_key => [
	    [qw(RealmUser.user_id RealmOwner.realm_id User.user_id
                Address.realm_id Email.realm_id Phone.realm_id
                TaxId.realm_id)],
	],
	other => [qw(
            RealmOwner.display_name
            User.first_name
            User.middle_name
            User.last_name
            Email.email
            Phone.phone
            Address.street1
            Address.street2
            Address.city
            Address.state
            Address.country
            Address.zip
            TaxId.tax_id
        )],
	auth_id => [qw(RealmUser.realm_id)],
	where => [
#TODO: probably should have to quote the last one, problem in base class
	    'RealmOwner.name', 'like', "'=%-1'",
	    'AND',
	    'email_t.location', '=', Bivio::Type::Location::HOME->as_int,
	],
    };
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
