# Copyright (c) 2000 bivio Inc.  All rights reserved.
# $Id$
package Bivio::Biz::Model::ECSubscriptionListForm;
use strict;
$Bivio::Biz::Model::ECSubscriptionListForm::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Biz::Model::ECSubscriptionListForm::VERSION;

=head1 NAME

Bivio::Biz::Model::ECSubscriptionListForm - modify subscription list

=head1 SYNOPSIS

    use Bivio::Biz::Model::ECSubscriptionListForm;

=cut

=head1 EXTENDS

L<Bivio::Biz::ListFormModel>

=cut

use Bivio::Biz::ListFormModel;
@Bivio::Biz::Model::ECSubscriptionListForm::ISA = ('Bivio::Biz::ListFormModel');

=head1 DESCRIPTION

C<Bivio::Biz::Model::ECSubscriptionListForm> is for modifying running
or expired subscriptions

=cut

#=IMPORTS

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

=head1 METHODS

=cut

=for html <a name="execute_empty_row"></a>

=head2 execute_empty_row()

Loads all form fields with the list attributes

=cut

sub execute_empty_row {
    my($self) = @_;
    my($list) = $self->get_list_model;
    # copy list values into form fields
    foreach my $field (@{$list->get_keys}) {
        $self->internal_put_field($field, $list->get($field))
                if $self->has_keys($field);
    }
    return;
}

=for html <a name="execute_if_allowed"></a>

=head2 execute_if_allowed(Bivio::Agent::Request req) : boolean

Call execute() to process this form ONLY IF user has
admin privileges.

=cut

sub execute_if_allowed {
    my($proto, $req) = @_;
    return 0 unless $req->can_user_execute_task(
            Bivio::Agent::TaskId::CLUB_ADMIN_SUBSCRIBE_ACCOUNT_SYNC());
    return $proto->execute($req);
}

=for html <a name="execute_ok_row"></a>

=head2 execute_ok_row()

Changes I<renewal_method> or I<renewal_period> fields if the
user modifies it.

=cut

sub execute_ok_row {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    my($properties) = $self->internal_get;
    my($list) = $self->get_list_model;
    my($req) = $self->get_request;

    if ($properties->{'ECSubscription.renewal_method'}
            != $list->get('ECSubscription.renewal_method')
           || $properties->{'ECSubscription.renewal_period'}
            != $list->get('ECSubscription.renewal_period')) {
        my($subscription) = $list->get_model('ECSubscription');
        $subscription->update({
            renewal_method => $properties->{'ECSubscription.renewal_method'},
            renewal_period => $properties->{'ECSubscription.renewal_period'},
        });
    }
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
	list_class => 'ECSubscriptionList',
	visible => [
	    {
                name => 'ECSubscription.renewal_method',
		in_list => 1,
		constraint => 'NOT_ZERO_ENUM',
	    },
	    {
                name => 'ECSubscription.renewal_period',
		in_list => 1,
		constraint => 'NOT_ZERO_ENUM',
	    },
        ],
    };
    return $self->merge_initialize_info(
	    $self->SUPER::internal_initialize, $info);
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2000 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
