# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::ListModel;
use strict;
$Bivio::Biz::ListModel::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Biz::ListModel - an abstract model of an SQL query and result

=head1 SYNOPSIS

=cut

=head1 EXTENDS

L<Bivio::Biz::Model>

=cut

use Bivio::Biz::Model;
@Bivio::Biz::ListModel::ISA = ('Bivio::Biz::Model');

=head1 DESCRIPTION

C<Bivio::Biz::ListModel> 

=cut

#=IMPORTS
use Bivio::SQL::ListSupport;
use Bivio::SQL::ListQuery;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;
#TODO: Move this into prefs
my($_PAGE_SIZE) = 10;


=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(Bivio::Agent::Request req) : Bivio::Biz::ListModel

Create a new ListModel associated with the request.

=cut

sub new {
    my($self) = &Bivio::Biz::Model::new(@_);
    # NOTE: fields are dynamically replaced.  See, e.g. load.
    $self->{$_PACKAGE} = {
	empty_properties => $self->internal_get,
    };
    return $self;
}

=head1 METHODS

=cut

=for html <a name="execute"></a>

=head2 static execute(Bivio::Agent::Request)

Loads a new instance of this model using the request.

=cut

sub execute {
    my($proto, $req) = @_;
    my($query) = $req->unsafe_get('query');
    $proto->new($req)->load($query ? %$query : ());
    return;
}

=for html <a name="get_result_set_size"></a>

=head2 get_result_set_size() : int

Returns the number of rows loaded.

=cut

sub get_result_set_size {
    my($rows) = shift->{$_PACKAGE}->{rows};
    Carp::croak('not loaded') unless $rows;
    return int(@$rows);
}

=for html <a name="internal_initialize_sql_support"></a>

=head2 static internal_initialize_sql_support() : Bivio::SQL::Support

Returns the L<Bivio::SQL::ListSupport|Bivio::SQL::ListSupport>
for this class.  Calls L<internal_initialize|"internal_initialize">
to get the hash_ref to initialize the sql support instance.

=cut

sub internal_initialize_sql_support {
    return Bivio::SQL::ListSupport->new(shift->internal_initialize);
}

=for html <a name="load"></a>

=head2 load(hash query)

Loads the property model from I<query> which must be a form
acceptable to L<Bivio::SQL::ListQuery|Bivio::SQL::ListQuery>.

I<auth_id> and I<count> will be added as attributes using the
values in the request.

If the load is successful, saves the model in the request.

=cut

sub load {
    my($self, %query) = @_;
    # Clear out old query
    $query{auth_id} = $self->get_request->get('auth_id');
    $query{count} = $_PAGE_SIZE;
    my($sql_support) = $self->internal_get_sql_support;
    my($list_query) = Bivio::SQL::ListQuery->new(\%query, $sql_support);
    my($rows) = $sql_support->load($list_query);
    my($empty_properties) = $self->{$_PACKAGE}->{empty_properties};
    # Easier to just replace the hash_ref
    $self->{$_PACKAGE} = {
	rows => $rows,
	cursor => -1,
	query => $list_query,
	empty_properties => $empty_properties,
    };
    $self->internal_put($empty_properties);
    $self->get_request->put(ref($self), $self);
    return;
}

=for html <a name="next_row"></a>

=head2 next_row() : boolean

Advances the cursor to the next row and sets the properties
to the new row's values.  If there are no more rows, returns
false.

B<Only returns false ONCE.  After that calls die.>

=cut

sub next_row {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    Carp::croak('no cursor') unless defined($fields->{cursor});
    if (++$fields->{cursor} >= int(@{$fields->{rows}})) {
	$fields->{cursor} = undef;
	$self->internal_put($fields->{empty_properties});
	return 0;
    }
    $self->internal_put($fields->{rows}->[$fields->{cursor}]);
    return 1;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
