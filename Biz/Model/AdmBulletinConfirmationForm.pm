# Copyright (c) 2003 bivio Software Artisans, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::AdmBulletinConfirmationForm;
use strict;
$Bivio::Biz::Model::AdmBulletinConfirmationForm::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Biz::Model::AdmBulletinConfirmationForm::VERSION;

=head1 NAME

Bivio::Biz::Model::AdmBulletinConfirmationForm - confirm bulletin

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::Biz::Model::AdmBulletinConfirmationForm;

=cut

=head1 EXTENDS

L<Bivio::Biz::FormModel>

=cut

use Bivio::Biz::FormModel;
@Bivio::Biz::Model::AdmBulletinConfirmationForm::ISA = ('Bivio::Biz::FormModel');

=head1 DESCRIPTION

C<Bivio::Biz::Model::AdmBulletinConfirmationForm>

=cut

#=IMPORTS

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="execute_ok"></a>

=head2 execute_ok()

Saves the 'confirmed' state into the order context.

=cut

sub execute_ok {
    my($self) = @_;
    $self->put_context_fields(confirmed_bulletin => 1)
        if $self->unsafe_get('ok_button');
    $self->put_context_fields(test_mode => $self->unsafe_get('test_button')
       ? 1 : 0);
    return;
}

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : hash_ref;

B<FOR INTERNAL USE ONLY>

=cut

sub internal_initialize {
    my($self) = @_;
    my($info) = {
	require_context => 1,
	version => 1,
        visible => [
            {
                name => 'test_button',
                type => 'OKButton',
                constraint => 'NONE',
            },
            {
                name => 'edit_button',
                type => 'OKButton',
                constraint => 'NONE',
            },
        ],
    };
    return $self->merge_initialize_info(
	    $self->SUPER::internal_initialize, $info);
}

#=PRIVATE SUBROUTINES

=head1 COPYRIGHT

Copyright (c) 2003 bivio Software Artisans, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
