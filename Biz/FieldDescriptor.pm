# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::FieldDescriptor;
use strict;
$Bivio::Biz::FieldDescriptor::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Biz::FieldDescriptor - A type descriptor for model properties.

=head1 SYNOPSIS

    use Bivio::Biz::FieldDescriptor;
    my($fd) = Bivio::Biz::FieldDescriptor->lookup('STRING', 256);

=cut

use Bivio::UNIVERSAL;
@Bivio::Biz::FieldDescriptor::ISA = qw(Bivio::UNIVERSAL);

=head1 DESCRIPTION

C<Bivio::Biz::FieldDescriptor> describes the type of a piece of data,
ie date, string, currency, ...

=cut

=head1 CONSTANTS

=cut

=for html <a name="BOOLEAN"></a>

=head2 BOOLEAN : int

Boolean type.

=cut

sub BOOLEAN {
    return 1;
}

=for html <a name="CURRENCY"></a>

=head2 CURRENCY : int

Currency type.

=cut

sub CURRENCY {
    return BOOLEAN + 1;
}

=for html <a name="DATE"></a>

=head2 DATE : int

Date type.

=cut

sub DATE {
    return CURRENCY() + 1;
}

=for html <a name="EMAIL_REF"></a>

=head2 EMAIL_REF : int

An email reference compound type. An email ref is made up of
(name, address, subject) parts.

=cut

sub EMAIL_REF {
    return DATE() + 1;
}

=for html <a name="EMAIL"></a>

=head2 EMAIL : int

Email address type.

=cut

sub EMAIL {
    return EMAIL_REF() + 1;
}

=for html <a name="GENDER"></a>

=head2 GENDER : int

Gender type.

=cut

sub GENDER {
    return EMAIL() + 1;
}

=for html <a name="HTML_REF"></a>

=head2 HTML_REF : int

An HTML reference compound type. An html ref is made up of (link, text) parts.

=cut

sub HTML_REF {
    return GENDER() + 1;
}

=for html <a name="MODEL_REF"></a>

=head2 MODEL_REF : int

A model reference compound type. A model ref is made up of (id, text) parts.

=cut

sub MODEL_REF {
    return HTML_REF() + 1;
}

=for html <a name="NUMBER"></a>

=head2 NUMBER : int

Numeric type.

=cut

sub NUMBER {
    return MODEL_REF() + 1;
}

=for html <a name="PASSWORD"></a>

=head2 PASSWORD : int

Password type.

=cut

sub PASSWORD {
    return NUMBER() + 1;
}

=for html <a name="ROLE"></a>

=head2 ROLE : int

Role type.

=cut

sub ROLE {
    return PASSWORD() + 1;
}

=for html <a name="STRING"></a>

=head2 STRING : int

String type.

=cut

sub STRING {
    return ROLE() + 1;
}

=for html <a name="USER_FULL_NAME"></a>

=head2 USER_FULL_NAME : int

Full name type.

=cut

sub USER_FULL_NAME {
    return STRING() + 1;
}

#=IMPORTS
use Bivio::IO::Trace;
use Carp();

#=VARIABLES
use vars qw($_TRACE);
Bivio::IO::Trace->register;
my($_PACKAGE) = __PACKAGE__;
my(%_CACHE);

=head1 FACTORIES

=cut

=for html <a name="lookup"></a>

=head2 static lookup(string type_name) : FieldDescriptor

Returns a new or cached FieldDescriptor with the specified type.

=head2 static lookup(string type_name, int size) : FieldDescriptor

Returns a new or cached FieldDescriptor with the specified type and
field size

=head2 static lookup(string type_name, int size, int decimal_digits) : FieldDescriptor

Returns a new or cached FieldDescriptor with the specified type, field size,
and decimal digits.

=cut

sub lookup {
    my($proto, $type_name, $size, $decimal_digits) = @_;

    # lookup named constant, makes code look nicer
    my($type) = eval("$type_name()");
    $type || Carp::croak("invalid type $type_name");

    my($cache_key) = $type;
    $cache_key .= '_'.$size if $size;
    $cache_key .= '_'.$decimal_digits if $decimal_digits;

    my($result) = $_CACHE{$cache_key};

    if (! $result) {
	$result = &_new($proto, $type, $size, $decimal_digits);
	$_CACHE{$cache_key} = $result;
    }
    return $result;
}

=head1 METHODS

=cut

=for html <a name="get_decimal_digits"></a>

=head2 get_decimal_digits() : int

Returns the number of decimal digits the data type uses. This value is
undefined for non numeric types.

=cut

sub get_decimal_digits {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    return $fields->{decimal_digits};
}

=for html <a name="get_size"></a>

=head2 get_size() : int

Returns the field size of the data type. This value is undefined for
compound types.

=cut

sub get_size {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    return $fields->{size};
}

=for html <a name="get_type"></a>

=head2 get_type() : int

Returns the field type. See the constants section for possible
values.

=cut

sub get_type {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    return $fields->{type};
}

#=PRIVATE METHODS

# static _new(int type, int size, int decimal_digits) : Bivio::Biz::FieldDescriptor
#
# Creates a new FieldDescriptor with the specified type, and optional
# size and decimal digits.

sub _new {
    my($proto, $type, $size, $decimal_digits) = @_;
    my($self) = &Bivio::UNIVERSAL::new($proto);
    $self->{$_PACKAGE} = {
	type => $type,
	size => $size,
	decimal_digits => $decimal_digits
    };
    return $self;
}

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
