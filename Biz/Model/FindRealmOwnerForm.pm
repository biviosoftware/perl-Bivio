# Copyright (c) 2000 bivio, Inc.  All rights reserved.
# $Id$
package Bivio::Biz::Model::FindRealmOwnerForm;
use strict;
$Bivio::Biz::Model::FindRealmOwnerForm::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Biz::Model::FindRealmOwnerForm - simple form for finding a realm owner

=head1 SYNOPSIS

    use Bivio::Biz::Model::FindRealmOwnerForm;

=cut

=head1 EXTENDS

L<Bivio::Biz::FormModel>

=cut

use Bivio::Biz::FormModel;
@Bivio::Biz::Model::FindRealmOwnerForm::ISA = ('Bivio::Biz::FormModel');

=head1 DESCRIPTION

C<Bivio::Biz::Model::FindRealmOwnerForm> looks up a string in the
database.

=cut

#=IMPORTS
use Bivio::Biz::Util::RealmOwner;

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="execute_input"></a>

=head2 execute_input() : boolean

Looks up search_string.

=cut

sub execute_input {
    my($self) = @_;
    my($properties) = $self->internal_get;
    my($res) = Bivio::Biz::Util::RealmOwner->find(
	    $properties->{search_string});
    $properties->{search_result} = \$res;
    $self->internal_stay_on_page;
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
	    {
		name => 'search_string',
		type => 'Line',
		constraint => 'NOT_NULL',
	    },
	    {
		name => 'search_result',
		type => 'BLOB',
		constraint => 'NONE',
	    },
	],
    };
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2000 bivio, Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
