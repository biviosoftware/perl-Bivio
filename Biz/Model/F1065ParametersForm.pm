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

L<Bivio::Biz::ListFormModel>

=cut

use Bivio::Biz::ListFormModel;
@Bivio::Biz::Model::F1065ParametersForm::ISA = ('Bivio::Biz::ListFormModel');

=head1 DESCRIPTION

C<Bivio::Biz::Model::F1065ParametersForm> IRS 1065 parameters

=cut

#=IMPORTS
use Bivio::Societas::Biz::Model::Tax1065;
use Bivio::Biz::Model::TaxYearSubForm;
use Bivio::SQL::Connection;
use Bivio::Type::CountryCode;
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

=for html <a name="execute_empty_row"></a>

=head2 execute_empty_row()

Loads country codes.

=cut

sub execute_empty_row {
    my($self) = @_;
    $self->internal_put_field('country_code',
	    Bivio::Type::CountryCode->unsafe_from_any(
		    $self->get_list_model->get('RealmInstrument.country')));
    return;
}

=for html <a name="execute_empty_start"></a>

=head2 execute_empty_start()

Loads current settings.

=cut

sub execute_empty_start {
    my($self) = @_;
    my($tax) = Bivio::Societas::Biz::Model::Tax1065->new($self->get_request)
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

    # put an error on start date for emphasis
    $self->internal_put_error('Club.start_date', Bivio::TypeError::NULL())
	    unless defined($self->get('Club.start_date'));
    return;
}

=for html <a name="execute_ok_row"></a>

=head2 execute_ok_row()

Saves the foreign tax country code into the RealmInstrument.

=cut

sub execute_ok_row {
    my($self) = @_;

    my($realm_inst) = $self->get_list_model->get_model('RealmInstrument');
    $realm_inst->update({
	country => $self->get('country_code')->get_name,
    });
    return;
}

=for html <a name="execute_ok_start"></a>

=head2 execute_ok_start()

Saves new settings.

=cut

sub execute_ok_start {
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
	version => 4,
	list_class => 'ForeignTaxCountryList',
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
	),
	    {
		name => 'country_code',
		type => 'CountryCode',
		constraint => 'NOT_NULL',
		in_list => 1,
	    },
	],
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

=for html <a name="internal_initialize_list"></a>

=head2 internal_initialize_list() : Bivio::Biz::ListModel

Loads and returns the MemberTaxList using the date from the
query string.

=cut

sub internal_initialize_list {
    my($self) = @_;

    Bivio::Biz::Action::ReportDate->set_report_date(
	    _get_end_date($self), $self->get_request);
    Bivio::Biz::Model::ForeignTaxCountryList->execute_load_all(
	    $self->get_request);
    # use the super class to get the list from the request
    return $self->SUPER::internal_initialize_list();
}

=for html <a name="validate_row"></a>

=head2 validate_row()

Ensures the selected country is valid.

=cut

sub validate_row {
    my($self) = @_;

    # must be selected, and not the US
    $self->internal_put_error('country_code',
	    Bivio::TypeError::SELECT_VALID_FOREIGN_TAX_COUNTRY())
	    if $self->get('country_code')
		    == Bivio::Type::CountryCode::UNKNOWN()
			    || $self->get('country_code')
				    == Bivio::Type::CountryCode::US();
    return;
}

=for html <a name="validate_start"></a>

=head2 validate_start()

Ensures fields are valid.

=cut

sub validate_start {
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
    return Bivio::Biz::Model::TaxYearSubForm->get_tax_date($self->get_request);
}

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
