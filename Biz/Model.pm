# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::Model;
use strict;
$Bivio::Biz::Model::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Biz::Model - a business object

=head1 SYNOPSIS

    my($model) = ...;

    # load a model with data
    $model->find(Bivio::Biz::FindParams->new({id => 100}));

    # execute an action
    $model->get_action('<action-name>')->execute($model, $req);

    # check for errors
    if (! $model->get_status()->is_OK()) {
        foreach (@{$model->get_status()->get_errors())) {
            print($_.get_message());
        }
    }

=cut

use Bivio::UNIVERSAL;
@Bivio::Biz::Model::ISA = qw(Bivio::UNIVERSAL);

=head1 DESCRIPTION

C<Bivio::Biz::Model> is more interface than implementation, it provides
a common set of methods for L<Bivio::Biz::PropertyModel> and
L<Bivio::Biz::PropertyModel>. Models provide methods to access display
heading and titles as well as lookup for L<Bivio::Biz::Action>s. During
action invocation, a model may be set into an error state. Check for
errors using the L<Bivio::Biz::Status> instance returned from
L<Bivio::Biz::Model/"get_status">.

=cut

#=IMPORTS
use Bivio::Biz::Status;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(string name) : Bivio::Biz::Model

Creates a new model with the specified class name. The name should be
unique across all models types.

=cut

sub new {
    my($proto, $name) = @_;
    my($self) = &Bivio::UNIVERSAL::new(@_);
    $self->{$_PACKAGE} = {
	name => $name,
	status => Bivio::Biz::Status->new()
    };
    return $self;
}

=head1 METHODS

=cut

=for html <a name="find"></a>

=head2 abstract find(FindParams fp) : boolean

Loads the model using values from the specified search parameters.
Returns 1 if successful, or 0 if no data was loaded. See
L<Bivio::Biz::FindParams>.

=cut

sub find {
    die("abstract method");
}

=for html <a name="get_action"></a>

=head2 get_action(string name) : Action

Returns the named action or undef if no action exists for
that name. See L<Bivio::Biz::Action>.

=cut

sub get_action {
    die("abstract method");
}

=for html <a name="get_actions_names"></a>

=head2 abstract get_actions_names() : array

Returns an array of model actions names.

=cut

sub get_actions_names {
    die("abstract method");
}


=for html <a name="get_heading"></a>

=head2 abstract get_heading() : string

Returns a suitable heading for the model.

=cut

sub get_heading {
    die("abstract method");
}

=for html <a name="get_name"></a>

=head2 get_name() : string

Returns the model's name.

=cut

sub get_name {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    return $fields->{name};
}

=for html <a name="get_status"></a>

=head2 get_status() : Status

Returns the current status of the model. See L<Bivio::Biz::Status>.

=cut

sub get_status {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    return $fields->{status};
}

=for html <a name="get_title"></a>

=head2 abstract get_title() : string

Returns a suitable title of the model.

=cut

sub get_title {
    die("abstract method");
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
