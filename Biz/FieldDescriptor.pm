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

=for html <a name="BOOLEAN_T"></a>

=head2 BOOLEAN_T : int

Boolean type.

=cut

sub BOOLEAN_T {
    return 0;
}

=for html <a name="CURRENCY_T"></a>

=head2 CURRENCY_T : string

Currency type.

=cut

sub CURRENCY_T {
    return BOOLEAN_T + 1;
}

=for html <a name="DATE_T"></a>

=head2 DATE_T : int

Date type.

=cut

sub DATE_T {
    return CURRENCY_T() + 1;
}

=for html <a name="EMAIL_REF_T"></a>

=head2 EMAIL_REF_T : int

An email reference compound type.

=cut

sub EMAIL_REF_T {
    return DATE_T() + 1;
}

=for html <a name="EMAIL_T"></a>

=head2 EMAIL_T : int

Email address type.

=cut

sub EMAIL_T {
    return EMAIL_REF_T() + 1;
}

=for html <a name="GENDER_T"></a>

=head2 GENDER_T : int

Gender type.

=cut

sub GENDER_T {
    return EMAIL_T() + 1;
}

=for html <a name="HTML_REF_T"></a>

=head2 HTML_REF_T : int

An HTML reference compound type.

=cut

sub HTML_REF_T {
    return GENDER_T() + 1;
}

=for html <a name="MODEL_REF_T"></a>

=head2 MODEL_REF_T : int

A model reference compound type.

=cut

sub MODEL_REF_T {
    return HTML_REF_T() + 1;
}

=for html <a name="NUMBER_T"></a>

=head2 NUMBER_T : int

Numeric type.

=cut

sub NUMBER_T {
    return MODEL_REF_T() + 1;
}

=for html <a name="ROLE_T"></a>

=head2 ROLE_T : int

Role type.

=cut

sub ROLE_T {
    return NUMBER_T() + 1;
}

=for html <a name="STRING_T"></a>

=head2 STRING_T : int

String type.

=cut

sub STRING_T {
    return ROLE_T() + 1;
}

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

my($_BOOLEAN) = Bivio::Biz::FieldDescriptor->new(BOOLEAN_T(), 1);
my($_DATE) = Bivio::Biz::FieldDescriptor->new(DATE_T(), 10);
my($_EMAIL) = Bivio::Biz::FieldDescriptor->new(EMAIL_T(), 255);
my($_EMAIL_REF) = Bivio::Biz::FieldDescriptor->new(EMAIL_REF_T(), -1);
my($_GENDER) = Bivio::Biz::FieldDescriptor->new(GENDER_T(), 1);
my($_HTML_REF) = Bivio::Biz::FieldDescriptor->new(HTML_REF_T(), -1);
my($_MODEL_REF) = Bivio::Biz::FieldDescriptor->new(MODEL_REF_T(), -1);
my($_NUMBER3) = Bivio::Biz::FieldDescriptor->new(NUMBER_T(), 3);
my($_NUMBER4) = Bivio::Biz::FieldDescriptor->new(NUMBER_T(), 4);
my($_NUMBER16) = Bivio::Biz::FieldDescriptor->new(NUMBER_T(), 16);
my($_ROLE) = Bivio::Biz::FieldDescriptor->new(ROLE_T(), 2);
my($_STRING32) = Bivio::Biz::FieldDescriptor->new(STRING_T(), 32);
my($_STRING64) = Bivio::Biz::FieldDescriptor->new(STRING_T(), 64);
my($_STRING128) = Bivio::Biz::FieldDescriptor->new(STRING_T(), 128);
my($_STRING256) = Bivio::Biz::FieldDescriptor->new(STRING_T(), 256);
my($_STRING1024) = Bivio::Biz::FieldDescriptor->new(STRING_T(), 1024);

=head1 INSTANCES

BOOLEAN
DATE
EMAIL
EMAIL_REF
GENDER
HTML_REF
MODEL_REF
NUMBER3
NUMBER4
NUMBER16
ROLE
STRING32
STRING64
STRING128
STRING256
STRING1024

=cut

sub BOOLEAN {
    return $_BOOLEAN;
}

sub DATE {
    return $_DATE;
}

sub EMAIL {
    return $_EMAIL;
}

sub EMAIL_REF {
    return $_EMAIL_REF;
}

sub GENDER {
    return $_GENDER;
}

sub HTML_REF {
    return $_HTML_REF;
}

sub MODEL_REF {
    return $_MODEL_REF;
}

sub NUMBER3 {
    return $_NUMBER3;
}

sub NUMBER4 {
    return $_NUMBER4;
}

sub NUMBER16 {
    return $_NUMBER16;
}

sub ROLE {
    return $_ROLE;
}

sub STRING32 {
    return $_STRING32;
}

sub STRING64 {
    return $_STRING64;
}

sub STRING128 {
    return $_STRING128;
}

sub STRING256 {
    return $_STRING256;
}

sub STRING1024 {
    return $_STRING1024;
}


=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(int type, string name, float length) : Bivio::Biz::FieldDescriptor

Creates a new FieldDescriptor with the specified type and length. A negative
length indicates that the field is compound, or the length is unknown.

=cut

sub new {
    my($proto, $type, $length) = @_;
    my($self) = &Bivio::UNIVERSAL::new($proto);
    $self->{$_PACKAGE} = {
	type => $type,
	length => $length
    };
    return $self;
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

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
