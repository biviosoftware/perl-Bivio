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
    $model->load(id => 100);

=cut

use Bivio::UNIVERSAL;
@Bivio::Biz::Model::ISA = qw(Bivio::UNIVERSAL);

=head1 DESCRIPTION

C<Bivio::Biz::Model> is more interface than implementation, it provides
a common set of methods for L<Bivio::Biz::PropertyModel> and
L<Bivio::Biz::ListModel>.

=cut

#=IMPORTS

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(Bivio::Agent::Request req) : Bivio::Biz::Model

Creates a new model.

=cut

sub new {
    my($proto, $req) = @_;
    my($self) = &Bivio::UNIVERSAL::new(@_);
    return $self;
}

=head1 METHODS

=cut

=for html <a name="die"></a>

=head2 static die(Bivio::Type::Enum code, hash_ref attrs, string package, string file, int line)

Terminate the I<model> as entity and request in I<attrs> with a specific code.

=cut

sub die {
    my($self, $code, $attrs, $package, $file, $line) = @_;
    $package ||= (caller)[0];
    $file ||= (caller)[1];
    $line ||= (caller)[2];
    $attrs ||= {};
    ref($attrs) eq 'HASH' || ($attrs = {attrs => $attrs});
    $attrs->{entity} = $self;
    $attrs->{request} = $self->get_request;
    Bivio::Die->die($code, $attrs, $package, $file, $line);
}

=for html <a name="find"></a>

=head2 abstract load(string key, string value, ...) : boolean

Loads the model using values from the specified search parameters.
Returns 1 if successful, or 0 if no data was loaded.

=cut

sub load {
    CORE::die("abstract method");
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
