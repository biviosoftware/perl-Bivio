# Copyright (c) 2000 bivio, Inc.  All rights reserved.
# $Id$
package Bivio::Biz::Model::ExpenseInfo;
use strict;
$Bivio::Biz::Model::ExpenseInfo::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Biz::Model::ExpenseInfo::VERSION;

=head1 NAME

Bivio::Biz::Model::ExpenseInfo - entry expense cateogory

=head1 SYNOPSIS

    use Bivio::Biz::Model::ExpenseInfo;

=cut

=head1 EXTENDS

L<Bivio::Biz::PropertyModel>

=cut

use Bivio::Biz::PropertyModel;
@Bivio::Biz::Model::ExpenseInfo::ISA = ('Bivio::Biz::PropertyModel');

=head1 DESCRIPTION

C<Bivio::Biz::Model::ExpenseInfo> entry expense cateogory

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
	table_name => 'expense_info_t',
	columns => {
	    entry_id => ['PrimaryId', 'PRIMARY_KEY'],
            expense_category_id => ['PrimaryId', 'NOT_NULL'],
            realm_id => ['PrimaryId', 'NOT_NULL'],
	    allocate_equally => ['Boolean', 'NOT_NULL'],
        },
	auth_id => 'realm_id',
	other => [
	    [qw(entry_id Entry.entry_id)],
	    [qw(expense_category_id ExpenseCategory.expense_category_id)],
	],
    };
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2000 bivio, Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
