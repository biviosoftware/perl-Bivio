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
use Bivio::Biz::Model::Tax1065;
use Bivio::Type::Date;
use Bivio::Type::F1065Partnership;
use Bivio::Type::F1065Return;

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
    my($properties) = $self->internal_get;
    my($end_date) = Bivio::Biz::Accounting::Tax->get_last_tax_year;

    my($tax) = Bivio::Biz::Model::Tax1065->new($self->get_request);
    unless ($tax->unsafe_load(fiscal_end_date => $end_date)) {
	$tax->create_default($end_date);
    }

    # copy values into properties
    foreach my $field (@{$tax->get_keys}) {
	my($form_field) = 'Tax1065.'.$field;
	if ($self->has_keys($form_field)) {
	    $properties->{$form_field} = $tax->get($field);
	}
    }
    return;
}

=for html <a name="execute_input"></a>

=head2 execute_input()

Saves new settings.

=cut

sub execute_input {
    my($self) = @_;
    my($values) = $self->get_model_properties('Tax1065');
    my($end_date) = Bivio::Biz::Accounting::Tax->get_last_tax_year;

#TODO: bug in form, doesn't handle undef booleans
    $values->{partnership_is_partner} ||= 0;
    $values->{partner_is_partnership} ||= 0;
    $values->{consolidated_audit} ||= 0;

    my($tax) = Bivio::Biz::Model::Tax1065->new($self->get_request);
    $tax->load(fiscal_end_date => $end_date);
    $tax->update($values);

    return;
}

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : hash_ref;

B<FOR INTERNAL USE ONLY>

=cut

sub internal_initialize {
    return {
	version => 1,
	visible => [
	    'Tax1065.allocation_method',
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
	],
	auth_id => [
	    'Tax1065.realm_id',
	],
	primary_key => [
	    'Tax1065.realm_id',
	    'Tax1065.fiscal_end_date',
	],
    };
}

=for html <a name="validate"></a>

=head2 validate()

Ensures fields are valid.

=cut

sub validate {
    my($self) = @_;

#TODO: partnership_type can't be general if a non general partner exists

    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
