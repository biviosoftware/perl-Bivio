# Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::PetShop::Model::WorkflowCallerForm;
use strict;
$Bivio::PetShop::Model::WorkflowCallerForm::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::PetShop::Model::WorkflowCallerForm::VERSION;

=head1 NAME

Bivio::PetShop::Model::WorkflowCallerForm - calls a workflow before beginning

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::PetShop::Model::WorkflowCallerForm;

=cut

=head1 EXTENDS

L<Bivio::Biz::FormModel>

=cut

use Bivio::Biz::FormModel;
@Bivio::PetShop::Model::WorkflowCallerForm::ISA = ('Bivio::Biz::FormModel');

=head1 DESCRIPTION

C<Bivio::PetShop::Model::WorkflowCallerForm>

=cut

#=IMPORTS

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="execute_empty"></a>

=head2 execute_empty() : Bivio::Agent::TaskId

Calls WORKFLOW_STEP_1

=cut

sub execute_empty {
    shift->get_request->server_redirect({
	task_id => Bivio::Agent::TaskId->WORKFLOW_STEP_1,
	require_context => 1,
    });
    return;
}

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : hash_ref

=cut

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
	version => 1,
	visible => [
	    {
		name => 'prev_task',
		type => 'String',
		constraint => 'NOT_NULL',
	    },
	],
    });
}

#=PRIVATE SUBROUTINES

=head1 COPYRIGHT

Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
