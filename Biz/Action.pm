# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::Action;
use strict;
$Bivio::Biz::Action::VERSION = sprintf('%d.%02d', q$Revision$ =~ /+/g);

=head1 NAME

Bivio::Biz::Action - An abstract model action.

=head1 SYNOPSIS

    use Bivio::Biz::Action;
    Bivio::Biz::Action->new();

=cut

@Bivio::Biz::Action::ISA = qw(Bivio::UNIVERSAL);

=head1 DESCRIPTION

C<Bivio::Biz::Action> describes a interaction which can be performed
on a Model. Models expose the actions which may be performed against
themselves through get_actions(). Actions may be done, and undone. At
any time it may not be possible to (un)execute an action depending on the
state of the model it relates to.

=cut

=head1 CONSTANTS

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

=head2 can_execute(UNIVERSAL target) : boolean

Returns 1 if the action can be executed on the specified target. The Action
base class always returns 0.

=cut

sub can_execute {
    return 0;
}

=for html <a name="can_unexecute"></a>

=head2 can_unexecute(UNIVERSAL target) : boolean

Returns 1 if the action can be undone on the specified target. The Action
base class always returns 0.

=cut

sub can_unexecute {
    return 0;
}

=for html <a name="execute"></a>

=head2 abstract execute(UNIVERSAL target, Request req) : boolean

Call this method to perform the action on the specified target,
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

=head2 abstract unexecute(UNIVERSAL target, Request req) : boolean

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
