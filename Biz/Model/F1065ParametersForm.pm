# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::Model::F1065ParametersForm;
use strict;
$Bivio::Biz::Model::F1065ParametersForm::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

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
use Bivio::Biz::Model::Address;
use Bivio::Biz::Model::Tax1065;
use Bivio::Biz::Model::TaxId;
use Bivio::SQL::Connection;
use Bivio::Type::Date;
use Bivio::Type::DateTime;
use Bivio::Type::F1065Partner;
use Bivio::Type::F1065Partnership;
use Bivio::Type::F1065Return;
use Bivio::Type::Location;
use Bivio::TypeError;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

=head1 METHODS

=cut

=for html <a name="execute_empty"></a>

=head2 execute_empty()

Loads current settings.

=cut

sub execute_empty {
    my($self) = @_;
    my($req) = $self->get_request;
    my($properties) = $self->internal_get;
    my($end_date) = Bivio::Biz::Accounting::Tax->get_last_tax_year;
#TODO: hacked in for Bivio::UI::HTML::Format::USTaxId
    $req->put(target_realm_owner => $req->get('auth_realm')->get('owner'));

    my($tax) = Bivio::Biz::Model::Tax1065->new($req);
    $tax->load_or_default($end_date);

    $properties->{'Tax1065.realm_id'} = $req->get('auth_id');
    $properties->{'Tax1065.fiscal_end_date'} = $end_date;
    $properties->{'Address.location'} = Bivio::Type::Location::HOME();
    $self->load_from_model_properties('Tax1065');
    $self->load_from_model_properties('Address');
    $self->load_from_model_properties('TaxId');
    $self->load_from_model_properties('Club');

    return;
}

=for html <a name="execute_ok"></a>

=head2 execute_ok()

Saves new settings.

=cut

sub execute_ok {
    my($self) = @_;
    my($req) = $self->get_request;
    my($values) = $self->get_model_properties('Tax1065');
    my($end_date) = Bivio::Biz::Accounting::Tax->get_last_tax_year;

#TODO: bug in form, doesn't handle undef booleans
    $values->{partnership_is_partner} ||= 0;
    $values->{partner_is_partnership} ||= 0;
    $values->{consolidated_audit} ||= 0;

    my($tax) = Bivio::Biz::Model::Tax1065->new($req);
    $tax->load(fiscal_end_date => $end_date);
    $tax->update($values);

#TODO: couldn't get get_model() to work...
    my($address) = Bivio::Biz::Model::Address->new($req);
    $address->load(location => Bivio::Type::Location::HOME());
    $address->update($self->get_model_properties('Address'));
    my($tax_id) = Bivio::Biz::Model::TaxId->new($req);
    $tax_id->load;
    $tax_id->update($self->get_model_properties('TaxId'));
    my($club) = Bivio::Biz::Model::Club->new($req);
    $club->load;
    $club->update($self->get_model_properties('Club'));

    return;
}

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : hash_ref;

B<FOR INTERNAL USE ONLY>

=cut

sub internal_initialize {
    my($self) = @_;
    my($info) = {
	version => 2,
	visible => [
	    'Tax1065.partnership_type',
#TODO: bug in form doesn't allow undef booleans as false
	    {
		name => 'Tax1065.partnership_is_partner',
		type => 'Boolean',
		constraint => 'NONE',
	    },
	    {
		name => 'Tax1065.partner_is_partnership',
		type => 'Boolean',
		constraint => 'NONE',
	    },
	    {
		name => 'Tax1065.consolidated_audit',
		type => 'Boolean',
		constraint => 'NONE',
	    },
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
    my($req) = $self->get_request;

#TODO: hacked in for Bivio::UI::HTML::Format::USTaxId
    $req->put(target_realm_owner => $req->get('auth_realm')->get('owner'));

    if ($self->get('Tax1065.partnership_type')
	    == Bivio::Type::F1065Partnership::GENERAL()) {

	# general partnerships can have only general partners

	my($end_date) = Bivio::Biz::Accounting::Tax->get_last_tax_year;
	my($sql_date) = Bivio::Type::DateTime->to_sql_value('?');
	my($sth) = Bivio::SQL::Connection->execute("
                SELECT COUNT(*)
                FROM tax_k1_t
                WHERE partner_type != ?
                AND fiscal_end_date = $sql_date
                AND realm_id=?",
		[Bivio::Type::F1065Partner->GENERAL->as_int,
			$end_date, $req->get('auth_id')]);
	my($count) = 0;
	while (my $row = $sth->fetchrow_arrayref) {
	    $count = $row->[0];
	}
#TODO: total hack, errors don't show up on radio lists, put on irs center
#	$self->internal_put_error('Tax1065.partner_type',
	$self->internal_put_error('Tax1065.irs_center',
		Bivio::TypeError::INVALID_PARTNERSHIP_TYPE()) if $count;
    }

    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
