# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::FindParams;
use strict;
$Bivio::Biz::FindParams::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Biz::FindParams - model find parameters

=head1 SYNOPSIS

    use Bivio::Biz::FindParams;
    Bivio::Biz::FindParams->new();

=cut

use Bivio::UNIVERSAL;
@Bivio::Biz::FindParams::ISA = qw(Bivio::UNIVERSAL);

=head1 DESCRIPTION

C<Bivio::Biz::FindParams> provides a useful wrapper around a hash of values
used when invoking Model.find(). from_string() and to_string() convert to
and from the URI format.

=cut

=head1 CONSTANTS

=cut

#=IMPORTS
use Bivio::IO::Trace;

#=VARIABLES
use vars qw($_TRACE);
Bivio::IO::Trace->register;
my($_PACKAGE) = __PACKAGE__;

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::Biz::FindParams

Creates an empty finder.

=cut

=head2 static new(hash map) : Bivio::Biz::FindParams

Creates a finder with the specified map. The constructor doesn't copy
the map, so don't modify the hash after invoking this.

=cut


sub new {
    my($proto, $map) = @_;
    my($self) = &Bivio::UNIVERSAL::new($proto);
    $self->{$_PACKAGE} = {
	map => $map || {}
    };
    return $self;
}

=for html <a name="from_string"></a>

=head2 static from_string(string uri_value) : Bivio::Bizz::FindParams

Creates a finder from the uri string format. The format should be:
[mf=]<key>'('<value>')'{','<key>'('<value>')'}

=cut

sub from_string {
    my($proto, $uri_value) = @_;

    #DANGER: this won't work if there are ','  characters
    #        embedded in the search values. '(' ')' are handled OK.

    my($map) = {};

    # remove optional 'mf='
    $uri_value =~ s/^mf=//;

    foreach (split(',', $uri_value)) {

	# matches xxx(yyy)
	if (/^(\w+)\((.*)\)$/) {
	    $map->{$1} = $2;
	}
    }
    return $proto->new($map);
}

=head1 METHODS

=cut

=for html <a name="clear"></a>

=head2 clear()

Removes all the parameters.

=cut

sub clear {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};

    #pjm: how to remove all elements without creating a new one?
    $fields->{map} = {};
}

=for html <a name="clone"></a>

=head2 clone() : Bivio::Biz::FindParams

Creates a duplicate copy of this FindParams.

=cut

sub clone {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};

    # copy the hash
    my(%map) = %{$fields->{map}};
    return $self->new(\%map);
}

=for html <a name="get"></a>

=head2 get(string key) : string

Returns the named value.

=cut

sub get {
    my($self, $key) = @_;
    my($fields) = $self->{$_PACKAGE};
    return $fields->{map}->{$key};
}

=for html <a name="has_keys"></a>

=head2 has_keys(string key, string key2, ...) : boolean

Returns 1 if the named keys exist, otherwise 0.

=cut

sub has_keys {
    my($self, @keys) = @_;
    my($fields) = $self->{$_PACKAGE};
    my($map) = $fields->{map};

    foreach (@keys) {
	return 0 if (! exists($map->{$_}));
    }
    return 1;
}

=for html <a name="is_empty"></a>

=head2 is_empty() : boolean

Returns whether any parameters are specified.

=cut

sub is_empty {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};

    return ! %{$fields->{map}};
}

=for html <a name="put"></a>

=head2 put(string key, string value)

Adds or replaces the named value.

=cut

sub put {
    my($self, $key, $value) = @_;
    my($fields) = $self->{$_PACKAGE};
    $fields->{map}->{$key} = $value;
}

=for html <a name="remove"></a>

=head2 remove(string key)

Removes the named value from the parameters.

=cut

sub remove {
    my($self, $key) = @_;
    my($fields) = $self->{$_PACKAGE};
    delete($fields->{map}->{$key});
}

=for html <a name="to_string"></a>

=head2 to_string() : string

Overrides Bivio::Universal::to_string() to return the URI value. See
from_string() for the format.

=cut

sub to_string {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};

    my($uri_value) = '';
    my($map) = $fields->{map};

    foreach (keys(%$map)) {
	$uri_value .= $_.'('.$map->{$_}.'),';
    }
    # remove extra ','
    chop($uri_value);

    $uri_value = 'mf='.$uri_value if $uri_value;

    return $uri_value;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
