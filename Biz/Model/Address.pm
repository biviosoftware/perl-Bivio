# Copyright (c) 1999 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Biz::Model::Address;
use strict;
$Bivio::Biz::Model::Address::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Biz::Model::Address::VERSION;

=head1 NAME

Bivio::Biz::Model::Address - interface to address_t SQL table

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::Biz::Model::Address;
    Bivio::Biz::Model::Address->new($req);

=cut

=head1 EXTENDS

L<Bivio::Biz::Model::LocationBase>

=cut

use Bivio::Biz::Model::LocationBase;
@Bivio::Biz::Model::Address::ISA = qw(Bivio::Biz::Model::LocationBase);

=head1 DESCRIPTION

C<Bivio::Biz::Model::Address> is the create, read, update,
and delete interface to the C<address_t> table.

=cut

#=IMPORTS

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="execute_load_home"></a>

=head2 static execute_load_home(Bivio::Agent::Request req) : boolean

Loads the home address for the current realm.

=cut

sub execute_load_home {
    my($proto, $req) = @_;
    $proto->new($req)->load({
	location => Bivio::Type::Location->HOME,
    });
    return 0;
}

=for html <a name="format"></a>

=head2 format() : string

=head2 static format(Bivio::Biz::Model model, string model_prefix) : string

Returns the street1, street2, city, state, zip, and country as
a single string (with embedded newlines).

In the second form, I<list_model> is used to get the values, not I<self>.
List Models can declare a method of the form:

    sub format_address {
	my($self) = shift;
	Bivio::Biz::Model::Address->format($self, 'Address.');
    }

Always returns a valid (defined) string, but may be zero length.

=cut

sub format {
    my($self, $model, $model_prefix) = shift->internal_get_target(@_);
    my($m, $p) = ($model, $model_prefix);
    my($sep) = ', ';
    my($csz) = undef;
    foreach my $n ($m->unsafe_get($p.'city', $p.'state', $p.'zip')) {
	$csz .= $n.$sep if defined($n);
	$sep = '  ';
    }
    chop($csz), chop($csz) if defined($csz);
    my($res) = '';
    my(@f) = $m->unsafe_get($p.'street1', $p.'street2', $p.'country');
    splice(@f, 2, 0, $csz);
    foreach my $n (@f) {
	$res .= $n."\n" if defined($n);
    }
    chop($res);
    return $res;
}

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : hash_ref

B<FOR INTERNAL USE ONLY>

=cut

sub internal_initialize {
    return {
	version => 1,
	table_name => 'address_t',
	columns => {
            realm_id => ['RealmOwner.realm_id', 'PRIMARY_KEY'],
	    location => ['Location', 'PRIMARY_KEY'],
	    street1 => ['Line', 'NONE'],
	    street2 => ['Line', 'NONE'],
	    city => ['Name', 'NONE'],
	    state => ['Name', 'NONE'],
	    zip => ['Name', 'NONE'],
	    country => ['Country', 'NONE'],
        },
	auth_id => 'realm_id',
    };
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio Software, Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
