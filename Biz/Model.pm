# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::Model;
use strict;
use Bivio::Biz::Status();
$Bivio::Biz::Model::VERSION = sprintf('%d.%02d', q$Revision$ =~ /+/g);

=head1 NAME

Bivio::Biz::Model - a business object

=head1 SYNOPSIS

    use Bivio::Biz::Model;
    Bivio::Biz::Model->new();

=cut

@Bivio::Biz::Model::ISA = qw(Bivio::UNIVERSAL);

=head1 DESCRIPTION

C<Bivio::Biz::Model>

=cut

=head1 CONSTANTS

=cut

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(string name) : Bivio::Biz::Model

Creates a new model with the specified class name.

=cut

sub new {
    my($self, $name) = &Bivio::UNIVERSAL::new(@_);
    $self->{$_PACKAGE} = {
	name => $name,
	status => Bivio::Biz::Status->new()
    };
    return $self;
}

=head1 METHODS

=cut

=for html <a name="find"></a>

=head2 abstract find(FindParams p) : boolean

Loads the model using values from the specified FindParams.
Returns 1 if successful, or 0 if no data was loaded.

=cut

sub find {
    die("abstract method");
}

=for html <a name="get_action"></a>

=head2 get_action(string name) : Action

Returns the named action or undef if no action exists for
that name.

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

Returns the current status of the model.

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
