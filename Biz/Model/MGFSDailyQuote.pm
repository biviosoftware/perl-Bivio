# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::Model::MGFSDailyQuote;
use strict;
$Bivio::Biz::Model::MGFSDailyQuote::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Biz::Model::MGFSDailyQuote - 

=head1 SYNOPSIS

    use Bivio::Biz::Model::MGFSDailyQuote;
    Bivio::Biz::Model::MGFSDailyQuote->new();

=cut

=head1 EXTENDS

L<Bivio::Biz::PropertyModel>

=cut

use Bivio::Biz::PropertyModel;
@Bivio::Biz::Model::MGFSDailyQuote::ISA = ('Bivio::Biz::PropertyModel');

=head1 DESCRIPTION

C<Bivio::Biz::Model::MGFSDailyQuote>

=cut

#=IMPORTS
use Bivio::Data::MGFS::Id;
use Bivio::Type::Amount;
use Bivio::Type::Date;

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
	table_name => 'mgfs_daily_quote_t',
	columns => {
	    mg_id => ['Bivio::Data::MGFS::Id',
		    Bivio::SQL::Constraint::PRIMARY_KEY()],
            dttm => ['Bivio::Type::Date',
    		Bivio::SQL::Constraint::PRIMARY_KEY()],
	    high => ['Bivio::Type::Amount',
    		Bivio::SQL::Constraint::NOT_NULL()],
            low => ['Bivio::Type::Amount',
    		Bivio::SQL::Constraint::NOT_NULL()],
            close => ['Bivio::Type::Amount',
    		Bivio::SQL::Constraint::NOT_NULL()],
            volume => ['Bivio::Type::Amount',
    		Bivio::SQL::Constraint::NOT_NULL()],
        },
    };
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
