# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::Model::ConnectSurvey;
use strict;
$Bivio::Biz::Model::ConnectSurvey::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Biz::Model::ConnectSurvey - interface to connect_survey_t

=head1 SYNOPSIS

    use Bivio::Biz::Model::ConnectSurvey;
    Bivio::Biz::Model::ConnectSurvey->new($req);

=cut

=head1 EXTENDS

L<Bivio::Biz::PropertyModel>

=cut

use Bivio::Biz::PropertyModel;
@Bivio::Biz::Model::ConnectSurvey::ISA = qw(Bivio::Biz::PropertyModel);

=head1 DESCRIPTION

C<Bivio::Biz::Model::ConnectSurvey> is the create, read, update,
and delete interface to the C<connect_survey_t> table.

=cut

#=IMPORTS
use Bivio::SQL::Constraint;
use Bivio::Type::Country;
use Bivio::Survey::Outlook;
use Bivio::Survey::Risk;
use Bivio::Survey::AgeRange;
use Bivio::Survey::Experience;
use Bivio::Survey::Contribution;
use Bivio::Survey::Vicinity;

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
	table_name => 'connect_survey_t',
	columns => {
	    realm_id => ['Bivio::Type::PrimaryId',
		Bivio::SQL::Constraint::PRIMARY_KEY()],
	    experience => ['Bivio::Survey::Experience',
		Bivio::SQL::Constraint::NOT_NULL()],
	    contribution => ['Bivio::Survey::Contribution',
		Bivio::SQL::Constraint::NOT_NULL()],
	    age_range  => ['Bivio::Survey::AgeRange',
		Bivio::SQL::Constraint::NOT_NULL()],
	    vicinity  => ['Bivio::Survey::Vicinity',
		Bivio::SQL::Constraint::NOT_NULL()],
	    risk  => ['Bivio::Survey::Risk',
		Bivio::SQL::Constraint::NOT_NULL()],
	    outlook  => ['Bivio::Survey::Outlook',
		Bivio::SQL::Constraint::NOT_NULL()],
        },
	auth_id => 'realm_id',
    };
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
