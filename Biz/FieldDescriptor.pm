# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::FieldDescriptor;
use strict;
use Bivio::UNIVERSAL();
$Bivio::Biz::FieldDescriptor::VERSION = sprintf('%d.%02d', q$Revision$ =~ /+/g);

=head1 NAME

Bivio::Biz::FieldDescriptor - A type descriptor for model properties.

=head1 SYNOPSIS

    use Bivio::Biz::FieldDescriptor;
    Bivio::Biz::FieldDescriptor->new();

=cut

@Bivio::Biz::FieldDescriptor::ISA = qw(Bivio::UNIVERSAL);

=head1 DESCRIPTION

C<Bivio::Biz::FieldDescriptor>

=cut

=head1 CONSTANTS


=cut

=for html <a name="BOOLEAN"></a>

=head2 BOOLEAN : int

Boolean type.

=cut

sub BOOLEAN {
    return 0;
}

=for html <a name="CURRENCY"></a>

=head2 CURRENCY : string

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

An email reference compound type.

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

An HTML reference compound type.

=cut

sub HTML_REF {
    return GENDER() + 1;
}

=for html <a name="MODEL_REF"></a>

=head2 MODEL_REF : int

A model reference compound type.

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

=for html <a name="ROLE"></a>

=head2 ROLE : int

Role type.

=cut

sub ROLE {
    return NUMBER() + 1;
}

=for html <a name="STRING"></a>

=head2 STRING : int

String type.

=cut

sub STRING {
    return ROLE() + 1;
}

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;
my(%_CACHE);

=head1 FACTORIES

=cut

=for html <a name="lookup"></a>

=head2 static lookup(int type, float length) : FieldDescriptor

Returns a new or cached FieldDescriptor with the specified type
and length.

=cut

sub lookup {
    my($proto, $type, $length) = @_;
    my($cache_key) = $type.'_'.$length;
    my($result) = $_CACHE{$cache_key};

    if (! $result) {
	$result = &_new($proto, $type, $length);
	$_CACHE{$cache_key} = $result;
    }
    return $result;
}

=head1 METHODS

=cut

=for html <a name="get_length"></a>

=head2 get_length() : float

Returns the maximum length of the field. For integer types, this is
always a whole number. For floating point types, the decimal indicates
the number of digits after the point - ex. 15.2 has 2 decimal places.

=cut

sub get_length {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    return $fields->{length};
}

=for html <a name="getype"></a>

=head2 getype() : int

Returns the field type. See the constants section for possible
values.

=cut

sub get_type {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    return $fields->{type};
}

#=PRIVATE METHODS

# static _new(int type, string name, float length) : Bivio::Biz::FieldDescriptor
#
# Creates a new FieldDescriptor with the specified type and length. A
# negative length indicates that the field is compound, or the length
# is unknown.

sub _new {
    my($proto, $type, $length) = @_;
    my($self) = &Bivio::UNIVERSAL::new($proto);
    $self->{$_PACKAGE} = {
	type => $type,
	length => $length
    };
    return $self;
}

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
