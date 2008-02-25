# Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::AdmUserList;
use strict;
$Bivio::Biz::Model::AdmUserList::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Biz::Model::AdmUserList::VERSION;

=head1 NAME

Bivio::Biz::Model::AdmUserList - sortable list of all users

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::Biz::Model::AdmUserList;

=cut

=head1 EXTENDS

L<Bivio::Biz::ListModel>

=cut

use Bivio::Biz::ListModel;
@Bivio::Biz::Model::AdmUserList::ISA = ('Bivio::Biz::ListModel');

=head1 DESCRIPTION

C<Bivio::Biz::Model::AdmUserList> is a sortable list of all users.

=cut

=head1 CONSTANTS

=cut

=for html <a name="LOAD_ALL_SEARCH_STRING"></a>

=head2 LOAD_ALL_SEARCH_STRING : string

Returns string used for load all.

=cut

sub LOAD_ALL_SEARCH_STRING {
    return 'All';
}

#=IMPORTS

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="internal_post_load_row"></a>

=head2 internal_post_load_row(hash_ref row) : boolean

Format display_name.

=cut

sub internal_post_load_row {
    my($self, $row) = @_;
    $row->{display_name} = Bivio::Biz::Model->get_instance('User')
        ->concat_last_first_middle(
	    @{$row}{map({"User.$_"} qw(last_name first_name middle_name))});
    return 1;
}

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : hash_ref

Returns config

=cut

sub internal_initialize {
    return {
	version => 1,
	can_iterate => 1,
	order_by => [
	    'User.last_name',
	    'User.first_name',
	    'User.middle_name',
	],
        primary_key => ['User.user_id'],
	other => [
	    {
		name => 'display_name',
		type => 'Line',
		constraint => 'NOT_NULL',
	    },
	],
    };
}

=for html <a name="internal_prepare_statement"></a>

=head2 internal_prepare_statement(Bivio::SQL::Statement stmt, Bivio::SQL::ListQuery query)

Narrow the search of users by last name.

=cut

sub internal_prepare_statement {
    my($self, $stmt, $query) = @_;
    my($search) = $query->get('search');

    return unless $search;

    if ($search eq $self->LOAD_ALL_SEARCH_STRING) {
#TODO: Why is this here?
	$query->put(count => $self->LOAD_ALL_SIZE);
    }
    elsif ($search =~ /^\d+$/) {
	$stmt->where(['User.user_id', [$search]]);
    }
    else {
	$stmt->where($stmt->LIKE('User.last_name_sort', lc($search) . '%'));
    }

    return;
}

#=PRIVATE SUBROUTINES

=head1 COPYRIGHT

Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
