# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::Model::F1065ParametersForm;
use strict;
$Bivio::Biz::Model::F1065ParametersForm::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Biz::Model::F1065ParametersForm::VERSION;

=head1 NAME

Bivio::Biz::Model::F1065ParametersForm - IRS 1065 parameters

=head1 SYNOPSIS

    use Bivio::Biz::Model::F1065ParametersForm;
    Bivio::Biz::Model::F1065ParametersForm->new();

=cut

=head1 EXTENDS

L<Bivio::Biz::FormModel>

=cut

use Bivio::Biz::FormModel;
@Bivio::Biz::Model::F1065ParametersForm::ISA = ('Bivio::Biz::FormModel');

=head1 DESCRIPTION

C<Bivio::Biz::Model::F1065ParametersForm> IRS 1065 parameters

=cut

#=IMPORTS
use Bivio::Biz::Model::Tax1065;
use Bivio::SQL::Connection;
use Bivio::Type::DateTime;
use Bivio::Type::F1065Partner;
use Bivio::Type::F1065Partnership;
use Bivio::Type::Location;
use Bivio::TypeError;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;
my($_SQL_DATE_VALUE) = Bivio::Type::DateTime->to_sql_value('?');

=head1 METHODS

=cut

=for html <a name="execute_empty"></a>

=head2 execute_empty()

Loads current settings.

=cut

sub execute_empty {
    my($self) = @_;
    my($tax) = Bivio::Biz::Model::Tax1065->new($self->get_request)
	    ->load_or_default(_get_end_date($self));

    # save the keys to related models in hidden fields
    $self->internal_put_field('Tax1065.realm_id' => $tax->get('realm_id'));
    $self->internal_put_field('Tax1065.fiscal_end_date'
	    => $tax->get('fiscal_end_date'));
    $self->internal_put_field('Address.location'
	    => Bivio::Type::Location::HOME());

    # load values from models
    foreach my $model (qw(Tax1065 Address TaxId Club)) {
	$self->load_from_model_properties($model);
    }
    return;
}

=for html <a name="execute_ok"></a>

=head2 execute_ok()

Saves new settings.

=cut

sub execute_ok {
    my($self) = @_;

    # save values into related models
    foreach my $model (qw(Tax1065 Address TaxId Club)) {
	$self->get_model($model)->update($self->get_model_properties($model));
    }
    return;
}

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : hash_ref;

B<FOR INTERNAL USE ONLY>

=cut

sub internal_initialize {
    my($self) = @_;
    my($info) = {
	version => 3,
	require_context => 1,
	visible => [
	    'Tax1065.partnership_type',
	    'Tax1065.partnership_is_partner',
	    'Tax1065.partner_is_partnership',
	    'Tax1065.consolidated_audit',
	    # this is required for taxes
	    {
		name => 'Club.start_date',
		type => 'Date',
		constraint => 'NOT_NULL',
	    },
	    qw(
	    Tax1065.irs_center
	    Address.street1
	    Address.street2
	    Address.city
	    Address.state
	    Address.zip
	    TaxId.tax_id
	)],
	hidden => [qw(
            Address.location
	    Tax1065.realm_id
	    Tax1065.fiscal_end_date
	)],
	auth_id => [qw(
	    Tax1065.realm_id Address.realm_id TaxId.realm_id Club.club_id
	)],
	primary_key => [
	    'Tax1065.realm_id',
	    'Tax1065.fiscal_end_date',
	],
    };
    return $self->merge_initialize_info(
	    $self->SUPER::internal_initialize, $info);
}

=for html <a name="validate"></a>

=head2 validate()

Ensures fields are valid.

=cut

sub validate {
    my($self) = @_;

    if ($self->get('Tax1065.partnership_type')
	    == Bivio::Type::F1065Partnership::GENERAL()) {

	# general partnerships may only have general partners

	my($sth) = Bivio::SQL::Connection->execute("
                SELECT COUNT(*)
                FROM tax_k1_t
                WHERE partner_type != ?
                AND fiscal_end_date = $_SQL_DATE_VALUE
                AND realm_id=?",
		[Bivio::Type::F1065Partner::GENERAL()->as_int,
		    _get_end_date($self),
		    $self->get_request->get('auth_id')]);

	my($count) = 0;
	while (my $row = $sth->fetchrow_arrayref) {
	    $count = $row->[0];
	}

	$self->internal_put_error('Tax1065.partnership_type',
		Bivio::TypeError::INVALID_PARTNERSHIP_TYPE()) if $count;
    }
    return;
}

#=PRIVATE METHODS

# _get_end_date() : string
#
# Returns the end date for the tax year.
#
sub _get_end_date {
    my($self) = @_;
    my($date) = $self->unsafe_get_context_field('date')
	    || Bivio::Biz::Accounting::Tax->get_last_tax_year;
    Bivio::Biz::Action::ReportDate->set_report_date($date, $self->get_request);
    return $date;
}

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
