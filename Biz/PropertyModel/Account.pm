# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::PropertyModel::Account;
use strict;
$Bivio::Biz::PropertyModel::Account::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Biz::PropertyModel::Account - a club account

=head1 SYNOPSIS

    use Bivio::Biz::PropertyModel::Account;
    Bivio::Biz::PropertyModel::Account->new();

=cut

=head1 EXTENDS

L<Bivio::Biz::PropertyModel>

=cut

use Bivio::Biz::PropertyModel;
@Bivio::Biz::PropertyModel::Account::ISA = qw(Bivio::Biz::PropertyModel);

=head1 DESCRIPTION

C<Bivio::Biz::PropertyModel::Account> represents a club account.

=cut

=head1 CONSTANTS

=cut

#=IMPORTS
use Bivio::Biz::FieldDescriptor;
use Bivio::IO::Trace;
use Bivio::SQL::Support;

#=VARIABLES
use vars qw($_TRACE);
Bivio::IO::Trace->register;
my($_PACKAGE) = __PACKAGE__;

=head1 METHODS

=cut

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : array_ref

=cut

sub internal_initialize {
    my($property_info) = {
	'account_id' => ['Internal ID',
		Bivio::Biz::FieldDescriptor->lookup('NUMBER', 16)],
	'club_id' => ['Internal Club ID',
		Bivio::Biz::FieldDescriptor->lookup('NUMBER', 16)],
	'name' => ['Name',
		Bivio::Biz::FieldDescriptor->lookup('STRING', 256)],
	'tax_free' => ['Tax Free',
		Bivio::Biz::FieldDescriptor->lookup('BOOLEAN')],
	'in_valuation' => ['Used In Valuation Calculation',
		Bivio::Biz::FieldDescriptor->lookup('BOOLEAN')],
	'institution_id' => ['Institution ID',
		Bivio::Biz::FieldDescriptor->lookup('NUMBER', 16)],
	'account_number' => ['Account Number',
		Bivio::Biz::FieldDescriptor->lookup('STRING', 32)],
	'external_password' => ['External Account Password',
		Bivio::Biz::FieldDescriptor->lookup('STRING', 32)],
    };
    return [$property_info,
	    Bivio::SQL::Support->new('account_t', keys(%$property_info)),
	    ['account_id']];
}

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
