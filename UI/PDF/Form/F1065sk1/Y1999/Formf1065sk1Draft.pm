# This file was built by buildFormModule.pl
# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::PDF::Form::F1065sk1::Y1999::Formf1065sk1Draft;
use strict;
$Bivio::UI::PDF::Form::F1065sk1::Y1999::Formf1065sk1Draft::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::PDF::Form::F1065sk1::Y1999::Formf1065sk1Draft - 

=head1 SYNOPSIS

    use Bivio::UI::PDF::Form::F1065sk1::Y1999::Formf1065sk1Draft;
    Bivio::UI::PDF::Form::F1065sk1::Y1999::Formf1065sk1Draft->new();

=cut

=head1 EXTENDS

L<Bivio::UI::PDF::Form::Form>

=cut

use Bivio::UI::PDF::Form::Form;
@Bivio::UI::PDF::Form::F1065sk1::Y1999::Formf1065sk1Draft::ISA = ('Bivio::UI::PDF::Form::Form');

=head1 DESCRIPTION

C<Bivio::UI::PDF::Form::F1065sk1::Y1999::Formf1065sk1Draft>

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

=head2 static new() : Bivio::UI::PDF::Form::F1065sk1::Y1999::Formf1065sk1Draft



=cut

sub new {
    return Bivio::UI::PDF::Form::Form::new(@_);
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
%PDF-1.3%����
69 0 obj<< /Linearized 1 /O 73 /H [ 4080 688 ] /L 66300 /E 44778 /N 2 /T 64802 >> endobj                                                          xref69 139 0000000016 00000 n
0000003129 00000 n
0000003217 00000 n
0000004044 00000 n
0000004768 00000 n
0000005000 00000 n
0000005496 00000 n
0000005673 00000 n
0000005850 00000 n
0000006023 00000 n
0000006194 00000 n
0000006371 00000 n
0000006542 00000 n
0000006722 00000 n
0000006903 00000 n
0000007189 00000 n
0000007443 00000 n
0000007586 00000 n
0000007678 00000 n
0000007911 00000 n
0000008197 00000 n
0000008451 00000 n
0000008594 00000 n
0000008827 00000 n
0000009111 00000 n
0000009362 00000 n
0000009503 00000 n
0000009735 00000 n
0000009906 00000 n
0000010193 00000 n
0000010447 00000 n
0000010590 00000 n
0000010824 00000 n
0000011114 00000 n
0000011366 00000 n
0000011508 00000 n
0000011741 00000 n
0000011920 00000 n
0000012099 00000 n
0000012278 00000 n
0000012457 00000 n
0000012636 00000 n
0000012815 00000 n
0000012989 00000 n
0000013168 00000 n
0000013347 00000 n
0000013526 00000 n
0000013699 00000 n
0000013989 00000 n
0000014241 00000 n
0000014383 00000 n
0000014616 00000 n
0000014906 00000 n
0000015158 00000 n
0000015300 00000 n
0000015533 00000 n
0000015823 00000 n
0000016075 00000 n
0000016217 00000 n
0000016450 00000 n
0000016628 00000 n
0000016807 00000 n
0000016986 00000 n
0000017165 00000 n
0000017344 00000 n
0000017523 00000 n
0000017702 00000 n
0000017881 00000 n
0000018060 00000 n
0000018239 00000 n
0000018418 00000 n
0000018597 00000 n
0000018776 00000 n
0000018955 00000 n
0000019134 00000 n
0000019313 00000 n
0000019492 00000 n
0000019671 00000 n
0000019850 00000 n
0000020029 00000 n
0000020208 00000 n
0000020387 00000 n
0000020566 00000 n
0000020745 00000 n
0000020924 00000 n
0000021103 00000 n
0000021282 00000 n
0000021460 00000 n
0000021637 00000 n
0000021814 00000 n
0000021958 00000 n
0000022179 00000 n
0000022216 00000 n
0000022440 00000 n
0000027079 00000 n
0000027154 00000 n
0000027231 00000 n
0000027362 00000 n
0000027565 00000 n
0000027776 00000 n
0000028472 00000 n
0000028542 00000 n
0000029241 00000 n
0000029451 00000 n
0000030302 00000 n
0000030516 00000 n
0000030874 00000 n
0000031109 00000 n
0000031297 00000 n
0000031320 00000 n
0000032453 00000 n
0000032476 00000 n
0000033640 00000 n
0000034433 00000 n
0000034646 00000 n
0000034856 00000 n
0000035648 00000 n
0000035670 00000 n
0000036520 00000 n
0000036542 00000 n
0000037537 00000 n
0000038334 00000 n
0000038554 00000 n
0000038576 00000 n
0000039511 00000 n
0000039938 00000 n
0000040126 00000 n
0000040364 00000 n
0000040434 00000 n
0000040456 00000 n
0000041454 00000 n
0000041676 00000 n
0000042474 00000 n
0000042496 00000 n
0000043510 00000 n
0000043532 00000 n
0000044533 00000 n
0000004080 00000 n
0000004746 00000 n
trailer<</Size 208/Info 66 0 R /Root 70 0 R /Prev 64792 /ID[<db3eab5519572fe8ed8de0088f1c99d8><db3eab5519572fe8ed8de0088f1c99d8>]>>startxref0%%EOF     70 0 obj<< /Type /Catalog /Pages 67 0 R /AcroForm 71 0 R /Names 72 0 R >> endobj71 0 obj<< /Fields [ 75 0 R 76 0 R 77 0 R 78 0 R 79 0 R 80 0 R 81 0 R 82 0 R 83 0 R 88 0 R 92 0 R 96 0 R 97 0 R 101 0 R 105 0 R 106 0 R 107 0 R 108 0 R 109 0 R 110 0 R 111 0 R 112 0 R 113 0 R 114 0 R 115 0 R 116 0 R 120 0 R 124 0 R 128 0 R 129 0 R 130 0 R 131 0 R 132 0 R 133 0 R 134 0 R 135 0 R 136 0 R 137 0 R 138 0 R 139 0 R 140 0 R 141 0 R 142 0 R 143 0 R 144 0 R 145 0 R 146 0 R 147 0 R 148 0 R 149 0 R 150 0 R 151 0 R 152 0 R 153 0 R 154 0 R 155 0 R 156 0 R 157 0 R 11 0 R 12 0 R 13 0 R 14 0 R 15 0 R 16 0 R 17 0 R 18 0 R 19 0 R 20 0 R 21 0 R 22 0 R 23 0 R 24 0 R 25 0 R 26 0 R 27 0 R 28 0 R 29 0 R 30 0 R 31 0 R 32 0 R 33 0 R 34 0 R 35 0 R 36 0 R 37 0 R 38 0 R 39 0 R 40 0 R 41 0 R 42 0 R 43 0 R 44 0 R 45 0 R 46 0 R 47 0 R 48 0 R 49 0 R 50 0 R 51 0 R 52 0 R ] /DR 61 0 R /DA (/Helv 0 Tf 0 g )>> endobj72 0 obj<< /AP 68 0 R >> endobj206 0 obj<< /S 329 /V 680 /Filter /FlateDecode /Length 207 0 R >> stream
H�b```c`������ �� �� �@Q�z�&+��:t��L�0q��Y3�M�omKIJ�����ݻ|ͪ+׮߰n����̛�p�eK-NOHM��-)����h�غm��ͼ[�v��DFD�LI�%44��P�((((llQ� 
 `g`8�H��.��/ۄ�F3��M!�	SY>��k�i��J�`w�s\&�P�xG�a*���'^�6���Y^�;Zq^�k*f���	(f| ���n Ǹ�I���l�\����/$�49d1�5]_���a�c��V��8E0�'66�ofb`8��`s��Y��y"�
����T� �L&?ldzX�Y�,�-8�17�ay���4F��R''!���s��lPm��L�f�:0�e�*��A	�)���;��Đ��w���v
H73p��p	
���HKI���������l޺��6nX�n�իV�X�l�ŋ.�?o�ٳfΘ>m�ɓ&N�������	
��������pwsuqvrt��������07�����PWSUQVRT������`gceaf�0 X��2endstreamendobj207 0 obj572 endobj73 0 obj<< /Type /Page /Parent 67 0 R /Resources 166 0 R /Contents [ 178 0 R 180 0 R 186 0 R 188 0 R 192 0 R 198 0 R 202 0 R 204 0 R ] /MediaBox [ 0 0 612 792 ] /CropBox [ 0 0 612 792 ] /Rotate 0 /Annots 74 0 R >> endobj74 0 obj[ 75 0 R 76 0 R 77 0 R 78 0 R 79 0 R 80 0 R 81 0 R 82 0 R 83 0 R 88 0 R 92 0 R 96 0 R 97 0 R 101 0 R 105 0 R 106 0 R 107 0 R 108 0 R 109 0 R 110 0 R 111 0 R 112 0 R 113 0 R 114 0 R 115 0 R 116 0 R 120 0 R 124 0 R 128 0 R 129 0 R 130 0 R 131 0 R 132 0 R 133 0 R 134 0 R 135 0 R 136 0 R 137 0 R 138 0 R 139 0 R 140 0 R 141 0 R 142 0 R 143 0 R 144 0 R 145 0 R 146 0 R 147 0 R 148 0 R 149 0 R 150 0 R 151 0 R 152 0 R 153 0 R 154 0 R 155 0 R 156 0 R 157 0 R 158 0 R 159 0 R ]endobj75 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 281.8392 723.46609 341.8392 735.46609 ] /T (f1-1)/FT /Tx /Q 1 /P 73 0 R /F 4 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj76 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 403.8392 723.46609 462.8392 736.46609 ] /T (f1-2)/FT /Tx /Q 1 /P 73 0 R /F 4 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj77 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 465.12463 723.34253 495.52783 736.77551 ] /T (f1-3)/FT /Tx /P 73 0 R /F 4 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj78 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 176.8392 711.46609 300.8392 722.46609 ] /T (f1-4)/FT /Tx /P 73 0 R /F 4 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj79 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 459.8392 711.46609 486.8392 722.46609 ] /T (f1-6)/FT /Tx /Q 2 /P 73 0 R /F 4 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj80 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 489.8392 711.46609 568.8392 722.46609 ] /T (f1-7)/FT /Tx /P 73 0 R /F 4 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj81 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 43.8392 651.46609 300.8392 699.46609 ] /T (f1-5)/FT /Tx /P 73 0 R /Ff 4096 /F 4 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj82 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 309.8392 651.46609 568.8392 699.46609 ] /T (f1-8)/FT /Tx /P 73 0 R /Ff 4096 /F 4 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj83 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 127.8392 638.46609 136.8392 648.46609 ] /T (c1-1)/FT /Btn /DA (/HeBo 9 Tf 0 0 0.627 rg)/F 4 /H /T /MK << /CA (4)/AC (��)/RC (��)>> /P 73 0 R /AS /Off /AP << /N << /On 87 0 R >> /D << /On 84 0 R /Off 85 0 R >> >> >> endobj84 0 obj<< /Length 100 /Subtype /Form /BBox [ 0 0 9 10 ] /Resources << /ProcSet [ /PDF /Text ] /Font << /ZaDb 86 0 R >> >> >> stream
0.749 g 0 0 9 10 re f q 1 1 7 8 re W n BT /ZaDb 9 Tf 0 0 0.627 rg  1 0 0 1 0.693 1.7645 Tm (4) Tj ETendstreamendobj85 0 obj<< /Length 21 /Subtype /Form /BBox [ 0 0 9 10 ] /Resources << /ProcSet [ /PDF ] >> >> stream
0.749 g 0 0 9 10 re fendstreamendobj86 0 obj<< /Type /Font /Name /ZaDb /BaseFont /ZapfDingbats /Subtype /Type1 >> endobj87 0 obj<< /Length 80 /Subtype /Form /BBox [ 0 0 9 10 ] /Resources << /ProcSet [ /PDF /Text ] /Font << /ZaDb 86 0 R >> >> >> stream
q 1 1 7 8 re W n BT /ZaDb 9 Tf 0 0 0.627 rg  1 0 0 1 0.693 1.7645 Tm (4) Tj ET Qendstreamendobj88 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 214.8392 638.46609 223.8392 648.46609 ] /T (c1-2)/FT /Btn /DA (/HeBo 9 Tf 0 0 0.627 rg)/F 4 /H /T /MK << /CA (4)/AC (��)/RC (��)>> /P 73 0 R /AS /Off /AP << /N << /On 91 0 R >> /D << /On 89 0 R /Off 90 0 R >> >> >> endobj89 0 obj<< /Length 100 /Subtype /Form /BBox [ 0 0 9 10 ] /Resources << /ProcSet [ /PDF /Text ] /Font << /ZaDb 86 0 R >> >> >> stream
0.749 g 0 0 9 10 re f q 1 1 7 8 re W n BT /ZaDb 9 Tf 0 0 0.627 rg  1 0 0 1 0.693 1.7645 Tm (4) Tj ETendstreamendobj90 0 obj<< /Length 21 /Subtype /Form /BBox [ 0 0 9 10 ] /Resources << /ProcSet [ /PDF ] >> >> stream
0.749 g 0 0 9 10 re fendstreamendobj91 0 obj<< /Length 80 /Subtype /Form /BBox [ 0 0 9 10 ] /Resources << /ProcSet [ /PDF /Text ] /Font << /ZaDb 86 0 R >> >> >> stream
q 1 1 7 8 re W n BT /ZaDb 9 Tf 0 0 0.627 rg  1 0 0 1 0.693 1.7645 Tm (4) Tj ET Qendstreamendobj92 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 55.8392 626.46609 64.8392 635.46609 ] /T (c1-3)/FT /Btn /DA (/HeBo 9 Tf 0 0 0.627 rg)/F 4 /H /T /MK << /CA (4)/AC (��)/RC (��)>> /P 73 0 R /AS /Off /AP << /N << /On 95 0 R >> /D << /On 93 0 R /Off 94 0 R >> >> >> endobj93 0 obj<< /Length 99 /Subtype /Form /BBox [ 0 0 9 9 ] /Resources << /ProcSet [ /PDF /Text ] /Font << /ZaDb 86 0 R >> >> >> stream
0.749 g 0 0 9 9 re f q 1 1 7 7 re W n BT /ZaDb 9 Tf 0 0 0.627 rg  1 0 0 1 0.693 1.2645 Tm (4) Tj ETendstreamendobj94 0 obj<< /Length 20 /Subtype /Form /BBox [ 0 0 9 9 ] /Resources << /ProcSet [ /PDF ] >> >> stream
0.749 g 0 0 9 9 re fendstreamendobj95 0 obj<< /Length 80 /Subtype /Form /BBox [ 0 0 9 9 ] /Resources << /ProcSet [ /PDF /Text ] /Font << /ZaDb 86 0 R >> >> >> stream
q 1 1 7 7 re W n BT /ZaDb 9 Tf 0 0 0.627 rg  1 0 0 1 0.693 1.2645 Tm (4) Tj ET Qendstreamendobj96 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 219.8392 615.46609 299.8392 628.46609 ] /T (f1-9)/FT /Tx /P 73 0 R /F 4 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj97 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 127.8392 603.46609 137.8392 611.46609 ] /T (c1-4)/FT /Btn /DA (/HeBo 9 Tf 0 0 0.627 rg)/F 4 /H /T /MK << /CA (4)/AC (��)/RC (��)>> /P 73 0 R /AS /Off /AP << /N << /On 100 0 R >> /D << /On 98 0 R /Off 99 0 R >> >> >> endobj98 0 obj<< /Length 100 /Subtype /Form /BBox [ 0 0 10 8 ] /Resources << /ProcSet [ /PDF /Text ] /Font << /ZaDb 86 0 R >> >> >> stream
0.749 g 0 0 10 8 re f q 1 1 8 6 re W n BT /ZaDb 9 Tf 0 0 0.627 rg  1 0 0 1 1.193 0.7645 Tm (4) Tj ETendstreamendobj99 0 obj<< /Length 21 /Subtype /Form /BBox [ 0 0 10 8 ] /Resources << /ProcSet [ /PDF ] >> >> stream
0.749 g 0 0 10 8 re fendstreamendobj100 0 obj<< /Length 80 /Subtype /Form /BBox [ 0 0 10 8 ] /Resources << /ProcSet [ /PDF /Text ] /Font << /ZaDb 86 0 R >> >> >> stream
q 1 1 8 6 re W n BT /ZaDb 9 Tf 0 0 0.627 rg  1 0 0 1 1.193 0.7645 Tm (4) Tj ET Qendstreamendobj101 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 206.8392 603.46609 215.8392 611.46609 ] /T (c1-5)/FT /Btn /DA (/HeBo 9 Tf 0 0 0.627 rg)/F 4 /H /T /MK << /CA (4)/AC (��)/RC (��)>> /P 73 0 R /AS /Off /AP << /N << /On 104 0 R >> /D << /On 102 0 R /Off 103 0 R >> >> >> endobj102 0 obj<< /Length 99 /Subtype /Form /BBox [ 0 0 9 8 ] /Resources << /ProcSet [ /PDF /Text ] /Font << /ZaDb 86 0 R >> >> >> stream
0.749 g 0 0 9 8 re f q 1 1 7 6 re W n BT /ZaDb 9 Tf 0 0 0.627 rg  1 0 0 1 0.693 0.7645 Tm (4) Tj ETendstreamendobj103 0 obj<< /Length 20 /Subtype /Form /BBox [ 0 0 9 8 ] /Resources << /ProcSet [ /PDF ] >> >> stream
0.749 g 0 0 9 8 re fendstreamendobj104 0 obj<< /Length 80 /Subtype /Form /BBox [ 0 0 9 8 ] /Resources << /ProcSet [ /PDF /Text ] /Font << /ZaDb 86 0 R >> >> >> stream
q 1 1 7 6 re W n BT /ZaDb 9 Tf 0 0 0.627 rg  1 0 0 1 0.693 0.7645 Tm (4) Tj ET Qendstreamendobj105 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 203.8392 579.46609 233.8392 589.46609 ] /T (f1-10)/FT /Tx /Q 2 /P 73 0 R /F 4 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj106 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 255.8392 579.46609 285.8392 589.46609 ] /T (f1-11)/FT /Tx /Q 2 /P 73 0 R /F 4 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj107 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 203.8392 567.46609 233.8392 579.46609 ] /T (f1-12)/FT /Tx /Q 2 /P 73 0 R /F 4 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj108 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 255.8392 567.46609 285.8392 579.46609 ] /T (f1-13)/FT /Tx /Q 2 /P 73 0 R /F 4 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj109 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 203.8392 556.46609 233.8392 567.46609 ] /T (f1-14)/FT /Tx /Q 2 /P 73 0 R /F 4 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj110 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 255.8392 556.46609 285.8392 567.46609 ] /T (f1-15)/FT /Tx /Q 2 /P 73 0 R /F 4 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj111 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 226.8392 543.46609 300.8392 556.46609 ] /T (f1-15a)/FT /Tx /P 73 0 R /F 4 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj112 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 495.8392 627.46609 564.8392 639.46609 ] /T (f1-16)/FT /Tx /Q 2 /P 73 0 R /F 4 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj113 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 495.8392 615.46609 564.8392 627.46609 ] /T (f1-17)/FT /Tx /Q 2 /P 73 0 R /F 4 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj114 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 495.8392 603.46609 564.8392 615.46609 ] /T (f1-18)/FT /Tx /Q 2 /P 73 0 R /F 4 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj115 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 475.8392 591.46609 565.8392 603.46609 ] /T (f1-19)/FT /Tx /P 73 0 R /F 4 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj116 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 559.8392 566.46609 568.8392 575.46609 ] /T (c1-6)/FT /Btn /DA (/HeBo 9 Tf 0 0 0.627 rg)/F 4 /H /T /MK << /CA (4)/AC (��)/RC (��)>> /P 73 0 R /AS /Off /AP << /N << /On 119 0 R >> /D << /On 117 0 R /Off 118 0 R >> >> >> endobj117 0 obj<< /Length 99 /Subtype /Form /BBox [ 0 0 9 9 ] /Resources << /ProcSet [ /PDF /Text ] /Font << /ZaDb 86 0 R >> >> >> stream
0.749 g 0 0 9 9 re f q 1 1 7 7 re W n BT /ZaDb 9 Tf 0 0 0.627 rg  1 0 0 1 0.693 1.2645 Tm (4) Tj ETendstreamendobj118 0 obj<< /Length 20 /Subtype /Form /BBox [ 0 0 9 9 ] /Resources << /ProcSet [ /PDF ] >> >> stream
0.749 g 0 0 9 9 re fendstreamendobj119 0 obj<< /Length 80 /Subtype /Form /BBox [ 0 0 9 9 ] /Resources << /ProcSet [ /PDF /Text ] /Font << /ZaDb 86 0 R >> >> >> stream
q 1 1 7 7 re W n BT /ZaDb 9 Tf 0 0 0.627 rg  1 0 0 1 0.693 1.2645 Tm (4) Tj ET Qendstreamendobj120 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 436.8392 546.46609 445.8392 555.46609 ] /T (c1-7)/FT /Btn /DA (/HeBo 9 Tf 0 0 0.627 rg)/F 4 /H /T /MK << /CA (4)/AC (��)/RC (��)>> /P 73 0 R /AS /Off /AP << /N << /On 123 0 R >> /D << /On 121 0 R /Off 122 0 R >> >> >> endobj121 0 obj<< /Length 99 /Subtype /Form /BBox [ 0 0 9 9 ] /Resources << /ProcSet [ /PDF /Text ] /Font << /ZaDb 86 0 R >> >> >> stream
0.749 g 0 0 9 9 re f q 1 1 7 7 re W n BT /ZaDb 9 Tf 0 0 0.627 rg  1 0 0 1 0.693 1.2645 Tm (4) Tj ETendstreamendobj122 0 obj<< /Length 20 /Subtype /Form /BBox [ 0 0 9 9 ] /Resources << /ProcSet [ /PDF ] >> >> stream
0.749 g 0 0 9 9 re fendstreamendobj123 0 obj<< /Length 80 /Subtype /Form /BBox [ 0 0 9 9 ] /Resources << /ProcSet [ /PDF /Text ] /Font << /ZaDb 86 0 R >> >> >> stream
q 1 1 7 7 re W n BT /ZaDb 9 Tf 0 0 0.627 rg  1 0 0 1 0.693 1.2645 Tm (4) Tj ET Qendstreamendobj124 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 501.8392 546.46609 510.8392 555.46609 ] /T (c1-8)/FT /Btn /DA (/HeBo 9 Tf 0 0 0.627 rg)/F 4 /H /T /MK << /CA (4)/AC (��)/RC (��)>> /P 73 0 R /AS /Off /AP << /N << /On 127 0 R >> /D << /On 125 0 R /Off 126 0 R >> >> >> endobj125 0 obj<< /Length 99 /Subtype /Form /BBox [ 0 0 9 9 ] /Resources << /ProcSet [ /PDF /Text ] /Font << /ZaDb 86 0 R >> >> >> stream
0.749 g 0 0 9 9 re f q 1 1 7 7 re W n BT /ZaDb 9 Tf 0 0 0.627 rg  1 0 0 1 0.693 1.2645 Tm (4) Tj ETendstreamendobj126 0 obj<< /Length 20 /Subtype /Form /BBox [ 0 0 9 9 ] /Resources << /ProcSet [ /PDF ] >> >> stream
0.749 g 0 0 9 9 re fendstreamendobj127 0 obj<< /Length 80 /Subtype /Form /BBox [ 0 0 9 9 ] /Resources << /ProcSet [ /PDF /Text ] /Font << /ZaDb 86 0 R >> >> >> stream
q 1 1 7 7 re W n BT /ZaDb 9 Tf 0 0 0.627 rg  1 0 0 1 0.693 1.2645 Tm (4) Tj ET Qendstreamendobj128 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 40.8392 495.46609 160.8392 507.46609 ] /T (f1-20)/FT /Tx /Q 2 /P 73 0 R /F 4 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj129 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 164.8392 495.46609 260.8392 507.46609 ] /T (f1-21)/FT /Tx /Q 2 /P 73 0 R /F 4 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj130 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 265.8392 495.46609 362.8392 507.46609 ] /T (f1-22)/FT /Tx /Q 2 /P 73 0 R /F 4 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj131 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 368.8392 495.46609 454.8392 507.46609 ] /T (f1-23)/FT /Tx /Q 2 /P 73 0 R /F 4 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj132 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 459.8392 495.46609 564.8392 507.46609 ] /T (f1-24)/FT /Tx /Q 2 /P 73 0 R /F 4 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj133 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 365.8392 459.46609 457.8392 471.46609 ] /T (f1-25)/FT /Tx /Q 2 /P 73 0 R /F 4 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj134 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 365.8392 447.46609 457.8392 459.46609 ] /T (f1-26)/FT /Tx /Q 2 /P 73 0 R /F 4 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj135 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 365.8392 435.46609 457.8392 447.46609 ] /T (f1-27)/FT /Tx /Q 2 /P 73 0 R /F 4 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj136 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 365.8392 411.46609 457.8392 424.46609 ] /T (f1-28)/FT /Tx /Q 2 /P 73 0 R /F 4 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj137 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 365.8392 399.46609 457.8392 410.46609 ] /T (f1-29)/FT /Tx /Q 2 /P 73 0 R /F 4 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj138 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 365.8392 387.46609 457.8392 398.46609 ] /T (f1-30)/FT /Tx /Q 2 /P 73 0 R /F 4 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj139 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 365.8392 375.46609 457.8392 387.46609 ] /T (f1-31)/FT /Tx /Q 2 /P 73 0 R /F 4 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj140 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 365.8392 351.46609 457.8392 364.46609 ] /T (f1-32)/FT /Tx /Q 2 /P 73 0 R /F 4 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj141 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 365.8392 339.46609 457.8392 351.46609 ] /T (f1-33)/FT /Tx /Q 2 /P 73 0 R /F 4 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj142 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 365.8392 327.46609 457.8392 339.46609 ] /T (f1-34)/FT /Tx /Q 2 /P 73 0 R /F 4 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj143 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 365.8392 315.46609 457.8392 327.46609 ] /T (f1-35)/FT /Tx /Q 2 /P 73 0 R /F 4 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj144 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 365.8392 303.46609 457.8392 315.46609 ] /T (f1-36)/FT /Tx /Q 2 /P 73 0 R /F 4 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj145 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 365.8392 291.46609 457.8392 303.46609 ] /T (f1-37)/FT /Tx /Q 2 /P 73 0 R /F 4 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj146 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 365.8392 267.46609 457.8392 280.46609 ] /T (f1-38)/FT /Tx /Q 2 /P 73 0 R /F 4 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj147 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 365.8392 255.46609 457.8392 267.46609 ] /T (f1-39)/FT /Tx /Q 2 /P 73 0 R /F 4 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj148 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 365.8392 243.46609 457.8392 255.46609 ] /T (f1-40)/FT /Tx /Q 2 /P 73 0 R /F 4 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj149 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 365.8392 231.46609 457.8392 242.46609 ] /T (f1-41)/FT /Tx /Q 2 /P 73 0 R /F 4 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj150 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 365.8392 195.46609 457.8392 209.46609 ] /T (f1-42)/FT /Tx /Q 2 /P 73 0 R /F 4 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj151 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 365.8392 183.46609 457.8392 195.46609 ] /T (f1-43)/FT /Tx /Q 2 /P 73 0 R /F 4 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj152 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 365.8392 159.46609 457.8392 172.46609 ] /T (f1-44)/FT /Tx /Q 2 /P 73 0 R /F 4 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj153 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 365.8392 147.46609 457.8392 159.46609 ] /T (f1-45)/FT /Tx /Q 2 /P 73 0 R /F 4 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj154 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 365.8392 123.46609 457.8392 136.46609 ] /T (f1-46)/FT /Tx /Q 2 /P 73 0 R /F 4 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj155 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 365.8392 99.46609 457.8392 113.46609 ] /T (f1-47)/FT /Tx /Q 2 /P 73 0 R /F 4 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj156 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 365.8392 87.46609 457.8392 98.46609 ] /T (f1-48)/FT /Tx /Q 2 /P 73 0 R /F 4 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj157 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 365.8392 75.46609 457.8392 87.46609 ] /T (f1-49)/FT /Tx /Q 2 /P 73 0 R /F 4 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj158 0 obj<< /Type /Annot /Subtype /Popup /Rect [ 233.93141 -155.33214 433.93298 44.66943 ] /Open false /F 27 /Parent 159 0 R >> endobj159 0 obj<< /Type /Annot /Subtype /Stamp /Rect [ 234 7 378 45 ] /Popup 158 0 R /C [ 0.75294 0.75294 0.75294 ] /T (John H Yates)/Contents ()/M (D:20000322205016-07'00')/AP 160 0 R /F 4 /Name /Draft >> endobj160 0 obj<< /N 161 0 R >> endobj161 0 obj<< /Length 71 /Subtype /Form /BBox [ 0 0 246 65 ] /Resources << /ProcSet [ /PDF ] /XObject << /FRM 162 0 R >> >> >> stream
q 0 0 246 65 re W n q 0 0 246 65 re W n 1 0 0 1 123 32.5 cm /FRM Do Q Qendstreamendobj162 0 obj<< /Length 4432 /Filter /FlateDecode /Type /XObject /Subtype /Form /BBox [ 179 374 425 439 ] /FormType 1 /Matrix [ 1 0 0 1 -302 -406.5 ] /Name /FRM /Resources 163 0 R >> stream
H�lW[�%��7�=�t$�!iY@�0@� ���H�}=��^O��H����_��?��>����_��?������g��|���w�h��̳��������|����#>� 9��]�����p�'����g�}�O����ӟ���'T��>~$��PfO�!*�<u���,,7��h�)9����_x���tX=a�!��*?�Rr&�Ds�ڒ�5��'����)�6L;%_�FB�G|�3	m>�،V�S��s2�D�Y����A�H��緃[��5����L��<QA�����$�RR�仞M��!w?{��0��_"������(��N4�\*��Ҟ}Ny����~ Mp�)���C%L�P�]0EsG~x��]�@�7]|i�e6ʜ���S�0�O��o<�a̺$�H�?�0H�n%e����f ��L�Ʃ:�9�]2xאּ8j�D������$��Y��:ӄ�WI���*�2������h:j\l\��K'�K��ִ��B������9����A: _N��[}g�e�ڹc��.��'� �@y������z��]����X�RQO���D�K4Q��n�Ew%Y���Mx��d��"�qY<L��+l��x��-Q6/��V��+&�w��7īk��[�;�H@R�5����%�����_�Z	���v��|l�	[ǄCE��#��J�@��:�u��� K�5���&K2{��\-�[�x���Gֽ3�W��LK�_��Q��cx��9�b8l^�ث�Ylπ�-�gEp����"*�PRE��#�%��"D�_���|�����#%���$�T���� PWuA-�2ֳZi�jb7/�.Nʍ�Lb �|�:޺��G<V��h*��{J4�.���"����g�{q�(�\����*tw�X2{�ſ*�����	f���H!jc1��E�[M����*�eoo��qy�'򬢬5f)���\GxiS$����l�H���.P��p^��"].j>��m*��h[ש�@iXj�֏(�BQxlM�󶥪�X׿
lp4��xc�{���Ku��Q9��1HQ}� �r�M��ϔt=XU-|�t`�pkK �R� w�Jvq:*������2&B|�u���l'q�[���I��cq�y���P9�'f�1z���TO���e�\����v���d|ɣyZeH�6�a8o=��OH_n�=,d+l�-���$�+�p�|U�c; ze�ƫ1F�H���޻���sU���i0�W�%C���xGc{U5Q+Z��)%��_qY��TxΊ����|Uq�F���}n�)�ٯ��4E�-�T�ѣ.�����XL-ʭ�狄x/u=�G�eJ��j#+�Zp��&7�nI�C7�#�c��Zm+��;ˊ��w�X;�O��9���UxQ�Z��p�d{v����2	���h�Oa�<Ѧ�K���#����"6S������v?�1��t�\}ka�h�2��T�u�����M�6%��u}1��o�;q=p�<f��0E6�܎���#b9`���|�,B1�>�J�{���m!���J�|�;t9����[^+���|�������/��u��7����g��d]U�=��vJѬ Ŗ�A�#N�;�~�]�G��'w*��*��rGLʲ ł�F�4n�����z����a���:�%X��\��[��:�N�6�&Zm���j5�Nn���"V��8j1��hN�_��~/P����hEv�Uy�i�'w��]OP|��J��]n�
|�kL^�ۦ�A_�����d��"N9C�-�K���k�_}Q�dj��Ywho$=ߕ_Gj�[�x��q?)�N���@�3�c���|��w�Ш`�MH�h��(�Q��D���m�����l:��cL�n�ta�o�R째��c��;�����q�$��.&�T���Bt�Dܟ-�Ӎ�W�jE��ͳ��P#'�!N-���?=�f���9ܼE�{d�je��wSQV}q�� p��ٸ��� W�r���kEb�-�Lv�����S�ij2\*�G��"����I��.J(L��³g`���q\��R1n�U\?�9[Gf]�"����1��E��,>Aq�Ā���*�����V�t�;�*���
e��nK�}��YZC<z�E��΁G����8�JX��
���"�#�):��-�b��݌���["�>�"��m����Rk�h�3?��_,��lmQ4˃{v��@<���w#B^�J�w�$�U���@�.D�^-X�@�T�{N�?oٽ����X�/D�2���S� %���CfA%���8Z])In���y��d�ASca2YYV_4@ԟݧ
4ĜZ����qs��Xő�y4�� �8�����8ⴞ���)���+)q�6�aU�]�ǌ^���c���)\�z3�~f�rke�V���j��[�>�M%�xe���kk�B����g�J��Za�V� ш�dj�����d�Sz���R	�B�9L�袚��OKRO��&>uɜ�Wyga�����;�Vr��W})S�{�L���Zw�0�F��j���4X���,7���}��%��a�Ơ ���=�;O�.�{S�8.Ƀ�$�X���z���e��"�=�)}�*vZaʶ�;����_:��tq9�4쒀2��[��S8�v���ß��G���JӲD�x�a�@��I�Q&�2�э���j�]Z|�G�{�������>��R��\"��~�����~2!X#A��L� ���K���I"L�����d��� T�c����)�H�u�����́��Q݂=�g�M˦�'�ud��kE�� '�x��W�Y��8��^�+S~,�]�X������SХql"��-Ꮳ0��m����0��-�el)s���6\u�r�i:���ZҙU�mוE�1�b*E�}��r��h��Dk��B}�O��QK"�S�����2]���Vr�cL�*�]X��b��+��<��_���R�Ԧ��n�9j�� �I��/Gn�)s[�;|�v
��$�����u����)M�N��G|�t�#�)|xk��D��[+��5
�Z�H�[�`^x%� ~RR�wXV�ƲH��v@e�-\�ƽ�"=��A�ZV�㡚�:�d����]?ڡ�6)���P��2��\���%�UZ�w|�k�Х��m��;��LI^׮�<u&k̅�߀)���96�ж���,�E��L����O�[��C�������;,Q��Z�}�7�
��L��ٹ�������&�/�7)�en7=��xuǈq�8�o��jg��{�=F~-|xx�8��-Mۻ%$O���BͩG(1�ݟ4
u��]��4,�k����O�y[�E{�R�+��m�l��*t�T^Q��'�x � 2C��W~��:�:�Z�5���L�*��������&c���5��߷M*Bv�O��xxg�~-T=g0�8�jrtk5.���r<�4,yb��x�r�L�m���X}��-#ިa�]%0�6�p�����c��6n~��L���[�$��7f���ܠ7�U�\����)S(��]����	Ǡz1��	��z��e{(bԋ)ӦK�aL5/,a��E��~���'��FU���M�æ%f�?q��d�e�g�e���T�W�c������K�nCxr4�-�u�D�� MO��vP�k[�b��P���}^�L�B��k�[(��Ov*	\Dr�ë���f��J������L��t]���#��()ܶ:��N���i?֗�F�-SSd��7�/�5��xo]��g:nlXO?�[oP��r<����yC�z����`7�Mc���Q- ���4߬��Fөځ�.Uf��e9��Ţ%�5�����ZP���ô�M�$�<fL#�ũE4�Ȟ�ں^j!O��8��pCZ�0�dB�'R��J_�]�)�ov�w�y���nBO�N߄*��ᚥ*�����3�|���=���gr��x��X�x�F�D����� S�j!������)M@�eX�-R-Kvb&�$ԣ�e��t����"���?j��9D�BN>+��q؞"���ae�1âO�x}L�,�ĸ ��N�^AHV�ԸV s�e\H���gS��D�n�޿PCƎd���?�qGu,7��P.Ozٱt�i9�C�_b�#�]k �SG��7#>����hF�����S�gz�$�*��&$�{ua�/�*�u��0�#\���ͽE��)�-��|�Bͩ9J���$�tG,�9�~���%�ɖ�~�����ʯ�n�$�N{��1�"�����S.N�9�@��J.�:�������Dt��ض�����U�w���	I��l�3�cI캳�!0a�9��_�O]�"e\��H���� u�@�
endstreamendobj163 0 obj<< /ProcSet [ /PDF ] /ExtGState << /GS2 164 0 R >> >> endobj164 0 obj<< /Type /ExtGState /SA true /OP false /HT 165 0 R >> endobj165 0 obj<< /Type /Halftone /HalftoneType 1 /HalftoneName (Default)/Frequency 60 /Angle 45 /SpotFunction /Round >> endobj166 0 obj<< /ProcSet [ /PDF /Text ] /Font << /F1 172 0 R /F2 170 0 R /F3 168 0 R /F4 184 0 R /F5 181 0 R /F6 189 0 R /F7 200 0 R /F8 176 0 R /F9 194 0 R >> /ExtGState << /GS1 205 0 R >> >> endobj167 0 obj<< /Type /FontDescriptor /Ascent 686 /CapHeight 686 /Descent -174 /Flags 32 /FontBBox [ -199 -250 1014 934 ] /FontName /FranklinGothic-Demi /ItalicAngle 0 /StemV 147 /XHeight 508 >> endobj168 0 obj<< /Type /Font /Subtype /Type1 /FirstChar 32 /LastChar 181 /Widths [ 300 320 460 600 600 700 720 300 380 380 600 600 300 240 300 600 600 600 600 600 600 600 600 600 600 600 300 300 600 600 600 540 800 640 660 660 660 580 540 660 660 300 400 640 500 880 660 660 620 660 660 600 540 660 600 900 640 600 660 380 600 380 600 500 380 540 540 540 540 540 300 560 540 260 260 560 260 820 540 540 540 540 340 500 380 540 480 740 540 480 420 380 300 380 600 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 300 0 0 0 0 0 0 0 0 0 0 0 0 0 300 0 600 600 0 0 0 0 0 740 0 0 0 240 0 0 0 600 0 0 0 540 ] /Encoding /WinAnsiEncoding /BaseFont /FranklinGothic-Demi /FontDescriptor 167 0 R >> endobj169 0 obj<< /Type /Encoding /Differences [ 1 /H17075 ] >> endobj170 0 obj<< /Type /Font /Subtype /Type1 /FirstChar 32 /LastChar 181 /Widths [ 278 278 463 556 556 1000 685 278 296 296 407 600 278 407 278 371 556 556 556 556 556 556 556 556 556 556 278 278 600 600 600 556 800 685 704 741 741 648 593 759 741 295 556 722 593 907 741 778 667 778 722 649 611 741 630 944 667 667 648 333 371 333 600 500 259 574 611 574 611 574 333 611 593 258 278 574 258 906 593 611 611 611 389 537 352 593 520 814 537 519 519 333 223 333 600 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 278 0 0 0 0 1000 0 0 0 0 0 0 0 0 278 0 556 556 0 0 0 0 0 800 0 0 0 407 0 0 0 600 0 0 0 593 ] /Encoding /WinAnsiEncoding /BaseFont /HelveticaNeue-Bold /FontDescriptor 173 0 R >> endobj171 0 obj<< /Type /FontDescriptor /Ascent 714 /CapHeight 714 /Descent -198 /Flags 32 /FontBBox [ -166 -214 1076 952 ] /FontName /HelveticaNeue-Roman /ItalicAngle 0 /StemV 85 /XHeight 517 >> endobj172 0 obj<< /Type /Font /Subtype /Type1 /FirstChar 32 /LastChar 240 /Widths [ 278 259 426 556 556 1000 630 278 259 259 352 600 278 389 278 333 556 556 556 556 556 556 556 556 556 556 278 278 600 600 600 556 800 648 685 722 704 611 574 759 722 259 519 667 556 871 722 760 648 760 685 648 574 722 611 926 611 648 611 259 333 259 600 500 222 537 593 537 593 537 296 574 556 222 222 519 222 853 556 574 593 593 333 500 315 556 500 758 518 500 480 333 222 333 600 278 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 556 0 0 0 0 0 800 0 0 0 278 0 0 278 600 278 278 0 556 278 278 278 278 278 0 0 278 0 0 0 0 0 278 0 278 278 0 0 0 278 0 0 0 0 0 0 0 0 0 0 278 0 278 0 0 167 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 278 ] /Encoding /MacRomanEncoding /BaseFont /HelveticaNeue-Roman /FontDescriptor 171 0 R >> endobj173 0 obj<< /Type /FontDescriptor /Ascent 714 /CapHeight 714 /Descent -182 /Flags 262176 /FontBBox [ -166 -218 1078 975 ] /FontName /HelveticaNeue-Bold /ItalicAngle 0 /StemV 142 /XHeight 517 >> endobj174 0 obj<< /Filter /FlateDecode /Length 266 /Subtype /Type1C >> stream
H�bd`ab`ddT�sv������,K-*N���K-/.�,�p�����1����C��,�9��,?�y�Z~��*�9�Un���n����_��$��S�~�.������[��ahn`n�_PY���Q�����`hia�������\Y\��[�����_T�_�X���������R_��Z�ZT��R�J�r=�+S��3�B�
��p8=������������E���_5��~�0N�������<�)?jX����uw���f�]��` �Ym]
endstreamendobj175 0 obj<< /Type /FontDescriptor /Ascent 0 /CapHeight 0 /Descent 0 /Flags 4 /FontBBox [ -7 -227 989 764 ] /FontName /NCFHHN+Universal-NewswithCommPi /ItalicAngle 0 /StemV 0 /CharSet (/H17075)/FontFile3 174 0 R >> endobj176 0 obj<< /Type /Font /Subtype /Type1 /FirstChar 1 /LastChar 1 /Widths [ 1000 ] /Encoding 169 0 R /BaseFont /NCFHHN+Universal-NewswithCommPi /FontDescriptor 175 0 R >> endobj177 0 obj1053 endobj178 0 obj<< /Filter /FlateDecode /Length 177 0 R >> stream
H��V�r�F�\�sR�zߏ�"KrdǱ�b.�|��%�� Ȏ~�����,� _�\Ɂ��b�w��g@J��U����U�0�!R�%��8#�A�8�>Y�<?����焲�.�.���fų�0i����<�W�y>%��
��[��H�J�S��q���;�-$�%1�؍�w昫�t�����`�Lq�*��B\JN��'p�����Z�gQ&�_����o�g�~or�->#$!5q���J:K,�2���k="j����)��!��T9�΍hbDc�8�܀7��H�q`�#\�	Q���x��/�,�4��~���6��4��Y�eSn��^ƽ��8��C�כ׾/I�q�:9_ ,�J�M�[��*m�vfn혺����D\r%�B�\��~���ⴶ�Ѹ�Zi�Da�ƒ���:_�E�n���Ր����dRE8�	ޤ�v����&�8��a���k�p����#�����MU����9� w���q�_�MS7�,��0"��rEXB�u�Tq�X{�C^��鞋�pi�"��w��׾�-�[���C�8�ؚ�v=�v8u���m�;�����Õo�ԥg�8�~Az��i��.q'�ev��اT��S����۹}��Pn\
L%�c�&I���"tDw[��M;�+��^>"��<�?�6rj��e
TiT�)��eO�8�Y����^r�31ȕO� .tc�zĝ�`�c�Q��T�����cMFMQUmfM��%�����Pn*?�s�� 4ZM������juX�s�C.��D�ʀ%bk�2oҺ��`o�c+�mꃚ�9�Y��gc�$��ǘ0�����qrT�Y�C~{$����o�rf��Yzꗛ�Cy[4+�_c�9h5��q��u�aZ��c�97�Z*@�������u��
�����t�k�/]9�hX�_�)
��ѡ}*�u`���=,R/�n�J��"H�Vnz�ru�j����}[b���f��<�?�0����8��G ���?d�k@���cv�9h� ��H"endstreamendobj179 0 obj1084 endobj180 0 obj<< /Filter /FlateDecode /Length 179 0 R >> stream
H��VMo�FE��{h��~�4q�6�Ѓ�%Q�6)�T��������va�^/�3o�{3K�P��U� ?��Y���Im13Ң�!Iʖ�$N0�K��Zj���0�D��ˇ�.�#o�����Ϳ�&i��}�d���w�t�ڕ�s�L�Vi[�Umל6���v���>/?&�>0D�r�,8Ŝ
�+�!�MB|���G����(V�1��P��)@&dD�s]@�����NY������b+�g��	����!��c*�S&%o������'	����.���"3��Դŀ������y�f�;�<�W���j�קL�\�j���e3�7V+���L�J���x&�TX3��ΪU<p�~��v$}@��J_r�^ q��)
������n�-��ģ���j3��P`"�C�$�w^��[z�!�C�{w�=�ɏ���!7�sF� S
��>�� W� K&8��N} b�r�3���}���2� 1��E�eףF��{���E�����I����HN��3�`"�L�PB\	%�V�+`Xk���0��9#>k>�n�}��>�@�Т?:���O�kB���J'"@�{�w�{<��WT���kQ��_�0*�7��'h`�� ��NÓ�T�P7`?���շP��g�m�*�:���g����d,`B��\��Y��Z�ϸ��i��5�-���\���ݾ�|A��YNFR�vS�&�{9:�֥۔�̹-�.���*5�1�w!�m0"\��"\H`E�J���U�V��pk���A%�Ŋ_Ω�!�
3��Y��=pA�8~��@�oΟX2,G���FP6�B�Hi~<G��,к�V�����>��v�WÔ���A���;�E~�y�a�#�������*ݬ2D� 0�ˢi}�H\xT`7!�G���V�W�C}�:/Ԧ.O�
>%���B=�(�$�ɫ6*�Js8z�g�[�:���|�t�a4�X�1b����!�(~�Ehz�˰smhD�`0j0���0g��L\���L��Sf�e���fwVӤ�ԇj/����>D�A�Sn��7+��]-d�O� +NY�endstreamendobj181 0 obj<< /Type /Font /Subtype /Type1 /FirstChar 32 /LastChar 181 /Widths [ 278 259 426 556 556 926 630 278 259 259 352 600 278 389 278 333 556 556 556 556 556 556 556 556 556 556 278 278 600 600 600 556 800 667 685 722 704 611 574 759 722 259 519 667 556 870 722 759 648 759 685 648 574 722 611 926 611 611 611 259 333 259 600 500 222 519 593 537 593 537 296 574 556 222 222 481 222 852 556 574 593 593 333 481 315 556 481 759 481 481 444 333 222 333 600 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 556 556 278 278 278 278 278 800 278 278 278 278 278 278 278 600 278 278 278 556 ] /Encoding /WinAnsiEncoding /BaseFont /HelveticaNeue-Italic /FontDescriptor 182 0 R >> endobj182 0 obj<< /Type /FontDescriptor /Ascent 714 /CapHeight 714 /Descent -198 /Flags 96 /FontBBox [ -166 -214 1106 957 ] /FontName /HelveticaNeue-Italic /ItalicAngle -12 /StemV 85 /XHeight 517 >> endobj183 0 obj<< /Type /FontDescriptor /Ascent 750 /CapHeight 750 /Descent -189 /Flags 32 /FontBBox [ -174 -250 1071 990 ] /FontName /Helvetica-Condensed /ItalicAngle 0 /StemV 79 /XHeight 556 >> endobj184 0 obj<< /Type /Font /Subtype /Type1 /FirstChar 32 /LastChar 181 /Widths [ 250 333 250 500 500 833 667 250 333 333 500 500 250 333 250 278 500 500 500 500 500 500 500 500 500 500 250 250 500 500 500 500 800 556 556 556 611 500 444 611 611 278 444 556 500 778 611 611 556 611 611 556 500 611 556 833 556 556 500 333 250 333 500 500 333 444 500 444 500 444 278 500 500 222 222 444 222 778 500 500 500 500 333 444 278 500 444 667 444 444 389 274 250 274 500 250 250 250 250 250 250 250 250 250 250 250 250 250 250 250 250 250 250 250 250 250 250 250 250 250 250 250 250 250 250 250 250 250 250 250 500 500 250 250 250 250 250 800 250 250 250 250 250 250 250 500 250 250 250 500 ] /Encoding /WinAnsiEncoding /BaseFont /Helvetica-Condensed /FontDescriptor 183 0 R >> endobj185 0 obj770 endobj186 0 obj<< /Filter /FlateDecode /Length 185 0 R >> stream
H��U�N�@}�W�c��vo�KQA��ZT����8p���6E|h�����	uE"f��3sΜY ������Z��ʀ1b%���5Di	2�D�@A����>����7D�������Q3rfی�@�(D���]D�}��@Z�+h`�Ĥ�[��u��5��X�j��Ij�j�`��F԰�*SC�;������\��QX2�$�}�Z�:�6+��%��<+a�p�<������e�I��h^_-n�b��puA�����,�$-�F�ěԶͥ`��P����ikTب��� ͒|�`���e���M��pYo�����+1��'�RW�2L7�h-�@M��!�}��Ah3�-NρO�Aia�(��t!&��6l� 3��\�Qz&���ia�PM��g��f�4�IǨ=���������EKh���c��E�ɷi~�ا�䣳��
O�Lיҿ x���?����Q�/�#�4�cl]Y�8X�Ij)mc����emt���m�9�M;���iX����*�\�6��8�H�����������i�����c���C���(v�g@6z<��CX{�G�N�pZ���p�X�ʿ�4��7X��.[�2"S8�xOtg���̐%$���6�������,��3\#�$�u1��d#a���>p�<���yX��#��s�cg���=M�>�*G-.�Ӣ��K�wj;r�K��>
�ﮒ�	w����9�w�c�f���u}�Pߞ޿>p��S;T�O� d�8Qendstreamendobj187 0 obj915 endobj188 0 obj<< /Filter /FlateDecode /Length 187 0 R >> stream
H��UɎ�F��+�	�v�KnY� � �[�M�F
(R )8���T/�D�ak>��b�{��U5 ʏ�j�P�S�yǀA�+��jX�/�ʟ
J��<~�ޏ�t��z����t���C�U���Ổ��l!��t4&�9|���#NY��KAZ��B(�,SP#��1엶�a~�0!�%RK���Q(J��ǼF���R	e�	�]�(EM��"f�G�8j4f��c��$�j��I޶(t-T�Ss������z�v�ܝ{��x�[���%ak�0�s�H�MEG�?�=b��~�u͡��$ARRn��&�Nf�	u"�l��Ʊ��0�{�=7>i��,���r1añB5���x,~(/�|I���θ%��[��,KN��#�937;?z��Ƀr�Y�c����d�5L�2�d��؟��е�s��ۚ�����*�:t0�Zm�²�r'F;,����bB�(�����Dj韫�rnd-��~>W}�N�[�����q���s�x�W�r�4S7}�s��T��\�
�q������B�S=��0.�r���E#�������u5��f|�.���8�J���ua�/�p#
M�`��{�;q=�_ihoPtnj���#��fRE�դ��/��t�9 lcD�ɸ~J������¶�hd\�ܱlE�1\�73���Ax�"�|�4I[\Y��,�&�'����1��c��	��EA��좗k�,�rR�8�����E���v��i�lV���Վy�~����hT�9����J�"N����ŌeN�hw��7�|��BJ��E����s�+3�r/�J�J�\^�y��k��=�v�E���=�q| i�u�%��W��"�Ds_m��E����[ȕ$FZ9̓Z>���-X�V�K���f%����n�D��_� �@Yendstreamendobj189 0 obj<< /Type /Font /Subtype /Type1 /FirstChar 32 /LastChar 181 /Widths [ 250 333 333 500 500 833 667 250 333 333 500 500 333 333 333 278 500 500 500 500 500 500 500 500 500 500 278 278 500 500 500 500 833 556 556 556 611 500 500 611 611 278 444 556 500 778 611 611 556 611 611 556 500 611 556 833 556 556 500 333 250 333 500 500 333 500 500 444 500 500 278 500 500 278 278 444 278 778 500 500 500 500 333 444 278 500 444 667 444 444 389 274 250 274 500 250 250 250 250 250 250 250 250 250 250 250 250 250 250 250 250 250 250 250 250 250 250 250 250 250 250 250 250 250 250 250 250 250 250 250 500 500 250 250 250 250 250 830 250 250 250 250 250 250 250 500 250 250 250 500 ] /Encoding /WinAnsiEncoding /BaseFont /Helvetica-Condensed-Bold /FontDescriptor 190 0 R >> endobj190 0 obj<< /Type /FontDescriptor /Ascent 750 /CapHeight 750 /Descent -189 /Flags 262176 /FontBBox [ -169 -250 1091 991 ] /FontName /Helvetica-Condensed-Bold /ItalicAngle 0 /StemV 130 /XHeight 564 >> endobj191 0 obj855 endobj192 0 obj<< /Filter /FlateDecode /Length 191 0 R >> stream
H��VMo�@��W�1Ex��� H��`�1r��q)�{f��M�JH(R�ff߼�vl Ȋ%�0	�]��\m����>g�\�t��jyE�����:�Dji��'��a�.qFA������hl��؃�=rA�S�AN	��MȪB��,�A(�Pw�zߔ�_�����u���m�m=�M�ؔb$�
�u��N�E9e��}�oy���w�0��;����'�+�U&�%�q)	����(=��s��x�����L�XA(4B��(��X�x8_`���rD=E 
��
��KAZ�JY��G1O���<=r���)QrFX�,f����L��ǳE�!/�*��|���au�r��%��+�8W�r>�9ʕϐ��<'r� %��B��S�A	%�c
������Рi�L�.s�\��3����>twy���v_�ߡ���^ͮmΉRTO�Sl{���i4�6��ˌ>drMQ.lT#\_�z����03CV�
��q�w[���
�|����Z.p�������M��ú�a�w;��aה����b[��N��ӈ����?���7���s�)b���9��2S �u����E5R�������43;[�#�D�>ٿ���-e��+z%���<�&�R���)[@��E��(���<�V�aŃ~78�u���W���$�H��agjT!�&<�����V]z0M�j��⢫�t����\�s�=��=h0�܉�S�����I�{uO5�t��/�aj������Dr�9W�ˮ��܉愈y�g�$Չ��X���l�u�@z�)��M=��A��η��o{?{�};�����c�������ZW�` ��S�endstreamendobj193 0 obj<< /Filter /FlateDecode /Length 335 /Subtype /Type1C >> stream
H�bd`ab`ddT�sv������,K-*N��u/JM�.�,��M,��)2����C��,�9��,?�y�r����y�Un���n����W�����}�$������Y��ad`aj�_PY���Q�����`hia�������\Y\��[�����_T�_�X���������R_��Z�ZT�;S�L�r=�32�,Ჸ}�������������}����}��p^��e	�w������+j?1n�m���쏣����+b1''Y�w3{�F��5r���5��R@��=��w�=[�Oc��c���r|�S�L��w��ĩ�-��~�t� q���
endstreamendobj194 0 obj<< /Type /Font /Subtype /Type1 /FirstChar 1 /LastChar 1 /Widths [ 333 ] /Encoding 196 0 R /BaseFont /NCFJHK+Universal-GreekwithMathPi /FontDescriptor 195 0 R >> endobj195 0 obj<< /Type /FontDescriptor /Ascent 0 /CapHeight 0 /Descent 0 /Flags 4 /FontBBox [ -30 -240 1012 815 ] /FontName /NCFJHK+Universal-GreekwithMathPi /ItalicAngle 0 /StemV 0 /CharSet (/H20854)/FontFile3 193 0 R >> endobj196 0 obj<< /Type /Encoding /Differences [ 1 /H20854 ] >> endobj197 0 obj918 endobj198 0 obj<< /Filter /FlateDecode /Length 197 0 R >> stream
H��V�n�@���y )Adٝ�?r� 	��!M\Hmd�����NڒT�b{�3sΙ3� @���)f�U����7U7/o��=p潁�� �
�qX=SHK(:ׅ��i�[�g�˲x�A@yY8�����o�ah�~������ eU�.�y�4,��Lr�)�3�m�X2�e��:{�ΑϪ�������w��2+nͼ�"�ce��=��w�}�,�bՄ�ҞY�ns�qv�I+H%��9G�B#^�� �Ϛ��j��Zְʋ�UsSCS�vSWU^²^���|m�]��:0(���Sʾ���~��}U]O��aG.��vy?m��O�7)��r'x�P���ƈ��%Lܦ@��	�g&q;�*���^���>/۾�ڿ]�Ђ0+�P��r(C��]��&�M��e����Z��V�a!F��K��go��7�|��{Y�iZLzMFK��1���Q��t\v(�Q�����LPo�� �$�e�<�ʅ���Y��O?
���e�8R}̍�u}TGgt���h��Ȭ��2��E��yҹ�DH�s�S���Ke�� 	�&�Q4�pH�嵬S҇�x��T&y������	U1�E �V��=�* �ힽ�f���<������,MI�	 �j�c,m�)�U�7M��P�8��b��Ǧ߬�g�����]�<�>I��#���t�(#�+�b;��(��Z&ڂY.�b��#��4�>�:o�x�4�]�+��/#���Ǩ�{VɮM�AzLVQ�2G�"S��D��Vr��W���Uw��<L̇
ϸ����u8GB:�9y����V�5zN��ag�d�eH�	����y��i��K�lx� h/&̭t�b�5\�q`EP��rqIP����CVC�Q�!�Q�v��kH<�5$��'� F�0�endstreamendobj199 0 obj<< /Type /FontDescriptor /Ascent 750 /CapHeight 750 /Descent -189 /Flags 262176 /FontBBox [ -168 -250 1113 1000 ] /FontName /Helvetica-Condensed-Black /ItalicAngle 0 /StemV 159 /XHeight 560 >> endobj200 0 obj<< /Type /Font /Subtype /Type1 /FirstChar 32 /LastChar 181 /Widths [ 250 333 333 500 500 833 667 250 278 278 500 500 333 333 333 278 500 500 500 500 500 500 500 500 500 500 278 278 500 500 500 500 830 556 556 556 556 500 500 556 556 278 444 556 444 778 556 556 556 556 556 500 500 556 556 778 556 556 444 278 250 278 500 500 333 500 500 500 500 500 333 500 500 278 278 500 278 722 500 500 500 500 333 444 333 500 444 667 444 444 389 274 250 274 500 250 250 250 250 250 250 250 250 250 250 250 250 250 250 250 250 250 250 250 250 250 250 250 250 250 250 250 250 250 250 250 250 250 250 250 500 500 250 250 250 250 250 830 250 250 250 250 250 250 250 500 250 250 250 500 ] /Encoding /WinAnsiEncoding /BaseFont /Helvetica-Condensed-Black /FontDescriptor 199 0 R >> endobj201 0 obj934 endobj202 0 obj<< /Filter /FlateDecode /Length 201 0 R >> stream
H��V�n�8E����@Z����2�h
t�zw�8�DQlE~c�x.)R��M�pp�=�M@��k_�h]�_��!BpJi҈���������� �?)<BJ����[H�,����T�	�0�qs� 
���FQ��Ԋj�ZÍ�CS\��>��n��l����/��LК(ō3���ƿ��|;`L4�{H�cr�5QB�F�9f&�e2l�Gb�J�9��s�d�ݨg۰��sN��xrd�Y�r�&ω�!v��j��/ME��^
dGd� +68j]#6yN������E�h��k�i�dȊ�h�M�'C�F}(N�Q��{�nAD����r�&ω�!v���	s�Ԥ��q%�yȰAV%IM�5' 6yN�����;x��8	W��Ȋ�h�M�'C�F}s�;�'wI|)�??���э�ׇ�+�)܍GJ�F'�e]��g�.p���#e������g��i�[<�,��8�*\0�'�ˡ���=�зO��Op<ٷv� �٧��1Z�������-���r>Q��΀�q�2�.NE�+��!�m��3k�zÍ�j挿|�w�8����k̒Ӳ�h	o�yxy����D3az?W;A��O_��{K/�ޅ@��䘤�y	S�C$�폡�����'���7h�������g��c;���-�2��y�����po����v�3&�;�<����oDL|}��K����,��6���n��⛞|D$Q�
��"�wR��bՔ|:���%��� �>�b�?.�N/a��U��8�o���o����8����:w��X�W�����5a��1R�Q��t�
��ÈbK'M��q���&����z�1�35:q�]{�C��ԏn��n�"�<x�LnZϦ������+r��g�/� �endstreamendobj203 0 obj921 endobj204 0 obj<< /Filter /FlateDecode /Length 203 0 R >> stream
H��U�j�V%[}Emj边��6�d` 0�,ܳ�[���-��ɇ�R��W���`��K��SU��  ���$'LHP�n5\2�1|y9g_�_�엏O�&�0����E;��)1�Y(.��-ˏyu�����,�Q
�Ň�j���jƗ�/��� e[y %\*F����@)N�{�c�<��M�1H�x��P	�z�)�C�-tt��[���3��S�ڎP���_B�: ��m���'��.������1L��|�䘟��+^�$^�C�mr���Ƕ��`x)�ڇ<7m=��K�-\ �H�A�}����c�_�Q��>4����,��rz���s�|[i��0��RB��7^l+}����:4�]�gѼz�}���z�VD�|�SI���"_�%L�l���f�j�� ��)��i���ӧ@C�#�%�xA\2��j�np�/2�q�`
���BN/׃g��Ҥ��S(J�v�18�҅��ڒA�ڴ� ʺ� }JC�Cݣ���ٍ��zj>�� 2P{l֙�1Z�������8#r�9I���;r��|nl�(�}GT������۟�/��˦E��nf�>��4�}@�a�I�J�ʘu8v|
��QH������>�>��.:?O]��9S��&�kf���HԈ�F	t��Z�Z�"߭�m��jp�ܨ��Y6ϓ�;�J�Q�D��8���DW���J��>+e����f��l3�l����&�ܳ81a	P�1cV�W����6,��-��%@�DJ-p����B��R����φ�͉�h�.5E]n��"��~%H?c>C��~�����ڷI��?���nJa��7���r�6�]�JcvXM�gB�M���~ȋ�f�o����=��e��X(k�;�00���݁n�ͫ���9�C��F�X�� ���endstreamendobj205 0 obj<< /Type /ExtGState /SA false /SM 0.02 /TR /Identity >> endobj1 0 obj<< /Type /Page /Parent 67 0 R /Resources 5 0 R /Contents 6 0 R /MediaBox [ 0 0 612 792 ] /CropBox [ 0 0 612 792 ] /Rotate 0 /Annots 2 0 R >> endobj2 0 obj[ 11 0 R 12 0 R 13 0 R 14 0 R 15 0 R 16 0 R 17 0 R 18 0 R 19 0 R 20 0 R 21 0 R 22 0 R 23 0 R 24 0 R 25 0 R 26 0 R 27 0 R 28 0 R 29 0 R 30 0 R 31 0 R 32 0 R 33 0 R 34 0 R 35 0 R 36 0 R 37 0 R 38 0 R 39 0 R 40 0 R 41 0 R 42 0 R 43 0 R 44 0 R 45 0 R 46 0 R 47 0 R 48 0 R 49 0 R 50 0 R 51 0 R 52 0 R 3 0 R 4 0 R ]endobj3 0 obj<< /Type /Annot /Subtype /Popup /Rect [ 234.82428 -156.22501 434.82585 43.77657 ] /Open false /F 27 /Parent 4 0 R >> endobj4 0 obj<< /Type /Annot /Subtype /Stamp /Rect [ 235 6 379 44 ] /Popup 3 0 R /C [ 0.75294 0.75294 0.75294 ] /T (John H Yates)/Contents ()/M (D:20000322205028-07'00')/AP 59 0 R /F 4 /Name /Draft >> endobj5 0 obj<< /ProcSet [ /PDF /Text ] /Font << /F1 172 0 R /F5 181 0 R /F6 189 0 R /F8 176 0 R /F9 194 0 R /F10 7 0 R /F11 8 0 R /F12 9 0 R >> /ExtGState << /GS1 205 0 R >> >> endobj6 0 obj<< /Length 5393 /Filter /FlateDecode >> stream
H��W�n�Hľ�+�Q"N�ٝ�,�d;��O�<�R�fV�%�I��?[}�Hʒl`�Z}�S��Z��<N~�x��c;a�&!e!�"�d��pVh2c�4n���Y���У��х�f�����O?3J�?LtaKF(��OJ�*�H�pti9��'���L�����&��գ���[���-�2*�>*��tY�6�S�֞�����f���%����œ[V��:c�n��YF���!�Z����'}��_��WB��a�'��;%�I8C�RF����YMnq����D*��biz9NZ�������ZYX�Mxy�(�E��.��,�]�����¿�JJ�kZ�6{א�S��f�`8v���TV���z{��I�!���� �{�ݼ+m��(��jcө~���A��m!����(�gW���n�M}��8�>U�#�ޭSp�(�1@JP�T�^r��R�2��>P͹$�\�lB����M�+��Vү.�1��1�r$�LТ���J�ExIة��۽_~=�{�$���6d�m�������kVVXI�XY"�h&C"������	N�[���R�%�N)�k�_I����@�)�H�̣��[��9L,�>��U�߸&�7d�,8���`͟�)R��ߧ���'�M��L�����}�݄��7�%�i� l�����Қ%f�s��,{SL��?���
ЅC�:�Z K�� C2�$r���;}��%%+��|(y�,��vP
.�gGb�����BJ$D&�,,�X|p��-�ʃA�@�5�)Ov�v���[Up�n]�G�p�z��¬�C�W���:��C	���T�O�H���3�`	�&�V2?h��k�[H�׽
9Y�<�����K2
RXd{:���i���,e��*A��H�@�DNeeA��������������״i��E^(�uHݰ���
�߫z��c�O۵#�v�a�1�w!"�j��U�ɤ��.��`�`��,��4�Q'���Joi���i��2X�]�笳=��ӆΫ��=�����)J&����=��m�F�`v�5��|�W66�t�:~1,���ˬv�j�]T������9^��L�K��k>�ؕx�t*C�D/�h�b�򯐩��}�w���A�ޫҍ`'�{�����j�D�dݕ��%$��t�C�
�%fJV�K�c�G�V"JyiW���rT` �d�M�8���ޘQq�y���KS��Re�-�4�[/þ��!�T���M�u/��z^����R�+#��ْ.E8>�1c�-A4�%���X�.EX�#f�o�:��v��/RQl6?|�����/�ĥ�6aq�<��^���ARv���;�՘O�J�Py�B:��o�H��9m��f�Z�=��z�|IO���}�y���n��+(��ל���z�7��"�� �!S�[��Z�W�"�#.1�b�4|� {u�{�G�!�m�$(`�0o�Y���N���v/`:�z&�]/�c����|zqI�(.b��K�ryNT!�B��Мu,�v�U5�3��*�̐2�ט/ԫ�MM�J��r�z�ٽ�Ji�kJ���.��bw5��� �ܹ��8��(�!�L��M�n7���e�b(��&i���K�2�T�h2�Vu��9^P�/��U���ak�~�hny�����6�ۅ6�"��w;�C{<6�����i���K�V��Q
Sb��"���X#J�y�[�M�ⷼ�t�?�a�N=	��q�I�~�>�@N�hx$"c�����D�w���EVT�*��I�[���" 5�W+�4��=ڤ��Ц,� �q�w��y#�_3�<�ȫx�5}ޔgxsU�!n�DI/�а�j����B����h �� 5�����%n+L90+q�Ѕl�}�}���{Hq�J���C��{r��ۺ
�rK�/��F/����Vx�IL�=ڀQy�GN�1�#�J�}1ƻ���kWO��kR�vć5� X��0��2�4���w0,�A�/�~����I@o�����o��X�;�juwS\/W�CB�����rńbw���"V�^�e"�������%��R�7OM\�uQϔ���&��$���m�c�Ƶ�Ȩ�('��c]�1�X�����n��e�ܤ���9:���K
�G�;�<p"�,H�pA�!����*� d�r!g�(����d�d"�j��l^m��R��=���1yȻ!�^����2(]"�lȔTuqY���z���eS��wӯ��8�1�`�T��kM�)DE�a�W�9qI��x�]5,�ǆ�G^cX�4LwJ�z���-Y�G�e�Gy[X#suS����ٸQ
�5�f��Q�čՑ�y����r�^��Be$
�+�(�����j�B�}!��m"�.4xC����]�e��!�{�	�4��=�ssk���C�B��C�,#�-�w���6{|m�]�����yMT���9�Rrh��ɋCpdvߖ�d;'��Z8RG�.3ı2�F��z��ͮ�y�p1����}�	:6����Q�N$����c�c��@( R�u����.1��鞿Qp��/�'�2�v#����EQ1ٛ�G��ν9�����]R�diH(Ey` �gj�����@Vh�z�3��Ԟ����S_%��$G��W�Q3h
�/��mz�}�ԥn�\�2�?���Kf�J��>� ���ˋ���t���ʤsf�be�O>י�l_�޸����2,me�JdoQ�m�E�E�-�q(�Ȑ��i*�ƅJ[�*�SteR	~��+���K]�*�.mi+�J^���L*ain[�T��ܶ�U��ں06/mͱ��!m
��E�V<9d�L���>��:�T4��D@��N�!�I��N�`9x&7sX��>7�T��%�7�^ m�wO�#�������ۧ`�4���"Io�>���L�F]��s�L��-:��}nי9�3��o'���;o����$L��=��;��ʏ�qy����ک�^�E�ړ�:<tuqK�4=���뻎]�}�g��r���/��rJG�J�W8�/aT�q�&"gM0��1��>��
�W6��lN=bP]�>�<0�n|�3Y���F���x}�崔��rTfq=Z�b�����Yvx9�rcN hDrԞE��� wXb��š9$J;��{�SYھ��H]�VQO�z[������C��.��U������ƶ�g������Ov��6قB���o2��J�YǗV>$;̡��N�ɋ�
�஼�3K���Ƅ�򪜢,����x#*�%XVED�����1%����X���Nթw���]�AE;��B降}K�����8��c�,F:+r)��p��I��J����&��J��<���BL������~bd���=����nt|6�;�I��Iu�����Ek
g�q�F�8MK_��3��̏Sf1�dl�&�㩥�&N��rA��7�B�a�*�1y���\��T�+�b��]�.x�)�8�`!���b�@Vʢ��D"�I�1R��=�T퐳���&�e�"h%BUjD���娂i���Wtm�1�`��Re!H�U$�(5��*P��B�2Ϫ^#��3S��r�n����. ���/+�
��A�ũ��+ �7�"���8��1�'��p$�⃪s��U� � :�%ώ�Y��VX2��-�H�)�����%R�N�b)[�4�"��&p�i��=�&�~$� U'	TO�� ��m��܂q!�!�;�`	
�C�� �HTChGbaL�%�z���I�Dw1^R�qE*��J��S5����D���A�7*�(6�B���&�F��̢��Dnyv�T"T9��fG 2A��%�4H@�)x�@�c�$��UK���E�d�x��"�a�Gf�!?�0ڀ��	��v���ES-��<G��ɉ,zS�"~~�Qչ��Yާ@s��ᖟSKU��(� ȶ�~
��85[C"���	}x�|���ϒϭ�ȟ{>�� ��7]VQ��q�P r\?��~����1|dъ�u�X=2I9ZFF4������8�$"�bo���*��"J1�R�޷����F�Del!\g�	0y��L�7!d�X�&d��1ي�JX��%�iF{g�t���MEy8�˾��3 �g�$R�%Q#�Y�?��"b��2�;-Bj*\6��\n�^�Itep�b�GFa��N�'��{��_�$s�����D
��H��v��;5R˓Е�]Xf�9�,�}��b
}K�l�HT<�'g�ʀFB�7ч\�(����J���t���(���@�c�L��?bx�{�y`�0l���;h�����������񴦁�8�?O������%o�ֹ�19�-\*=Cf]��߽{4���paO�<�,`&�dP]<�7�.��������u<�����=�ý&SU.R�-���Y�X�?�1�B��1uKK\$k��OAnҥ�uD�}%�KyA����^�+�����j"E.ҟ 9�11q�-�	_u2�>����q�v�u���ު�I=6񱵄	�����Xy�?rي���y����G��a\v��/G��fD�����yX�ۧ���v|ȸ@���L�)���8�ZjO�<���ht�@%b���󠉦Fq��n�4�,�,��XEt4��������i�e*Uѿև�n<豚mP��W!����Z�s����-����*�����C�>�K�> 7�1��g@�?W����1O�?��m�����Ϸ����~:<�£�UPO�#�~@̇��a��l|x<~������vla���?=�E���w�6���93�m�H%�X�`��@^�#�x  �׬ ��X�T]�{�z��h8�hV�U��y6��v�i�OK��� �<����yswY�|�??+���-bu�/-�����4� �)��WJ� ��Ր˰�'R�9��\��ͤ���,+�U�h��'0����m�(��T#S��W��" �b?{olX��j���YK�H�YS�!im���x`~{w�q ~?���ʨ��xw:�%}��[fSO�3�K�hl�Ɓ��I{�R��F�a�<�����X2M�@�3��8��ݧ+�:
&O>t�E7��`���ԋ�VU؝%�B�6ϟ���J��8���!���������������J�:��4���#ğP�, �z�Pϧ�0����_��k^�s��Ѓs��B�q�F:۴����E�aM�%�r_l��;Q@2��藙�$�Ϛ?⎕��f�QqR"��&ؚ�Eg�]��}�^��.cUO�b�K�@d����-H��|��4���ԕ3 �qo�ν��l�a�k<�RQD�4=����3���TC�=+�Y�֪O�� �=�
endstreamendobj7 0 obj<< /Type /Font /Subtype /Type1 /FirstChar 32 /LastChar 181 /Widths [ 278 259 426 556 556 1000 630 278 259 259 352 600 278 389 278 333 556 556 556 556 556 556 556 556 556 556 278 278 600 600 600 556 800 648 685 722 704 611 574 759 722 259 519 667 556 871 722 760 648 760 685 648 574 722 611 926 611 648 611 259 333 259 600 500 222 537 593 537 593 537 296 574 556 222 222 519 222 853 556 574 593 593 333 500 315 556 500 758 518 500 480 333 222 333 600 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 556 556 278 278 278 278 278 800 278 278 278 278 278 278 278 600 278 278 278 556 ] /Encoding /WinAnsiEncoding /BaseFont /HelveticaNeue-Roman /FontDescriptor 171 0 R >> endobj8 0 obj<< /Type /Font /Subtype /Type1 /FirstChar 32 /LastChar 181 /Widths [ 278 278 463 556 556 1000 685 278 296 296 407 600 278 407 278 371 556 556 556 556 556 556 556 556 556 556 278 278 600 600 600 556 800 685 704 741 741 648 593 759 741 295 556 722 593 907 741 778 667 778 722 649 611 741 630 944 667 667 648 333 371 333 600 500 259 574 611 574 611 574 333 611 593 258 278 574 258 906 593 611 611 611 389 537 352 593 520 814 537 519 519 333 223 333 600 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 556 556 278 278 278 278 278 800 278 278 278 278 278 278 278 600 278 278 278 593 ] /Encoding /WinAnsiEncoding /BaseFont /HelveticaNeue-Bold /FontDescriptor 173 0 R >> endobj9 0 obj<< /Type /Font /Subtype /Type1 /FirstChar 32 /LastChar 181 /Widths [ 278 296 481 556 556 963 685 278 296 296 407 600 278 407 278 389 556 556 556 556 556 556 556 556 556 556 278 278 600 600 600 574 800 685 722 741 741 667 593 759 741 296 556 722 574 907 741 778 667 778 722 648 611 741 630 944 667 648 648 333 389 333 600 500 259 574 611 556 611 574 352 611 611 259 259 556 259 907 611 593 611 611 389 519 370 611 519 815 519 519 500 333 222 333 600 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 556 556 278 278 278 278 278 800 278 278 278 278 278 278 278 600 278 278 278 611 ] /Encoding /WinAnsiEncoding /BaseFont /HelveticaNeue-BoldItalic /FontDescriptor 10 0 R >> endobj10 0 obj<< /Type /FontDescriptor /Ascent 714 /CapHeight 714 /Descent -182 /Flags 262240 /FontBBox [ -166 -218 1129 975 ] /FontName /HelveticaNeue-BoldItalic /ItalicAngle -12 /StemV 142 /XHeight 517 >> endobj11 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 366.08548 699.61502 458.08548 712.61502 ] /T (f2-1)/FT /Tx /Q 2 /P 1 0 R /F 4 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj12 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 366.08548 687.61502 458.08548 698.61502 ] /T (f2-2)/FT /Tx /Q 2 /P 1 0 R /F 4 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj13 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 366.08548 674.61502 458.08548 686.61502 ] /T (f2-3)/FT /Tx /Q 2 /P 1 0 R /F 4 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj14 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 366.08548 662.61502 458.08548 674.61502 ] /T (f2-4)/FT /Tx /Q 2 /P 1 0 R /F 4 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj15 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 366.08548 651.61502 458.08548 662.61502 ] /T (f2-5)/FT /Tx /Q 2 /P 1 0 R /F 4 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj16 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 366.08548 639.61502 458.08548 650.61502 ] /T (f2-6)/FT /Tx /Q 2 /P 1 0 R /F 4 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj17 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 366.08548 627.61502 458.08548 639.61502 ] /T (f2-7)/FT /Tx /Q 2 /P 1 0 R /F 4 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj18 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 366.08548 615.61502 458.08548 627.61502 ] /T (f2-8)/FT /Tx /Q 2 /P 1 0 R /F 4 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj19 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 366.08548 603.61502 458.08548 615.61502 ] /T (f2-9)/FT /Tx /Q 2 /P 1 0 R /F 4 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj20 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 366.08548 591.61502 458.08548 603.61502 ] /T (f2-10)/FT /Tx /Q 2 /P 1 0 R /F 4 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj21 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 366.08548 579.61502 458.08548 591.61502 ] /T (f2-11)/FT /Tx /Q 2 /P 1 0 R /F 4 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj22 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 366.08548 567.61502 458.08548 578.61502 ] /T (f2-12)/FT /Tx /Q 2 /P 1 0 R /F 4 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj23 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 163.08548 554.61502 336.08548 566.61502 ] /T (f2-13)/FT /Tx /P 1 0 R /F 4 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj24 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 252.08548 542.61502 335.08548 554.61502 ] /T (f2-14)/FT /Tx /P 1 0 R /F 4 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj25 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 366.08548 519.61502 458.08548 532.61502 ] /T (f2-15)/FT /Tx /Q 2 /P 1 0 R /F 4 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj26 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 366.08548 507.61502 458.08548 518.61502 ] /T (f2-16)/FT /Tx /Q 2 /P 1 0 R /F 4 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj27 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 224.08548 494.61502 234.08548 503.61502 ] /T (c2-1)/FT /Btn /DA (/HeBo 9 Tf 0 0 0.627 rg)/F 4 /H /T /MK << /CA (4)/AC (��)/RC (��)>> /P 1 0 R /AS /Off /AP << /N << /On 53 0 R >> /D << /On 54 0 R /Off 55 0 R >> >> >> endobj28 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 261.08548 494.61502 270.08548 503.61502 ] /T (c2-2)/FT /Btn /DA (/HeBo 9 Tf 0 0 0.627 rg)/F 4 /H /T /MK << /CA (4)/AC (��)/RC (��)>> /P 1 0 R /AS /Off /AP << /N << /On 56 0 R >> /D << /On 57 0 R /Off 58 0 R >> >> >> endobj29 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 366.08548 494.61502 458.08548 506.61502 ] /T (f2-17)/FT /Tx /Q 2 /P 1 0 R /F 4 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj30 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 366.08548 482.61502 458.08548 494.61502 ] /T (f2-18)/FT /Tx /Q 2 /P 1 0 R /F 4 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj31 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 366.08548 471.61502 458.08548 482.61502 ] /T (f2-19)/FT /Tx /Q 2 /P 1 0 R /F 4 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj32 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 246.08548 458.61502 334.08548 471.61502 ] /T (f2-20)/FT /Tx /P 1 0 R /F 4 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj33 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 366.08548 447.61502 458.08548 460.61502 ] /T (f2-21)/FT /Tx /Q 2 /P 1 0 R /F 4 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj34 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 366.08548 435.61502 458.08548 447.61502 ] /T (f2-22)/FT /Tx /Q 2 /P 1 0 R /F 4 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj35 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 366.08548 423.61502 458.08548 435.61502 ] /T (f2-23)/FT /Tx /Q 2 /P 1 0 R /F 4 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj36 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 366.08548 411.61502 458.08548 422.61502 ] /T (f2-24)/FT /Tx /Q 2 /P 1 0 R /F 4 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj37 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 366.08548 399.61502 458.08548 410.61502 ] /T (f2-25)/FT /Tx /Q 2 /P 1 0 R /F 4 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj38 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 366.08548 387.61502 458.08548 398.61502 ] /T (f2-26)/FT /Tx /Q 2 /P 1 0 R /F 4 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj39 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 366.08548 363.61502 458.08548 376.61502 ] /T (f2-27)/FT /Tx /Q 2 /P 1 0 R /F 4 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj40 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 366.08548 351.61502 458.08548 362.61502 ] /T (f2-28)/FT /Tx /Q 2 /P 1 0 R /F 4 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj41 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 90.08548 314.61502 570.08548 328.61502 ] /T (f2-29)/FT /Tx /P 1 0 R /F 4 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj42 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 90.08548 291.61502 570.08548 306.61502 ] /T (f2-30)/FT /Tx /P 1 0 R /F 4 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj43 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 90.08548 266.61502 570.08548 283.61502 ] /T (f2-31)/FT /Tx /P 1 0 R /F 4 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj44 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 90.08548 242.61502 570.08548 256.61502 ] /T (f2-32)/FT /Tx /P 1 0 R /F 4 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj45 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 90.08548 218.61502 570.08548 236.61502 ] /T (f2-33)/FT /Tx /P 1 0 R /F 4 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj46 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 90.08548 194.61502 570.08548 212.61502 ] /T (f2-34)/FT /Tx /P 1 0 R /F 4 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj47 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 90.08548 170.61502 570.08548 188.61502 ] /T (f2-35)/FT /Tx /P 1 0 R /F 4 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj48 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 90.08548 146.61502 570.08548 164.61502 ] /T (f2-36)/FT /Tx /P 1 0 R /F 4 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj49 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 90.08548 122.61502 570.08548 139.61502 ] /T (f2-37)/FT /Tx /P 1 0 R /F 4 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj50 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 90.08548 98.61502 570.08548 116.61502 ] /T (f2-38)/FT /Tx /P 1 0 R /F 4 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj51 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 90.08548 74.61502 571.08548 91.61502 ] /T (f2-39)/FT /Tx /P 1 0 R /F 4 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj52 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 90.08548 51.61502 571.08548 68.61502 ] /T (f2-40)/FT /Tx /P 1 0 R /F 4 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj53 0 obj<< /Length 80 /Subtype /Form /BBox [ 0 0 10 9 ] /Resources << /ProcSet [ /PDF /Text ] /Font << /ZaDb 86 0 R >> >> >> stream
q 1 1 8 7 re W n BT /ZaDb 9 Tf 0 0 0.627 rg  1 0 0 1 1.193 1.2645 Tm (4) Tj ET Qendstreamendobj54 0 obj<< /Length 100 /Subtype /Form /BBox [ 0 0 10 9 ] /Resources << /ProcSet [ /PDF /Text ] /Font << /ZaDb 86 0 R >> >> >> stream
0.749 g 0 0 10 9 re f q 1 1 8 7 re W n BT /ZaDb 9 Tf 0 0 0.627 rg  1 0 0 1 1.193 1.2645 Tm (4) Tj ETendstreamendobj55 0 obj<< /Length 21 /Subtype /Form /BBox [ 0 0 10 9 ] /Resources << /ProcSet [ /PDF ] >> >> stream
0.749 g 0 0 10 9 re fendstreamendobj56 0 obj<< /Length 80 /Subtype /Form /BBox [ 0 0 9 9 ] /Resources << /ProcSet [ /PDF /Text ] /Font << /ZaDb 86 0 R >> >> >> stream
q 1 1 7 7 re W n BT /ZaDb 9 Tf 0 0 0.627 rg  1 0 0 1 0.693 1.2645 Tm (4) Tj ET Qendstreamendobj57 0 obj<< /Length 99 /Subtype /Form /BBox [ 0 0 9 9 ] /Resources << /ProcSet [ /PDF /Text ] /Font << /ZaDb 86 0 R >> >> >> stream
0.749 g 0 0 9 9 re f q 1 1 7 7 re W n BT /ZaDb 9 Tf 0 0 0.627 rg  1 0 0 1 0.693 1.2645 Tm (4) Tj ETendstreamendobj58 0 obj<< /Length 20 /Subtype /Form /BBox [ 0 0 9 9 ] /Resources << /ProcSet [ /PDF ] >> >> stream
0.749 g 0 0 9 9 re fendstreamendobj59 0 obj<< /N 161 0 R >> endobj60 0 obj<< /Type /Font /Name /Helv /BaseFont /Helvetica /Subtype /Type1 /Encoding 63 0 R >> endobj61 0 obj<< /Encoding 62 0 R /Font 64 0 R >> endobj62 0 obj<< /PDFDocEncoding 63 0 R >> endobj63 0 obj<< /Type /Encoding /Differences [ 24 /breve /caron /circumflex /dotaccent /hungarumlaut /ogonek /ring /tilde 39 /quotesingle 96 /grave 128 /bullet /dagger /daggerdbl /ellipsis /emdash /endash /florin /fraction /guilsinglleft /guilsinglright /minus /perthousand /quotedblbase /quotedblleft /quotedblright /quoteleft /quoteright /quotesinglbase /trademark /fi /fl /Lslash /OE /Scaron /Ydieresis /Zcaron /dotlessi /lslash /oe /scaron /zcaron 160 /Euro 164 /currency 166 /brokenbar 168 /dieresis /copyright /ordfeminine 172 /logicalnot /.notdef /registered /macron /degree /plusminus /twosuperior /threesuperior /acute /mu 183 /periodcentered /cedilla /onesuperior /ordmasculine 188 /onequarter /onehalf /threequarters 192 /Agrave /Aacute /Acircumflex /Atilde /Adieresis /Aring /AE /Ccedilla /Egrave /Eacute /Ecircumflex /Edieresis /Igrave /Iacute /Icircumflex /Idieresis /Eth /Ntilde /Ograve /Oacute /Ocircumflex /Otilde /Odieresis /multiply /Oslash /Ugrave /Uacute /Ucircumflex /Udieresis /Yacute /Thorn /germandbls /agrave /aacute /acircumflex /atilde /adieresis /aring /ae /ccedilla /egrave /eacute /ecircumflex /edieresis /igrave /iacute /icircumflex /idieresis /eth /ntilde /ograve /oacute /ocircumflex /otilde /odieresis /divide /oslash /ugrave /uacute /ucircumflex /udieresis /yacute /thorn /ydieresis ] >> endobj64 0 obj<< /Helv 60 0 R /HeBo 65 0 R /ZaDb 86 0 R >> endobj65 0 obj<< /Type /Font /Name /HeBo /BaseFont /Helvetica-Bold /Subtype /Type1 /Encoding 63 0 R >> endobj66 0 obj<< /CreationDate (D:19991124135053)/Producer (Acrobat Distiller 4.0 for Windows)/Creator (Mecca III\(TM\) 9.40)/Title (1999 Form 1065 \(Schedule K-1\))/Subject (Partner's Share of Income, Credits, Deductions, etc.)/Author (T:FP)/ModDate (D:20000322205057-07'00')>> endobj67 0 obj<< /Type /Pages /Kids [ 73 0 R 1 0 R ] /Count 2 >> endobj68 0 obj<< /Names [ (�� D r a f t - E N U - 0)161 0 R ] >> endobjxref0 69 0000000000 65535 f
0000044612 00000 n
0000044778 00000 n
0000045109 00000 n
0000045249 00000 n
0000045465 00000 n
0000045651 00000 n
0000051118 00000 n
0000051909 00000 n
0000052699 00000 n
0000053493 00000 n
0000053714 00000 n
0000053892 00000 n
0000054070 00000 n
0000054248 00000 n
0000054426 00000 n
0000054604 00000 n
0000054782 00000 n
0000054960 00000 n
0000055138 00000 n
0000055316 00000 n
0000055495 00000 n
0000055674 00000 n
0000055853 00000 n
0000056026 00000 n
0000056199 00000 n
0000056378 00000 n
0000056557 00000 n
0000056844 00000 n
0000057131 00000 n
0000057310 00000 n
0000057489 00000 n
0000057668 00000 n
0000057841 00000 n
0000058020 00000 n
0000058199 00000 n
0000058378 00000 n
0000058557 00000 n
0000058736 00000 n
0000058915 00000 n
0000059094 00000 n
0000059273 00000 n
0000059445 00000 n
0000059617 00000 n
0000059789 00000 n
0000059961 00000 n
0000060133 00000 n
0000060305 00000 n
0000060477 00000 n
0000060649 00000 n
0000060821 00000 n
0000060992 00000 n
0000061162 00000 n
0000061332 00000 n
0000061565 00000 n
0000061819 00000 n
0000061962 00000 n
0000062194 00000 n
0000062445 00000 n
0000062586 00000 n
0000062622 00000 n
0000062729 00000 n
0000062785 00000 n
0000062833 00000 n
0000064182 00000 n
0000064248 00000 n
0000064360 00000 n
0000064650 00000 n
0000064722 00000 n
trailer<</Size 69/ID[<db3eab5519572fe8ed8de0088f1c99d8><db3eab5519572fe8ed8de0088f1c99d8>]>>startxref173%%EOF
!!! Base Root Pointer !!!
70 0 R
!!! Base Size !!!
208
!!! Base Xref Offset !!!
173
!!! Xlator Set Class !!!
Bivio::UI::PDF::Form::F1065sk1::Y1999::XlatorSet
!!! Field Text !!!
78 0 obj
<<
/Type /Annot
/Subtype /Widget
/Rect [ 176.8392 711.46609 300.8392 722.46609 ]
/T (f1-4)
/FT /Tx
/P 73 0 R
/F 4
/DA (/HeBo 9 Tf 0 0 0.627 rg)
>>
endobj
81 0 obj
<<
/Type /Annot
/Subtype /Widget
/Rect [ 43.8392 651.46609 300.8392 699.46609 ]
/T (f1-5)
/FT /Tx
/P 73 0 R
/Ff 4096
/F 4
/DA (/HeBo 9 Tf 0 0 0.627 rg)
>>
endobj
79 0 obj
<<
/Type /Annot
/Subtype /Widget
/Rect [ 459.8392 711.46609 486.8392 722.46609 ]
/T (f1-6)
/FT /Tx
/Q 2
/P 73 0 R
/F 4
/DA (/HeBo 9 Tf 0 0 0.627 rg)
>>
endobj
80 0 obj
<<
/Type /Annot
/Subtype /Widget
/Rect [ 489.8392 711.46609 568.8392 722.46609 ]
/T (f1-7)
/FT /Tx
/P 73 0 R
/F 4
/DA (/HeBo 9 Tf 0 0 0.627 rg)
>>
endobj
82 0 obj
<<
/Type /Annot
/Subtype /Widget
/Rect [ 309.8392 651.46609 568.8392 699.46609 ]
/T (f1-8)
/FT /Tx
/P 73 0 R
/Ff 4096
/F 4
/DA (/HeBo 9 Tf 0 0 0.627 rg)
>>
endobj
92 0 obj
<<
/Type /Annot
/Subtype /Widget
/Rect [ 55.8392 626.46609 64.8392 635.46609 ]
/T (c1-3)
/FT /Btn
/DA (/HeBo 9 Tf 0 0 0.627 rg)
/F 4
/H /T
/MK << /CA (4) /AC (��) /RC (��) >>
/P 73 0 R
/AS /Off
/AP << /N << /On 95 0 R >> /D << /On 93 0 R /Off 94 0 R >> >>
>>
endobj
88 0 obj
<<
/Type /Annot
/Subtype /Widget
/Rect [ 214.8392 638.46609 223.8392 648.46609 ]
/T (c1-2)
/FT /Btn
/DA (/HeBo 9 Tf 0 0 0.627 rg)
/F 4
/H /T
/MK << /CA (4) /AC (��) /RC (��) >>
/P 73 0 R
/AS /Off
/AP << /N << /On 91 0 R >> /D << /On 89 0 R /Off 90 0 R >> >>
>>
endobj
83 0 obj
<<
/Type /Annot
/Subtype /Widget
/Rect [ 127.8392 638.46609 136.8392 648.46609 ]
/T (c1-1)
/FT /Btn
/DA (/HeBo 9 Tf 0 0 0.627 rg)
/F 4
/H /T
/MK << /CA (4) /AC (��) /RC (��) >>
/P 73 0 R
/AS /Off
/AP << /N << /On 87 0 R >> /D << /On 84 0 R /Off 85 0 R >> >>
>>
endobj
96 0 obj
<<
/Type /Annot
/Subtype /Widget
/Rect [ 219.8392 615.46609 299.8392 628.46609 ]
/T (f1-9)
/FT /Tx
/P 73 0 R
/F 4
/DA (/HeBo 9 Tf 0 0 0.627 rg)
>>
endobj
97 0 obj
<<
/Type /Annot
/Subtype /Widget
/Rect [ 127.8392 603.46609 137.8392 611.46609 ]
/T (c1-4)
/FT /Btn
/DA (/HeBo 9 Tf 0 0 0.627 rg)
/F 4
/H /T
/MK << /CA (4) /AC (��) /RC (��) >>
/P 73 0 R
/AS /Off
/AP << /N << /On 100 0 R >> /D << /On 98 0 R /Off 99 0 R >> >>
>>
endobj
101 0 obj
<<
/Type /Annot
/Subtype /Widget
/Rect [ 206.8392 603.46609 215.8392 611.46609 ]
/T (c1-5)
/FT /Btn
/DA (/HeBo 9 Tf 0 0 0.627 rg)
/F 4
/H /T
/MK << /CA (4) /AC (��) /RC (��) >>
/P 73 0 R
/AS /Off
/AP << /N << /On 104 0 R >> /D << /On 102 0 R /Off 103 0 R >> >>
>>
endobj
105 0 obj
<<
/Type /Annot
/Subtype /Widget
/Rect [ 203.8392 579.46609 233.8392 589.46609 ]
/T (f1-10)
/FT /Tx
/Q 2
/P 73 0 R
/F 4
/DA (/HeBo 9 Tf 0 0 0.627 rg)
>>
endobj
106 0 obj
<<
/Type /Annot
/Subtype /Widget
/Rect [ 255.8392 579.46609 285.8392 589.46609 ]
/T (f1-11)
/FT /Tx
/Q 2
/P 73 0 R
/F 4
/DA (/HeBo 9 Tf 0 0 0.627 rg)
>>
endobj
107 0 obj
<<
/Type /Annot
/Subtype /Widget
/Rect [ 203.8392 567.46609 233.8392 579.46609 ]
/T (f1-12)
/FT /Tx
/Q 2
/P 73 0 R
/F 4
/DA (/HeBo 9 Tf 0 0 0.627 rg)
>>
endobj
108 0 obj
<<
/Type /Annot
/Subtype /Widget
/Rect [ 255.8392 567.46609 285.8392 579.46609 ]
/T (f1-13)
/FT /Tx
/Q 2
/P 73 0 R
/F 4
/DA (/HeBo 9 Tf 0 0 0.627 rg)
>>
endobj
109 0 obj
<<
/Type /Annot
/Subtype /Widget
/Rect [ 203.8392 556.46609 233.8392 567.46609 ]
/T (f1-14)
/FT /Tx
/Q 2
/P 73 0 R
/F 4
/DA (/HeBo 9 Tf 0 0 0.627 rg)
>>
endobj
110 0 obj
<<
/Type /Annot
/Subtype /Widget
/Rect [ 255.8392 556.46609 285.8392 567.46609 ]
/T (f1-15)
/FT /Tx
/Q 2
/P 73 0 R
/F 4
/DA (/HeBo 9 Tf 0 0 0.627 rg)
>>
endobj
111 0 obj
<<
/Type /Annot
/Subtype /Widget
/Rect [ 226.8392 543.46609 300.8392 556.46609 ]
/T (f1-15a)
/FT /Tx
/P 73 0 R
/F 4
/DA (/HeBo 9 Tf 0 0 0.627 rg)
>>
endobj
124 0 obj
<<
/Type /Annot
/Subtype /Widget
/Rect [ 501.8392 546.46609 510.8392 555.46609 ]
/T (c1-8)
/FT /Btn
/DA (/HeBo 9 Tf 0 0 0.627 rg)
/F 4
/H /T
/MK << /CA (4) /AC (��) /RC (��) >>
/P 73 0 R
/AS /Off
/AP << /N << /On 127 0 R >> /D << /On 125 0 R /Off 126 0 R >> >>
>>
endobj
120 0 obj
<<
/Type /Annot
/Subtype /Widget
/Rect [ 436.8392 546.46609 445.8392 555.46609 ]
/T (c1-7)
/FT /Btn
/DA (/HeBo 9 Tf 0 0 0.627 rg)
/F 4
/H /T
/MK << /CA (4) /AC (��) /RC (��) >>
/P 73 0 R
/AS /Off
/AP << /N << /On 123 0 R >> /D << /On 121 0 R /Off 122 0 R >> >>
>>
endobj
136 0 obj
<<
/Type /Annot
/Subtype /Widget
/Rect [ 365.8392 411.46609 457.8392 424.46609 ]
/T (f1-28)
/FT /Tx
/Q 2
/P 73 0 R
/F 4
/DA (/HeBo 9 Tf 0 0 0.627 rg)
>>
endobj
137 0 obj
<<
/Type /Annot
/Subtype /Widget
/Rect [ 365.8392 399.46609 457.8392 410.46609 ]
/T (f1-29)
/FT /Tx
/Q 2
/P 73 0 R
/F 4
/DA (/HeBo 9 Tf 0 0 0.627 rg)
>>
endobj
139 0 obj
<<
/Type /Annot
/Subtype /Widget
/Rect [ 365.8392 375.46609 457.8392 387.46609 ]
/T (f1-31)
/FT /Tx
/Q 2
/P 73 0 R
/F 4
/DA (/HeBo 9 Tf 0 0 0.627 rg)
>>
endobj
141 0 obj
<<
/Type /Annot
/Subtype /Widget
/Rect [ 365.8392 339.46609 457.8392 351.46609 ]
/T (f1-33)
/FT /Tx
/Q 2
/P 73 0 R
/F 4
/DA (/HeBo 9 Tf 0 0 0.627 rg)
>>
endobj
142 0 obj
<<
/Type /Annot
/Subtype /Widget
/Rect [ 365.8392 327.46609 457.8392 339.46609 ]
/T (f1-34)
/FT /Tx
/Q 2
/P 73 0 R
/F 4
/DA (/HeBo 9 Tf 0 0 0.627 rg)
>>
endobj
148 0 obj
<<
/Type /Annot
/Subtype /Widget
/Rect [ 365.8392 243.46609 457.8392 255.46609 ]
/T (f1-40)
/FT /Tx
/Q 2
/P 73 0 R
/F 4
/DA (/HeBo 9 Tf 0 0 0.627 rg)
>>
endobj
12 0 obj
<<
/Type /Annot
/Subtype /Widget
/Rect [ 366.08548 687.61502 458.08548 698.61502 ]
/T (f2-2)
/FT /Tx
/Q 2
/P 1 0 R
/F 4
/DA (/HeBo 9 Tf 0 0 0.627 rg)
>>
endobj
13 0 obj
<<
/Type /Annot
/Subtype /Widget
/Rect [ 366.08548 674.61502 458.08548 686.61502 ]
/T (f2-3)
/FT /Tx
/Q 2
/P 1 0 R
/F 4
/DA (/HeBo 9 Tf 0 0 0.627 rg)
>>
endobj
23 0 obj
<<
/Type /Annot
/Subtype /Widget
/Rect [ 163.08548 554.61502 336.08548 566.61502 ]
/T (f2-13)
/FT /Tx
/P 1 0 R
/F 4
/DA (/HeBo 9 Tf 0 0 0.627 rg)
>>
endobj
24 0 obj
<<
/Type /Annot
/Subtype /Widget
/Rect [ 252.08548 542.61502 335.08548 554.61502 ]
/T (f2-14)
/FT /Tx
/P 1 0 R
/F 4
/DA (/HeBo 9 Tf 0 0 0.627 rg)
>>
endobj
25 0 obj
<<
/Type /Annot
/Subtype /Widget
/Rect [ 366.08548 519.61502 458.08548 532.61502 ]
/T (f2-15)
/FT /Tx
/Q 2
/P 1 0 R
/F 4
/DA (/HeBo 9 Tf 0 0 0.627 rg)
>>
endobj
28 0 obj
<<
/Type /Annot
/Subtype /Widget
/Rect [ 261.08548 494.61502 270.08548 503.61502 ]
/T (c2-2)
/FT /Btn
/DA (/HeBo 9 Tf 0 0 0.627 rg)
/F 4
/H /T
/MK << /CA (4) /AC (��) /RC (��) >>
/P 1 0 R
/AS /Off
/AP << /N << /On 56 0 R >> /D << /On 57 0 R /Off 58 0 R >> >>
>>
endobj
27 0 obj
<<
/Type /Annot
/Subtype /Widget
/Rect [ 224.08548 494.61502 234.08548 503.61502 ]
/T (c2-1)
/FT /Btn
/DA (/HeBo 9 Tf 0 0 0.627 rg)
/F 4
/H /T
/MK << /CA (4) /AC (��) /RC (��) >>
/P 1 0 R
/AS /Off
/AP << /N << /On 53 0 R >> /D << /On 54 0 R /Off 55 0 R >> >>
>>
endobj
29 0 obj
<<
/Type /Annot
/Subtype /Widget
/Rect [ 366.08548 494.61502 458.08548 506.61502 ]
/T (f2-17)
/FT /Tx
/Q 2
/P 1 0 R
/F 4
/DA (/HeBo 9 Tf 0 0 0.627 rg)
>>
endobj
34 0 obj
<<
/Type /Annot
/Subtype /Widget
/Rect [ 366.08548 435.61502 458.08548 447.61502 ]
/T (f2-22)
/FT /Tx
/Q 2
/P 1 0 R
/F 4
/DA (/HeBo 9 Tf 0 0 0.627 rg)
>>
endobj
37 0 obj
<<
/Type /Annot
/Subtype /Widget
/Rect [ 366.08548 399.61502 458.08548 410.61502 ]
/T (f2-25)
/FT /Tx
/Q 2
/P 1 0 R
/F 4
/DA (/HeBo 9 Tf 0 0 0.627 rg)
>>
endobj
38 0 obj
<<
/Type /Annot
/Subtype /Widget
/Rect [ 366.08548 387.61502 458.08548 398.61502 ]
/T (f2-26)
/FT /Tx
/Q 2
/P 1 0 R
/F 4
/DA (/HeBo 9 Tf 0 0 0.627 rg)
>>
endobj
!!! Data End !!!
