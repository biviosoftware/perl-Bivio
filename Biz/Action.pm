# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::Action;
use strict;
$Bivio::Biz::Action::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Biz::Action - An abstract model action.

=cut

use Bivio::UNIVERSAL;
@Bivio::Biz::Action::ISA = qw(Bivio::UNIVERSAL);

=head1 DESCRIPTION

C<Bivio::Biz::Action> describes a interaction which can be performed
on a Model. Models expose the actions which may be performed against
themselves through L<Bivio::Biz::Model/"get_action">. Actions may be done,
and undone. At any time it may not be possible to (un)execute an action
depending on the state of the model it relates to. Actions can be queried
as to whether they can be performed using the L<"can_execute"> and
L<"can_unexecute">.

An action embodies a complete transactions against a model. During execution,
the action either completes successful and commits all data to storage, or
fails and rolls back changes. Actions should wrap their execution in
exception handling to properly rollback from a software crash.

Generally there will be at most one action executed when processing a
request. Actions should work with models only and not do any view
manipulation.

Actions get their execution arguments from a request by name using the
L<Bivio::Agent::Request/"get_arg"> method of Bivio::Agent::Request.

=cut

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(string name, string display_name, string description, string icon) : Bivio::Biz::Action

Creates an action with the specified name, display text, description and icon.

=cut

sub new {
    my($proto, $name, $display_name, $description, $icon) = @_;
    my($self) = &Bivio::UNIVERSAL::new($proto);
    $self->{$_PACKAGE} = {
	name => $name,
	display_name => $display_name,
	description => $description,
	icon => $icon
    };
    return $self;
}

=head1 METHODS

=cut

=for html <a name="can_execute"></a>

=head2 can_execute(Model model) : boolean

Returns 1 if the action can be executed on the specified model. The Action
base class always returns 0.

=cut

sub can_execute {
    return 0;
}

=for html <a name="can_unexecute"></a>

=head2 can_unexecute(Model model) : boolean

Returns 1 if the action can be undone on the specified model. The Action
base class always returns 0.

=cut

sub can_unexecute {
    return 0;
}

=for html <a name="execute"></a>

=head2 abstract execute(Model model, Request req) : boolean

Call this method to perform the action on the specified model,
using arguments from the specified request. Returns 1 if successful, 0
otherwise.

=cut

sub execute {
    die("abstract method");
}

=for html <a name="get_description"></a>

=head2 get_description() : string

Returns text describing the action.

=cut

sub get_description {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    return $fields->{description};
}

=for html <a name="get_display_name"></a>

=head2 get_display_name() : string

Returns the text to display for the action.

=cut

sub get_display_name {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    return $fields->{display_name};
}

=for html <a name="get_icon"></a>

=head2 get_icon() : string

Returns the icon name which represents this action.

=cut

sub get_icon {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    return $fields->{icon};
}

=for html <a name="get_name"></a>

=head2 get_name() : string

Returns the action's name.

=cut

sub get_name {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    return $fields->{name};
}

=for html <a name="unexecute"></a>

=head2 abstract unexecute(Model model, Request req) : boolean

Call this method to undo the action on the specified target,
using the arguments from the specified request. Returns 1 if successful, 0
otherwise.

=cut

sub unexecute {
    die("abstract method");
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
