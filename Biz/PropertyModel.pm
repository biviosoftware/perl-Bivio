# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::PropertyModel;
use strict;
$Bivio::Biz::Model::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Biz::PropertyModel - An abstract model with a set of named elements

=head1 SYNOPSIS

    use Bivio::Biz::PropertyModel;

=cut

=head1 EXTENDS

L<Bivio::Biz::Model>

=cut

use Bivio::Biz::Model;
@Bivio::Biz::PropertyModel::ISA = ('Bivio::Biz::Model');

=head1 DESCRIPTION

C<Bivio::Biz::PropertyModel> implements the data modification languange (DML)
interface to the database.  Attributes match columns one-to-one.

=cut

#=IMPORTS
use Bivio::Die;
use Bivio::DieCode;
use Bivio::SQL::PropertySupport;
use Carp ();

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="create"></a>

=head2 create(hash_ref new_values)

Creates a new model in the database with the specified values. After creation,
this instance takes ownership of I<new_values>.  Dies on error.

=cut

sub create {
    my($self, $new_values) = @_;
    my($sql_support) = $self->internal_get_sql_support;
    # Make sure all columns are defined
    my($n);
    foreach $n (@{$sql_support->get('column_names')}) {
	$new_values->{$n} = undef unless exists($new_values->{$n});
    }
    $sql_support->create($new_values, $self);
    $self->internal_put($new_values);
    my($req) = $self->unsafe_get_request;
    $req->put(ref($self), $self) if $req;
    return;
}

=for html <a name="delete"></a>

=head2 delete()

Deletes the current model from the database.   Dies on error.

=cut

sub delete {
    my($self) = @_;
    $self->internal_get_sql_support->delete($self->internal_get, $self);
    return;
}

=for html <a name="internal_initialize_sql_support"></a>

=head2 static internal_initialize_sql_support() : Bivio::SQL::Support

Returns the L<Bivio::SQL::PropertySupport|Bivio::SQL::PropertySupport>
for this class.  Calls L<internal_initialize|"internal_initialize">
to get the hash_ref to initialize the sql support instance.

Dynamically overrides L<unsafe_load|"unsafe_load"> for models which don't have
an C<auth_id>.  This makes the code in unsafe_load simpler which means there
are fewer errors and security holes.

=cut

sub internal_initialize_sql_support {
    my($proto) = @_;
    my($sql_support) =  Bivio::SQL::PropertySupport->new(
	    $proto->internal_initialize);
    unless ($sql_support->unsafe_get('auth_id')) {
	my($pkg) = ref($proto) || $proto;
	eval "
	    package $pkg;
            sub unsafe_load {
		Carp::croak('no query arguments') unless int(\@_) > 1;
		return shift->unauth_load(\@_);
	    }
	    1;
	" || die("$@");
    }
    return $sql_support;
}

=for html <a name="load"></a>

=head2 load(hash query)

Loads the model or dies if not found or other error.
Subclasses shouldn't override this method.

=cut

sub load {
    my($self) = shift;
    $self->unsafe_load(@_) && return;
    $self->die(Bivio::DieCode::NOT_FOUND(), {@_}, caller);
}

=for html <a name="unauth_load"></a>

=head2 unauth_load(hash query) : boolean

Loads the model as with L<unsafe_load|"unsafe_load">.  However, does
not insert security realm into query params.  Use this when you
B<are certain> there are no security issues involved with loading
the date.

On success, saves model in request and returns true.

Returns false if not found.  Dies on any other errors.

Subclasses should override this method if there model doesn't match
the usual property model.  L<unsafe_load|"unsafe_load"> and
L<load|"load"> call this method.

=cut

sub unauth_load {
    my($self, %query) = @_;
    # Don't bother checking query.  Will kick back if empty.
    my($values) = $self->internal_get_sql_support->unsafe_load(\%query, $self);
    return 0 unless $values;
    $self->internal_put($values);
    # If found, put a reference to this model in request
    my($req) = $self->unsafe_get_request;
    $req->put(ref($self), $self) if $req;
    return 1;
}

=for html <a name="unsafe_load"></a>

=head2 unsafe_load(hash query) : boolean

Loads the model.  On success, saves model in request and returns true.

Returns false if not found.  Dies on all other errors.

Subclasses shouldn't override this method.

B<This method will be dynamically overridden.  See
L<internal_initialize_sql_support|"internal_initialize_sql_support">.

=cut

sub unsafe_load {
    my($self) = shift;
    Carp::croak('no query arguments') unless @_;

    # Ensure we are only getting data from the realm we are authorized
    # to operate in.
    my($sql_support) = $self->internal_get_sql_support;
    my($k) = $sql_support->get('auth_id')->{name};
    my($v) = $self->get_request->get('auth_id');
    # Will override existing value for auth_id if any
    return $self->unauth_load(@_, $k => $v);
}

=for html <a name="update"></a>

=head2 update(hash_ref new_values) : boolean

Updates the current model's values.
NOTE: find should be called prior to an update.

=cut

sub update {
    my($self, $new_values) = @_;
    my($properties) = $self->internal_get;
    $self->internal_get_sql_support->update($properties, $new_values, $self);
    my($n);
    foreach $n (keys(%$new_values)) {
	$properties->{$n} =  $new_values->{$n};
    }
    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
