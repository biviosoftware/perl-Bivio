# This file was built by buildFormModule.pl
# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id: buildFormModule.pl,v 1.2 2000/03/20 05:43:48 yates Exp $
package Bivio::UI::PDF::Form::f1065sk1::y1999::Form;
use strict;
$Bivio::UI::PDF::Form::f1065sk1::y1999::Form::VERSION = sprintf('%d.%02d', q$Revision: 1.2 $ =~ /\d+/g);

=head1 NAME

Bivio::UI::PDF::Form::f1065sk1::y1999::Form - 

=head1 SYNOPSIS

    use Bivio::UI::PDF::Form::f1065sk1::y1999::Form;
    Bivio::UI::PDF::Form::f1065sk1::y1999::Form->new();

=cut

=head1 EXTENDS

L<Bivio::UI::PDF::Form::Form>

=cut

use Bivio::UI::PDF::Form::Form;
@Bivio::UI::PDF::Form::f1065sk1::y1999::Form::ISA = ('Bivio::UI::PDF::Form::Form');

=head1 DESCRIPTION

C<Bivio::UI::PDF::Form::f1065sk1::y1999::Form>

=cut

#=IMPORTS
use Bivio::UI::PDF::OpaqueUpdate;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

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

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::UI::PDF::Form::f1065sk1::y1999::Form



=cut

sub new {
    my($self) = Bivio::UI::PDF::Form::Form::new(@_);
    $self->{$_PACKAGE} = {};
    return $self;
}

=head1 METHODS

=cut

=for html <a name="get_base_update_ref"></a>

=head2 get_base_update_ref() : 



=cut

sub get_base_update_ref {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    return($_BASE_UPDATE_REF);
}

=for html <a name="get_field_ref"></a>

=head2 get_field_ref() : 



=cut

sub get_field_ref {
    my($self, $field_name) = @_;
    my($fields) = $self->{$_PACKAGE};
    my($field_obj_ref) = ${$_FIELD_DICTIONARY_REF}{$field_name};
    unless (defined($field_obj_ref)) {
	die("Clone failure; did you forget to remake the Form.pm file?");
    }
    return($field_obj_ref->clone());
}

=for html <a name="get_obj_ref"></a>

=head2 get_obj_ref() : 



=cut

sub get_obj_ref {
    my($self, $obj_number) = @_;
    my($fields) = $self->{$_PACKAGE};
    return(${$_OBJ_DICTIONARY_REF}{$obj_number}->clone());
}

=for html <a name="get_xlator_set_ref"></a>

=head2 get_xlator_set_ref() : 



=cut

sub get_xlator_set_ref {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    return($_XLATOR_SET_REF);
}

=for html <a name="initialize"></a>

=head2 initialize() : 



=cut

sub initialize {
    my($proto) = @_;
    ($_BASE_UPDATE_REF, $_XLATOR_SET_REF, $_FIELD_DICTIONARY_REF,
	   $_OBJ_DICTIONARY_REF)
	    = $proto->_read_data(\*DATA);

    $_INITIALIZED = 1;

    return;
}

=for html <a name="initialized"></a>

=head2 initialized() : 



=cut

sub initialized {
    my($proto) = @_;
    return($_INITIALIZED);
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id: buildFormModule.pl,v 1.2 2000/03/20 05:43:48 yates Exp $

=cut

1;

__DATA__
%%% PDF Base File %%%
%PDF-1.3%����
65 0 obj<< /Linearized 1 /O 68 /H [ 3847 634 ] /L 59877 /E 38913 /N 2 /T 58459 >> endobj                                                          xref65 130 0000000016 00000 n
0000002949 00000 n
0000003022 00000 n
0000004481 00000 n
0000004713 00000 n
0000005191 00000 n
0000005368 00000 n
0000005545 00000 n
0000005718 00000 n
0000005889 00000 n
0000006066 00000 n
0000006237 00000 n
0000006417 00000 n
0000006598 00000 n
0000006884 00000 n
0000007138 00000 n
0000007281 00000 n
0000007373 00000 n
0000007606 00000 n
0000007892 00000 n
0000008146 00000 n
0000008289 00000 n
0000008522 00000 n
0000008806 00000 n
0000009057 00000 n
0000009198 00000 n
0000009430 00000 n
0000009601 00000 n
0000009887 00000 n
0000010141 00000 n
0000010284 00000 n
0000010517 00000 n
0000010803 00000 n
0000011054 00000 n
0000011195 00000 n
0000011427 00000 n
0000011606 00000 n
0000011785 00000 n
0000011964 00000 n
0000012143 00000 n
0000012322 00000 n
0000012501 00000 n
0000012675 00000 n
0000012854 00000 n
0000013033 00000 n
0000013212 00000 n
0000013385 00000 n
0000013675 00000 n
0000013927 00000 n
0000014069 00000 n
0000014302 00000 n
0000014592 00000 n
0000014844 00000 n
0000014986 00000 n
0000015219 00000 n
0000015509 00000 n
0000015761 00000 n
0000015903 00000 n
0000016136 00000 n
0000016314 00000 n
0000016493 00000 n
0000016672 00000 n
0000016851 00000 n
0000017030 00000 n
0000017209 00000 n
0000017388 00000 n
0000017567 00000 n
0000017746 00000 n
0000017925 00000 n
0000018104 00000 n
0000018283 00000 n
0000018462 00000 n
0000018641 00000 n
0000018820 00000 n
0000018999 00000 n
0000019178 00000 n
0000019357 00000 n
0000019536 00000 n
0000019715 00000 n
0000019894 00000 n
0000020073 00000 n
0000020252 00000 n
0000020431 00000 n
0000020610 00000 n
0000020789 00000 n
0000020968 00000 n
0000021146 00000 n
0000021323 00000 n
0000021500 00000 n
0000021703 00000 n
0000021914 00000 n
0000022610 00000 n
0000022680 00000 n
0000023379 00000 n
0000023589 00000 n
0000024440 00000 n
0000024654 00000 n
0000025012 00000 n
0000025247 00000 n
0000025435 00000 n
0000025458 00000 n
0000026591 00000 n
0000026614 00000 n
0000026827 00000 n
0000027620 00000 n
0000027830 00000 n
0000028622 00000 n
0000029785 00000 n
0000029807 00000 n
0000030656 00000 n
0000030678 00000 n
0000030898 00000 n
0000031695 00000 n
0000032689 00000 n
0000032711 00000 n
0000033138 00000 n
0000033326 00000 n
0000033564 00000 n
0000033634 00000 n
0000034569 00000 n
0000034591 00000 n
0000034813 00000 n
0000035611 00000 n
0000036609 00000 n
0000036631 00000 n
0000037645 00000 n
0000037667 00000 n
0000037746 00000 n
0000003847 00000 n
0000004459 00000 n
trailer<</Size 195/Info 63 0 R /Root 66 0 R /Prev 58449 /ID[<91da8e308ff95581fb7fae43e15e76d0><91da8e308ff95581fb7fae43e15e76d0>]>>startxref0%%EOF     66 0 obj<< /Type /Catalog /Pages 64 0 R /AcroForm 67 0 R >> endobj67 0 obj<< /Fields [ 70 0 R 71 0 R 72 0 R 73 0 R 74 0 R 75 0 R 76 0 R 77 0 R 78 0 R 83 0 R 87 0 R 91 0 R 92 0 R 96 0 R 100 0 R 101 0 R 102 0 R 103 0 R 104 0 R 105 0 R 106 0 R 107 0 R 108 0 R 109 0 R 110 0 R 111 0 R 115 0 R 119 0 R 123 0 R 124 0 R 125 0 R 126 0 R 127 0 R 128 0 R 129 0 R 130 0 R 131 0 R 132 0 R 133 0 R 134 0 R 135 0 R 136 0 R 137 0 R 138 0 R 139 0 R 140 0 R 141 0 R 142 0 R 143 0 R 144 0 R 145 0 R 146 0 R 147 0 R 148 0 R 149 0 R 150 0 R 151 0 R 152 0 R 9 0 R 10 0 R 11 0 R 12 0 R 13 0 R 14 0 R 15 0 R 16 0 R 17 0 R 18 0 R 19 0 R 20 0 R 21 0 R 22 0 R 23 0 R 24 0 R 25 0 R 26 0 R 27 0 R 28 0 R 29 0 R 30 0 R 31 0 R 32 0 R 33 0 R 34 0 R 35 0 R 36 0 R 37 0 R 38 0 R 39 0 R 40 0 R 41 0 R 42 0 R 43 0 R 44 0 R 45 0 R 46 0 R 47 0 R 48 0 R 49 0 R 50 0 R ] /DR 58 0 R /DA (/Helv 0 Tf 0 g )>> endobj193 0 obj<< /S 311 /V 602 /Filter /FlateDecode /Length 194 0 R >> stream
H�b```a`�gg`g`���π �@1�,�'�ۇ��0�t�tM��8iB_{m]LTtck[KSs��%�,\�rՊ�˗M�2c���s�͝5;>"6.%9';�����a�����6�'l���KhhZ2���QPPP��4��@��������`1n)w�΍z�.7�
�i�k�$�6�C��I��S��&LUd^`�k$`����΋V�.�����c��#s�A&�9c\�������t]_-b�g|�!�m�2���ol�"�<ox��>30N9� a)�`$�|�����y�����r�8Z��<�#�T 2W�Ȏ��KTZ�V�@�m�Сo�DՖӄx�^�s�����d`��H��) ������-$( &*"-%)/'���cdh`fj�z�`��Z�b���K/Z�`���sfϚ9c���S&O�8���������������1$8(0��������������������������X_[KSC]MUEYIQAFB\����������� � ���lendstreamendobj194 0 obj518 endobj68 0 obj<< /Type /Page /Parent 64 0 R /Resources 153 0 R /Contents [ 165 0 R 171 0 R 173 0 R 177 0 R 183 0 R 187 0 R 189 0 R 192 0 R ] /MediaBox [ 0 0 612 792 ] /CropBox [ 0 0 612 792 ] /Rotate 0 /Annots 69 0 R >> endobj69 0 obj[ 70 0 R 71 0 R 72 0 R 73 0 R 74 0 R 75 0 R 76 0 R 77 0 R 78 0 R 83 0 R 87 0 R 91 0 R 92 0 R 96 0 R 100 0 R 101 0 R 102 0 R 103 0 R 104 0 R 105 0 R 106 0 R 107 0 R 108 0 R 109 0 R 110 0 R 111 0 R 115 0 R 119 0 R 123 0 R 124 0 R 125 0 R 126 0 R 127 0 R 128 0 R 129 0 R 130 0 R 131 0 R 132 0 R 133 0 R 134 0 R 135 0 R 136 0 R 137 0 R 138 0 R 139 0 R 140 0 R 141 0 R 142 0 R 143 0 R 144 0 R 145 0 R 146 0 R 147 0 R 148 0 R 149 0 R 150 0 R 151 0 R 152 0 R ]endobj70 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 281.8392 723.46609 341.8392 735.46609 ] /T (f1-1)/FT /Tx /Q 1 /P 68 0 R /F 4 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj71 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 403.8392 723.46609 462.8392 736.46609 ] /T (f1-2)/FT /Tx /Q 1 /P 68 0 R /F 4 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj72 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 465.12463 723.34253 495.52783 736.77551 ] /T (f1-3)/FT /Tx /P 68 0 R /F 4 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj73 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 176.8392 711.46609 300.8392 722.46609 ] /T (f1-4)/FT /Tx /P 68 0 R /F 4 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj74 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 459.8392 711.46609 486.8392 722.46609 ] /T (f1-6)/FT /Tx /Q 2 /P 68 0 R /F 4 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj75 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 489.8392 711.46609 568.8392 722.46609 ] /T (f1-7)/FT /Tx /P 68 0 R /F 4 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj76 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 43.8392 651.46609 300.8392 699.46609 ] /T (f1-5)/FT /Tx /P 68 0 R /Ff 4096 /F 4 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj77 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 309.8392 651.46609 568.8392 699.46609 ] /T (f1-8)/FT /Tx /P 68 0 R /Ff 4096 /F 4 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj78 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 127.8392 638.46609 136.8392 648.46609 ] /T (c1-1)/FT /Btn /DA (/HeBo 9 Tf 0 0 0.627 rg)/F 4 /H /T /MK << /CA (4)/AC (��)/RC (��)>> /P 68 0 R /AS /Off /AP << /N << /On 82 0 R >> /D << /On 79 0 R /Off 80 0 R >> >> >> endobj79 0 obj<< /Length 100 /Subtype /Form /BBox [ 0 0 9 10 ] /Resources << /ProcSet [ /PDF /Text ] /Font << /ZaDb 81 0 R >> >> >> stream
0.749 g 0 0 9 10 re f q 1 1 7 8 re W n BT /ZaDb 9 Tf 0 0 0.627 rg  1 0 0 1 0.693 1.7645 Tm (4) Tj ETendstreamendobj80 0 obj<< /Length 21 /Subtype /Form /BBox [ 0 0 9 10 ] /Resources << /ProcSet [ /PDF ] >> >> stream
0.749 g 0 0 9 10 re fendstreamendobj81 0 obj<< /Type /Font /Name /ZaDb /BaseFont /ZapfDingbats /Subtype /Type1 >> endobj82 0 obj<< /Length 80 /Subtype /Form /BBox [ 0 0 9 10 ] /Resources << /ProcSet [ /PDF /Text ] /Font << /ZaDb 81 0 R >> >> >> stream
q 1 1 7 8 re W n BT /ZaDb 9 Tf 0 0 0.627 rg  1 0 0 1 0.693 1.7645 Tm (4) Tj ET Qendstreamendobj83 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 214.8392 638.46609 223.8392 648.46609 ] /T (c1-2)/FT /Btn /DA (/HeBo 9 Tf 0 0 0.627 rg)/F 4 /H /T /MK << /CA (4)/AC (��)/RC (��)>> /P 68 0 R /AS /Off /AP << /N << /On 86 0 R >> /D << /On 84 0 R /Off 85 0 R >> >> >> endobj84 0 obj<< /Length 100 /Subtype /Form /BBox [ 0 0 9 10 ] /Resources << /ProcSet [ /PDF /Text ] /Font << /ZaDb 81 0 R >> >> >> stream
0.749 g 0 0 9 10 re f q 1 1 7 8 re W n BT /ZaDb 9 Tf 0 0 0.627 rg  1 0 0 1 0.693 1.7645 Tm (4) Tj ETendstreamendobj85 0 obj<< /Length 21 /Subtype /Form /BBox [ 0 0 9 10 ] /Resources << /ProcSet [ /PDF ] >> >> stream
0.749 g 0 0 9 10 re fendstreamendobj86 0 obj<< /Length 80 /Subtype /Form /BBox [ 0 0 9 10 ] /Resources << /ProcSet [ /PDF /Text ] /Font << /ZaDb 81 0 R >> >> >> stream
q 1 1 7 8 re W n BT /ZaDb 9 Tf 0 0 0.627 rg  1 0 0 1 0.693 1.7645 Tm (4) Tj ET Qendstreamendobj87 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 55.8392 626.46609 64.8392 635.46609 ] /T (c1-3)/FT /Btn /DA (/HeBo 9 Tf 0 0 0.627 rg)/F 4 /H /T /MK << /CA (4)/AC (��)/RC (��)>> /P 68 0 R /AS /Off /AP << /N << /On 90 0 R >> /D << /On 88 0 R /Off 89 0 R >> >> >> endobj88 0 obj<< /Length 99 /Subtype /Form /BBox [ 0 0 9 9 ] /Resources << /ProcSet [ /PDF /Text ] /Font << /ZaDb 81 0 R >> >> >> stream
0.749 g 0 0 9 9 re f q 1 1 7 7 re W n BT /ZaDb 9 Tf 0 0 0.627 rg  1 0 0 1 0.693 1.2645 Tm (4) Tj ETendstreamendobj89 0 obj<< /Length 20 /Subtype /Form /BBox [ 0 0 9 9 ] /Resources << /ProcSet [ /PDF ] >> >> stream
0.749 g 0 0 9 9 re fendstreamendobj90 0 obj<< /Length 80 /Subtype /Form /BBox [ 0 0 9 9 ] /Resources << /ProcSet [ /PDF /Text ] /Font << /ZaDb 81 0 R >> >> >> stream
q 1 1 7 7 re W n BT /ZaDb 9 Tf 0 0 0.627 rg  1 0 0 1 0.693 1.2645 Tm (4) Tj ET Qendstreamendobj91 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 219.8392 615.46609 299.8392 628.46609 ] /T (f1-9)/FT /Tx /P 68 0 R /F 4 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj92 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 127.8392 603.46609 137.8392 611.46609 ] /T (c1-4)/FT /Btn /DA (/HeBo 9 Tf 0 0 0.627 rg)/F 4 /H /T /MK << /CA (4)/AC (��)/RC (��)>> /P 68 0 R /AS /Off /AP << /N << /On 95 0 R >> /D << /On 93 0 R /Off 94 0 R >> >> >> endobj93 0 obj<< /Length 100 /Subtype /Form /BBox [ 0 0 10 8 ] /Resources << /ProcSet [ /PDF /Text ] /Font << /ZaDb 81 0 R >> >> >> stream
0.749 g 0 0 10 8 re f q 1 1 8 6 re W n BT /ZaDb 9 Tf 0 0 0.627 rg  1 0 0 1 1.193 0.7645 Tm (4) Tj ETendstreamendobj94 0 obj<< /Length 21 /Subtype /Form /BBox [ 0 0 10 8 ] /Resources << /ProcSet [ /PDF ] >> >> stream
0.749 g 0 0 10 8 re fendstreamendobj95 0 obj<< /Length 80 /Subtype /Form /BBox [ 0 0 10 8 ] /Resources << /ProcSet [ /PDF /Text ] /Font << /ZaDb 81 0 R >> >> >> stream
q 1 1 8 6 re W n BT /ZaDb 9 Tf 0 0 0.627 rg  1 0 0 1 1.193 0.7645 Tm (4) Tj ET Qendstreamendobj96 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 206.8392 603.46609 215.8392 611.46609 ] /T (c1-5)/FT /Btn /DA (/HeBo 9 Tf 0 0 0.627 rg)/F 4 /H /T /MK << /CA (4)/AC (��)/RC (��)>> /P 68 0 R /AS /Off /AP << /N << /On 99 0 R >> /D << /On 97 0 R /Off 98 0 R >> >> >> endobj97 0 obj<< /Length 99 /Subtype /Form /BBox [ 0 0 9 8 ] /Resources << /ProcSet [ /PDF /Text ] /Font << /ZaDb 81 0 R >> >> >> stream
0.749 g 0 0 9 8 re f q 1 1 7 6 re W n BT /ZaDb 9 Tf 0 0 0.627 rg  1 0 0 1 0.693 0.7645 Tm (4) Tj ETendstreamendobj98 0 obj<< /Length 20 /Subtype /Form /BBox [ 0 0 9 8 ] /Resources << /ProcSet [ /PDF ] >> >> stream
0.749 g 0 0 9 8 re fendstreamendobj99 0 obj<< /Length 80 /Subtype /Form /BBox [ 0 0 9 8 ] /Resources << /ProcSet [ /PDF /Text ] /Font << /ZaDb 81 0 R >> >> >> stream
q 1 1 7 6 re W n BT /ZaDb 9 Tf 0 0 0.627 rg  1 0 0 1 0.693 0.7645 Tm (4) Tj ET Qendstreamendobj100 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 203.8392 579.46609 233.8392 589.46609 ] /T (f1-10)/FT /Tx /Q 2 /P 68 0 R /F 4 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj101 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 255.8392 579.46609 285.8392 589.46609 ] /T (f1-11)/FT /Tx /Q 2 /P 68 0 R /F 4 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj102 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 203.8392 567.46609 233.8392 579.46609 ] /T (f1-12)/FT /Tx /Q 2 /P 68 0 R /F 4 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj103 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 255.8392 567.46609 285.8392 579.46609 ] /T (f1-13)/FT /Tx /Q 2 /P 68 0 R /F 4 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj104 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 203.8392 556.46609 233.8392 567.46609 ] /T (f1-14)/FT /Tx /Q 2 /P 68 0 R /F 4 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj105 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 255.8392 556.46609 285.8392 567.46609 ] /T (f1-15)/FT /Tx /Q 2 /P 68 0 R /F 4 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj106 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 226.8392 543.46609 300.8392 556.46609 ] /T (f1-15a)/FT /Tx /P 68 0 R /F 4 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj107 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 495.8392 627.46609 564.8392 639.46609 ] /T (f1-16)/FT /Tx /Q 2 /P 68 0 R /F 4 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj108 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 495.8392 615.46609 564.8392 627.46609 ] /T (f1-17)/FT /Tx /Q 2 /P 68 0 R /F 4 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj109 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 495.8392 603.46609 564.8392 615.46609 ] /T (f1-18)/FT /Tx /Q 2 /P 68 0 R /F 4 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj110 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 475.8392 591.46609 565.8392 603.46609 ] /T (f1-19)/FT /Tx /P 68 0 R /F 4 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj111 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 559.8392 566.46609 568.8392 575.46609 ] /T (c1-6)/FT /Btn /DA (/HeBo 9 Tf 0 0 0.627 rg)/F 4 /H /T /MK << /CA (4)/AC (��)/RC (��)>> /P 68 0 R /AS /Off /AP << /N << /On 114 0 R >> /D << /On 112 0 R /Off 113 0 R >> >> >> endobj112 0 obj<< /Length 99 /Subtype /Form /BBox [ 0 0 9 9 ] /Resources << /ProcSet [ /PDF /Text ] /Font << /ZaDb 81 0 R >> >> >> stream
0.749 g 0 0 9 9 re f q 1 1 7 7 re W n BT /ZaDb 9 Tf 0 0 0.627 rg  1 0 0 1 0.693 1.2645 Tm (4) Tj ETendstreamendobj113 0 obj<< /Length 20 /Subtype /Form /BBox [ 0 0 9 9 ] /Resources << /ProcSet [ /PDF ] >> >> stream
0.749 g 0 0 9 9 re fendstreamendobj114 0 obj<< /Length 80 /Subtype /Form /BBox [ 0 0 9 9 ] /Resources << /ProcSet [ /PDF /Text ] /Font << /ZaDb 81 0 R >> >> >> stream
q 1 1 7 7 re W n BT /ZaDb 9 Tf 0 0 0.627 rg  1 0 0 1 0.693 1.2645 Tm (4) Tj ET Qendstreamendobj115 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 436.8392 546.46609 445.8392 555.46609 ] /T (c1-7)/FT /Btn /DA (/HeBo 9 Tf 0 0 0.627 rg)/F 4 /H /T /MK << /CA (4)/AC (��)/RC (��)>> /P 68 0 R /AS /Off /AP << /N << /On 118 0 R >> /D << /On 116 0 R /Off 117 0 R >> >> >> endobj116 0 obj<< /Length 99 /Subtype /Form /BBox [ 0 0 9 9 ] /Resources << /ProcSet [ /PDF /Text ] /Font << /ZaDb 81 0 R >> >> >> stream
0.749 g 0 0 9 9 re f q 1 1 7 7 re W n BT /ZaDb 9 Tf 0 0 0.627 rg  1 0 0 1 0.693 1.2645 Tm (4) Tj ETendstreamendobj117 0 obj<< /Length 20 /Subtype /Form /BBox [ 0 0 9 9 ] /Resources << /ProcSet [ /PDF ] >> >> stream
0.749 g 0 0 9 9 re fendstreamendobj118 0 obj<< /Length 80 /Subtype /Form /BBox [ 0 0 9 9 ] /Resources << /ProcSet [ /PDF /Text ] /Font << /ZaDb 81 0 R >> >> >> stream
q 1 1 7 7 re W n BT /ZaDb 9 Tf 0 0 0.627 rg  1 0 0 1 0.693 1.2645 Tm (4) Tj ET Qendstreamendobj119 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 501.8392 546.46609 510.8392 555.46609 ] /T (c1-8)/FT /Btn /DA (/HeBo 9 Tf 0 0 0.627 rg)/F 4 /H /T /MK << /CA (4)/AC (��)/RC (��)>> /P 68 0 R /AS /Off /AP << /N << /On 122 0 R >> /D << /On 120 0 R /Off 121 0 R >> >> >> endobj120 0 obj<< /Length 99 /Subtype /Form /BBox [ 0 0 9 9 ] /Resources << /ProcSet [ /PDF /Text ] /Font << /ZaDb 81 0 R >> >> >> stream
0.749 g 0 0 9 9 re f q 1 1 7 7 re W n BT /ZaDb 9 Tf 0 0 0.627 rg  1 0 0 1 0.693 1.2645 Tm (4) Tj ETendstreamendobj121 0 obj<< /Length 20 /Subtype /Form /BBox [ 0 0 9 9 ] /Resources << /ProcSet [ /PDF ] >> >> stream
0.749 g 0 0 9 9 re fendstreamendobj122 0 obj<< /Length 80 /Subtype /Form /BBox [ 0 0 9 9 ] /Resources << /ProcSet [ /PDF /Text ] /Font << /ZaDb 81 0 R >> >> >> stream
q 1 1 7 7 re W n BT /ZaDb 9 Tf 0 0 0.627 rg  1 0 0 1 0.693 1.2645 Tm (4) Tj ET Qendstreamendobj123 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 40.8392 495.46609 160.8392 507.46609 ] /T (f1-20)/FT /Tx /Q 2 /P 68 0 R /F 4 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj124 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 164.8392 495.46609 260.8392 507.46609 ] /T (f1-21)/FT /Tx /Q 2 /P 68 0 R /F 4 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj125 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 265.8392 495.46609 362.8392 507.46609 ] /T (f1-22)/FT /Tx /Q 2 /P 68 0 R /F 4 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj126 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 368.8392 495.46609 454.8392 507.46609 ] /T (f1-23)/FT /Tx /Q 2 /P 68 0 R /F 4 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj127 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 459.8392 495.46609 564.8392 507.46609 ] /T (f1-24)/FT /Tx /Q 2 /P 68 0 R /F 4 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj128 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 365.8392 459.46609 457.8392 471.46609 ] /T (f1-25)/FT /Tx /Q 2 /P 68 0 R /F 4 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj129 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 365.8392 447.46609 457.8392 459.46609 ] /T (f1-26)/FT /Tx /Q 2 /P 68 0 R /F 4 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj130 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 365.8392 435.46609 457.8392 447.46609 ] /T (f1-27)/FT /Tx /Q 2 /P 68 0 R /F 4 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj131 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 365.8392 411.46609 457.8392 424.46609 ] /T (f1-28)/FT /Tx /Q 2 /P 68 0 R /F 4 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj132 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 365.8392 399.46609 457.8392 410.46609 ] /T (f1-29)/FT /Tx /Q 2 /P 68 0 R /F 4 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj133 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 365.8392 387.46609 457.8392 398.46609 ] /T (f1-30)/FT /Tx /Q 2 /P 68 0 R /F 4 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj134 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 365.8392 375.46609 457.8392 387.46609 ] /T (f1-31)/FT /Tx /Q 2 /P 68 0 R /F 4 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj135 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 365.8392 351.46609 457.8392 364.46609 ] /T (f1-32)/FT /Tx /Q 2 /P 68 0 R /F 4 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj136 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 365.8392 339.46609 457.8392 351.46609 ] /T (f1-33)/FT /Tx /Q 2 /P 68 0 R /F 4 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj137 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 365.8392 327.46609 457.8392 339.46609 ] /T (f1-34)/FT /Tx /Q 2 /P 68 0 R /F 4 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj138 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 365.8392 315.46609 457.8392 327.46609 ] /T (f1-35)/FT /Tx /Q 2 /P 68 0 R /F 4 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj139 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 365.8392 303.46609 457.8392 315.46609 ] /T (f1-36)/FT /Tx /Q 2 /P 68 0 R /F 4 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj140 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 365.8392 291.46609 457.8392 303.46609 ] /T (f1-37)/FT /Tx /Q 2 /P 68 0 R /F 4 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj141 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 365.8392 267.46609 457.8392 280.46609 ] /T (f1-38)/FT /Tx /Q 2 /P 68 0 R /F 4 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj142 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 365.8392 255.46609 457.8392 267.46609 ] /T (f1-39)/FT /Tx /Q 2 /P 68 0 R /F 4 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj143 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 365.8392 243.46609 457.8392 255.46609 ] /T (f1-40)/FT /Tx /Q 2 /P 68 0 R /F 4 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj144 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 365.8392 231.46609 457.8392 242.46609 ] /T (f1-41)/FT /Tx /Q 2 /P 68 0 R /F 4 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj145 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 365.8392 195.46609 457.8392 209.46609 ] /T (f1-42)/FT /Tx /Q 2 /P 68 0 R /F 4 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj146 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 365.8392 183.46609 457.8392 195.46609 ] /T (f1-43)/FT /Tx /Q 2 /P 68 0 R /F 4 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj147 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 365.8392 159.46609 457.8392 172.46609 ] /T (f1-44)/FT /Tx /Q 2 /P 68 0 R /F 4 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj148 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 365.8392 147.46609 457.8392 159.46609 ] /T (f1-45)/FT /Tx /Q 2 /P 68 0 R /F 4 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj149 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 365.8392 123.46609 457.8392 136.46609 ] /T (f1-46)/FT /Tx /Q 2 /P 68 0 R /F 4 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj150 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 365.8392 99.46609 457.8392 113.46609 ] /T (f1-47)/FT /Tx /Q 2 /P 68 0 R /F 4 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj151 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 365.8392 87.46609 457.8392 98.46609 ] /T (f1-48)/FT /Tx /Q 2 /P 68 0 R /F 4 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj152 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 365.8392 75.46609 457.8392 87.46609 ] /T (f1-49)/FT /Tx /Q 2 /P 68 0 R /F 4 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj153 0 obj<< /ProcSet [ /PDF /Text ] /Font << /F1 159 0 R /F2 157 0 R /F3 155 0 R /F4 170 0 R /F5 168 0 R /F6 176 0 R /F7 186 0 R /F8 163 0 R /F9 180 0 R >> /ExtGState << /GS1 191 0 R >> >> endobj154 0 obj<< /Type /FontDescriptor /Ascent 686 /CapHeight 686 /Descent -174 /Flags 32 /FontBBox [ -199 -250 1014 934 ] /FontName /FranklinGothic-Demi /ItalicAngle 0 /StemV 147 /XHeight 508 >> endobj155 0 obj<< /Type /Font /Subtype /Type1 /FirstChar 32 /LastChar 181 /Widths [ 300 320 460 600 600 700 720 300 380 380 600 600 300 240 300 600 600 600 600 600 600 600 600 600 600 600 300 300 600 600 600 540 800 640 660 660 660 580 540 660 660 300 400 640 500 880 660 660 620 660 660 600 540 660 600 900 640 600 660 380 600 380 600 500 380 540 540 540 540 540 300 560 540 260 260 560 260 820 540 540 540 540 340 500 380 540 480 740 540 480 420 380 300 380 600 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 300 0 0 0 0 0 0 0 0 0 0 0 0 0 300 0 600 600 0 0 0 0 0 740 0 0 0 240 0 0 0 600 0 0 0 540 ] /Encoding /WinAnsiEncoding /BaseFont /FranklinGothic-Demi /FontDescriptor 154 0 R >> endobj156 0 obj<< /Type /Encoding /Differences [ 1 /H17075 ] >> endobj157 0 obj<< /Type /Font /Subtype /Type1 /FirstChar 32 /LastChar 181 /Widths [ 278 278 463 556 556 1000 685 278 296 296 407 600 278 407 278 371 556 556 556 556 556 556 556 556 556 556 278 278 600 600 600 556 800 685 704 741 741 648 593 759 741 295 556 722 593 907 741 778 667 778 722 649 611 741 630 944 667 667 648 333 371 333 600 500 259 574 611 574 611 574 333 611 593 258 278 574 258 906 593 611 611 611 389 537 352 593 520 814 537 519 519 333 223 333 600 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 278 0 0 0 0 1000 0 0 0 0 0 0 0 0 278 0 556 556 0 0 0 0 0 800 0 0 0 407 0 0 0 600 0 0 0 593 ] /Encoding /WinAnsiEncoding /BaseFont /HelveticaNeue-Bold /FontDescriptor 160 0 R >> endobj158 0 obj<< /Type /FontDescriptor /Ascent 714 /CapHeight 714 /Descent -198 /Flags 32 /FontBBox [ -166 -214 1076 952 ] /FontName /HelveticaNeue-Roman /ItalicAngle 0 /StemV 85 /XHeight 517 >> endobj159 0 obj<< /Type /Font /Subtype /Type1 /FirstChar 32 /LastChar 240 /Widths [ 278 259 426 556 556 1000 630 278 259 259 352 600 278 389 278 333 556 556 556 556 556 556 556 556 556 556 278 278 600 600 600 556 800 648 685 722 704 611 574 759 722 259 519 667 556 871 722 760 648 760 685 648 574 722 611 926 611 648 611 259 333 259 600 500 222 537 593 537 593 537 296 574 556 222 222 519 222 853 556 574 593 593 333 500 315 556 500 758 518 500 480 333 222 333 600 278 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 556 0 0 0 0 0 800 0 0 0 278 0 0 278 600 278 278 0 556 278 278 278 278 278 0 0 278 0 0 0 0 0 278 0 278 278 0 0 0 278 0 0 0 0 0 0 0 0 0 0 278 0 278 0 0 167 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 278 ] /Encoding /MacRomanEncoding /BaseFont /HelveticaNeue-Roman /FontDescriptor 158 0 R >> endobj160 0 obj<< /Type /FontDescriptor /Ascent 714 /CapHeight 714 /Descent -182 /Flags 262176 /FontBBox [ -166 -218 1078 975 ] /FontName /HelveticaNeue-Bold /ItalicAngle 0 /StemV 142 /XHeight 517 >> endobj161 0 obj<< /Filter /FlateDecode /Length 266 /Subtype /Type1C >> stream
H�bd`ab`ddT�sv������,K-*N���K-/.�,�p�����1����C��,�9��,?�y�Z~��*�9�Un���n����_��$��S�~�.������[��ahn`n�_PY���Q�����`hia�������\Y\��[�����_T�_�X���������R_��Z�ZT��R�J�r=�+S��3�B�
��p8=������������E���_5��~�0N�������<�)?jX����uw���f�]��` �Ym]
endstreamendobj162 0 obj<< /Type /FontDescriptor /Ascent 0 /CapHeight 0 /Descent 0 /Flags 4 /FontBBox [ -7 -227 989 764 ] /FontName /NCFHHN+Universal-NewswithCommPi /ItalicAngle 0 /StemV 0 /CharSet (/H17075)/FontFile3 161 0 R >> endobj163 0 obj<< /Type /Font /Subtype /Type1 /FirstChar 1 /LastChar 1 /Widths [ 1000 ] /Encoding 156 0 R /BaseFont /NCFHHN+Universal-NewswithCommPi /FontDescriptor 162 0 R >> endobj164 0 obj1053 endobj165 0 obj<< /Filter /FlateDecode /Length 164 0 R >> stream
H��V�r�F�\�sR�zߏ�"KrdǱ�b.�|��%�� Ȏ~�����,� _�\Ɂ��b�w��g@J��U����U�0�!R�%��8#�A�8�>Y�<?����焲�.�.���fų�0i����<�W�y>%��
��[��H�J�S��q���;�-$�%1�؍�w昫�t�����`�Lq�*��B\JN��'p�����Z�gQ&�_����o�g�~or�->#$!5q���J:K,�2���k="j����)��!��T9�΍hbDc�8�܀7��H�q`�#\�	Q���x��/�,�4��~���6��4��Y�eSn��^ƽ��8��C�כ׾/I�q�:9_ ,�J�M�[��*m�vfn혺����D\r%�B�\��~���ⴶ�Ѹ�Zi�Da�ƒ���:_�E�n���Ր����dRE8�	ޤ�v����&�8��a���k�p����#�����MU����9� w���q�_�MS7�,��0"��rEXB�u�Tq�X{�C^��鞋�pi�"��w��׾�-�[���C�8�ؚ�v=�v8u���m�;�����Õo�ԥg�8�~Az��i��.q'�ev��اT��S����۹}��Pn\
L%�c�&I���"tDw[��M;�+��^>"��<�?�6rj��e
TiT�)��eO�8�Y����^r�31ȕO� .tc�zĝ�`�c�Q��T�����cMFMQUmfM��%�����Pn*?�s�� 4ZM������juX�s�C.��D�ʀ%bk�2oҺ��`o�c+�mꃚ�9�Y��gc�$��ǘ0�����qrT�Y�C~{$����o�rf��Yzꗛ�Cy[4+�_c�9h5��q��u�aZ��c�97�Z*@�������u��
�����t�k�/]9�hX�_�)
��ѡ}*�u`���=,R/�n�J��"H�Vnz�ru�j����}[b���f��<�?�0����8��G ���?d�k@���cv�9h� ��H"endstreamendobj166 0 obj1083 endobj167 0 obj<< /Type /FontDescriptor /Ascent 714 /CapHeight 714 /Descent -198 /Flags 96 /FontBBox [ -166 -214 1106 957 ] /FontName /HelveticaNeue-Italic /ItalicAngle -12 /StemV 85 /XHeight 517 >> endobj168 0 obj<< /Type /Font /Subtype /Type1 /FirstChar 32 /LastChar 181 /Widths [ 278 259 426 556 556 926 630 278 259 259 352 600 278 389 278 333 556 556 556 556 556 556 556 556 556 556 278 278 600 600 600 556 800 667 685 722 704 611 574 759 722 259 519 667 556 870 722 759 648 759 685 648 574 722 611 926 611 611 611 259 333 259 600 500 222 519 593 537 593 537 296 574 556 222 222 481 222 852 556 574 593 593 333 481 315 556 481 759 481 481 444 333 222 333 600 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 556 556 278 278 278 278 278 800 278 278 278 278 278 278 278 600 278 278 278 556 ] /Encoding /WinAnsiEncoding /BaseFont /HelveticaNeue-Italic /FontDescriptor 167 0 R >> endobj169 0 obj<< /Type /FontDescriptor /Ascent 750 /CapHeight 750 /Descent -189 /Flags 32 /FontBBox [ -174 -250 1071 990 ] /FontName /Helvetica-Condensed /ItalicAngle 0 /StemV 79 /XHeight 556 >> endobj170 0 obj<< /Type /Font /Subtype /Type1 /FirstChar 32 /LastChar 181 /Widths [ 250 333 250 500 500 833 667 250 333 333 500 500 250 333 250 278 500 500 500 500 500 500 500 500 500 500 250 250 500 500 500 500 800 556 556 556 611 500 444 611 611 278 444 556 500 778 611 611 556 611 611 556 500 611 556 833 556 556 500 333 250 333 500 500 333 444 500 444 500 444 278 500 500 222 222 444 222 778 500 500 500 500 333 444 278 500 444 667 444 444 389 274 250 274 500 250 250 250 250 250 250 250 250 250 250 250 250 250 250 250 250 250 250 250 250 250 250 250 250 250 250 250 250 250 250 250 250 250 250 250 500 500 250 250 250 250 250 800 250 250 250 250 250 250 250 500 250 250 250 500 ] /Encoding /WinAnsiEncoding /BaseFont /Helvetica-Condensed /FontDescriptor 169 0 R >> endobj171 0 obj<< /Filter /FlateDecode /Length 166 0 R >> stream
H��VMo�FE��{h��~�4q�6�Ѓ�%Q�6)�T��������va�^/�3o�{3K���R���̵5Hj���-I�S��'1p��p�_rư�R#�χ	&
�_>$w�y�UE��$m��4I[���&c$-P�C��׮t��gZ�Jۢ@�j���\]���u�y�1y��!���d�)�T�`Xi�n�ӥo=�Wh<G�������*N29  ��"W݇,�p�Z���P[�>�M(�X��	�S)ǝ2�+y�|�'��<H��D�w��u��ԧ�-<�xEd���+4Ö�q�ɼ�H̬V�>e���*T+@�P�/����Za56f�V*��X�3i�q�wV����Sݶ#��8W��s��3�TNQh�O����t;WlQ5'�\�W��%�A�j&A��2������}��ݻ��M~t]^���3:�R�������1X2���t�㗋�^�<�E�(���7�-�-�5���;���7,�N�u�p�O2O|�>�@rjǝ��@e���J(	�_�Z[}���Y���Y��p�p�틦�!J��љ���(4xB_zf���P:����C��1̾��\��\��=�:�Qټ��<A#�(Y�u�􀀦/�B�����n���R�>�o�V��Qew_�8��o.&�`Z�����,֢ƍ�O�_��oA0���E�������p2�"���7�$����.ݦ|D`�m�p����W?T�)����h[�0��*��B+�U�e��R��F�[���*),V�rN���P�i.�Ҿ������~�p�Ēa9:߇4��a��FJ��8��e�����}=�d���C��\@4>�L޹,��� KD���|�TNW�f�!J�!\M뻤h@�£k�	A?�d/��2���S�y�6uy:T�)��Xu�Y�D�$�M^�Q�U���?���Թ�E���C�+`���2���M�F�#/B�^��kC#*�Q+�!�o�9�Ng���&`� �2;t(���6[���&զ>P{	�,��5�!��Z�Zp3ܾ9X����j!� �Yaendstreamendobj172 0 obj769 endobj173 0 obj<< /Filter /FlateDecode /Length 172 0 R >> stream
H��U�N�@}�W�c��vo�KQA��ZT����8p���6E|h�����	uE"f��3sΜY��:
8|J�U�
?)�#V�/
�@PC�� CK�P��D�>�(�xÁA�	�Jj��i5#!g��D��B�,�E��W@�
�5��VJLj`���^�qY���լ�m��ƞ��	�hiDK�25��s�?:P�o�..��K_�%#Lr�g��%�Sn��*^�*ͳ6y�ɓ[�l|]֝D�����&/v��
W��>��9��"I�k�I�Im�\
F�,)̘�F������
�,�wV�m^����
�U����+��rc+�*ue+�� p#��Ԅ�nB���6c��������v�R�{Jb�M�a��	2����gҨ(1�F��4�>p�mFO���q���x��k���\�����<�]^T�|�懌}M>:�Z��T�t�)��7q�<��A)�%�B<�Lc9�֕���Ց聑���6vO�\]�F��Kئ��ڴ��p]ٮ��h�9�3n��?nP��P\�8?�o�6N��+>�}�8�n��ayd���\=���z�w�	��?G�5��{�N��x�5�p���,#2����Dwf�Ϻ�YBb�8l+z8)ˀ��r ;!�0�1�I2[S�N6F�A�����쟇��)?�x;w9vVi�����3�r��"9-�9�d�p��#7�t�S����*)�pG.qq� ��Sw<�i�o�Y�	�����g��1�C�� #�81endstreamendobj174 0 obj914 endobj175 0 obj<< /Type /FontDescriptor /Ascent 750 /CapHeight 750 /Descent -189 /Flags 262176 /FontBBox [ -169 -250 1091 991 ] /FontName /Helvetica-Condensed-Bold /ItalicAngle 0 /StemV 130 /XHeight 564 >> endobj176 0 obj<< /Type /Font /Subtype /Type1 /FirstChar 32 /LastChar 181 /Widths [ 250 333 333 500 500 833 667 250 333 333 500 500 333 333 333 278 500 500 500 500 500 500 500 500 500 500 278 278 500 500 500 500 833 556 556 556 611 500 500 611 611 278 444 556 500 778 611 611 556 611 611 556 500 611 556 833 556 556 500 333 250 333 500 500 333 500 500 444 500 500 278 500 500 278 278 444 278 778 500 500 500 500 333 444 278 500 444 667 444 444 389 274 250 274 500 250 250 250 250 250 250 250 250 250 250 250 250 250 250 250 250 250 250 250 250 250 250 250 250 250 250 250 250 250 250 250 250 250 250 250 500 500 250 250 250 250 250 830 250 250 250 250 250 250 250 500 250 250 250 500 ] /Encoding /WinAnsiEncoding /BaseFont /Helvetica-Condensed-Bold /FontDescriptor 175 0 R >> endobj177 0 obj<< /Filter /FlateDecode /Length 174 0 R >> stream
H��UɎ�F��+�	�v�KnY� � �[�M�F
(R )8���T/�D�ak>��b�{��U5@A��X���?św���i��5�2k�����j����M�>�G���N��j�:��Y5�0l�K�x��LGc��Ç(8�U�ο�%� �"�2�1B[�~i������X"�4J!����Ap�k��I(�P֙��%�2QԄ)b�|D��FcK8fIb<�����m�@�Bu:5����xh��n�ݹ�ޏ�%m_��Ð87���Tt��c�#Ʃ��]�:8L$�!�V�o�0�dV�P'R�6�j�zC���s�vo˂N,6!Q3h�����̗�~�[ҏ��E������tQ�93s�c��p��<� �U?���oH�AKQ�d.�H��1���];����1���Y,�I ,��C3���,,�)Wqb��2���*�Q!t��q��)�Ot�����*��1@�"���s�W�$��z���;<Ǌ�>qE(GO3uӧ|1�IN8�u� g�Q9�,�<Ճ���-]4ⸯZ؞}`XWùj�g�½ߍ�����M�P���W1������wp�������E禦���:��k&U���PM����~M�#�	 ��6FK�W�D:᯿)l�F����VT���|33����.2��K��ŕ����i���{���X�0��P�]d��.z��R.'5�c^�?�_�`��k�����f5�J:\��[���Fe��AY�@~���(���蠩�^�X�t�v�~#�'{+�ĠkXT��oq?��2��+�Rz�ĭ��啟��&�ߓo[�,��#���Q7[r�x�h)�J4�e�f�Y�[�/��\Ib���<��c8���݂�m5��8?nV2�x~.��MĨ� �pX�endstreamendobj178 0 obj855 endobj179 0 obj<< /Filter /FlateDecode /Length 335 /Subtype /Type1C >> stream
H�bd`ab`ddT�sv������,K-*N��u/JM�.�,��M,��)2����C��,�9��,?�y�r����y�Un���n����W�����}�$������Y��ad`aj�_PY���Q�����`hia�������\Y\��[�����_T�_�X���������R_��Z�ZT�;S�L�r=�32�,Ჸ}�������������}����}��p^��e	�w������+j?1n�m���쏣����+b1''Y�w3{�F��5r���5��R@��=��w�=[�Oc��c���r|�S�L��w��ĩ�-��~�t� q���
endstreamendobj180 0 obj<< /Type /Font /Subtype /Type1 /FirstChar 1 /LastChar 1 /Widths [ 333 ] /Encoding 182 0 R /BaseFont /NCFJHK+Universal-GreekwithMathPi /FontDescriptor 181 0 R >> endobj181 0 obj<< /Type /FontDescriptor /Ascent 0 /CapHeight 0 /Descent 0 /Flags 4 /FontBBox [ -30 -240 1012 815 ] /FontName /NCFJHK+Universal-GreekwithMathPi /ItalicAngle 0 /StemV 0 /CharSet (/H20854)/FontFile3 179 0 R >> endobj182 0 obj<< /Type /Encoding /Differences [ 1 /H20854 ] >> endobj183 0 obj<< /Filter /FlateDecode /Length 178 0 R >> stream
H��VMo�@��W�1Ex��� H��`�1r��q)�{f��M�JH(R�ff߼�vl��x�QB�P�e���Ưn�s��M�o�Q��W���]�p`P�3K��(~�_�(�9�Rg�ИZ(���挎=��#�8��p(ބ�*�h�b��Ru���M9��~XwM�A�V����T�M�!F"�ЎP'x�\��PVا��W��m�qx�i��/X��q�RXe�Z����p�a�	!��S��>g���hњ��Tq��B#�l�2��E���k<_*G��S$���J� O��ũ�.qS��<���#�y8�e g��bFJ����{<kQ�0�r��"z!��q��VG-gzY�쿒�sE(���\)����s"PB_*Ԉ<��P"<��K
*���Ȅ�2�̅
>#و��Cw����n�u��ޯ������(E�D8Ŷ��x�Fch3���C&W��r�F5��UN����j����3�0d�p��7}����� ɗ�˫�W��~h}��Ի=��v}����vMY��ۈ ��o�$K8���}���<|�X�9G�b!f�~�SI�h!3�\�/�,\T#��q�	i�PH3��:?J�����}ܢQ���WҁO:ȃj��(u�~��ԡ�[d��2��Γ;a�)V<�w��[�H�Ay(N$�v�F�m�3�*�_�`ե�īf��*.�Z�GW�������1gݓL�уCʝ�:.�z*���W�TSK������z�hL$��s����ȝ��aN�H��/q&�=@R�����n˦^�����[��C��|�{������޷C��~�=&��,?��u� ��S�endstreamendobj184 0 obj918 endobj185 0 obj<< /Type /FontDescriptor /Ascent 750 /CapHeight 750 /Descent -189 /Flags 262176 /FontBBox [ -168 -250 1113 1000 ] /FontName /Helvetica-Condensed-Black /ItalicAngle 0 /StemV 159 /XHeight 560 >> endobj186 0 obj<< /Type /Font /Subtype /Type1 /FirstChar 32 /LastChar 181 /Widths [ 250 333 333 500 500 833 667 250 278 278 500 500 333 333 333 278 500 500 500 500 500 500 500 500 500 500 278 278 500 500 500 500 830 556 556 556 556 500 500 556 556 278 444 556 444 778 556 556 556 556 556 500 500 556 556 778 556 556 444 278 250 278 500 500 333 500 500 500 500 500 333 500 500 278 278 500 278 722 500 500 500 500 333 444 333 500 444 667 444 444 389 274 250 274 500 250 250 250 250 250 250 250 250 250 250 250 250 250 250 250 250 250 250 250 250 250 250 250 250 250 250 250 250 250 250 250 250 250 250 250 500 500 250 250 250 250 250 830 250 250 250 250 250 250 250 500 250 250 250 500 ] /Encoding /WinAnsiEncoding /BaseFont /Helvetica-Condensed-Black /FontDescriptor 185 0 R >> endobj187 0 obj<< /Filter /FlateDecode /Length 184 0 R >> stream
H��V�n�@���y )Adٝ�?r� 	��!M\Hmd�����NڒT�b{�3sΙ3� ʛb�\��?�~Su��G�,�g�����qB0���u!�3�����3p]H)����mqV�,��o���c�(�>����g�*n��PV��" ����N�"_9(�$W�"8�ƈ!�\����W���Zo�n��|GQ�,�"���[-bQ� 1Vx����^y�G�R)�QM(+�U�6gqg瘴�T|�3apT+4�U	���鯪��e���]57545l7u�Q�%,�5]/���V�e_���iHi1�����[��W����q�	j��ӆ����~��(�!w��
�w�j����NY��m
����zf����_��8h.������%-�B��(�1�]���ob��\6-������mbTϸ��|��i�Ap���,a��e0���Ť��a��3
\��N��e�B5]ѡ�z��&ˎ2H2[����\hm.8�����`1�^��#����q\�Gut�@Ǽp��֎��:Z)#�OQ�<�'��J��9�8E���T�0�@� nb.E�AG�$Y^�:%}��:Le�G:I����Pc\�o�s����ًhƙ����}��Ф�D� R��>��f��_U{Ӵ?�剃
/V=|l�ͪz���!�U�#꓄A|�1R��9M'�2����*����q�B� ��e�-��)�>��!M�������A��o�b���2"�}�z�g������d�-s4�)2��ND��a%��U��]u�����|x����+;)�^G�cq$!�����P]/�n�^�礻vf�OY�Ě`I?M�WNH�v���ʆW
��b��J�[!V\3�5�V����+���%x:�<d5$��k��N��ģ\C�A� 	�0�endstreamendobj188 0 obj934 endobj189 0 obj<< /Filter /FlateDecode /Length 188 0 R >> stream
H��V�n�8E����@Z����2�h
t�zw�8�DQlE~c�x.)R��M�pp�=�M?����!��5P��O."W��&�h�mQ�Q��->�
����s!�$�K�^k��T�R/Ȑ8L圀s7���K�i�> �H���1ܨ94ŵ�蓋���v�a�j��ͤ��R�8J��h��(�ډ���D#���8&W0^%$h�cf}P� �Yq$�Ě�<'N�؍�Pp&��x8礹�'GV�E+Gl�8b7�ȡ���TD-�@vD���`���5b�����Q�k�]�����v�&N��8�V���9q2�nԇB�e@����Dd� +�QA+Gl�8b7�ȡ�0�HMj��Q�d�Q�Դ^sb�����Q
)��W�H��pO��8�V���9q2�n�7�G��}r�ė���#�����H}��"���x��i4p"�Qֵ�{�q�w��89R&�p�j<�|��������k����Sx�Q��z�O�3}����Ǔ}k���}����������۲\l-���HG.��T���l.R�f�<ñ��7܈���f����p׍S�~��,9-����֞�1����^�K4��s����U�����]�J�I*��0%<D�o��z(١�z�8����;��Y�Zx�}?�|ݱ�"(�Pʚ��=����a(om7>c�A ����+���F���W��H��J�H	�Bq�o�Np M�v( !���GD��p�,�{'�z(VMɧé�}�Q�-���"��-V���_�����_ehy�c��OX��x<�����n�s�U|p���HH]f��#��Nw��=�(�t҄?W��N�m����ί��C:��P�g�ѵg8���O���f�v� ��S����l:��O���"��Py�� bb�endstreamendobj190 0 obj921 endobj191 0 obj<< /Type /ExtGState /SA false /SM 0.02 /TR /Identity >> endobj192 0 obj<< /Filter /FlateDecode /Length 190 0 R >> stream
H��U�j�V%[}Emj边��6�d` 0�,ܳ�[���-��ɇ�R��W���`��K��SU�� �ߋLr%�V�%S�×�s�%���~�ȁA�i��?�KX�c�����Q(޲��W�슿�"��Z|�(����f|���<P��P¥2p`�I���"���W�0�����t��$����`�G!��;t�BGG:��ߚ�<Cy:u����1_�5!Dh��~nڶi��{�����X�<äHPʗL��鸻��L��0����!�?�~l�������}�s����k�)����0���ޗ�>v��j�C����X�/���z=������f���,%��~�Ŷҧ����C��5}ͫ���x*0��kE�W:��;�,�eZ���fzYl�)��z
�K�K��:�?}
4Ծ9�Y�%s������"c�g����)��r=x�H-M�>��Dh�@��(]=�-/�M��ҧ4�8�=:1Y�ݨ8�����"��f�	�UJ��OIH�3"'o��T�1��#'kQP���֌B�wD5kJ̸��r��lZ�y�a���`�N#��F�����Y�cǧ�H��;9�� }�n��w��X������k�3%��l�f�^��D�8l�@g��E�u(�ݪ��(��ȍj�e�<����d��?@tۍ�Z/�Gt�� ��񇠔Y�Rf��J�m��6s�f*�m��=K�� �3fuu��Kj�b(���QO��w�Qk,�:�)%���lќ�V�RSԥ�)B}�W�W��3f�3��헞_I̭}�t �j�[��o|��;)!wn#���4f���Xq&���?�xi�����h��_�kJစ�v��	�� ������ؼ�.�q���0�8��ot��O� g�uendstreamendobj1 0 obj<< /Type /Page /Parent 64 0 R /Resources 3 0 R /Contents 4 0 R /MediaBox [ 0 0 612 792 ] /CropBox [ 0 0 612 792 ] /Rotate 0 /Annots 2 0 R >> endobj2 0 obj[ 9 0 R 10 0 R 11 0 R 12 0 R 13 0 R 14 0 R 15 0 R 16 0 R 17 0 R 18 0 R 19 0 R 20 0 R 21 0 R 22 0 R 23 0 R 24 0 R 25 0 R 26 0 R 27 0 R 28 0 R 29 0 R 30 0 R 31 0 R 32 0 R 33 0 R 34 0 R 35 0 R 36 0 R 37 0 R 38 0 R 39 0 R 40 0 R 41 0 R 42 0 R 43 0 R 44 0 R 45 0 R 46 0 R 47 0 R 48 0 R 49 0 R 50 0 R ]endobj3 0 obj<< /ProcSet [ /PDF /Text ] /Font << /F1 159 0 R /F5 168 0 R /F6 176 0 R /F8 163 0 R /F9 180 0 R /F10 5 0 R /F11 6 0 R /F12 7 0 R >> /ExtGState << /GS1 191 0 R >> >> endobj4 0 obj<< /Length 5393 /Filter /FlateDecode >> stream
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
endstreamendobj5 0 obj<< /Type /Font /Subtype /Type1 /FirstChar 32 /LastChar 181 /Widths [ 278 259 426 556 556 1000 630 278 259 259 352 600 278 389 278 333 556 556 556 556 556 556 556 556 556 556 278 278 600 600 600 556 800 648 685 722 704 611 574 759 722 259 519 667 556 871 722 760 648 760 685 648 574 722 611 926 611 648 611 259 333 259 600 500 222 537 593 537 593 537 296 574 556 222 222 519 222 853 556 574 593 593 333 500 315 556 500 758 518 500 480 333 222 333 600 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 556 556 278 278 278 278 278 800 278 278 278 278 278 278 278 600 278 278 278 556 ] /Encoding /WinAnsiEncoding /BaseFont /HelveticaNeue-Roman /FontDescriptor 158 0 R >> endobj6 0 obj<< /Type /Font /Subtype /Type1 /FirstChar 32 /LastChar 181 /Widths [ 278 278 463 556 556 1000 685 278 296 296 407 600 278 407 278 371 556 556 556 556 556 556 556 556 556 556 278 278 600 600 600 556 800 685 704 741 741 648 593 759 741 295 556 722 593 907 741 778 667 778 722 649 611 741 630 944 667 667 648 333 371 333 600 500 259 574 611 574 611 574 333 611 593 258 278 574 258 906 593 611 611 611 389 537 352 593 520 814 537 519 519 333 223 333 600 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 556 556 278 278 278 278 278 800 278 278 278 278 278 278 278 600 278 278 278 593 ] /Encoding /WinAnsiEncoding /BaseFont /HelveticaNeue-Bold /FontDescriptor 160 0 R >> endobj7 0 obj<< /Type /Font /Subtype /Type1 /FirstChar 32 /LastChar 181 /Widths [ 278 296 481 556 556 963 685 278 296 296 407 600 278 407 278 389 556 556 556 556 556 556 556 556 556 556 278 278 600 600 600 574 800 685 722 741 741 667 593 759 741 296 556 722 574 907 741 778 667 778 722 648 611 741 630 944 667 648 648 333 389 333 600 500 259 574 611 556 611 574 352 611 611 259 259 556 259 907 611 593 611 611 389 519 370 611 519 815 519 519 500 333 222 333 600 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 556 556 278 278 278 278 278 800 278 278 278 278 278 278 278 600 278 278 278 611 ] /Encoding /WinAnsiEncoding /BaseFont /HelveticaNeue-BoldItalic /FontDescriptor 8 0 R >> endobj8 0 obj<< /Type /FontDescriptor /Ascent 714 /CapHeight 714 /Descent -182 /Flags 262240 /FontBBox [ -166 -218 1129 975 ] /FontName /HelveticaNeue-BoldItalic /ItalicAngle -12 /StemV 142 /XHeight 517 >> endobj9 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 366.08548 699.61502 458.08548 712.61502 ] /T (f2-1)/FT /Tx /Q 2 /P 1 0 R /F 4 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj10 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 366.08548 687.61502 458.08548 698.61502 ] /T (f2-2)/FT /Tx /Q 2 /P 1 0 R /F 4 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj11 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 366.08548 674.61502 458.08548 686.61502 ] /T (f2-3)/FT /Tx /Q 2 /P 1 0 R /F 4 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj12 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 366.08548 662.61502 458.08548 674.61502 ] /T (f2-4)/FT /Tx /Q 2 /P 1 0 R /F 4 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj13 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 366.08548 651.61502 458.08548 662.61502 ] /T (f2-5)/FT /Tx /Q 2 /P 1 0 R /F 4 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj14 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 366.08548 639.61502 458.08548 650.61502 ] /T (f2-6)/FT /Tx /Q 2 /P 1 0 R /F 4 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj15 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 366.08548 627.61502 458.08548 639.61502 ] /T (f2-7)/FT /Tx /Q 2 /P 1 0 R /F 4 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj16 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 366.08548 615.61502 458.08548 627.61502 ] /T (f2-8)/FT /Tx /Q 2 /P 1 0 R /F 4 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj17 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 366.08548 603.61502 458.08548 615.61502 ] /T (f2-9)/FT /Tx /Q 2 /P 1 0 R /F 4 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj18 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 366.08548 591.61502 458.08548 603.61502 ] /T (f2-10)/FT /Tx /Q 2 /P 1 0 R /F 4 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj19 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 366.08548 579.61502 458.08548 591.61502 ] /T (f2-11)/FT /Tx /Q 2 /P 1 0 R /F 4 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj20 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 366.08548 567.61502 458.08548 578.61502 ] /T (f2-12)/FT /Tx /Q 2 /P 1 0 R /F 4 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj21 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 163.08548 554.61502 336.08548 566.61502 ] /T (f2-13)/FT /Tx /P 1 0 R /F 4 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj22 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 252.08548 542.61502 335.08548 554.61502 ] /T (f2-14)/FT /Tx /P 1 0 R /F 4 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj23 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 366.08548 519.61502 458.08548 532.61502 ] /T (f2-15)/FT /Tx /Q 2 /P 1 0 R /F 4 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj24 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 366.08548 507.61502 458.08548 518.61502 ] /T (f2-16)/FT /Tx /Q 2 /P 1 0 R /F 4 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj25 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 224.08548 494.61502 234.08548 503.61502 ] /T (c2-1)/FT /Btn /DA (/HeBo 9 Tf 0 0 0.627 rg)/F 4 /H /T /MK << /CA (4)/AC (��)/RC (��)>> /P 1 0 R /AS /Off /AP << /N << /On 51 0 R >> /D << /On 52 0 R /Off 53 0 R >> >> >> endobj26 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 261.08548 494.61502 270.08548 503.61502 ] /T (c2-2)/FT /Btn /DA (/HeBo 9 Tf 0 0 0.627 rg)/F 4 /H /T /MK << /CA (4)/AC (��)/RC (��)>> /P 1 0 R /AS /Off /AP << /N << /On 54 0 R >> /D << /On 55 0 R /Off 56 0 R >> >> >> endobj27 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 366.08548 494.61502 458.08548 506.61502 ] /T (f2-17)/FT /Tx /Q 2 /P 1 0 R /F 4 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj28 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 366.08548 482.61502 458.08548 494.61502 ] /T (f2-18)/FT /Tx /Q 2 /P 1 0 R /F 4 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj29 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 366.08548 471.61502 458.08548 482.61502 ] /T (f2-19)/FT /Tx /Q 2 /P 1 0 R /F 4 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj30 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 246.08548 458.61502 334.08548 471.61502 ] /T (f2-20)/FT /Tx /P 1 0 R /F 4 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj31 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 366.08548 447.61502 458.08548 460.61502 ] /T (f2-21)/FT /Tx /Q 2 /P 1 0 R /F 4 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj32 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 366.08548 435.61502 458.08548 447.61502 ] /T (f2-22)/FT /Tx /Q 2 /P 1 0 R /F 4 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj33 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 366.08548 423.61502 458.08548 435.61502 ] /T (f2-23)/FT /Tx /Q 2 /P 1 0 R /F 4 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj34 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 366.08548 411.61502 458.08548 422.61502 ] /T (f2-24)/FT /Tx /Q 2 /P 1 0 R /F 4 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj35 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 366.08548 399.61502 458.08548 410.61502 ] /T (f2-25)/FT /Tx /Q 2 /P 1 0 R /F 4 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj36 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 366.08548 387.61502 458.08548 398.61502 ] /T (f2-26)/FT /Tx /Q 2 /P 1 0 R /F 4 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj37 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 366.08548 363.61502 458.08548 376.61502 ] /T (f2-27)/FT /Tx /Q 2 /P 1 0 R /F 4 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj38 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 366.08548 351.61502 458.08548 362.61502 ] /T (f2-28)/FT /Tx /Q 2 /P 1 0 R /F 4 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj39 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 90.08548 314.61502 570.08548 328.61502 ] /T (f2-29)/FT /Tx /P 1 0 R /F 4 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj40 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 90.08548 291.61502 570.08548 306.61502 ] /T (f2-30)/FT /Tx /P 1 0 R /F 4 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj41 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 90.08548 266.61502 570.08548 283.61502 ] /T (f2-31)/FT /Tx /P 1 0 R /F 4 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj42 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 90.08548 242.61502 570.08548 256.61502 ] /T (f2-32)/FT /Tx /P 1 0 R /F 4 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj43 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 90.08548 218.61502 570.08548 236.61502 ] /T (f2-33)/FT /Tx /P 1 0 R /F 4 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj44 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 90.08548 194.61502 570.08548 212.61502 ] /T (f2-34)/FT /Tx /P 1 0 R /F 4 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj45 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 90.08548 170.61502 570.08548 188.61502 ] /T (f2-35)/FT /Tx /P 1 0 R /F 4 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj46 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 90.08548 146.61502 570.08548 164.61502 ] /T (f2-36)/FT /Tx /P 1 0 R /F 4 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj47 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 90.08548 122.61502 570.08548 139.61502 ] /T (f2-37)/FT /Tx /P 1 0 R /F 4 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj48 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 90.08548 98.61502 570.08548 116.61502 ] /T (f2-38)/FT /Tx /P 1 0 R /F 4 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj49 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 90.08548 74.61502 571.08548 91.61502 ] /T (f2-39)/FT /Tx /P 1 0 R /F 4 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj50 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 90.08548 51.61502 571.08548 68.61502 ] /T (f2-40)/FT /Tx /P 1 0 R /F 4 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj51 0 obj<< /Length 80 /Subtype /Form /BBox [ 0 0 10 9 ] /Resources << /ProcSet [ /PDF /Text ] /Font << /ZaDb 81 0 R >> >> >> stream
q 1 1 8 7 re W n BT /ZaDb 9 Tf 0 0 0.627 rg  1 0 0 1 1.193 1.2645 Tm (4) Tj ET Qendstreamendobj52 0 obj<< /Length 100 /Subtype /Form /BBox [ 0 0 10 9 ] /Resources << /ProcSet [ /PDF /Text ] /Font << /ZaDb 81 0 R >> >> >> stream
0.749 g 0 0 10 9 re f q 1 1 8 7 re W n BT /ZaDb 9 Tf 0 0 0.627 rg  1 0 0 1 1.193 1.2645 Tm (4) Tj ETendstreamendobj53 0 obj<< /Length 21 /Subtype /Form /BBox [ 0 0 10 9 ] /Resources << /ProcSet [ /PDF ] >> >> stream
0.749 g 0 0 10 9 re fendstreamendobj54 0 obj<< /Length 80 /Subtype /Form /BBox [ 0 0 9 9 ] /Resources << /ProcSet [ /PDF /Text ] /Font << /ZaDb 81 0 R >> >> >> stream
q 1 1 7 7 re W n BT /ZaDb 9 Tf 0 0 0.627 rg  1 0 0 1 0.693 1.2645 Tm (4) Tj ET Qendstreamendobj55 0 obj<< /Length 99 /Subtype /Form /BBox [ 0 0 9 9 ] /Resources << /ProcSet [ /PDF /Text ] /Font << /ZaDb 81 0 R >> >> >> stream
0.749 g 0 0 9 9 re f q 1 1 7 7 re W n BT /ZaDb 9 Tf 0 0 0.627 rg  1 0 0 1 0.693 1.2645 Tm (4) Tj ETendstreamendobj56 0 obj<< /Length 20 /Subtype /Form /BBox [ 0 0 9 9 ] /Resources << /ProcSet [ /PDF ] >> >> stream
0.749 g 0 0 9 9 re fendstreamendobj57 0 obj<< /Type /Font /Name /Helv /BaseFont /Helvetica /Subtype /Type1 /Encoding 60 0 R >> endobj58 0 obj<< /Encoding 59 0 R /Font 61 0 R >> endobj59 0 obj<< /PDFDocEncoding 60 0 R >> endobj60 0 obj<< /Type /Encoding /Differences [ 24 /breve /caron /circumflex /dotaccent /hungarumlaut /ogonek /ring /tilde 39 /quotesingle 96 /grave 128 /bullet /dagger /daggerdbl /ellipsis /emdash /endash /florin /fraction /guilsinglleft /guilsinglright /minus /perthousand /quotedblbase /quotedblleft /quotedblright /quoteleft /quoteright /quotesinglbase /trademark /fi /fl /Lslash /OE /Scaron /Ydieresis /Zcaron /dotlessi /lslash /oe /scaron /zcaron 160 /Euro 164 /currency 166 /brokenbar 168 /dieresis /copyright /ordfeminine 172 /logicalnot /.notdef /registered /macron /degree /plusminus /twosuperior /threesuperior /acute /mu 183 /periodcentered /cedilla /onesuperior /ordmasculine 188 /onequarter /onehalf /threequarters 192 /Agrave /Aacute /Acircumflex /Atilde /Adieresis /Aring /AE /Ccedilla /Egrave /Eacute /Ecircumflex /Edieresis /Igrave /Iacute /Icircumflex /Idieresis /Eth /Ntilde /Ograve /Oacute /Ocircumflex /Otilde /Odieresis /multiply /Oslash /Ugrave /Uacute /Ucircumflex /Udieresis /Yacute /Thorn /germandbls /agrave /aacute /acircumflex /atilde /adieresis /aring /ae /ccedilla /egrave /eacute /ecircumflex /edieresis /igrave /iacute /icircumflex /idieresis /eth /ntilde /ograve /oacute /ocircumflex /otilde /odieresis /divide /oslash /ugrave /uacute /ucircumflex /udieresis /yacute /thorn /ydieresis ] >> endobj61 0 obj<< /Helv 57 0 R /HeBo 62 0 R /ZaDb 81 0 R >> endobj62 0 obj<< /Type /Font /Name /HeBo /BaseFont /Helvetica-Bold /Subtype /Type1 /Encoding 60 0 R >> endobj63 0 obj<< /CreationDate (D:19991124135053)/Producer (Acrobat Distiller 4.0 for Windows)/Creator (Mecca III\(TM\) 9.40)/Title (1999 Form 1065 \(Schedule K-1\))/Subject (Partner's Share of Income, Credits, Deductions, etc.)/Author (T:FP)/ModDate (D:19991209144759-05'00')>> endobj64 0 obj<< /Type /Pages /Kids [ 68 0 R 1 0 R ] /Count 2 >> endobjxref0 65 0000000000 65535 f
0000038747 00000 n
0000038913 00000 n
0000039231 00000 n
0000039417 00000 n
0000044884 00000 n
0000045675 00000 n
0000046465 00000 n
0000047258 00000 n
0000047478 00000 n
0000047655 00000 n
0000047833 00000 n
0000048011 00000 n
0000048189 00000 n
0000048367 00000 n
0000048545 00000 n
0000048723 00000 n
0000048901 00000 n
0000049079 00000 n
0000049258 00000 n
0000049437 00000 n
0000049616 00000 n
0000049789 00000 n
0000049962 00000 n
0000050141 00000 n
0000050320 00000 n
0000050607 00000 n
0000050894 00000 n
0000051073 00000 n
0000051252 00000 n
0000051431 00000 n
0000051604 00000 n
0000051783 00000 n
0000051962 00000 n
0000052141 00000 n
0000052320 00000 n
0000052499 00000 n
0000052678 00000 n
0000052857 00000 n
0000053036 00000 n
0000053208 00000 n
0000053380 00000 n
0000053552 00000 n
0000053724 00000 n
0000053896 00000 n
0000054068 00000 n
0000054240 00000 n
0000054412 00000 n
0000054584 00000 n
0000054755 00000 n
0000054925 00000 n
0000055095 00000 n
0000055328 00000 n
0000055582 00000 n
0000055725 00000 n
0000055957 00000 n
0000056208 00000 n
0000056349 00000 n
0000056456 00000 n
0000056512 00000 n
0000056560 00000 n
0000057909 00000 n
0000057975 00000 n
0000058087 00000 n
0000058377 00000 n
trailer<</Size 65/ID[<91da8e308ff95581fb7fae43e15e76d0><91da8e308ff95581fb7fae43e15e76d0>]>>startxref173%%EOF
%%% Base Root Pointer %%%
66 0 R
%%% Base Size %%%
195
%%% Base Xref Offset %%%
173
%%% Xlator Set Class %%%
Bivio::UI::PDF::Form::f1065sk1::y1999::XlatorSet
%%% Field Text %%%
73 0 obj
<<
/Type /Annot
/Subtype /Widget
/Rect [ 176.8392 711.46609 300.8392 722.46609 ]
/T (f1-4)
/FT /Tx
/P 68 0 R
/F 4
/DA (/HeBo 9 Tf 0 0 0.627 rg)
>>
endobj
76 0 obj
<<
/Type /Annot
/Subtype /Widget
/Rect [ 43.8392 651.46609 300.8392 699.46609 ]
/T (f1-5)
/FT /Tx
/P 68 0 R
/Ff 4096
/F 4
/DA (/HeBo 9 Tf 0 0 0.627 rg)
>>
endobj
74 0 obj
<<
/Type /Annot
/Subtype /Widget
/Rect [ 459.8392 711.46609 486.8392 722.46609 ]
/T (f1-6)
/FT /Tx
/Q 2
/P 68 0 R
/F 4
/DA (/HeBo 9 Tf 0 0 0.627 rg)
>>
endobj
75 0 obj
<<
/Type /Annot
/Subtype /Widget
/Rect [ 489.8392 711.46609 568.8392 722.46609 ]
/T (f1-7)
/FT /Tx
/P 68 0 R
/F 4
/DA (/HeBo 9 Tf 0 0 0.627 rg)
>>
endobj
77 0 obj
<<
/Type /Annot
/Subtype /Widget
/Rect [ 309.8392 651.46609 568.8392 699.46609 ]
/T (f1-8)
/FT /Tx
/P 68 0 R
/Ff 4096
/F 4
/DA (/HeBo 9 Tf 0 0 0.627 rg)
>>
endobj
83 0 obj
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
/P 68 0 R
/AS /Off
/AP << /N << /On 86 0 R >> /D << /On 84 0 R /Off 85 0 R >> >>
>>
endobj
78 0 obj
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
/P 68 0 R
/AS /Off
/AP << /N << /On 82 0 R >> /D << /On 79 0 R /Off 80 0 R >> >>
>>
endobj
87 0 obj
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
/P 68 0 R
/AS /Off
/AP << /N << /On 90 0 R >> /D << /On 88 0 R /Off 89 0 R >> >>
>>
endobj
91 0 obj
<<
/Type /Annot
/Subtype /Widget
/Rect [ 219.8392 615.46609 299.8392 628.46609 ]
/T (f1-9)
/FT /Tx
/P 68 0 R
/F 4
/DA (/HeBo 9 Tf 0 0 0.627 rg)
>>
endobj
92 0 obj
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
/P 68 0 R
/AS /Off
/AP << /N << /On 95 0 R >> /D << /On 93 0 R /Off 94 0 R >> >>
>>
endobj
96 0 obj
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
/P 68 0 R
/AS /Off
/AP << /N << /On 99 0 R >> /D << /On 97 0 R /Off 98 0 R >> >>
>>
endobj
100 0 obj
<<
/Type /Annot
/Subtype /Widget
/Rect [ 203.8392 579.46609 233.8392 589.46609 ]
/T (f1-10)
/FT /Tx
/Q 2
/P 68 0 R
/F 4
/DA (/HeBo 9 Tf 0 0 0.627 rg)
>>
endobj
101 0 obj
<<
/Type /Annot
/Subtype /Widget
/Rect [ 255.8392 579.46609 285.8392 589.46609 ]
/T (f1-11)
/FT /Tx
/Q 2
/P 68 0 R
/F 4
/DA (/HeBo 9 Tf 0 0 0.627 rg)
>>
endobj
102 0 obj
<<
/Type /Annot
/Subtype /Widget
/Rect [ 203.8392 567.46609 233.8392 579.46609 ]
/T (f1-12)
/FT /Tx
/Q 2
/P 68 0 R
/F 4
/DA (/HeBo 9 Tf 0 0 0.627 rg)
>>
endobj
103 0 obj
<<
/Type /Annot
/Subtype /Widget
/Rect [ 255.8392 567.46609 285.8392 579.46609 ]
/T (f1-13)
/FT /Tx
/Q 2
/P 68 0 R
/F 4
/DA (/HeBo 9 Tf 0 0 0.627 rg)
>>
endobj
104 0 obj
<<
/Type /Annot
/Subtype /Widget
/Rect [ 203.8392 556.46609 233.8392 567.46609 ]
/T (f1-14)
/FT /Tx
/Q 2
/P 68 0 R
/F 4
/DA (/HeBo 9 Tf 0 0 0.627 rg)
>>
endobj
105 0 obj
<<
/Type /Annot
/Subtype /Widget
/Rect [ 255.8392 556.46609 285.8392 567.46609 ]
/T (f1-15)
/FT /Tx
/Q 2
/P 68 0 R
/F 4
/DA (/HeBo 9 Tf 0 0 0.627 rg)
>>
endobj
106 0 obj
<<
/Type /Annot
/Subtype /Widget
/Rect [ 226.8392 543.46609 300.8392 556.46609 ]
/T (f1-15a)
/FT /Tx
/P 68 0 R
/F 4
/DA (/HeBo 9 Tf 0 0 0.627 rg)
>>
endobj
115 0 obj
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
/P 68 0 R
/AS /Off
/AP << /N << /On 118 0 R >> /D << /On 116 0 R /Off 117 0 R >> >>
>>
endobj
119 0 obj
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
/P 68 0 R
/AS /Off
/AP << /N << /On 122 0 R >> /D << /On 120 0 R /Off 121 0 R >> >>
>>
endobj
131 0 obj
<<
/Type /Annot
/Subtype /Widget
/Rect [ 365.8392 411.46609 457.8392 424.46609 ]
/T (f1-28)
/FT /Tx
/Q 2
/P 68 0 R
/F 4
/DA (/HeBo 9 Tf 0 0 0.627 rg)
>>
endobj
132 0 obj
<<
/Type /Annot
/Subtype /Widget
/Rect [ 365.8392 399.46609 457.8392 410.46609 ]
/T (f1-29)
/FT /Tx
/Q 2
/P 68 0 R
/F 4
/DA (/HeBo 9 Tf 0 0 0.627 rg)
>>
endobj
134 0 obj
<<
/Type /Annot
/Subtype /Widget
/Rect [ 365.8392 375.46609 457.8392 387.46609 ]
/T (f1-31)
/FT /Tx
/Q 2
/P 68 0 R
/F 4
/DA (/HeBo 9 Tf 0 0 0.627 rg)
>>
endobj
136 0 obj
<<
/Type /Annot
/Subtype /Widget
/Rect [ 365.8392 339.46609 457.8392 351.46609 ]
/T (f1-33)
/FT /Tx
/Q 2
/P 68 0 R
/F 4
/DA (/HeBo 9 Tf 0 0 0.627 rg)
>>
endobj
137 0 obj
<<
/Type /Annot
/Subtype /Widget
/Rect [ 365.8392 327.46609 457.8392 339.46609 ]
/T (f1-34)
/FT /Tx
/Q 2
/P 68 0 R
/F 4
/DA (/HeBo 9 Tf 0 0 0.627 rg)
>>
endobj
143 0 obj
<<
/Type /Annot
/Subtype /Widget
/Rect [ 365.8392 243.46609 457.8392 255.46609 ]
/T (f1-40)
/FT /Tx
/Q 2
/P 68 0 R
/F 4
/DA (/HeBo 9 Tf 0 0 0.627 rg)
>>
endobj
10 0 obj
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
11 0 obj
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
21 0 obj
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
22 0 obj
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
23 0 obj
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
25 0 obj
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
/AP << /N << /On 51 0 R >> /D << /On 52 0 R /Off 53 0 R >> >>
>>
endobj
26 0 obj
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
/AP << /N << /On 54 0 R >> /D << /On 55 0 R /Off 56 0 R >> >>
>>
endobj
27 0 obj
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
32 0 obj
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
35 0 obj
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
36 0 obj
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
%%% Data End %%%
