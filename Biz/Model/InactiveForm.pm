# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::Model::InactiveForm;
use strict;
$Bivio::Biz::Model::InactiveForm::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Biz::Model::InactiveForm - a single boolean value form

=head1 SYNOPSIS

    my($form) = $req->get('Bivio::Biz::Model::InactiveForm');
    my($show) = $form->get('show_inactive');

=cut

=head1 EXTENDS

L<Bivio::Biz::FormModel>

=cut

use Bivio::Biz::FormModel;
@Bivio::Biz::Model::InactiveForm::ISA = ('Bivio::Biz::FormModel');

=head1 DESCRIPTION

C<Bivio::Biz::Model::InactiveForm> has a single boolean value. The form
will never execute_ok(), but keeps track of the value.

=cut

#=IMPORTS
use Bivio::TypeError;
use Bivio::SQL::Constraint;
use Bivio::Type::Boolean;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

=head1 METHODS

=cut

=for html <a name="execute_active_only"></a>

=head2 static execute_active_only(Bivio::Agent::Request req)

Loads this form forcing show_inactive to false.

=cut

sub execute_active_only {
    my($proto, $req) = @_;
    $proto->execute($req, {show_inactive => 0});
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
            {
               name => 'show_inactive',
	       type => 'Bivio::Type::Boolean',
	       constraint => Bivio::SQL::Constraint::NONE(),
	    },
	],
    };
    return $self->merge_initialize_info(
	    $self->SUPER::internal_initialize, $info);
}

=for html <a name="validate"></a>

=head2 validate()

Keep the form on the same page, doesn't redirect to "next".

=cut

sub validate {
    my($self) = @_;
    $self->internal_stay_on_page;
    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
