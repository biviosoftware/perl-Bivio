# Copyright (c) 2001 bivio Inc.  All rights reserved.
# $Id$
package Bivio::Biz::Model::MembersMergeForm;
use strict;
$Bivio::Biz::Model::MembersMergeForm::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Biz::Model::MembersMergeForm::VERSION;

=head1 NAME

Bivio::Biz::Model::MembersMergeForm - Merge 2 club members

=head1 SYNOPSIS

    use Bivio::Biz::Model::MembersMergeForm;

=cut

=head1 EXTENDS

L<Bivio::Biz::FormModel>

=cut

use Bivio::Biz::FormModel;
@Bivio::Biz::Model::MembersMergeForm::ISA = ('Bivio::Biz::FormModel');

=head1 DESCRIPTION

C<Bivio::Biz::Model::MembersMergeForm>

=cut

#=IMPORTS

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

=head1 METHODS

=cut

=for html <a name="execute_empty"></a>

=head2 execute_empty() : 



=cut

=for html <a name="execute_ok"></a>

=head2 execute_ok() : 

Merges 2 users

=cut

sub execute_ok {
    my($self) = @_;
    my($req) = $self->get_request();
    my($user) = Bivio::Biz::Util::User->new->put_request($req);

    # Get the user selected coming into page
    my($list) = $req->get('Bivio::Biz::Model::ClubUserList');
    $list->set_cursor(0);

    # Figure out which type of member it is
    my($shadow_member) = undef;
    my($target) = undef;
    if ($list->is_shadow_member) {
	$shadow_member = $list->get_model('RealmOwner');
    }
    else {
	_put_error_if_transactions($self, $list);
	$target = $list->get_model('RealmOwner');
    }

    # Load RealmOwner from user selected on the page
    my($realm_owner) = Bivio::Biz::Model::RealmOwner->new($req)
	    ->unauth_load_by_id_or_name_or_die(
		    $self->get_model('RealmUser')->get('user_id'));

    # Don't care if overwrite shadow or target member...if we do there's no
    # valid target member and we'll choke in a few lines.
    if ($realm_owner->is_shadow_user) {
	$shadow_member = $realm_owner;
    }
    else {
	_put_error_if_transactions($self);
	$target = $realm_owner;
    }

    # Make sure a target and a shadow member were found
    $self->internal_put_error('Exactly one member can/must be shadow',
	    Bivio::TypeError::MERGE_FAILURE())
	    unless (defined($target) && defined($shadow_member));

#TODO remove this once form errors will display
    Bivio::Die->die("shouldn't get here")
		unless defined($target) && defined($shadow_member);
    # Merge!
    Bivio::Biz::Util::User->new->put_request($req)->merge(
	    $shadow_member, $target);
    return;
}

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : hash_ref 

B<FOR INTERNAL USE ONLY>

=cut

sub internal_initialize {
    my($self) = @_;
    my($info) = {
        version => 1,
	visible => [
	    'RealmUser.user_id',
	],
    };
    return $self->merge_initialize_info(
            $self->SUPER::internal_initialize, $info);
}


#=PRIVATE METHODS

# _put_error_if_transactions($self)
#
# _put_error_if_transactions($self, $list)
#
# User->merge will die if target has transactions...this is more friendly
# for app. user.
#
sub _put_error_if_transactions {
    my($self, $list) = @_;
    my($subject) = (defined($list)
	    ? $list
	    : $self);
    if ($subject->get_model('RealmUser')->has_transactions) {
	$self->internal_put_error('Merge target has transactions',
			Bivio::TypeError::MERGE_FAILURE());
    }
    return;
}


=head1 COPYRIGHT

Copyright (c) 2001 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
