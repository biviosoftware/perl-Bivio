# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::Model::JapanSurvey;
use strict;
$Bivio::Biz::Model::JapanSurvey::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Biz::Model::JapanSurvey - interface to japan_survey_t

=head1 SYNOPSIS

    use Bivio::Biz::Model::JapanSurvey;
    Bivio::Biz::Model::JapanSurvey->new($req);

=cut

=head1 EXTENDS

L<Bivio::Biz::PropertyModel>

=cut

use Bivio::Biz::PropertyModel;
@Bivio::Biz::Model::JapanSurvey::ISA = qw(Bivio::Biz::PropertyModel);

=head1 DESCRIPTION

C<Bivio::Biz::Model::JapanSurvey> is the create, read, update,
and delete interface to the C<japan_survey_t> table.

=cut

#=IMPORTS
use Bivio::SQL::Constraint;
use Bivio::Type::DateTime;
use Bivio::Type::Line;
use Bivio::Type::Name;
use Bivio::Type::Boolean;
use Bivio::Type::Country;
use Bivio::Type::Amount;

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="create"></a>

=head2 create(hash_ref new_values)

Sets I<creation_date_time> and I<client_addr> if not set, then calls SUPER.

=cut

sub create {
    my($self, $values) = @_;
    $values->{creation_date_time} = Bivio::Type::DateTime->now()
	    unless $values->{creation_date_time};
    $values->{client_addr} = $self->get_request->get('client_addr')
	    unless defined($values->{client_addr});
    return $self->SUPER::create($values);
}

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : hash_ref

B<FOR INTERNAL USE ONLY>

=cut

sub internal_initialize {
    return {
	version => 1,
	table_name => 'japan_survey_t',
	columns => {
	    # This is actually bogus, but there is no way to have a
	    # model without a primary key at this time.
	    # (There is no consistent way to delete then.)
	    creation_date_time => ['Bivio::Type::DateTime',
		Bivio::SQL::Constraint::PRIMARY_KEY()],
	    client_addr => ['Bivio::Type::Name',
		Bivio::SQL::Constraint::PRIMARY_KEY()],
	    has_invested_before => ['Bivio::Type::Boolean',
		Bivio::SQL::Constraint::NONE()],
	    has_broker => ['Bivio::Type::Boolean',
		Bivio::SQL::Constraint::NONE()],
	    is_club_member => ['Bivio::Type::Boolean',
		Bivio::SQL::Constraint::NONE()],
	    would_start_club => ['Bivio::Type::Boolean',
		Bivio::SQL::Constraint::NONE()],
	    is_interested_in_market => ['Bivio::Type::Country',
		Bivio::SQL::Constraint::NONE()],
	    would_invest_yen => ['Bivio::Type::Amount',
		Bivio::SQL::Constraint::NONE()],
	    # This can't be Email, because we can't kick back the form
	    # with errors, so there can be no errors.  The rest
	    # are input with radio buttons so there isn't likely
	    # to be errors.  We want the attempt at an email address.
            email => ['Bivio::Type::Line',
    		Bivio::SQL::Constraint::NONE()],
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
