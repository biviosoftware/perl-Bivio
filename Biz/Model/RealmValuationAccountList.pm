# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::Model::RealmValuationAccountList;
use strict;
$Bivio::Biz::Model::RealmValuationAccountList::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Biz::Model::RealmValuationAccountList - 

=head1 SYNOPSIS

    use Bivio::Biz::Model::RealmValuationAccountList;
    Bivio::Biz::Model::RealmValuationAccountList->new();

=cut

=head1 EXTENDS

L<Bivio::Biz::ListModel>

=cut

use Bivio::Biz::ListModel;
@Bivio::Biz::Model::RealmValuationAccountList::ISA = ('Bivio::Biz::ListModel');

=head1 DESCRIPTION

C<Bivio::Biz::Model::RealmValuationAccountList>

=cut

#=IMPORTS

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
            RealmAccount.name
	)],
	primary_key => [
	    [qw(RealmAccount.realm_account_id)],
	],
	auth_id => [qw(RealmAccount.realm_id)],
	other => [qw(RealmAccount.in_valuation)],
	where => [
            # Must be in club valuation
	    'RealmAccount.in_valuation',
	    '=', 1
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
