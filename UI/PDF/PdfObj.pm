# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::PDF::PdfObj;
use strict;
$Bivio::UI::PDF::PdfObj::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::PDF::PdfObj - 

=head1 SYNOPSIS

    use Bivio::UI::PDF::PdfObj;
    Bivio::UI::PDF::PdfObj->new();

=cut

use Bivio::UNIVERSAL;
@Bivio::UI::PDF::PdfObj::ISA = ('Bivio::UNIVERSAL');

=head1 DESCRIPTION

C<Bivio::UI::PDF::PdfObj>

=cut

#=IMPORTS
use Bivio::IO::Trace;
use Bivio::UI::PDF::IndirectObjRef;
use Bivio::UI::PDF::Regex;

#=VARIABLES
use vars ('$_TRACE');
Bivio::IO::Trace->register;
my($_PACKAGE) = __PACKAGE__;

my($_ARRAY_END_REGEX) = Bivio::UI::PDF::Regex::ARRAY_END_REGEX();
my($_ARRAY_START_REGEX) = Bivio::UI::PDF::Regex::ARRAY_START_REGEX();
my($_BOOLEAN_REGEX) = Bivio::UI::PDF::Regex::BOOLEAN_REGEX();
my($_DIC_START_REGEX) = Bivio::UI::PDF::Regex::DIC_START_REGEX();
my($_IGNORE_REGEX) = Bivio::UI::PDF::Regex::IGNORE_REGEX();
my($_NAME_REGEX) = Bivio::UI::PDF::Regex::NAME_REGEX();
my($_NULL_OBJ_REGEX) = Bivio::UI::PDF::Regex::NULL_OBJ_REGEX();
my($_NUMBER_REGEX) = Bivio::UI::PDF::Regex::NUMBER_REGEX();
my($_OBJ_REF_REGEX) = Bivio::UI::PDF::Regex::OBJ_REF_REGEX();
my($_STRING_START_ANGLE_REGEX) = Bivio::UI::PDF::Regex::STRING_START_ANGLE_REGEX();
my($_STRING_START_PAREN_REGEX) = Bivio::UI::PDF::Regex::STRING_START_PAREN_REGEX();


=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::UI::PDF::PdfObj



=cut

sub new {
    my($self) = Bivio::UNIVERSAL::new(@_);
    $self->{$_PACKAGE} = {};
    return $self;
}

=head1 METHODS

=cut

=for html <a name="clone"></a>

=head2 abstract clone() : 



=cut

sub clone {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    die(__FILE__, ", ", __LINE__, ": abstract method.\n");
    return;
}

=for html <a name="extract_direct_obj"></a>

=head2 extract_direct_obj() : 



=cut

sub extract_direct_obj {
    my($self, $line_iter_ref) = @_;
    my($fields) = $self->{$_PACKAGE};

    my($direct_obj_ref);

    _trace('Input text is "', ${$line_iter_ref->current_ref()}, '"') if $_TRACE;

    if (${$line_iter_ref->current_ref()} =~ /$_ARRAY_START_REGEX|$_BOOLEAN_REGEX|$_DIC_START_REGEX|$_NAME_REGEX|$_OBJ_REF_REGEX|$_NUMBER_REGEX|$_STRING_START_PAREN_REGEX|$_STRING_START_ANGLE_REGEX|$_NULL_OBJ_REGEX/) {
	if (defined($1)) {
	    # We found the start of an array.
	    $direct_obj_ref = Bivio::UI::PDF::Array->new();
	} elsif (defined($2)) {
	    # We found a boolean.
	    $direct_obj_ref = Bivio::UI::PDF::Boolean->new();
	} elsif (defined($3)) {
	    # We found the start of a dictionary.
	    $direct_obj_ref = Bivio::UI::PDF::Dictionary->new();
	} elsif (defined($4)) {
	    # We found a name.
	    $direct_obj_ref = Bivio::UI::PDF::Name->new();
	} elsif (defined($5)) {
	    # We found an indirect object reference
	    unless (defined($6)) {
		die(__FILE__,", ", __LINE__,
			": no generation number returned\n");
	    }
	    $direct_obj_ref = Bivio::UI::PDF::IndirectObjRef->new();
	} elsif (defined($7)) {
	    # We found a number.
	    $direct_obj_ref = Bivio::UI::PDF::Number->new();
	} elsif (defined($8)) {
	    # We found the start of a string in parens.
	    $direct_obj_ref = Bivio::UI::PDF::StringParen->new();
	} elsif (defined($9)) {
	    # We found the start of a string in angle brackets.
	    $direct_obj_ref = Bivio::UI::PDF::StringAngle->new();
	} elsif (defined($10)) {
	    # We found the start of a null object.
	    $direct_obj_ref = Bivio::UI::PDF::Null->new();
	} else {
	    die(__FILE__,", ", __LINE__,
		    ": No match text returned\n");
	}

	$direct_obj_ref->extract($line_iter_ref);
    } else {
	die(__FILE__,", ", __LINE__, ": No regex match\n");
    }

    return($direct_obj_ref);
}

=for html <a name="get_value"></a>

=head2 abstract get_value() : 



=cut

sub get_value {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    die(__FILE__, ", ", __LINE__, ": abstract method.\n");
    return;
}

=for html <a name="is_indirect_obj"></a>

=head2 is_indirect_obj() : 



=cut

sub is_indirect_obj {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    return(0);
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
