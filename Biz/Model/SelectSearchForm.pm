# Copyright (c) 2003 bivio Software Artisans, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::SelectSearchForm;
use strict;
$Bivio::Biz::Model::SelectSearchForm::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Biz::Model::SelectSearchForm::VERSION;

=head1 NAME

Bivio::Biz::Model::SelectSearchForm - used to generate search queries

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::Biz::Model::SelectSearchForm;

=cut

=head1 EXTENDS

L<Bivio::Biz::FormModel>

=cut

use Bivio::Biz::FormModel;
@Bivio::Biz::Model::SelectSearchForm::ISA = ('Bivio::Biz::FormModel');

=head1 DESCRIPTION

C<Bivio::Biz::Model::SelectSearchForm>

=cut

#=IMPORTS
use Bivio::SQL::ListQuery;

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : hash_ref

Returns a single field.

=cut

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
	version => 1,
	visible => [{
	    name => 'search',
	    type => 'Line',
	    constraint => 'NONE',
	    form_name => Bivio::SQL::ListQuery->to_char('search'),

	}],
    });
    return;
}

#=PRIVATE SUBROUTINES

=head1 COPYRIGHT

Copyright (c) 2003 bivio Software Artisans, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
