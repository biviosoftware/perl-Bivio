# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::Widget;
use strict;
$Bivio::UI::Widget::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::Widget - a displayable entity

=head1 SYNOPSIS

    use Bivio::UI::Widget;
    Bivio::UI::Widget->new();

=cut

=head1 EXTENDS

L<Bivio::Collection::Attributes>

=cut

use Bivio::Collection::Attributes;
@Bivio::UI::Widget::ISA = qw(Bivio::Collection::Attributes);

=head1 DESCRIPTION

C<Bivio::UI::Widget>

=cut

=head1 CONSTANTS

=cut

#=IMPORTS

#=VARIABLES

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::UI::Widget

=cut

sub new {
    return Bivio::Collection::Attributes::new(@_);
}

=head1 METHODS

=cut

=for html <a name="get"></a>

=head2 get(string key, ...) : (string, ...)

Returns the named value(s).  If I<key> doesn't exist, checks I<parent>
attribute.  If it doesn't exist in parent(s), dies.

Use L<has_keys|"has_keys"> to test for existence.

=cut

sub get {
    my($self) = shift;
    my($values) = [];
    return wantarray ? @$values : $values->[0]
	    if _unsafe_get($self, \@_, $values);
    die("@$_: attribute(s) do not exist");
}

=for html <a name="has_keys"></a>

=head2 has_keys(string key, string key2, ...) : boolean

Returns 1 if the named keys exist, otherwise 0.  If the key
doesn't exist in the child, will check its parent.

=cut

sub has_keys {
    my($self) = shift;
    return _unsafe_get($self, \@_, []);
}

=for html <a name="unsafe_get"></a>

=head2 unsafe_get(string key, ...) : (string, ...)

Returns the named value(s).  If I<key> doesn't exist, checks I<parent>
attribute.  If it doesn't exist in parent(s), returns C<undef>.

=cut

sub unsafe_get {
    my($self) = shift;
    my($values) = [];
    _unsafe_get($self, \@_, $values);
    return wantarray ? @$values : $values->[0];
}


#=PRIVATE METHODS

# _unsafe_get(self, array_ref keys, array_ref values) : boolean
#
# Returns true if all keys could be found, else false.
# I<keys> is trimmed as values are found, so on failure, the only keys
# left are those that couldn't be found.
#
sub _unsafe_get {
    my($self, $keys, $values) = @_;
    my(@new_values) = $self->SUPER::unsafe_get(@$keys);
    my($i) = 0;
    my($j) = 0;
    while (@new_values) {
	my($v) = shift(@new_values);
	$i++ while defined($values->[$i]);
	# Leave this key in @$keys if no value returned
	$i++, $j++, next unless defined($v);
	# Find where to insert new value into @$values
	$values->[$i++] = $v;
	# Key found, so pop off list
	splice(@$keys, $j, 1);
    }
    # No more keys, all done
    return 1 unless int(@$keys);
    my($parent) = $self->SUPER::unsafe_get('parent');
    # Return failure if no parent
    return defined($parent) ? _unsafe_get($parent, $keys, $values) : 0;
}

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
