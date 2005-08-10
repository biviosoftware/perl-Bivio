# Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::PetShop::Model::WorkflowStepForm;
use strict;
$Bivio::PetShop::Model::WorkflowStepForm::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::PetShop::Model::WorkflowStepForm::VERSION;

=head1 NAME

Bivio::PetShop::Model::WorkflowStepForm - step in workflow

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::PetShop::Model::WorkflowStepForm;

=cut

=head1 EXTENDS

L<Bivio::Biz::FormModel>

=cut

use Bivio::Biz::FormModel;
@Bivio::PetShop::Model::WorkflowStepForm::ISA = ('Bivio::Biz::FormModel');

=head1 DESCRIPTION

C<Bivio::PetShop::Model::WorkflowStepForm>

=cut

#=IMPORTS

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="execute_ok"></a>

=head2 execute_ok()

Stuffs current task in context.

=cut

sub execute_ok {
    my($self) = @_;
    $self->put_context_fields(
	prev_task => $self->get_request->get('task_id')->get_long_desc,
    ) if $self->has_context_field('prev_task');
    return;
}

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : hash_ref

=cut

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
	version => 1,
    });
}

#=PRIVATE SUBROUTINES

=head1 COPYRIGHT

Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
