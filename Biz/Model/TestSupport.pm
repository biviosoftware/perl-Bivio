# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::Model::TestSupport;
use strict;
$Bivio::Biz::Model::TestSupport::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Biz::Model::TestSupport - interface to test_support_t SQL table

=head1 SYNOPSIS

    use Bivio::Biz::Model::TestSupport;
    Bivio::Biz::Model::TestSupport->new($req);

=cut

=head1 EXTENDS

L<Bivio::Biz::PropertyModel>

=cut

use Bivio::Biz::PropertyModel;
@Bivio::Biz::Model::TestSupport::ISA = qw(Bivio::Biz::PropertyModel);

=head1 DESCRIPTION

C<Bivio::Biz::Model::TestSupport> is the create, read, update,
and delete interface to the C<test_support_t> table.

=cut

#=IMPORTS
use Bivio::SQL::Constraint;
use Bivio::Type::Amount;
use Bivio::Type::Boolean;
use Bivio::Type::Date;
use Bivio::Type::DateTime;
use Bivio::Type::Gender;
use Bivio::Type::Line;
use Bivio::Type::Name;
use Bivio::Type::PrimaryId;
use Bivio::Type::PrimaryId;
use Bivio::Type::Text;
use Bivio::Type::Time;

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : hash_ref

B<FOR INTERNAL USE ONLY>

=cut

sub internal_initialize {
    return {
	version => 1,
	table_name => $_TABLE,
	columns => {
    	test_support_id => ['Bivio::Type::PrimaryId',
    	    Bivio::SQL::Constraint::PRIMARY_KEY()],
    	name => ['Bivio::Type::Name',
    	    Bivio::SQL::Constraint::NONE()],
    	line => ['Bivio::Type::Line',
    	    Bivio::SQL::Constraint::NONE()],
    	text => ['Bivio::Type::Text',
    	    Bivio::SQL::Constraint::NONE()],
    	amount => ['Bivio::Type::Amount',
    	    Bivio::SQL::Constraint::NONE()],
    	boolean => ['Bivio::Type::Boolean',
    	    Bivio::SQL::Constraint::NOT_NULL()],
    	date_time => ['Bivio::Type::DateTime',
    	    Bivio::SQL::Constraint::NOT_NULL()],
    	dt => ['Bivio::Type::Date',
    	    Bivio::SQL::Constraint::NONE()],
    	tm => ['Bivio::Type::Time',
    	    Bivio::SQL::Constraint::NONE()],
    	gender => ['Bivio::Type::Gender',
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
