# Copyright (c) 2000 bivio Inc.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Club::AccountInstitution;
use strict;
$Bivio::UI::HTML::Club::AccountInstitution::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::UI::HTML::Club::AccountInstitution::VERSION;

=head1 NAME

Bivio::UI::HTML::Club::AccountInstitution - edit account institution

=head1 SYNOPSIS

    use Bivio::UI::HTML::Club::AccountInstitution;

=cut

=head1 EXTENDS

L<Bivio::UI::HTML::DescriptivePage>

=cut

use Bivio::UI::HTML::DescriptivePage;
@Bivio::UI::HTML::Club::AccountInstitution::ISA = ('Bivio::UI::HTML::DescriptivePage');

=head1 DESCRIPTION

C<Bivio::UI::HTML::Club::AccountInstitution> edits the account institution
information.

=cut

#=IMPORTS

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

=head1 METHODS

=cut

=for html <a name="create_content"></a>

=head2 create_content() : Bivio::UI::HTML::Widget

Create widgets.

=cut

sub create_content {
    my($self) = @_;
    $self->put_heading('CLUB_ACCOUNTING_ACCOUNT_INSTITUTION');
    return $self->form('AccountInstitutionForm', [
	['RealmAccount.realm_account_id', undef, undef, undef,
		{
		    choices => ['Bivio::Biz::Model::RealmAccountList'],
		    list_display_field => 'RealmAccount.name',
		    list_id_field => 'RealmAccount.realm_account_id',
		},
	],
	['RealmAccount.institution', undef, undef, undef,
	    {wf_want_select => 1},
	],
	['RealmAccount.account_number'],
	['RealmAccount.external_password'],
    ]);
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2000 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
