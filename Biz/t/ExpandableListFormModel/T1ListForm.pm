# Copyright (c) 2002 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::t::ExpandableListFormModel::T1ListForm;
use strict;
$Bivio::Biz::t::ExpandableListFormModel::T1ListForm::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Biz::t::ExpandableListFormModel::T1ListForm::VERSION;

=head1 NAME

Bivio::Biz::t::ExpandableListFormModel::T1ListForm - test

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::Biz::t::ExpandableListFormModel::T1ListForm;

=cut

=head1 EXTENDS

L<Bivio::Biz::ExpandableListFormModel>

=cut

use Bivio::Biz::ExpandableListFormModel;
@Bivio::Biz::t::ExpandableListFormModel::T1ListForm::ISA = ('Bivio::Biz::ExpandableListFormModel');

=head1 DESCRIPTION

C<Bivio::Biz::t::ExpandableListFormModel::T1ListForm>

=cut


#=IMPORTS

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="execute_empty_row"></a>

=head2 execute_empty_row() : 



=cut

sub execute_empty_row {
    my($self) = @_;
    $self->internal_load_field('form_index', 'index');
    return;
}

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : hash_ref;

B<FOR INTERNAL USE ONLY>

=cut

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
	list_class => 'NumberedList',
	version => 1,
	visible => [
	    {
		name => 'form_index',
	        type => 'Integer',
		constraint => 'NONE',
		in_list => 1,
	    },
	],
    });
}

#=PRIVATE SUBROUTINES

=head1 COPYRIGHT

Copyright (c) 2002 bivio Software, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
