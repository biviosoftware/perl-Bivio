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
will never execute_input(), but keeps track of the value.

=cut

#=IMPORTS
use Bivio::TypeError;
use Bivio::SQL::Constraint;
use Bivio::Type::Boolean;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

=head1 METHODS

=cut

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : hash_ref;

B<FOR INTERNAL USE ONLY>

=cut

sub internal_initialize {
    return {
	version => 1,
	visible => [
            {
               name => 'show_inactive',
	       type => 'Bivio::Type::Boolean',
	       constraint => Bivio::SQL::Constraint::NONE(),
	    },
	],
    };
}

=for html <a name="validate"></a>

=head2 validate(boolean is_create)

Always creates errors, never leave this form.

=cut

sub validate {
    my($self) = @_;
    $self->internal_put_error('', Bivio::TypeError::UNKNOWN());
    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
