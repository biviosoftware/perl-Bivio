# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::TestModel;
use strict;
$Bivio::Biz::TestModel::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Biz::TestModel - a parameterized testing model

=head1 SYNOPSIS

    use Bivio::Biz::TestModel;
    Bivio::Biz::TestModel->new();

=cut

=head1 EXTENDS

L<Bivio::Biz::Model>

=cut

use Bivio::Biz::Model;
@Bivio::Biz::TestModel::ISA = qw(Bivio::Biz::Model);

=head1 DESCRIPTION

C<Bivio::Biz::TestModel>

=cut

=head1 CONSTANTS

=cut

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(hash actions, string heading, string title) : Bivio::Biz::TestModel

Creates a testing model which exposes the specified actions.

=cut

sub new {
    my($proto, $name, $actions, $heading, $title) = @_;
    my($self) = &Bivio::Biz::Model::new($proto, $name);
    $self->{$_PACKAGE} = {
	heading => $heading,
	title => $title,
	actions => $actions
    };
    return $self;
}

=head1 METHODS

=cut

=for html <a name="find"></a>

=head2 load(FindParams fp)

This is ignored because test model has no state.

=cut

sub load {
    #NOP
}

=for html <a name="get_action"></a>

=head2 get_action(string name) : Action

Returns the named action

=cut

sub get_action {
    my($self, $name) = @_;
    my($fields) = $self->{$_PACKAGE};
    return $fields->{actions}->{$name};
}

=for html <a name="get_actions"></a>

=head2 get_actions() : hash

Returns all the actions associated with this model.

=cut

sub get_actions {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    return $fields->{actions};
}

=for html <a name="get_heading"></a>

=head2 get_heading() : string

Returns the heading.

=cut

sub get_heading {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    return $fields->{heading};
}

=for html <a name="get_title"></a>

=head2 get_title() : string

Return the title

=cut

sub get_title {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    return $fields->{title};
}


#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
