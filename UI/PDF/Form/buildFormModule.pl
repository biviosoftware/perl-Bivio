#!/usr/bin/perl -w

# Call with:
#	Name of target module file.
#	Complete class name of target module.
#	Complete parent class name of target module.
#	Name of pdf file.
#	Complete class name of XlatorSet class for the tartet module.

use strict;

use Bivio::IO::Trace;
use Bivio::UI::PDF::Pdf;

my($usage) = "$0 <module file> <module class> <parent class> <pdf file> <XlatorSet class>";

#Bivio::IO::Trace->set_filters(1, undef);
#my($trace_filter) = Bivio::IO::Trace->get_filter();

unless (4 == $#ARGV) {
    die("$usage\n");
}
my($module_file, $module_class, $parent_class, $pdf_file, $xlator_set_class)
	= @ARGV;

# Create a Pdf object that parses the input Pdf file.
my($pdf_ref) = Bivio::UI::PDF::Pdf->new();
$pdf_ref->parse_complete_pdf($pdf_file);

# Read in the data, which is a template for the module file we are building.
my($old_record_separator) = $/;
$/ = undef;
my($module_text) = <DATA>;
$/ = $old_record_separator;

# Insert the module's class name.
$module_text =~ s/!!!Class!!!/$module_class/g;
# Insert the module's parent name.
$module_text =~ s/!!!Parent!!!/$parent_class/g;
# Insert the XlatorSet class name.
$module_text =~ s/(!!! Xlator Set Class !!!)/$1\n$xlator_set_class/;
# Insert the pointer to the root object of the Pdf file.
my($root_pointer) = $pdf_ref->get_root_pointer()->get_value();
$module_text =~ s/(!!! Base Root Pointer !!!)/$1\n$root_pointer/;
# Insert the size.
my($size) = $pdf_ref->get_size()->get_value();
$module_text =~ s/(!!! Base Size !!!)/$1\n$size/;
# Insert the xref offset.
my($xref_offset) = $pdf_ref->get_xref_offset()->get_value();
$module_text =~ s/(!!! Base Xref Offset !!!)/$1\n$xref_offset/;

# Find all the Pdf fields referenced in the XlatorSet and insert their text.
eval("require $xlator_set_class;");
if ($@) {
    die("require error \"$@\"\n");
}
my($xlators_array_ref) = $xlator_set_class->get_xlators_ref();
my($emit_ref) = Bivio::UI::PDF::Emit->new();
local($_);
map {
    my(@field_names) = $_->get_pdf_field_names();
    map {
	my($field_ref) = $pdf_ref->get_field_ref_by_name($_);
	unless (defined($field_ref)) {
	    die("Field \"", $_, "\" not found");
	}
	$field_ref->emit_with_kids($emit_ref, $pdf_ref);
    } @field_names;
} @{$xlators_array_ref};
my($field_text_ref) = $emit_ref->get_text_ref();
chop(${$field_text_ref});
$module_text =~ s/(!!! Field Text !!!)/$1\n${$field_text_ref}/;

# Inser the text of the base Pdf file.
my($pdf_text_ref) = $pdf_ref->get_pdf_text_ref();
$module_text =~ s/(!!! PDF Base File !!!)/$1\n${$pdf_text_ref}/;

open(OUT, ">$module_file") or die("Error opening \"$module_file\"\n");
print(OUT $module_text);

1;

__DATA__
# This file was built by buildFormModule.pl
# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package !!!Class!!!;
use strict;
$!!!Class!!!::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

!!!Class!!! - 

=head1 SYNOPSIS

    use !!!Class!!!;
    !!!Class!!!->new();

=cut

=head1 EXTENDS

L<!!!Parent!!!>

=cut

use !!!Parent!!!;
@!!!Class!!!::ISA = ('!!!Parent!!!');

=head1 DESCRIPTION

C<!!!Class!!!>

=cut

#=IMPORTS
use Bivio::UI::PDF::OpaqueUpdate;

#=VARIABLES

# Keep a reference to an OpaqueUpdate that contains the text of the base Pdf
# document to which we are adding field values.
my($_BASE_UPDATE_REF);

# Store a reference to an instance of $_XLATOR_SET_CLASS.
my($_XLATOR_SET_REF);

# Key = field name, e,g. 'f1-13'
# Value = reference to corresponding field object, into which a value can be
# inserted.
my($_FIELD_DICTIONARY_REF);

# Key = object number
# Value = reference to corresponding indirect object.
my($_OBJ_DICTIONARY_REF);
my($_INITIALIZED) = 0;
__PACKAGE__->initialize();

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : !!!Class!!!



=cut

sub new {
    return !!!Parent!!!::new(@_);
}

=head1 METHODS

=cut

=for html <a name="get_base_update_ref"></a>

=head2 static get_base_update_ref() : 



=cut

sub get_base_update_ref {
    return $_BASE_UPDATE_REF;
}

=for html <a name="get_field_ref"></a>

=head2 static get_field_ref() : 



=cut

sub get_field_ref {
    my(undef, $field_name) = @_;
    my($field_obj_ref) = ${$_FIELD_DICTIONARY_REF}{$field_name};
    die("Clone failure; did you forget to remake the Form.pm file?")
	    unless defined($field_obj_ref);
    return $field_obj_ref->clone();
}

=for html <a name="get_obj_ref"></a>

=head2 static get_obj_ref() : 



=cut

sub get_obj_ref {
    my(undef, $obj_number) = @_;
    return ${$_OBJ_DICTIONARY_REF}{$obj_number}->clone();
}

=for html <a name="get_xlator_set_ref"></a>

=head2 static get_xlator_set_ref() : 



=cut

sub get_xlator_set_ref {
    return $_XLATOR_SET_REF;
}

=for html <a name="initialize"></a>

=head2 static initialize() : 



=cut

sub initialize {
    my($proto) = @_;
    return if $_INITIALIZED;
    ($_BASE_UPDATE_REF, $_XLATOR_SET_REF, $_FIELD_DICTIONARY_REF,
	   $_OBJ_DICTIONARY_REF)
	    = $proto->internal_read_data(\*DATA);
    $_INITIALIZED = 1;
    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;

__DATA__
!!! PDF Base File !!!
!!! Base Root Pointer !!!
!!! Base Size !!!
!!! Base Xref Offset !!!
!!! Xlator Set Class !!!
!!! Field Text !!!
!!! Data End !!!
