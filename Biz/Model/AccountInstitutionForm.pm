# Copyright (c) 2000 bivio Inc.  All rights reserved.
# $Id$
package Bivio::Biz::Model::AccountInstitutionForm;
use strict;
$Bivio::Biz::Model::AccountInstitutionForm::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Biz::Model::AccountInstitutionForm::VERSION;

=head1 NAME

Bivio::Biz::Model::AccountInstitutionForm - edits the institution info

=head1 SYNOPSIS

    use Bivio::Biz::Model::AccountInstitutionForm;

=cut

=head1 EXTENDS

L<Bivio::Biz::FormModel>

=cut

use Bivio::Biz::FormModel;
@Bivio::Biz::Model::AccountInstitutionForm::ISA = ('Bivio::Biz::FormModel');

=head1 DESCRIPTION

C<Bivio::Biz::Model::AccountInstitutionForm> edits the institution information
on the account form.

=cut

#=IMPORTS

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

=head1 METHODS

=cut

=for html <a name="execute_empty"></a>

=head2 execute_empty()

Loads the account we are setting.

=cut

sub execute_empty {
    my($self) = @_;
    $self->internal_put_field('RealmAccount.realm_account_id',
	    => $self->get_request->get('Bivio::Biz::Model::RealmAccountList')
	    ->get_default_broker_account);
    $self->load_from_model_properties('RealmAccount');
    return;
}

=for html <a name="execute_ok"></a>

=head2 execute_ok()

Updates the values in the account.

=cut

sub execute_ok {
    my($self) = @_;
    $self->get_model('RealmAccount')->update(
	    $self->get_model_properties('RealmAccount'));
    return;
}

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : hash_ref

Declares account form.

=cut

sub internal_initialize {
    my($self) = @_;
    my($info) = {
	version => 1,
	require_context => 1,
	visible => [
	    'RealmAccount.realm_account_id',
	    'RealmAccount.institution',
	    'RealmAccount.account_number',
	    'RealmAccount.external_password',
	],
    };
    return $self->merge_initialize_info(
	    $self->SUPER::internal_initialize, $info);
}

=for html <a name="validate"></a>

=head2 validate()

Ensures that if an institution is set, we have an account and password.

=cut

sub validate {
    my($self) = @_;
    return if $self->get_errors;

    my($properties) = $self->internal_get;
    return if $properties->{institution}
	    == Bivio::Type::Institution::UNKNOWN();

    foreach my $f (qw(account_number external_password)) {
	my($f2) = 'RealmAccount.'.$f;
	$self->internal_put_error($f2, Bivio::TypeError::NULL())
		unless defined($properties->{$f2});
    }
    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2000 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
