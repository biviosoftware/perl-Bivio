# Copyright (c) 2000 bivio, Inc.  All rights reserved.
# $Id$
package Bivio::Biz::Model::ExpenseCategory;
use strict;
$Bivio::Biz::Model::ExpenseCategory::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Biz::Model::ExpenseCategory::VERSION;

=head1 NAME

Bivio::Biz::Model::ExpenseCategory - an expense category

=head1 SYNOPSIS

    use Bivio::Biz::Model::ExpenseCategory;

=cut

=head1 EXTENDS

L<Bivio::Biz::PropertyModel>

=cut

use Bivio::Biz::PropertyModel;
@Bivio::Biz::Model::ExpenseCategory::ISA = ('Bivio::Biz::PropertyModel');

=head1 DESCRIPTION

C<Bivio::Biz::Model::ExpenseCategory> an expense category. May be deductible
or non-deductible. May be a sub-category of an existing expense.

=cut

#=IMPORTS

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;
my($_DEFAULT_DEDUCTIBLE) = {
    'Bond Insurance' => undef,
    'Educational Material' => {
	'Books & Videos' => undef,
	'Subscriptions' => undef,
    },
    'Investment Advice' => undef,
    'Margin Interest' => undef,
    'NAIC Membership Dues' => undef,
    'Office Supplies' => {
	'Envelopes & Stamps' => undef,
	'Paper & Copies' => undef,
    },
    'Rental' => {
	'Mailbox Rental' => undef,
	'Meeting Space Rental' => undef,
	'Safe Deposit Box Rental' => undef,
    },
    'Service Charges & Fees' => undef,
    'Software & Technical Support' => undef,
    'Tax Preparation' => undef,
};

my($_DEFAULT_NONDEDUCTIBLE) = {
    'Conventions & Seminars' => undef,
    'Flowers' => undef,
    'Food & Drink' => undef,
    'Party Supplies' => undef,
};

=head1 METHODS

=cut

=for html <a name="create_initial"></a>

=head2 create_initial()

=head2 create_initial(string realm_id)

Creates default expense categories for the realm of the current request.

=cut

sub create_initial {
    my($self, $realm_id) = @_;
    $realm_id ||= $self->get_request->get('auth_id');

    $self->create({
	realm_id => $realm_id,
	name => 'Deductible Expense',
	deductible => 1,
	parent_category_id => undef,
    });
    _create_categories($self, $self->get('expense_category_id'),
	    $_DEFAULT_DEDUCTIBLE, 1, $realm_id);

    $self->create({
	realm_id => $realm_id,
	name => 'Non-Deductible Expense',
	deductible => 0,
	parent_category_id => undef,
    });
    _create_categories($self, $self->get('expense_category_id'),
	    $_DEFAULT_NONDEDUCTIBLE, 0, $realm_id);

    return;
}

=for html <a name="get_default_category_id"></a>

=head2 get_default_category_id(boolean deductible) : string

Returns the default category id for the specified deductible type.

=cut

sub get_default_category_id {
    my($self, $deductible) = @_;
    # return the first, non subcategory of the appropriate type
    my($id) = 0;
    my($sth) = Bivio::SQL::Connection->execute('
            SELECT expense_category_id
            FROM expense_category_t
            WHERE parent_category_id IS NULL
            AND deductible=?
            AND realm_id=?',
	    [$deductible, $self->get_request->get('auth_id')]);
    while (my $row = $sth->fetchrow_arrayref) {
	$id ||= $row->[0];
    }
    return $id;
}

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : hash_ref

B<FOR INTERNAL USE ONLY>

=cut

sub internal_initialize {
    return {
	version => 1,
	table_name => 'expense_category_t',
	columns => {
            expense_category_id => ['PrimaryId', 'PRIMARY_KEY'],
            realm_id => ['PrimaryId', 'NOT_NULL'],
	    name => ['Line', 'NOT_NULL'],
	    deductible => ['Boolean', 'NOT_NULL'],
	    parent_category_id => ['PrimaryId', 'NONE'],
        },
	auth_id => 'realm_id',
    };
}

#=PRIVATE METHODS

# _create_categories(string parent_id, hash_ref info, boolean deductible, string realm_id)
#
# Recursively creates instances of the specified categories for the current
# realm.
#
sub _create_categories {
    my($self, $parent_id, $info, $deductible, $realm_id) = @_;

    foreach my $name (keys(%$info)) {
	$self->create({
	    realm_id => $realm_id,
	    name => $name,
	    deductible => $deductible,
	    parent_category_id => $parent_id,
	});
	if ($info->{$name}) {
	    _create_categories($self, $self->get('expense_category_id'),
		    $info->{$name}, $deductible, $realm_id);
	}
    }
    return;
}

=head1 COPYRIGHT

Copyright (c) 2000 bivio, Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
