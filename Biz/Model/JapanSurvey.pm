# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::Model::JapanSurvey;
use strict;
$Bivio::Biz::Model::JapanSurvey::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Biz::Model::JapanSurvey::VERSION;

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
use Bivio::Type::DateTime;

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
	    creation_date_time => ['DateTime', 'PRIMARY_KEY'],
	    client_addr => ['Name', 'PRIMARY_KEY'],
	    has_invested_before => ['Boolean', 'NONE'],
	    has_broker => ['Boolean', 'NONE'],
	    is_club_member => ['Boolean', 'NONE'],
	    would_start_club => ['Boolean', 'NONE'],
	    is_interested_in_market => ['Country', 'NONE'],
	    would_invest_yen => ['Amount', 'NONE'],
	    # This can't be Email, because we can't kick back the form
	    # with errors, so there can be no errors.  The rest
	    # are input with radio buttons so there isn't likely
	    # to be errors.  We want the attempt at an email address.
            email => ['Line', 'NONE'],
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
