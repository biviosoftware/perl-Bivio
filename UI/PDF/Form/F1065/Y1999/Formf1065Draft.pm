# This file was built by buildFormModule.pl
# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::PDF::Form::F1065::Y1999::Formf1065Draft;
use strict;
$Bivio::UI::PDF::Form::F1065::Y1999::Formf1065Draft::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::PDF::Form::F1065::Y1999::Formf1065Draft - 

=head1 SYNOPSIS

    use Bivio::UI::PDF::Form::F1065::Y1999::Formf1065Draft;
    Bivio::UI::PDF::Form::F1065::Y1999::Formf1065Draft->new();

=cut

=head1 EXTENDS

L<Bivio::UI::PDF::Form::Form>

=cut

use Bivio::UI::PDF::Form::Form;
@Bivio::UI::PDF::Form::F1065::Y1999::Formf1065Draft::ISA = ('Bivio::UI::PDF::Form::Form');

=head1 DESCRIPTION

C<Bivio::UI::PDF::Form::F1065::Y1999::Formf1065Draft>

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

=head2 static new() : Bivio::UI::PDF::Form::F1065::Y1999::Formf1065Draft



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
570 0 obj<< /Linearized 1 /O 574 /H [ 7028 2262 ] /L 194802 /E 58155 /N 4 /T 183283 >> endobj                                                     xref570 184 0000000016 00000 n
0000004032 00000 n
0000004124 00000 n
0000006990 00000 n
0000009290 00000 n
0000009525 00000 n
0000010238 00000 n
0000010441 00000 n
0000010588 00000 n
0000010791 00000 n
0000010937 00000 n
0000011151 00000 n
0000011298 00000 n
0000011463 00000 n
0000011611 00000 n
0000011832 00000 n
0000011980 00000 n
0000012201 00000 n
0000012349 00000 n
0000012512 00000 n
0000012659 00000 n
0000012878 00000 n
0000013025 00000 n
0000013250 00000 n
0000013397 00000 n
0000013601 00000 n
0000013748 00000 n
0000013951 00000 n
0000014098 00000 n
0000014280 00000 n
0000014462 00000 n
0000014644 00000 n
0000014936 00000 n
0000015223 00000 n
0000015387 00000 n
0000015480 00000 n
0000015737 00000 n
0000016051 00000 n
0000016338 00000 n
0000016502 00000 n
0000016759 00000 n
0000017076 00000 n
0000017363 00000 n
0000017527 00000 n
0000017784 00000 n
0000018089 00000 n
0000018376 00000 n
0000018540 00000 n
0000018797 00000 n
0000019114 00000 n
0000019401 00000 n
0000019565 00000 n
0000019822 00000 n
0000020139 00000 n
0000020426 00000 n
0000020590 00000 n
0000020847 00000 n
0000021120 00000 n
0000021407 00000 n
0000021571 00000 n
0000021828 00000 n
0000021971 00000 n
0000022171 00000 n
0000022313 00000 n
0000022456 00000 n
0000022610 00000 n
0000022763 00000 n
0000022917 00000 n
0000023070 00000 n
0000023223 00000 n
0000023375 00000 n
0000023529 00000 n
0000023682 00000 n
0000023835 00000 n
0000023988 00000 n
0000024142 00000 n
0000024294 00000 n
0000024447 00000 n
0000024599 00000 n
0000024804 00000 n
0000025008 00000 n
0000025161 00000 n
0000025313 00000 n
0000025466 00000 n
0000025619 00000 n
0000025773 00000 n
0000025925 00000 n
0000026079 00000 n
0000026232 00000 n
0000026385 00000 n
0000026537 00000 n
0000026690 00000 n
0000026843 00000 n
0000026996 00000 n
0000027149 00000 n
0000027303 00000 n
0000027456 00000 n
0000027661 00000 n
0000027866 00000 n
0000028072 00000 n
0000028277 00000 n
0000028430 00000 n
0000028583 00000 n
0000028789 00000 n
0000028994 00000 n
0000029200 00000 n
0000029405 00000 n
0000029611 00000 n
0000029816 00000 n
0000029969 00000 n
0000030121 00000 n
0000030327 00000 n
0000030532 00000 n
0000030738 00000 n
0000030943 00000 n
0000031260 00000 n
0000031547 00000 n
0000031711 00000 n
0000031968 00000 n
0000032148 00000 n
0000032288 00000 n
0000032444 00000 n
0000032594 00000 n
0000032792 00000 n
0000032948 00000 n
0000033091 00000 n
0000033235 00000 n
0000033479 00000 n
0000033516 00000 n
0000033740 00000 n
0000038379 00000 n
0000038454 00000 n
0000038531 00000 n
0000038662 00000 n
0000038853 00000 n
0000039708 00000 n
0000039918 00000 n
0000040129 00000 n
0000040317 00000 n
0000040552 00000 n
0000040910 00000 n
0000041132 00000 n
0000041924 00000 n
0000042722 00000 n
0000042792 00000 n
0000043491 00000 n
0000043705 00000 n
0000043727 00000 n
0000044789 00000 n
0000045490 00000 n
0000045710 00000 n
0000045732 00000 n
0000046742 00000 n
0000046764 00000 n
0000047620 00000 n
0000047642 00000 n
0000048425 00000 n
0000049222 00000 n
0000049435 00000 n
0000050228 00000 n
0000050450 00000 n
0000050472 00000 n
0000051337 00000 n
0000051360 00000 n
0000052440 00000 n
0000052462 00000 n
0000053395 00000 n
0000053417 00000 n
0000054312 00000 n
0000054426 00000 n
0000054496 00000 n
0000054605 00000 n
0000055955 00000 n
0000056048 00000 n
0000056098 00000 n
0000056157 00000 n
0000056236 00000 n
0000056295 00000 n
0000056409 00000 n
0000057759 00000 n
0000057868 00000 n
0000057918 00000 n
0000007028 00000 n
0000009267 00000 n
trailer<</Size 754/Info 567 0 R /Root 571 0 R /Prev 183272 /ID[<7082243b0dfb3ee468e8d873148787cd><7082243b0dfb3ee468e8d873148787cd>]>>startxref0%%EOF    571 0 obj<< /Type /Catalog /Pages 568 0 R /AcroForm 572 0 R /Names 573 0 R >> endobj572 0 obj<< /Fields [ 576 0 R 578 0 R 580 0 R 423 0 R 584 0 R 586 0 R 424 0 R 590 0 R 592 0 R 594 0 R 596 0 R 598 0 R 599 0 R 600 0 R 425 0 R 426 0 R 610 0 R 427 0 R 618 0 R 622 0 R 428 0 R 631 0 R 429 0 R 430 0 R 431 0 R 432 0 R 433 0 R 434 0 R 435 0 R 436 0 R 648 0 R 649 0 R 437 0 R 438 0 R 439 0 R 440 0 R 441 0 R 442 0 R 443 0 R 444 0 R 445 0 R 446 0 R 447 0 R 448 0 R 666 0 R 667 0 R 668 0 R 669 0 R 449 0 R 450 0 R 451 0 R 452 0 R 672 0 R 673 0 R 674 0 R 675 0 R 676 0 R 677 0 R 453 0 R 454 0 R 455 0 R 456 0 R 680 0 R 681 0 R 682 0 R 683 0 R 457 0 R 684 0 R 688 0 R 690 0 R 691 0 R 458 0 R 692 0 R 693 0 R 459 0 R 460 0 R 461 0 R 462 0 R 463 0 R 464 0 R 465 0 R 466 0 R 24 0 R 25 0 R 26 0 R 27 0 R 28 0 R 29 0 R 30 0 R 31 0 R 32 0 R 33 0 R 34 0 R 35 0 R 36 0 R 37 0 R 38 0 R 39 0 R 467 0 R 41 0 R 42 0 R 43 0 R 44 0 R 45 0 R 46 0 R 47 0 R 48 0 R 49 0 R 59 0 R 60 0 R 61 0 R 62 0 R 63 0 R 67 0 R 468 0 R 469 0 R 77 0 R 78 0 R 82 0 R 83 0 R 84 0 R 85 0 R 86 0 R 87 0 R 88 0 R 89 0 R 101 0 R 470 0 R 471 0 R 102 0 R 103 0 R 104 0 R 105 0 R 106 0 R 107 0 R 108 0 R 109 0 R 472 0 R 111 0 R 473 0 R 474 0 R 475 0 R 476 0 R 116 0 R 117 0 R 118 0 R 119 0 R 120 0 R 121 0 R 122 0 R 123 0 R 124 0 R 125 0 R 126 0 R 127 0 R 128 0 R 129 0 R 130 0 R 477 0 R 478 0 R 479 0 R 480 0 R 481 0 R 482 0 R 483 0 R 484 0 R 485 0 R 486 0 R 487 0 R 488 0 R 489 0 R 490 0 R 491 0 R 492 0 R 493 0 R 494 0 R 495 0 R 496 0 R 497 0 R 498 0 R 499 0 R 500 0 R 501 0 R 502 0 R 503 0 R 504 0 R 505 0 R 506 0 R 507 0 R 508 0 R 509 0 R 510 0 R 511 0 R 512 0 R 513 0 R 514 0 R 176 0 R 177 0 R 178 0 R 179 0 R 180 0 R 181 0 R 182 0 R 183 0 R 184 0 R 185 0 R 186 0 R 187 0 R 188 0 R 189 0 R 196 0 R 197 0 R 515 0 R 516 0 R 517 0 R 518 0 R 198 0 R 199 0 R 200 0 R 201 0 R 202 0 R 203 0 R 519 0 R 520 0 R 204 0 R 205 0 R 206 0 R 207 0 R 208 0 R 209 0 R 210 0 R 211 0 R 212 0 R 213 0 R 214 0 R 215 0 R 216 0 R 217 0 R 218 0 R 219 0 R 220 0 R 221 0 R 222 0 R 223 0 R 224 0 R 521 0 R 522 0 R 523 0 R 524 0 R 525 0 R 526 0 R 238 0 R 239 0 R 240 0 R 241 0 R 242 0 R 243 0 R 527 0 R 528 0 R 529 0 R 530 0 R 531 0 R 532 0 R 533 0 R 534 0 R 535 0 R 536 0 R 254 0 R 255 0 R 256 0 R 257 0 R 258 0 R 259 0 R 260 0 R 261 0 R 537 0 R 538 0 R 539 0 R 540 0 R 541 0 R 542 0 R 270 0 R 271 0 R 543 0 R 544 0 R 545 0 R 546 0 R 276 0 R 277 0 R 547 0 R 548 0 R 278 0 R 279 0 R 280 0 R 282 0 R 549 0 R 550 0 R 551 0 R 552 0 R 553 0 R 554 0 R 555 0 R 556 0 R 557 0 R 558 0 R 559 0 R 560 0 R 294 0 R 295 0 R 296 0 R 297 0 R 298 0 R 299 0 R 300 0 R 301 0 R 302 0 R 303 0 R 305 0 R 561 0 R 306 0 R 307 0 R 308 0 R 309 0 R 310 0 R 562 0 R 312 0 R 313 0 R 314 0 R 316 0 R 317 0 R 563 0 R 318 0 R 319 0 R 320 0 R 321 0 R 323 0 R 564 0 R 325 0 R 565 0 R 326 0 R 327 0 R 328 0 R 329 0 R 331 0 R 332 0 R 566 0 R 333 0 R 334 0 R 335 0 R ] /DR 746 0 R /DA (/Helv 0 Tf 0 g )>> endobj573 0 obj<< /AP 569 0 R >> endobj752 0 obj<< /S 1130 /V 2173 /Filter /FlateDecode /Length 753 0 R >> stream
H��V{PSg�rs�ܘB��JD���		/y( � H��,�{� ��<Zpԍ-*v���u6A��*��(*Z���ntѪ]w�&�Yw֙�q��3�M�w�;9�9�|�  `W ؗ�Ә��% �)�@\E8�]����Cop��]Y��_��lh}8p��wMI���'W���:^���7ޑ=�hBM�,���l�����o���4$�z+�樶x�b��&wh��� ��S�Ay�ê�f(��h��M=�ʪX"��]]�<���n�"����|�Nܹ�-��V�������^{��zy�3�ـ��Oͯ�Z�\~����}w��-ȇ�5٪�Z������R��G��l������&U�I�.ݚ�4z�dI��Se��v��ݽ$�L�M�
9Иm#���'��W�6Y�C�c��.9���U��$p�+"���G+G�q	��Mq� �8�U͍����L�ޓ�<F*��J�ؕ�0�,0���(�mW��̮u
?�h���7�����,[9���[u�|?�}�$�ϡw��9��RGJ�tő��v:�%^/��+��3>+<����UsT>����Wt�L�{���l���n����f+l��h{׎|�xA��"Ŗq7���f[c�������6۾+=v��������>�û7YS���f_�eι�������������Ǔ���n>�}��F���^k�i������7��I��9���{����~{9�K����
 (���f�S��P*f`�*�|9��2��=��V�ݗ?��X�*p'��J9�|@���J���2�
��M��������	��LT�9���rȍ`;M*�#L��dL���� M>a���&K�^lp���,@H�� �5�~G�[`��%k��W��i�Ly��Q	Y��a	�
 `�55
�t��36߻�LG��'�:0�����n�]ħ�MD�%&;��$��,t`#� i��4A*4�B;Hm^��$U>���S9�R� ��f�Pyr�+Q�-�y��m���Í���υ����@E�&H��T�<�p�VE@1��%ʝr���P�\lb��R9Qp�+��*��Pe�P:-#vq0��K��:I�^��4�M{�Ծ��_�� ��r��L���� /<028 ����@����gx4/��z��;��`��P'�pF���z�7��ëcJ�T�\Ot��Q�ѓ�%���uـ�O��<G���o����x��K1�C�������f{-2��I�5 v��sTC�����'�h�(c�} �=Mn:i;�H�-6o�p���*N95E"��2�
������0��R��b�m�9A�r��Sd"��0�����a�z�=�S�-?#2.v�ix�V.ҿ���H��K�A��s�X��$�o�S`���o�&��' ��G�`C�,��#�NbO�@��9cFY��{���V���VDn�ơ�HW-�k��4����[oN������H����)��3h�-Y3�o&^�����E/U>�YU�=���^6�P�c�'��釿k��E�G��6d����s�{�̀�.�Øv�#U�i��'�70�1ftV:��.�>�]=ռݶ�i��׍��:���>WC.��{�s���>m��(�=��r���?k�[�Y��u9�|�dAh!�W[����N��k�&��kw���W��;jT߻1�o�!��%#��6���>r�z��ъ��N����<&m��ڇ���Q�,����5絜-�$/ugS۶����ȁ/�j���س?��m���I��k䱟?��;=�˱��n��
�ǲ�?�ܙQ�1Z�6���{~WvL�p�/�xǺ��f�hG�Y\�o��b|}��>7��?'��,����6��K3l���Y����X�'���J[�����Ӓ��������'�X���h�@lC���8q4C���3K���VO<�g�+��Q�}z�zXv�_M\u��O��}i5}���==�M�j��-Z��N�0a�v�P���e�ٍ��^��L���&��sɘF�"8:�J��*l��K�H�� �G�*endstreamendobj753 0 obj2143 endobj574 0 obj<< /Type /Page /Parent 568 0 R /Resources 703 0 R /Contents [ 717 0 R 721 0 R 723 0 R 725 0 R 731 0 R 733 0 R 735 0 R 737 0 R ] /MediaBox [ 0 0 612 792 ] /CropBox [ 0 0 612 792 ] /Rotate 0 /Annots 575 0 R >> endobj575 0 obj[ 576 0 R 578 0 R 580 0 R 582 0 R 584 0 R 586 0 R 588 0 R 590 0 R 592 0 R 594 0 R 596 0 R 598 0 R 599 0 R 600 0 R 601 0 R 606 0 R 610 0 R 614 0 R 618 0 R 622 0 R 626 0 R 630 0 R 631 0 R 632 0 R 633 0 R 634 0 R 635 0 R 636 0 R 637 0 R 638 0 R 639 0 R 640 0 R 641 0 R 642 0 R 643 0 R 644 0 R 645 0 R 646 0 R 647 0 R 648 0 R 649 0 R 650 0 R 651 0 R 652 0 R 653 0 R 654 0 R 655 0 R 656 0 R 657 0 R 658 0 R 659 0 R 660 0 R 661 0 R 662 0 R 663 0 R 664 0 R 665 0 R 666 0 R 667 0 R 668 0 R 669 0 R 670 0 R 671 0 R 672 0 R 673 0 R 674 0 R 675 0 R 676 0 R 677 0 R 678 0 R 679 0 R 680 0 R 681 0 R 682 0 R 683 0 R 684 0 R 688 0 R 689 0 R 690 0 R 691 0 R 692 0 R 693 0 R 694 0 R 695 0 R 696 0 R ]endobj576 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 295.33562 734.99957 331.33586 746.99965 ] /F 4 /P 574 0 R /T (f1-1)/FT /Tx /Q 1 /AP << /N 577 0 R >> /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj577 0 obj<< /Length 11 /Subtype /Form /BBox [ 0 0 36.00024 12.00008 ] /Resources << /ProcSet [ /PDF ] >> >> stream
/Tx BMC EMCendstreamendobj578 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 396.33638 734.99957 429.00328 746.99965 ] /F 4 /P 574 0 R /T (f1-2)/FT /Tx /Q 1 /AP << /N 579 0 R >> /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj579 0 obj<< /Length 11 /Subtype /Form /BBox [ 0 0 32.6669 12.00008 ] /Resources << /ProcSet [ /PDF ] >> >> stream
/Tx BMC EMCendstreamendobj580 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 434.33669 734.99957 460.33684 747.66631 ] /F 4 /P 574 0 R /T (f1-3)/FT /Tx /Q 1 /AP << /N 581 0 R >> /MaxLen 4 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj581 0 obj<< /Length 11 /Subtype /Form /BBox [ 0 0 26.00015 12.66673 ] /Resources << /ProcSet [ /PDF ] >> >> stream
/Tx BMC EMCendstreamendobj582 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 179.00137 698.99931 462.33687 714.66608 ] /F 4 /P 574 0 R /AP << /N 583 0 R >> /Parent 423 0 R >> endobj583 0 obj<< /Length 11 /Subtype /Form /BBox [ 0 0 283.33549 15.66676 ] /Resources << /ProcSet [ /PDF ] >> >> stream
/Tx BMC EMCendstreamendobj584 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 178.66747 675.49866 462.00296 691.16542 ] /P 574 0 R /F 4 /T (f1-5)/FT /Tx /AA << >> /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)/AP << /N 585 0 R >> >> endobj585 0 obj<< /Length 11 /Subtype /Form /BBox [ 0 0 283.33549 15.66676 ] /Resources << /ProcSet [ /PDF ] >> >> stream
/Tx BMC EMCendstreamendobj586 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 178.66747 647.49866 462.00296 667.16542 ] /P 574 0 R /F 4 /T (f1-6)/FT /Tx /AA << >> /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)/AP << /N 587 0 R >> >> endobj587 0 obj<< /Length 11 /Subtype /Form /BBox [ 0 0 283.33549 19.66676 ] /Resources << /ProcSet [ /PDF ] >> >> stream
/Tx BMC EMCendstreamendobj588 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 50.00038 698.9993 134.00099 712.66606 ] /F 4 /P 574 0 R /AP << /N 589 0 R >> /Parent 424 0 R >> endobj589 0 obj<< /Length 11 /Subtype /Form /BBox [ 0 0 84.00061 13.66676 ] /Resources << /ProcSet [ /PDF ] >> >> stream
/Tx BMC EMCendstreamendobj590 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 49.3349 675.49866 134.33551 690.16542 ] /P 574 0 R /F 4 /T (f1-8)/FT /Tx /AA << >> /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)/AP << /N 591 0 R >> >> endobj591 0 obj<< /Length 11 /Subtype /Form /BBox [ 0 0 85.00061 14.66676 ] /Resources << /ProcSet [ /PDF ] >> >> stream
/Tx BMC EMCendstreamendobj592 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 41.3349 646.49866 134.33551 661.16542 ] /P 574 0 R /F 4 /T (f1-9)/FT /Tx /AA << >> /Q 1 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)/AP << /N 593 0 R >> >> endobj593 0 obj<< /Length 11 /Subtype /Form /BBox [ 0 0 93.00061 14.66676 ] /Resources << /ProcSet [ /PDF ] >> >> stream
/Tx BMC EMCendstreamendobj594 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 467.36346 699.71539 493.78156 714.64093 ] /F 4 /P 574 0 R /T (f1-10)/FT /Tx /Q 2 /AP << /N 595 0 R >> /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj595 0 obj<< /Length 11 /Subtype /Form /BBox [ 0 0 26.41809 14.92554 ] /Resources << /ProcSet [ /PDF ] >> >> stream
/Tx BMC EMCendstreamendobj596 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 498.0038 699.66597 567.33768 714.66606 ] /F 4 /P 574 0 R /T (f1-11)/FT /Tx /Q 0 /AP << /N 597 0 R >> /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj597 0 obj<< /Length 11 /Subtype /Form /BBox [ 0 0 69.33388 15.00009 ] /Resources << /ProcSet [ /PDF ] >> >> stream
/Tx BMC EMCendstreamendobj598 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 468.00363 674.99911 568.33766 690.66589 ] /F 4 /P 574 0 R /T (f1-12)/FT /Tx /Q 1 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj599 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 474.33699 646.66556 544.33748 660.99899 ] /F 4 /P 574 0 R /T (f1-13)/FT /Tx /Q 2 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj600 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 546.33752 645.99889 564.00433 659.99899 ] /F 4 /P 574 0 R /T (f1-14)/FT /Tx /Q 2 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj601 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 171.33466 627.66541 180.00137 634.66547 ] /F 4 /P 574 0 R /AS /Off /AP << /N << /Yes 605 0 R >> /D << /Yes 602 0 R /Off 603 0 R >> >> /DA (/ZaDb 9 Tf 0 0 0.627 rg)/H /T /MK << /CA (4)/AC (��)/RC (��)>> /Parent 425 0 R >> endobj602 0 obj<< /Length 120 /Subtype /Form /BBox [ 0 0 8.66672 7.00006 ] /Resources << /ProcSet [ /PDF /Text ] /Font << /ZaDb 604 0 R >> >> >> stream
0.749 g 0 0 8.6667 7.0001 re f q 1 1 6.6667 5.0001 re W n BT /ZaDb 9 Tf 0 0 0.627 rg  1 0 0 1 0.5264 0.2646 Tm (4) Tj ETendstreamendobj603 0 obj<< /Length 30 /Subtype /Form /BBox [ 0 0 8.66672 7.00006 ] /Resources << /ProcSet [ /PDF ] >> >> stream
0.749 g 0 0 8.6667 7.0001 re fendstreamendobj604 0 obj<< /Type /Font /Name /ZaDb /BaseFont /ZapfDingbats /Subtype /Type1 >> endobj605 0 obj<< /Length 91 /Subtype /Form /BBox [ 0 0 8.66672 7.00006 ] /Resources << /ProcSet [ /PDF /Text ] /Font << /ZaDb 604 0 R >> >> >> stream
q 1 1 6.6667 5.0001 re W n BT /ZaDb 9 Tf 0 0 0.627 rg  1 0 0 1 0.5264 0.2646 Tm (4) Tj ET Qendstreamendobj606 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 265.16885 626.832 273.83557 635.83206 ] /DR 744 0 R /P 574 0 R /AS /Off /F 4 /H /T /MK << /CA (4)/AC (��)/RC (��)>> /DA (/ZaDb 9 Tf 0 0 0.627 rg)/AP << /N << /Yes 609 0 R >> /D << /Yes 607 0 R /Off 608 0 R >> >> /AA << >> /Parent 426 0 R >> endobj607 0 obj<< /Length 120 /Subtype /Form /BBox [ 0 0 8.66672 9.00006 ] /Resources << /ProcSet [ /PDF /Text ] /Font << /ZaDb 604 0 R >> >> >> stream
0.749 g 0 0 8.6667 9.0001 re f q 1 1 6.6667 7.0001 re W n BT /ZaDb 9 Tf 0 0 0.627 rg  1 0 0 1 0.5264 1.2646 Tm (4) Tj ETendstreamendobj608 0 obj<< /Length 30 /Subtype /Form /BBox [ 0 0 8.66672 9.00006 ] /Resources << /ProcSet [ /PDF ] >> >> stream
0.749 g 0 0 8.6667 9.0001 re fendstreamendobj609 0 obj<< /Length 91 /Subtype /Form /BBox [ 0 0 8.66672 9.00006 ] /Resources << /ProcSet [ /PDF /Text ] /Font << /ZaDb 604 0 R >> >> >> stream
q 1 1 6.6667 7.0001 re W n BT /ZaDb 9 Tf 0 0 0.627 rg  1 0 0 1 0.5264 1.2646 Tm (4) Tj ET Qendstreamendobj610 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 359.16885 627.832 366.83557 634.83206 ] /DR 746 0 R /P 574 0 R /AS /Off /F 4 /H /T /MK << /CA (4)/AC (��)/RC (��)>> /T (c1-3)/FT /Btn /AA << >> /DA (/ZaDb 9 Tf 0 0 0.627 rg)/AP << /N << /Yes 613 0 R >> /D << /Yes 611 0 R /Off 612 0 R >> >> >> endobj611 0 obj<< /Length 120 /Subtype /Form /BBox [ 0 0 7.66672 7.00006 ] /Resources << /ProcSet [ /PDF /Text ] /Font << /ZaDb 604 0 R >> >> >> stream
0.749 g 0 0 7.6667 7.0001 re f q 1 1 5.6667 5.0001 re W n BT /ZaDb 9 Tf 0 0 0.627 rg  1 0 0 1 0.0264 0.2646 Tm (4) Tj ETendstreamendobj612 0 obj<< /Length 30 /Subtype /Form /BBox [ 0 0 7.66672 7.00006 ] /Resources << /ProcSet [ /PDF ] >> >> stream
0.749 g 0 0 7.6667 7.0001 re fendstreamendobj613 0 obj<< /Length 91 /Subtype /Form /BBox [ 0 0 7.66672 7.00006 ] /Resources << /ProcSet [ /PDF /Text ] /Font << /ZaDb 604 0 R >> >> >> stream
q 1 1 5.6667 5.0001 re W n BT /ZaDb 9 Tf 0 0 0.627 rg  1 0 0 1 0.0264 0.2646 Tm (4) Tj ET Qendstreamendobj614 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 481.00584 627.39325 488.67256 635.39331 ] /DA (/ZaDb 9 Tf 0 0 0.627 rg)/P 574 0 R /AS /Off /F 4 /H /T /MK << /CA (4)/AC (��)/RC (��)>> /AP << /N << /Yes 617 0 R >> /D << /Yes 615 0 R /Off 616 0 R >> >> /DR 746 0 R /Parent 427 0 R >> endobj615 0 obj<< /Length 120 /Subtype /Form /BBox [ 0 0 7.66672 8.00006 ] /Resources << /ProcSet [ /PDF /Text ] /Font << /ZaDb 604 0 R >> >> >> stream
0.749 g 0 0 7.6667 8.0001 re f q 1 1 5.6667 6.0001 re W n BT /ZaDb 9 Tf 0 0 0.627 rg  1 0 0 1 0.0264 0.7646 Tm (4) Tj ETendstreamendobj616 0 obj<< /Length 30 /Subtype /Form /BBox [ 0 0 7.66672 8.00006 ] /Resources << /ProcSet [ /PDF ] >> >> stream
0.749 g 0 0 7.6667 8.0001 re fendstreamendobj617 0 obj<< /Length 91 /Subtype /Form /BBox [ 0 0 7.66672 8.00006 ] /Resources << /ProcSet [ /PDF /Text ] /Font << /ZaDb 604 0 R >> >> >> stream
q 1 1 5.6667 6.0001 re W n BT /ZaDb 9 Tf 0 0 0.627 rg  1 0 0 1 0.0264 0.7646 Tm (4) Tj ET Qendstreamendobj618 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 171.16885 614.832 179.83557 623.83206 ] /DR 746 0 R /P 574 0 R /AS /Off /F 4 /H /T /MK << /CA (4)/AC (��)/RC (��)>> /AA << >> /T (c1-5)/FT /Btn /DA (/ZaDb 9 Tf 0 0 0.627 rg)/AP << /N << /Yes 621 0 R >> /D << /Yes 619 0 R /Off 620 0 R >> >> >> endobj619 0 obj<< /Length 120 /Subtype /Form /BBox [ 0 0 8.66672 9.00006 ] /Resources << /ProcSet [ /PDF /Text ] /Font << /ZaDb 604 0 R >> >> >> stream
0.749 g 0 0 8.6667 9.0001 re f q 1 1 6.6667 7.0001 re W n BT /ZaDb 9 Tf 0 0 0.627 rg  1 0 0 1 0.5264 1.2646 Tm (4) Tj ETendstreamendobj620 0 obj<< /Length 30 /Subtype /Form /BBox [ 0 0 8.66672 9.00006 ] /Resources << /ProcSet [ /PDF ] >> >> stream
0.749 g 0 0 8.6667 9.0001 re fendstreamendobj621 0 obj<< /Length 91 /Subtype /Form /BBox [ 0 0 8.66672 9.00006 ] /Resources << /ProcSet [ /PDF /Text ] /Font << /ZaDb 604 0 R >> >> >> stream
q 1 1 6.6667 7.0001 re W n BT /ZaDb 9 Tf 0 0 0.627 rg  1 0 0 1 0.5264 1.2646 Tm (4) Tj ET Qendstreamendobj622 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 265.16885 614.832 273.83557 623.83206 ] /DR 746 0 R /P 574 0 R /AS /Off /F 4 /H /T /MK << /CA (4)/AC (��)/RC (��)>> /AA << >> /T (c1-6)/FT /Btn /DA (/ZaDb 9 Tf 0 0 0.627 rg)/AP << /N << /Yes 625 0 R >> /D << /Yes 623 0 R /Off 624 0 R >> >> >> endobj623 0 obj<< /Length 120 /Subtype /Form /BBox [ 0 0 8.66672 9.00006 ] /Resources << /ProcSet [ /PDF /Text ] /Font << /ZaDb 604 0 R >> >> >> stream
0.749 g 0 0 8.6667 9.0001 re f q 1 1 6.6667 7.0001 re W n BT /ZaDb 9 Tf 0 0 0.627 rg  1 0 0 1 0.5264 1.2646 Tm (4) Tj ETendstreamendobj624 0 obj<< /Length 30 /Subtype /Form /BBox [ 0 0 8.66672 9.00006 ] /Resources << /ProcSet [ /PDF ] >> >> stream
0.749 g 0 0 8.6667 9.0001 re fendstreamendobj625 0 obj<< /Length 91 /Subtype /Form /BBox [ 0 0 8.66672 9.00006 ] /Resources << /ProcSet [ /PDF /Text ] /Font << /ZaDb 604 0 R >> >> >> stream
q 1 1 6.6667 7.0001 re W n BT /ZaDb 9 Tf 0 0 0.627 rg  1 0 0 1 0.5264 1.2646 Tm (4) Tj ET Qendstreamendobj626 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 358.00584 615.39325 367.67256 623.39331 ] /AP << /N << /Yes 629 0 R >> /D << /Yes 627 0 R /Off 628 0 R >> >> /P 574 0 R /AS /Off /F 4 /H /T /MK << /CA (4)/AC (��)/RC (��)>> /AA << >> /Parent 457 0 R >> endobj627 0 obj<< /Length 120 /Subtype /Form /BBox [ 0 0 9.66672 8.00006 ] /Resources << /ProcSet [ /PDF /Text ] /Font << /ZaDb 604 0 R >> >> >> stream
0.749 g 0 0 9.6667 8.0001 re f q 1 1 7.6667 6.0001 re W n BT /ZaDb 9 Tf 0 0 0.627 rg  1 0 0 1 1.0264 0.7646 Tm (4) Tj ETendstreamendobj628 0 obj<< /Length 30 /Subtype /Form /BBox [ 0 0 9.66672 8.00006 ] /Resources << /ProcSet [ /PDF ] >> >> stream
0.749 g 0 0 9.6667 8.0001 re fendstreamendobj629 0 obj<< /Length 91 /Subtype /Form /BBox [ 0 0 9.66672 8.00006 ] /Resources << /ProcSet [ /PDF /Text ] /Font << /ZaDb 604 0 R >> >> >> stream
q 1 1 7.6667 6.0001 re W n BT /ZaDb 9 Tf 0 0 0.627 rg  1 0 0 1 1.0264 0.7646 Tm (4) Tj ET Qendstreamendobj630 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 439.00336 614.99866 567.33765 626.99873 ] /F 4 /P 574 0 R /Parent 428 0 R >> endobj631 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 439.16879 603.49855 567.50308 615.49863 ] /P 574 0 R /F 4 /T (f1-16)/FT /Tx /AA << >> /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj632 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 373.3362 543.66478 436.00333 556.66486 ] /F 4 /P 574 0 R /Parent 429 0 R >> endobj633 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 438.00334 542.99811 456.00349 556.99818 ] /F 4 /P 574 0 R /Parent 430 0 R >> endobj634 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 373.33556 531.33148 436.00269 543.33156 ] /P 574 0 R /F 4 /AA << >> /Parent 431 0 R >> endobj635 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 438.0027 531.66481 456.00285 542.66489 ] /P 574 0 R /F 4 /AA << >> /Parent 432 0 R >> endobj636 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 481.33556 530.99814 544.00269 545.99821 ] /P 574 0 R /F 4 /AA << >> /Parent 435 0 R >> endobj637 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 546.0027 531.33147 563.00285 545.33154 ] /P 574 0 R /F 4 /AA << >> /Parent 436 0 R >> endobj638 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 481.33556 507.6644 544.00269 520.66447 ] /P 574 0 R /F 4 /AA << >> /Parent 433 0 R >> endobj639 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 546.0027 507.99773 564.00285 520.9978 ] /P 574 0 R /F 4 /AA << >> /Parent 434 0 R >> endobj640 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 481.33556 495.99774 544.00269 506.99782 ] /P 574 0 R /F 4 /AA << >> /Parent 437 0 R >> endobj641 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 546.0027 495.33107 564.00285 507.33115 ] /P 574 0 R /F 4 /AA << >> /Parent 438 0 R >> endobj642 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 481.33556 483.99773 544.00269 494.9978 ] /P 574 0 R /F 4 /AA << >> /Parent 439 0 R >> endobj643 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 546.0027 483.33105 564.00285 495.33113 ] /P 574 0 R /F 4 /AA << >> /Parent 440 0 R >> endobj644 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 481.33556 471.33107 544.00269 483.33115 ] /P 574 0 R /F 4 /AA << >> /Parent 441 0 R >> endobj645 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 546.0027 471.6644 564.00285 483.66447 ] /P 574 0 R /F 4 /AA << >> /Parent 442 0 R >> endobj646 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 481.33556 459.6644 544.00269 471.66447 ] /P 574 0 R /F 4 /AA << >> /Parent 443 0 R >> endobj647 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 546.0027 459.99773 564.00285 470.9978 ] /P 574 0 R /F 4 /AA << >> /Parent 444 0 R >> endobj648 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 481.33556 434.6644 544.00269 447.66447 ] /P 574 0 R /F 4 /T (f1-33)/FT /Tx /AA << >> /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj649 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 546.0027 434.99773 564.00285 447.9978 ] /P 574 0 R /F 4 /T (f1-34)/FT /Tx /AA << >> /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj650 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 481.33556 411.6644 544.00269 424.66447 ] /P 574 0 R /F 4 /AA << >> /Parent 459 0 R >> endobj651 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 546.0027 410.99773 564.00285 423.9978 ] /P 574 0 R /F 4 /AA << >> /Parent 460 0 R >> endobj652 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 481.33556 387.66302 544.00269 400.6631 ] /P 574 0 R /F 4 /AA << >> /Parent 461 0 R >> endobj653 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 546.0027 386.99635 564.00285 400.99643 ] /P 574 0 R /F 4 /AA << >> /Parent 462 0 R >> endobj654 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 481.33556 374.99637 544.00269 386.99644 ] /P 574 0 R /F 4 /AA << >> /Parent 463 0 R >> endobj655 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 546.0027 375.3297 564.00285 387.32977 ] /P 574 0 R /F 4 /AA << >> /Parent 464 0 R >> endobj656 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 481.33556 363.99635 544.00269 374.99643 ] /P 574 0 R /F 4 /AA << >> /Parent 465 0 R >> endobj657 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 546.0027 363.32968 564.00285 375.32976 ] /P 574 0 R /F 4 /AA << >> /Parent 466 0 R >> endobj658 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 481.33556 351.3297 544.00269 363.32977 ] /P 574 0 R /F 4 /AA << >> /Parent 445 0 R >> endobj659 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 546.0027 351.66302 564.00285 362.6631 ] /P 574 0 R /F 4 /AA << >> /Parent 446 0 R >> endobj660 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 481.33556 339.66302 544.00269 350.6631 ] /P 574 0 R /F 4 /AA << >> /Parent 447 0 R >> endobj661 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 546.0027 338.99635 564.00285 350.99643 ] /P 574 0 R /F 4 /AA << >> /Parent 448 0 R >> endobj662 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 481.33556 327.66302 544.00269 338.6631 ] /P 574 0 R /F 4 /AA << >> /Parent 449 0 R >> endobj663 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 546.0027 327.99635 564.00285 338.99643 ] /P 574 0 R /F 4 /AA << >> /Parent 450 0 R >> endobj664 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 481.33556 315.99635 544.00269 326.99643 ] /P 574 0 R /F 4 /AA << >> /Parent 451 0 R >> endobj665 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 546.0027 315.32968 564.00285 327.32976 ] /P 574 0 R /F 4 /AA << >> /Parent 452 0 R >> endobj666 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 373.33556 303.66302 436.00269 315.6631 ] /P 574 0 R /F 4 /T (f1-51)/FT /Tx /AA << >> /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj667 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 438.0027 303.99635 456.00285 315.99643 ] /P 574 0 R /F 4 /T (f1-52)/FT /Tx /AA << >> /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj668 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 373.33556 291.99635 436.00269 302.99643 ] /P 574 0 R /F 4 /T (f1-53)/FT /Tx /AA << >> /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj669 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 438.0027 292.32968 456.00285 303.32976 ] /P 574 0 R /F 4 /T (f1-54)/FT /Tx /AA << >> /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj670 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 481.33556 291.66302 544.00269 304.6631 ] /P 574 0 R /F 4 /AA << >> /Parent 453 0 R >> endobj671 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 546.0027 291.99635 564.00285 304.99643 ] /P 574 0 R /F 4 /AA << >> /Parent 454 0 R >> endobj672 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 481.33556 278.99635 544.00269 290.99643 ] /P 574 0 R /F 4 /T (f1-57)/FT /Tx /AA << >> /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj673 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 546.0027 279.32968 564.00285 291.32976 ] /P 574 0 R /F 4 /T (f1-58)/FT /Tx /AA << >> /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj674 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 481.33556 266.99635 544.00269 278.99643 ] /P 574 0 R /F 4 /T (f1-59)/FT /Tx /AA << >> /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj675 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 546.0027 267.32968 564.00285 278.32976 ] /P 574 0 R /F 4 /T (f1-60)/FT /Tx /AA << >> /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj676 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 481.33556 255.32968 544.00269 266.32976 ] /P 574 0 R /F 4 /T (f1-61)/FT /Tx /AA << >> /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj677 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 546.0027 255.66301 564.00285 266.66309 ] /P 574 0 R /F 4 /T (f1-62)/FT /Tx /AA << >> /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj678 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 481.33556 231.4957 544.00269 245.49577 ] /P 574 0 R /F 4 /AA << >> /Parent 455 0 R >> endobj679 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 546.0027 231.82903 564.00285 245.8291 ] /P 574 0 R /F 4 /AA << >> /Parent 456 0 R >> endobj680 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 481.33556 207.82904 544.00269 221.82912 ] /P 574 0 R /F 4 /T (f1-65)/FT /Tx /AA << >> /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj681 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 546.0027 207.16237 564.00285 222.16245 ] /P 574 0 R /F 4 /T (f1-66)/FT /Tx /AA << >> /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj682 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 481.33556 171.82904 544.00269 186.82912 ] /P 574 0 R /F 4 /T (f1-67)/FT /Tx /AA << >> /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj683 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 546.0027 172.16237 564.00285 186.16245 ] /P 574 0 R /F 4 /T (f1-68)/FT /Tx /AA << >> /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj684 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 459.83585 89.82863 467.50256 97.82869 ] /DR 746 0 R /P 574 0 R /AS /Off /F 4 /H /T /MK << /CA (4)/AC (��)/RC (��)>> /T (c1-8)/FT /Btn /AA << >> /DA (/ZaDb 9 Tf 0 0 0.627 rg)/AP << /N << /Yes 687 0 R >> /D << /Yes 685 0 R /Off 686 0 R >> >> >> endobj685 0 obj<< /Length 120 /Subtype /Form /BBox [ 0 0 7.66672 8.00006 ] /Resources << /ProcSet [ /PDF /Text ] /Font << /ZaDb 604 0 R >> >> >> stream
0.749 g 0 0 7.6667 8.0001 re f q 1 1 5.6667 6.0001 re W n BT /ZaDb 9 Tf 0 0 0.627 rg  1 0 0 1 0.0264 0.7646 Tm (4) Tj ETendstreamendobj686 0 obj<< /Length 30 /Subtype /Form /BBox [ 0 0 7.66672 8.00006 ] /Resources << /ProcSet [ /PDF ] >> >> stream
0.749 g 0 0 7.6667 8.0001 re fendstreamendobj687 0 obj<< /Length 91 /Subtype /Form /BBox [ 0 0 7.66672 8.00006 ] /Resources << /ProcSet [ /PDF /Text ] /Font << /ZaDb 604 0 R >> >> >> stream
q 1 1 5.6667 6.0001 re W n BT /ZaDb 9 Tf 0 0 0.627 rg  1 0 0 1 0.0264 0.7646 Tm (4) Tj ET Qendstreamendobj688 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 474.33698 87.6613 568.00427 102.66139 ] /F 4 /P 574 0 R /T (g1-69)/FT /Tx /Q 1 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj689 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 176.33467 74.99454 415.3365 86.99461 ] /F 4 /P 574 0 R /Parent 458 0 R >> endobj690 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 442 75 473 87 ] /F 4 /P 574 0 R /T (f1-71)/FT /Tx /Q 2 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj691 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 476 75 569 87 ] /F 4 /P 574 0 R /T (f1-72)/FT /Tx /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj692 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 176.24908 63.24995 416.25092 75.25003 ] /P 574 0 R /F 4 /T (f1-73)/FT /Tx /AA << >> /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj693 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 462 64 569 75 ] /F 4 /P 574 0 R /T (f1-74)/FT /Tx /Q 1 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj694 0 obj<< /Type /Annot /Subtype /Popup /Rect [ 230.35994 -62.54568 733.36389 46.45517 ] /Open false /F 27 /Parent 717 0 R >> endobj695 0 obj<< /Type /Annot /Subtype /Popup /Rect [ 216.96692 -155.33214 416.96849 44.66943 ] /Open false /F 27 /Parent 696 0 R >> endobj696 0 obj<< /Type /Annot /Subtype /Stamp /Rect [ 234.8243 7.16899 378.57605 44.66945 ] /Popup 695 0 R /C [ 0.75294 0.75294 0.75294 ] /T (John H Yates)/Contents ()/M (D:20000322204626-07'00')/AP 697 0 R /F 4 /Name /Draft >> endobj697 0 obj<< /N 698 0 R >> endobj698 0 obj<< /Length 71 /Subtype /Form /BBox [ 0 0 246 65 ] /Resources << /ProcSet [ /PDF ] /XObject << /FRM 699 0 R >> >> >> stream
q 0 0 246 65 re W n q 0 0 246 65 re W n 1 0 0 1 123 32.5 cm /FRM Do Q Qendstreamendobj699 0 obj<< /Length 4432 /Filter /FlateDecode /Type /XObject /Subtype /Form /BBox [ 179 374 425 439 ] /FormType 1 /Matrix [ 1 0 0 1 -302 -406.5 ] /Name /FRM /Resources 700 0 R >> stream
H�lW[�%��7�=�t$�!iY@�0@� ���H�}=��^O��H����_��?��>����_��?������g��|���w�h��̳��������|����#>� 9��]�����p�'����g�}�O����ӟ���'T��>~$��PfO�!*�<u���,,7��h�)9����_x���tX=a�!��*?�Rr&�Ds�ڒ�5��'����)�6L;%_�FB�G|�3	m>�،V�S��s2�D�Y����A�H��緃[��5����L��<QA�����$�RR�仞M��!w?{��0��_"������(��N4�\*��Ҟ}Ny����~ Mp�)���C%L�P�]0EsG~x��]�@�7]|i�e6ʜ���S�0�O��o<�a̺$�H�?�0H�n%e����f ��L�Ʃ:�9�]2xאּ8j�D������$��Y��:ӄ�WI��*�2������h:j\l\��K'�K��ִ��B������9����A: _N��[}g�e�ڹc��.��'� �@y������z��]����X�RQO���D�K4Q��n�Ew%Y���Mx��d��"�qY<L��+l��x��-Q6/��V��+&�w��7īk��[�;�H@R�5����%�����_�Z	���v��|l�	[ǄCE��#��J�@��:�u��� K�5���&K2{��\-�[�x���Gֽ3�W��LK�_��Q��cx��9�b8l^�ث�Ylπ�-�gEp����"*�PRE��#�%��"D�_���|�����#%���$�T���� PWuA-�2ֳZi�jb7/�.Nʍ�Lb �|�:޺��G<V��h*��{J4�.���"����g�{q�(�\����*tw�X2{�ſ*�����	f���H!jc1��E�[M����*�eoo��qy�'򬢬5f)���\GxiS$����l�H���.P��p^��"].j>��m*��h[ש�@iXj�֏(�BQxlM�󶥪�X׿
lp4��xc�{���Ku��Q9��1HQ}� �r�M��ϔt=XU-|�t`�pkK �R� w�Jvq:*������2&B|�u���l'q�[���I��cq�y���P9�'f�1z���TO���e�\����v���d|ɣyZeH�6�a8o=��OH_n�=,d+l�-���$�+�p�|U�c; ze�ƫ1F�H��޻���sU���i0�W�%C���xGc{U5Q+Z��)%��_qY��TxΊ����|Uq�F���}n�)�ٯ��4E�-�T�ѣ.�����XL-ʭ�狄x/u=�G�eJ��j#+�Zp��&7�nI�C7�#�c��Zm+��;ˊ��w�X;�O��9���UxQ�Z��p�d{v����2	���h�Oa�<Ѧ�K���#����"6S������v?�1��t�\}ka�h�2��T�u�����M�6%��u}1��o�;q=p�<f��0E6�܎���#b9`���|�,B1�>�J�{���m!���J�|�;t9����[^+���|�������/��u��7����g��d]U�=��vJѬ Ŗ�A�#N�;�~�]�G��'w*��*��rGLʲ ł�F�4n�����z����a���:�%X��\��[��:�N�6�&Zm���j5�Nn���"V��8j1��hN�_��~/P����hEv�Uy�i�'w��]OP|��J��]n�
|�kL^�ۦ�A_�����d��"N9C�-�K���k�_}Q�dj��Ywho$=ߕ_Gj�[�x��q?)�N���@�3�c���|��w�Ш`�MH�h��(�Q��D���m�����l:��cL�n�ta�o�R째��c��;�����q�$��.&�T���Bt�Dܟ-�Ӎ�W�jE��ͳ��P#'�!N-���?=�f���9ܼE�{d�je��wSQV}q�� p��ٸ��� W�r���kEb�-�Lv�����S�ij2\*�G��"��I��.J(L��³g`���q\��R1n�U\?�9[Gf]�"����1��E��,>Aq�Ā���*�����V�t�;�*���
e��nK�}��YZC<z�E��΁G����8�JX��
���"�#�):��-�b��݌���["�>�"��m����Rk�h�3?��_,��lmQ4˃{v��@<���w#B^�J�w�$�U���@�.D�^-X�@�T�{N�?oٽ����X�/D�2���S� %���CfA%���8Z])In���y��d�ASca2YYV_4@ԟݧ
4ĜZ����qs��Xő�y4�� �8�����8ⴞ���)���+)q�6�aU�]�ǌ^���c���)\�z3�~f�rke�V���j��[�>�M%�xe���kk�B����g�J��Za�V� ш�dj�����d�Sz���R	�B�9L�袚��OKRO��&>uɜ�Wyga�����;�Vr��W})S�{�L���Zw�0�F��j���4X���,7���}��%��a�Ơ ���=�;O�.�{S�8.Ƀ�$�X���z���e��"�=�)}�*vZaʶ�;����_:��tq9�4쒀2��[��S8�v���ß��G���JӲD�x�a�@��I�Q&�2�э���j�]Z|�G�{�������>��R��\"��~�����~2!X#A��L� ���K���I"L�����d��� T�c����)�H�u�����́��Q݂=�g�M˦�'�ud��kE�� '�x��W�Y��8��^�+S~,�]�X������SХql"��-Ꮳ0��m����0��-�el)s���6\u�r�i:���ZҙU�mוE�1�b*E�}��r��h��Dk��B}�O��QK"�S�����2]���Vr�cL�*�]X��b��+��<��_���R�Ԧ��n�9j�� �I��/Gn�)s[�;|�v
��$�����u����)M�N��G|�t�#�)|xk��D��[+��5
�Z�H�[�`^x%� ~RR�wXV�ƲH��v@e�-\�ƽ�"=��A�ZV�㡚�:�d����]?ڡ�6)���P��2��\���%�UZ�w|�k�Х��m��;��LI^׮�<u&k̅�߀)���96�ж���,�E��L����O�[��C�������;,Q��Z�}�7�
��L��ٹ�������&�/�7)�en7=��xuǈq�8�o��jg��{�=F~-|xx�8��-Mۻ%$O���BͩG(1�ݟ4
u��]��4,�k����O�y[�E{�R�+��m�l��*t�T^Q��'�x � 2C��W~��:�:�Z�5���L�*��������&c���5��߷M*Bv�O��xxg�~-T=g0�8�jrtk5.���r<�4,yb��x�r�L�m���X}��-#ިa�]%0�6�p�����c��6n~��L���[�$��7f���ܠ7�U�\����)S(��]����	Ǡz1��	��z��e{(bԋ)ӦK�aL5/,a��E��~���'��FU���M�æ%f�?q��d�e�g�e���T�W�c������K�nCxr4�-�u�D�� MO��vP�k[�b��P���}^�L�B��k�[(��Ov*	\Dr�ë���f��J������L��t]���#�()ܶ:��N���i?֗�F�-SSd��7�/�5��xo]��g:nlXO?�[oP��r<����yC�z����`7�Mc���Q- ���4߬��Fөځ�.Uf��e9��Ţ%�5�����ZP���ô�M�$�<fL#�ũE4�Ȟ�ں^j!O��8��pCZ�0�dB�'R��J_�]�)�ov�w�y���nBO�N߄*��ᚥ*�����3�|���=���gr��x��X�x�F�D����� S�j!������)M@�eX�-R-Kvb&�$ԣ�e��t����"���?j��9D�BN>+��q؞"���ae�1âO�x}L�,�ĸ ��N�^AHV�ԸV s�e\H���gS��D�n�޿PCƎd���?�qGu,7��P.Ozٱt�i9�C�_b�#�]k �SG��7#>����hF�����S�gz�$�*��&$�{ua�/�*�u��0�#\���ͽE��)�-��|�Bͩ9J���$�tG,�9�~���%�ɖ�~�����ʯ�n�$�N{��1�"�����S.N�9�@��J.�:�������Dt��ض�����U�w���	I��l�3�cI캳�!0a�9��_�O]�"e\��H���� u�@�
endstreamendobj700 0 obj<< /ProcSet [ /PDF ] /ExtGState << /GS2 701 0 R >> >> endobj701 0 obj<< /Type /ExtGState /SA true /OP false /HT 702 0 R >> endobj702 0 obj<< /Type /Halftone /HalftoneType 1 /HalftoneName (Default)/Frequency 60 /Angle 45 /SpotFunction /Round >> endobj703 0 obj<< /ProcSet [ /PDF /Text ] /Font << /F1 704 0 R /F2 711 0 R /F3 712 0 R /F4 714 0 R /F5 718 0 R /F6 728 0 R /F7 726 0 R /F9 707 0 R >> /ExtGState << /GS1 745 0 R >> >> endobj704 0 obj<< /Type /Font /Subtype /Type1 /FirstChar 32 /LastChar 240 /Widths [ 278 259 426 556 556 1000 630 278 259 259 352 600 278 389 278 333 556 556 556 556 556 556 556 556 556 556 278 278 600 600 600 556 800 648 685 722 704 611 574 759 722 259 519 667 556 871 722 760 648 760 685 648 574 722 611 926 611 648 611 259 333 259 600 500 222 537 593 537 593 537 296 574 556 222 222 519 222 853 556 574 593 593 333 500 315 556 500 758 518 500 480 333 222 333 600 278 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 556 0 0 0 0 0 800 0 0 0 278 0 0 278 600 278 278 0 556 278 278 278 278 278 0 0 278 0 0 0 0 0 278 0 278 278 0 0 0 278 0 0 0 0 0 0 0 426 426 0 278 0 278 0 0 167 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 278 ] /Encoding /MacRomanEncoding /BaseFont /HelveticaNeue-Roman /FontDescriptor 705 0 R >> endobj705 0 obj<< /Type /FontDescriptor /Ascent 714 /CapHeight 714 /Descent -198 /Flags 32 /FontBBox [ -166 -214 1076 952 ] /FontName /HelveticaNeue-Roman /ItalicAngle 0 /StemV 85 /XHeight 517 >> endobj706 0 obj<< /Type /FontDescriptor /Ascent 686 /CapHeight 686 /Descent -174 /Flags 32 /FontBBox [ -199 -250 1014 934 ] /FontName /FranklinGothic-Demi /ItalicAngle 0 /StemV 147 /XHeight 508 >> endobj707 0 obj<< /Type /Font /Subtype /Type1 /FirstChar 1 /LastChar 1 /Widths [ 1000 ] /Encoding 713 0 R /BaseFont /EJEJOG+Universal-NewswithCommPi /FontDescriptor 708 0 R >> endobj708 0 obj<< /Type /FontDescriptor /Ascent 0 /CapHeight 0 /Descent 0 /Flags 4 /FontBBox [ -7 -227 989 764 ] /FontName /EJEJOG+Universal-NewswithCommPi /ItalicAngle 0 /StemV 0 /CharSet (/H17075)/FontFile3 709 0 R >> endobj709 0 obj<< /Filter /FlateDecode /Length 266 /Subtype /Type1C >> stream
H�bd`ab`ddTp�r��w���,K-*N���K-/.�,�p�����1����C��,�9��,?�y�Z~��*�9�Un���n����_��$��S�~�.������[��ahn`n�_PY���Q�����`hia�������\Y\��[�����_T�_�X���������R_��Z�ZT��R�J�r=�+S��3�B�
��p8=������������E���_5��~�0N�������<�)?jX����uw���f�]��` �1m\
endstreamendobj710 0 obj<< /Type /FontDescriptor /Ascent 750 /CapHeight 750 /Descent -189 /Flags 262176 /FontBBox [ -168 -250 1113 1000 ] /FontName /Helvetica-Condensed-Black /ItalicAngle 0 /StemV 159 /XHeight 560 >> endobj711 0 obj<< /Type /Font /Subtype /Type1 /FirstChar 32 /LastChar 181 /Widths [ 300 320 460 600 600 700 720 300 380 380 600 600 300 240 300 600 600 600 600 600 600 600 600 600 600 600 300 300 600 600 600 540 800 640 660 660 660 580 540 660 660 300 400 640 500 880 660 660 620 660 660 600 540 660 600 900 640 600 660 380 600 380 600 500 380 540 540 540 540 540 300 560 540 260 260 560 260 820 540 540 540 540 340 500 380 540 480 740 540 480 420 380 300 380 600 300 300 300 300 300 300 300 300 300 300 300 300 300 300 300 300 300 300 300 300 300 300 300 300 300 300 300 300 300 300 300 300 300 300 300 600 600 300 300 300 300 300 740 300 300 300 300 300 300 300 600 300 300 300 540 ] /Encoding /WinAnsiEncoding /BaseFont /FranklinGothic-Demi /FontDescriptor 706 0 R >> endobj712 0 obj<< /Type /Font /Subtype /Type1 /FirstChar 32 /LastChar 181 /Widths [ 250 333 333 500 500 833 667 250 278 278 500 500 333 333 333 278 500 500 500 500 500 500 500 500 500 500 278 278 500 500 500 500 830 556 556 556 556 500 500 556 556 278 444 556 444 778 556 556 556 556 556 500 500 556 556 778 556 556 444 278 250 278 500 500 333 500 500 500 500 500 333 500 500 278 278 500 278 722 500 500 500 500 333 444 333 500 444 667 444 444 389 274 250 274 500 250 250 250 250 250 250 250 250 250 250 250 250 250 250 250 250 250 250 250 250 250 250 250 250 250 250 250 250 250 250 250 250 250 250 250 500 500 250 250 250 250 250 830 250 250 250 250 250 250 250 500 250 250 250 500 ] /Encoding /WinAnsiEncoding /BaseFont /Helvetica-Condensed-Black /FontDescriptor 710 0 R >> endobj713 0 obj<< /Type /Encoding /Differences [ 1 /H17075 ] >> endobj714 0 obj<< /Type /Font /Subtype /Type1 /FirstChar 32 /LastChar 181 /Widths [ 278 278 463 556 556 1000 685 278 296 296 407 600 278 407 278 371 556 556 556 556 556 556 556 556 556 556 278 278 600 600 600 556 800 685 704 741 741 648 593 759 741 295 556 722 593 907 741 778 667 778 722 649 611 741 630 944 667 667 648 333 371 333 600 500 259 574 611 574 611 574 333 611 593 258 278 574 258 906 593 611 611 611 389 537 352 593 520 814 537 519 519 333 223 333 600 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 278 0 0 0 0 1000 0 0 0 0 0 0 0 0 278 0 556 556 0 0 0 0 0 800 0 0 0 407 0 0 0 600 0 0 0 593 ] /Encoding /WinAnsiEncoding /BaseFont /HelveticaNeue-Bold /FontDescriptor 715 0 R >> endobj715 0 obj<< /Type /FontDescriptor /Ascent 714 /CapHeight 714 /Descent -182 /Flags 262176 /FontBBox [ -166 -218 1078 975 ] /FontName /HelveticaNeue-Bold /ItalicAngle 0 /StemV 142 /XHeight 517 >> endobj716 0 obj982 endobj717 0 obj<< /Filter /FlateDecode /Length 716 0 R >> stream
H��UMo�FE��s�k�C�籮��bsi�-�)��]������me&��3o�{3�LKxJ�\!<�	B	���I+A*�R� E�`�
h\�}7��PN^#2k���<y�!�&�Y���/>	C�2mAKdij����:�k� I����f�R�%��^�?)m�bƬ@�hSf����eh��O͸��3~[|e+Es�T|�U�i���#!_TPo�Z�{w�=�����#}?Q�����^ 9|�o�9l���W$���}�I���]��|dxJ`9��$Ci�IO���x�ډ}�E'2m��]]R�\h���C��}�
	�>q'����G��	IA���1���CFD��)��\Ⱦ� ��Q�kw(�n��S��p�7�h�ͫ��N����-��p��\S;���UG+�<�k��!j�4�������b��Q�Y�L��?��̍oY1�	1�����W�A�a���j���ʺjY�o�[�����g���vcV��5�J(&Ӑ�?���۴�6̠0@U��~hJ�0��b�^�~f4-�2�"�T�Q���}fK��G�^0�1�CSV��@�=۲rm��\v��2��"��YjN%�c�J��q,a�X�f�կ��rCn*���@u�?��?4��0�VsK��@��6$��:o���}i�7GK~Y����8u\����n���{J�,gaY{)[w9=�x���Yp�&� >��|)�#ֺ�����ܨ�=s�p�;�k��x����R��J���{D��K(�4u��K��6��
x`��(��P<9�tX�7ńΦk�2#�4��������3�zC����o�WڪF�yސ�*�@��ɷ�~ʼ=7����+'��Y���G��h���L8-υ�O&1�pcL�m���y�#O*�?h0=5]�Ry�f���Xכ@����p��WCO>�W3��m�X�gR��$F&a�1��[� A;endstreamendobj718 0 obj<< /Type /Font /Subtype /Type1 /FirstChar 32 /LastChar 181 /Widths [ 250 333 333 500 500 833 667 250 333 333 500 500 333 333 333 278 500 500 500 500 500 500 500 500 500 500 278 278 500 500 500 500 833 556 556 556 611 500 500 611 611 278 444 556 500 778 611 611 556 611 611 556 500 611 556 833 556 556 500 333 250 333 500 500 333 500 500 444 500 500 278 500 500 278 278 444 278 778 500 500 500 500 333 444 278 500 444 667 444 444 389 274 250 274 500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 278 0 0 0 0 0 0 0 0 0 0 0 0 0 250 0 500 500 0 0 0 0 0 830 0 0 0 333 0 0 0 500 0 0 0 500 ] /Encoding /WinAnsiEncoding /BaseFont /Helvetica-Condensed-Bold /FontDescriptor 719 0 R >> endobj719 0 obj<< /Type /FontDescriptor /Ascent 750 /CapHeight 750 /Descent -189 /Flags 262176 /FontBBox [ -169 -250 1091 991 ] /FontName /Helvetica-Condensed-Bold /ItalicAngle 0 /StemV 130 /XHeight 564 >> endobj720 0 obj930 endobj721 0 obj<< /Filter /FlateDecode /Length 720 0 R >> stream
H��VKs�8���W�Ѓs0�7�޲�M;��[�-ѱveɣ�8��)Y�������@ >��� ����g�`�I(��a@a����V�d��;W�k[ߵ�h���{��8ԛ�տ	�%#�09ڔ��n롨ڮ鳮����&x[�j���x�:%�		ZZb��<;LR�	�Ɉ�1&�]"���R&Rkb�:�Q����<$������GnR"���!�j/�%�4�⾨���w}S����cKA��E���ޏ>T;����I5:GG�o����+�#0����KƉ�L�a�`�>��~_�[����o����S4Ƽ_�tyD賫���]���<o|��P�+��R�|��0K�p�|����|�����%
�x�b���GfN@�Y��������vʺ�s��7ļ����hy�c��}���|�����
(���]݄1��Y�y9F�C�"�Q,��"�RP"�7A3�O�����c��-�&�K�
¥f!2�NS�?��5ޥ��C��y_������\�����៽oں�ö��k��k�
�]�z���y��&�W��Ż�7�36^R��<y�<)��bV���0"��f���/�
��8����w�c�8z��D�T��`��>���9�K�W����e��c��P�(o�A.�}[Tؾ��Y���*���U��#�e�
�!�M�?m�sX��>x��q��>��	V<�\����c�+}6Џ���{@�`�C��,��0���g��|�����h9a�4�3�>:b�����U��|���O\Bӻx��2�1�?�ri��I1��਌a�2Q��=���5���V;����.�77�.j�3|�=ny�u�N7�V��>�24�k���_�7
y�,�|��D��:�b'-�d3H�\��&��(ǟ"��p>��� a�=endstreamendobj722 0 obj776 endobj723 0 obj<< /Filter /FlateDecode /Length 722 0 R >> stream
H���Ko�@��|�9�d6�f��6u��j+�[��#veCDQ�}g�c7��>�0����� �Hi"�N3µ�]PJ�6��>���T�|b5�@��VDj@	A��仈B��l����qB��X��F�P* �c��gf���R¹����)�6��r·52|�-��$e4n�N�e�Z'��q�@Q.��n���������{�5�8|\�jx�\7a�Jx�����D[���8&B2B�>�P���ƭ�˄bD;tC�����I���X��G��c(E�p�J�n���v�&#�16����KմP�๪4�v��~�^.^�K�4��\��%n�s9CZ���)�r�OQ*�1����	I�%"�{B�CB�$!i�q�槬�q{�V�����S[��a��v���%c��V�G���i`��`}�`F�XR)�08��E��
x~��/6eQ��M9�vK�-�%{*U���X�KQ�e�Ӭ7/��TۢO��~m�<ʛ���#�E6tɊ̟ym[��Єٽlb%$C'��]�k ��E��y�Z"z4CW���#��D]�aC$lK����4�R��@���Lz+H��R�=�η�m}��7��*a�"nCf���)kf�].[X�5������8����sj;7�����Ũ���N
*�X� �L�3Rʎ��\#%͎������3�ې��{T'.���ؔ�(
	%���Oj�	�FY��]plf.3 m��xr��͘Z����:�"�P�c�` ����endstreamendobj724 0 obj703 endobj725 0 obj<< /Filter /FlateDecode /Length 724 0 R >> stream
H���Ms�0����=���Vߺ�s�KgnuԦ�;g�L��c�xp|��+��ճ�$��'ᐿ$�����J)潱��L���#�># �dZ� C�q#}��H�u�2[!O�כ㡄uZ�v�A���Q3$��I��W_�E����]�}��uV��'��~���@�<p�&B
����Ii��(�U�@����B�m��˔�L{��*ȴ���{�S�j(�1o���9ğF��;P(��ZB~x聇�V^k�i�!Q9vE5�F2#Zdh'�J�>?�u	}� ��5���Ϗ;�}�EP�3��Xme�)��aE���C!��w�w��^��wid֑�J������u��Y&�a��ϭ8��b`u_TE���BQo�x���'�v����OE��1�J��[(O��;�����I7A�FҐ�����ɞТ='�H�\��-: ��6Hb�'��&��Ε��
���/����ٌ[�zɗ�)�,�����N���3+8�X:jf���Y�(ŨW7��)G�A}�7F��r�j�	k�x�`>��kjK��[(!GƝ)��R���Ҡ����\D��� iyH\��&q'F��}%�5e{'��8�A�s��M���R�˜4�9����q�W8�U^��)�p��K���ʫ���nc䦻
gN�v�1FހqP�z(�2�`���  ,��endstreamendobj726 0 obj<< /Type /Font /Subtype /Type1 /FirstChar 32 /LastChar 181 /Widths [ 278 296 481 556 556 963 685 278 296 296 407 600 278 407 278 389 556 556 556 556 556 556 556 556 556 556 278 278 600 600 600 574 800 685 722 741 741 667 593 759 741 296 556 722 574 907 741 778 667 778 722 648 611 741 630 944 667 648 648 333 389 333 600 500 259 574 611 556 611 574 352 611 611 259 259 556 259 907 611 593 611 611 389 519 370 611 519 815 519 519 500 333 222 333 600 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 556 556 278 278 278 278 278 800 278 278 278 278 278 278 278 600 278 278 278 611 ] /Encoding /WinAnsiEncoding /BaseFont /HelveticaNeue-BoldItalic /FontDescriptor 729 0 R >> endobj727 0 obj<< /Type /FontDescriptor /Ascent 714 /CapHeight 714 /Descent -198 /Flags 96 /FontBBox [ -166 -214 1106 957 ] /FontName /HelveticaNeue-Italic /ItalicAngle -12 /StemV 85 /XHeight 517 >> endobj728 0 obj<< /Type /Font /Subtype /Type1 /FirstChar 32 /LastChar 181 /Widths [ 278 259 426 556 556 926 630 278 259 259 352 600 278 389 278 333 556 556 556 556 556 556 556 556 556 556 278 278 600 600 600 556 800 667 685 722 704 611 574 759 722 259 519 667 556 870 722 759 648 759 685 648 574 722 611 926 611 611 611 259 333 259 600 500 222 519 593 537 593 537 296 574 556 222 222 481 222 852 556 574 593 593 333 481 315 556 481 759 481 481 444 333 222 333 600 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 556 556 278 278 278 278 278 800 278 278 278 278 278 278 278 600 278 278 278 556 ] /Encoding /WinAnsiEncoding /BaseFont /HelveticaNeue-Italic /FontDescriptor 727 0 R >> endobj729 0 obj<< /Type /FontDescriptor /Ascent 714 /CapHeight 714 /Descent -182 /Flags 262240 /FontBBox [ -166 -218 1129 975 ] /FontName /HelveticaNeue-BoldItalic /ItalicAngle -12 /StemV 142 /XHeight 517 >> endobj730 0 obj785 endobj731 0 obj<< /Filter /FlateDecode /Length 730 0 R >> stream
H���Mo�@���>�L���U�C��mn�B��Y��A����$�(
B
��c?��p�I�6D9B8�U��d�%Ns��QjE����AV%)���Or}πA��̥ ��H�ѲۄBV$�Pm-d�Iz�/a��&,��@�s��	�0#N�o
˄qI�u #\k�)-��M�����2����t���
��}���sb<&C�d��!�>��{>��|�b�r1fv����aB�]b&���y�n ��P�e��:�?+�� �8�-��7�8������!�hY%RX���;}F�`��Q�#>����l�������J�^ ��Z��ʔ�|�i�k8�9%�1�?�:@yJo���q���̻���9-_`0�挦���oyy����7�l.iZ�T�?�f����M���CT%U�[2B��,��r\�[~l���h�'θ:v0�z�|qH8��5v=�Έ.�^s�O!�H���MY�5����Nlc�LI��rC�M�����~�A=Z�S�Z�n��/��7�ܮ<��O�_m���o=�~ݶ��NrՎؠ|)�ƋH��Ԏ'd��n��n:�)3���b�~f��c��}�{�H��+ݏt���6P7�Zn��r�cy�{�C�S{�2q�	���6H����d�㨎�G�Ȝգ������D}��T���WL`�1�rĖ2����a�+��(�]�����Wy����"}7��Xq��C��h�|A�i��$��H)6���W�]�^5������K����k�W�]�N���P�` ��endstreamendobj732 0 obj1000 endobj733 0 obj<< /Filter /FlateDecode /Length 732 0 R >> stream
H��UMs�6��W�Q�X�A�q3m.錕��%AS~xH*��}@P���i���v���%�͓i�3�Iä�Tg�ę.rz��Ϝv�63��NKMf����_�ٻ����Y�
+-q�ҫ��)�-I^�%�u�q�9^��r��-�X��d+���:2L(�h}�-Dv޽St�ZIf���	�0n�u�q<��v~wڎU�4��9;�#���x�\tyZ��Xn�4l����28���d$�(l �B�BS�F*Ɍ$��6gJ��RW�o)=��)�𻤔S�
�Z�NDp+���0N#��[�bb�v�V��<�p!��PE�d����{z.���nO���v�9��멮�j,�z"�_���|�A��5F�t!�>.�K!����B>F���o0rf�Y@���ϻ]̯l�S;4���F�쩯Ǒ�]}jڔx�+�7P�S�R����"��H|��6	��?~��)��eW��8�ۂ3�'�Ŵ�$�Ӳ��<4��-�dI���@�i�������H��Hծj��o���Ӣ���V�K��� ���ƾ�y��� 5��Jh��+�N؎Q)�Jg�h���J�0[̈ԛJ���t]��N�Y��
�I&y%���d�v
̖8=��Y�a�Y�����#1oY�DD1��9��@#�Y��(!#�O���ٷe$=���/����~GKn���r��X~���*�z����o�BQ�'�z�<���5,��
�����hֻ������r.��y\����a�4��g۽�~w�Q��|z%�Z��$����{d3r���w�����q�1�V��3������{��=ʺ�@n��[�c4ak������Tu5�R�;C	��J㛍��#�fSp�me]�A	�g(ܚ"B�ZL���˱�w��l^îfp���4�k�x�2Z��!��UpU��)�X�Ү
�����^�����|�S��B�����g6������T�G���[� mI&�endstreamendobj734 0 obj853 endobj735 0 obj<< /Filter /FlateDecode /Length 734 0 R >> stream
H�|UK��FE�<E-� j���Ll�,&��-�8�Iq@r0�5r��'��&�"�HD�~�{U��|
IaJ�p��-�6D�i��ⷲxǀA�\h����=H�)b�1P�%�r�8|�F���^�$�q���ǂ�3di�Nߊ�c��R���������^�~�'�zh�����uS�W8u�Ku�B�ۯ�>��Q;oX#�j̉m�JH(����6�8<�&�g`eΉ�eE�E��<Fe�CQ֊$��<C���2}�� ����ԇ���$gD'�9�d�h*1A�#%�*3s)��_}2�#�	,�f�U���Q3JT�!#b�>��O?�~�q5��y>����ءp����aQ���r("�� �#B�&tP��S�Q�����lq�*��P+58I�l�XdU��}�sq�j�7��=�ù������?.�5M�U����%N�&�(�������=q8m�4�f�2S2wu��\�����`N7��k���?����.c�NU�3T�s�!ǌ"7�n�K@\�t�:z{!��`[���8�(�Z˛�!�:�w]��V˹�S�V+�*�e�&xQq^�*:�������n�Ü��Ӂ9�dK�8���#=� .���H����u�C������_���4��~=�pߍ����]����U��2�}$$����\@\����I�9�@�eF��qZ����v��r6H��������X�V��E2�k����s�����1�X	ivH���擐<����,�ŖX��+g��=�~-��^�m���%��l� �&�N_˸3�쐌���=�sҮ�3�-����R����Z��%q6Hƙc�+� ���Dendstreamendobj736 0 obj815 endobj737 0 obj<< /Filter /FlateDecode /Length 736 0 R >> stream
H��UM�9%��:N VT�*�t�&�6,ħ	{pf&!��!0��>O�n���bx����^}����5Ĕ�����0D�>=!���y
�sH=k��9��/����3Ǟ3!�։�B��A�x-�r�A�d^��~,�b��c���8�e�����vx����!�b���S��3��<�$n{B�qr�����O�>=zGK�}�����|I)�X�3kt9{�l�i���������G7y��i��Z��9��Q*C�S�����G�qB��'����r��8��6PF�o��kYĒ�I��4�461���7�#[na�7�1�#N�܋Q��/<F��A[��Ҧ�AM�݇Ogf���z�S*��*Ί'��z]u����"�v�~���=�?\SWF��pܙ��.��h7�R�=���5�;"�+�6�	[���p��5�93r8E^8k�p�^g,x)־x�,��;������3I�,�&���Ϝ0˜8a��y@xC!2&�#��"T��~���u���`�B��1�ΐXU;�Y[�?>�����x�{r�=��J)����G���������[�e�E.�\i���#�3~B�	��J/�>H�8-���1�m�@�0�^M�w�{�,�PA�NP`ʴ��Yz
׫��y�ȰNr�i�3�ץ��V�Ft566s���7�+}4�>�p�:!E�Z�Pg��Ԍ`��,��툭��b�+M�t;�K�bC։K�o`D�!�a�X��0�8)^�f�s(mKbP��Bv�.�?]�fVl\˳�6�qkƲQ�B+fʸ�Y�0��5X���` ]��endstreamendobj738 0 obj<< /Type /Font /Name /HeBo /BaseFont /Helvetica-Bold /Subtype /Type1 /Encoding 741 0 R >> endobj739 0 obj<< /Helv 740 0 R /HeBo 738 0 R /ZaDb 742 0 R >> endobj740 0 obj<< /Type /Font /Name /Helv /BaseFont /Helvetica /Subtype /Type1 /Encoding 741 0 R >> endobj741 0 obj<< /Type /Encoding /Differences [ 24 /breve /caron /circumflex /dotaccent /hungarumlaut /ogonek /ring /tilde 39 /quotesingle 96 /grave 128 /bullet /dagger /daggerdbl /ellipsis /emdash /endash /florin /fraction /guilsinglleft /guilsinglright /minus /perthousand /quotedblbase /quotedblleft /quotedblright /quoteleft /quoteright /quotesinglbase /trademark /fi /fl /Lslash /OE /Scaron /Ydieresis /Zcaron /dotlessi /lslash /oe /scaron /zcaron 160 /Euro 164 /currency 166 /brokenbar 168 /dieresis /copyright /ordfeminine 172 /logicalnot /.notdef /registered /macron /degree /plusminus /twosuperior /threesuperior /acute /mu 183 /periodcentered /cedilla /onesuperior /ordmasculine 188 /onequarter /onehalf /threequarters 192 /Agrave /Aacute /Acircumflex /Atilde /Adieresis /Aring /AE /Ccedilla /Egrave /Eacute /Ecircumflex /Edieresis /Igrave /Iacute /Icircumflex /Idieresis /Eth /Ntilde /Ograve /Oacute /Ocircumflex /Otilde /Odieresis /multiply /Oslash /Ugrave /Uacute /Ucircumflex /Udieresis /Yacute /Thorn /germandbls /agrave /aacute /acircumflex /atilde /adieresis /aring /ae /ccedilla /egrave /eacute /ecircumflex /edieresis /igrave /iacute /icircumflex /idieresis /eth /ntilde /ograve /oacute /ocircumflex /otilde /odieresis /divide /oslash /ugrave /uacute /ucircumflex /udieresis /yacute /thorn /ydieresis ] >> endobj742 0 obj<< /Type /Font /Name /ZaDb /BaseFont /ZapfDingbats /Subtype /Type1 >> endobj743 0 obj<< /PDFDocEncoding 741 0 R >> endobj744 0 obj<< /Encoding 743 0 R /Font 739 0 R >> endobj745 0 obj<< /Type /ExtGState /SA false /SM 0.02 /TR /Identity >> endobj746 0 obj<< /Encoding 750 0 R /Font 751 0 R >> endobj747 0 obj<< /Type /Font /Name /HeBo /BaseFont /Helvetica-Bold /Subtype /Type1 /Encoding 748 0 R >> endobj748 0 obj<< /Type /Encoding /Differences [ 24 /breve /caron /circumflex /dotaccent /hungarumlaut /ogonek /ring /tilde 39 /quotesingle 96 /grave 128 /bullet /dagger /daggerdbl /ellipsis /emdash /endash /florin /fraction /guilsinglleft /guilsinglright /minus /perthousand /quotedblbase /quotedblleft /quotedblright /quoteleft /quoteright /quotesinglbase /trademark /fi /fl /Lslash /OE /Scaron /Ydieresis /Zcaron /dotlessi /lslash /oe /scaron /zcaron 160 /Euro 164 /currency 166 /brokenbar 168 /dieresis /copyright /ordfeminine 172 /logicalnot /.notdef /registered /macron /degree /plusminus /twosuperior /threesuperior /acute /mu 183 /periodcentered /cedilla /onesuperior /ordmasculine 188 /onequarter /onehalf /threequarters 192 /Agrave /Aacute /Acircumflex /Atilde /Adieresis /Aring /AE /Ccedilla /Egrave /Eacute /Ecircumflex /Edieresis /Igrave /Iacute /Icircumflex /Idieresis /Eth /Ntilde /Ograve /Oacute /Ocircumflex /Otilde /Odieresis /multiply /Oslash /Ugrave /Uacute /Ucircumflex /Udieresis /Yacute /Thorn /germandbls /agrave /aacute /acircumflex /atilde /adieresis /aring /ae /ccedilla /egrave /eacute /ecircumflex /edieresis /igrave /iacute /icircumflex /idieresis /eth /ntilde /ograve /oacute /ocircumflex /otilde /odieresis /divide /oslash /ugrave /uacute /ucircumflex /udieresis /yacute /thorn /ydieresis ] >> endobj749 0 obj<< /Type /Font /Name /Helv /BaseFont /Helvetica /Subtype /Type1 /Encoding 748 0 R >> endobj750 0 obj<< /PDFDocEncoding 748 0 R >> endobj751 0 obj<< /Helv 749 0 R /HeBo 747 0 R /ZaDb 604 0 R >> endobj1 0 obj<< /Type /Page /Parent 568 0 R /Resources 5 0 R /Contents 6 0 R /MediaBox [ 0 0 612 792 ] /CropBox [ 0 0 612 792 ] /Rotate 0 /Annots 2 0 R >> endobj2 0 obj[ 24 0 R 25 0 R 26 0 R 27 0 R 28 0 R 29 0 R 30 0 R 31 0 R 32 0 R 33 0 R 34 0 R 35 0 R 36 0 R 37 0 R 38 0 R 39 0 R 40 0 R 41 0 R 42 0 R 43 0 R 44 0 R 45 0 R 46 0 R 47 0 R 48 0 R 49 0 R 59 0 R 60 0 R 61 0 R 62 0 R 63 0 R 67 0 R 68 0 R 69 0 R 77 0 R 78 0 R 82 0 R 83 0 R 84 0 R 85 0 R 86 0 R 87 0 R 88 0 R 89 0 R 90 0 R 91 0 R 101 0 R 102 0 R 103 0 R 104 0 R 105 0 R 106 0 R 107 0 R 108 0 R 109 0 R 110 0 R 111 0 R 3 0 R 4 0 R ]endobj3 0 obj<< /Type /Annot /Subtype /Popup /Rect [ 233.93141 -155.33214 433.93298 44.66943 ] /Open false /F 27 /Parent 4 0 R >> endobj4 0 obj<< /Type /Annot /Subtype /Stamp /Rect [ 234 7 378 45 ] /Popup 3 0 R /C [ 0.75294 0.75294 0.75294 ] /T (John H Yates)/Contents ()/M (D:20000322204806-07'00')/AP 420 0 R /F 4 /Name /Draft >> endobj5 0 obj<< /ProcSet [ /PDF /Text ] /Font << /F1 704 0 R /F6 728 0 R /F9 707 0 R /F10 19 0 R /F11 20 0 R >> /ExtGState << /GS1 745 0 R >> >> endobj6 0 obj<< /Length 5147 /Filter /FlateDecode >> stream
H��W�n�Fž�W��(�:�;{_�u�u�B$`���@�P�������ڪ��Cj�I�6��TwW���ʨQ�~��+F��#Y).��He��5��rrB�-����7IE�rU?��z��[�F��V�Z�H�7�)cR���
rݬ2�!#כUF3����j�v�5�eZ��5��ޜ�]��2���v��3&�9w䲸/Q	g�qK�ʕ{=|U��L3{�Xs<��5������J2j�&O`�@>����
��/�w�I�R�P-FI��B�o3�hn�i���Y�f�������Ȼ�nۓ�]�%��,z�'Ǎ;r��˒<�߄<;<��j���o�j��5t�J��#�|.\�&�I�RR�LH����b��:�xjԉ��N�ɨs�%,�Vs�@_%�����a� r>`�=C�.��<�-��(�Λ a������c,্���}��l�]�L��ܖ�U�V�=b�\�]�l]tg�\��rL����6�(����`9�*D[� ԈQ�κ�
���D���D�I�xf
_�L�E�b�i��t���x��<��'u�ғM��j(��<U�ö+�Zr��ȣ���][�d�O��[m��'f�cnN�1������83�Q�Q���������vׅ�|=�X-7S�� �
�\br�d ��!�!_O�ܷ���
{�D_�.E�߹T�C���A]�X�^1�����r�����^O,ͨ����$_�3�KpNΝ�38�Q8�W���>?B���!�2K*���a�q8;1�C�n�a:�0��;C�f�cb��p�n ((q8���g��EMXdI�N F�D�&�������[�w����ؘ�1!N�\�pr�d�|L��ih^OC��-�ퟘ��j,B����;�����������??��nƻ����R��w4�G�,��i�f��\�o���.ˈ!w>��M����=V=j�gٚz��?�OB^f�Z!�\@�}m��rB#���Q'8�K2Ae���-^O=)�d}(7����IS:p��� ��z�lnS�z��b��o�|��"�j}����0���t�)��ʁ=ٖ���nᅪ%?����pT;M3F�a�p� �<�	8]�^丼ܬ��w���p�Q!�ױ%yN��皳ɷ�S1G�`��[�,�A�+��2� 2�4���s*�4�`�Ȅ��D���r=n_.��$��CՓ��R�����o?���&O�|��=�;1_����>�2<��0%�~ڥ�<:
����9	���d�MH�8$���aE@�5�H�T����U!��s� ����:R����Բ�����QNmn���O)��r8x��X���利/*I,�ENn���!�j=֡���T����ǻY���w���Q��o ������w6_ȡ˹[�+�x|�����|,�����C�������Џ ��k��Y��h��С�R��%��Q�Z��N�PRe2�߿����*mD�<��{@���3	s�'�]�r�h��C�o�8�.�DS�e��}�@��箫��� C��-���l	���q����H�G���w����b��Ca��t4�"t~p
jJ����_b�1�e��;_�gB�u��.Z����s`��`�����ErXj�[I2�2�t9�)�˦Mal��w�}��8�B'	�3���N������QwR�dd���X�e_�{��=߅��0*��\�z����(�bh�}YR��eXoU���v��s=�(4Y4Q��]�D����wO���쁕�1X�@���w��	�G�����Kh�"�����N]9��O{Y�旲�cc	��B�Wwϐ�x�e��t2yYX��}s�B��ҁy���S�S����D���8����<����+����M3'B�N����$R��,8�N��{���SMd����Inf��c�a|F7����Q7���@F��!c9��}L}R�,7�H9����U@*��82�Lw�Y�1��fsb�${?�X�甛dvt��$A�}oB����sJx&�C��z!��@"�g��4����L�,^�谴�ƛY\@璉nb0��d�֨3�4��A'\���� x&�6�$S���L�LnN:3I�x}�3�om�I&:��3��Qg&i���j����s#)�EtHZ �sI�*��b�Z|K%A=L4"�3A3^5f�f���V=y%�`���#�v��JҘ	����F*�xi��`b�8�#&�D����?;�#DU�.�0�-W��ݞ��M�$5�TU�9�AR/$���� ���3�4���d��	?�"��� �d����rzO�_���PjXX�����ac2�aG���� L	�G�$�G���3��A/Ff������N�)?���xO�/�rWո��_�a�M�&X�P�<�� Π|$y�����nh [�<�SCE�$&j�,a���L�`?��0�D<��z^��\�%�h~dzF #b���K?2U���Qt-S@$A̚4t���I
�HK���Ps�"Ӟ�ӃԘ�G���dǞтj�)`�F�l$ n�*���}��ئ��v<�ك	ߘ���l��#�y(>�p0��`�t4n���W����G���{����\a�5�b�@��ᐜ6I�6i�M�E�Pmk��aIu�7�����̍á���!}4�3�|�^I�觇���{@!HqQMpR1���	(�M��/����|{ؘ�Z*�6c&�p$�v�Cѷl�n��l��q��^���{E��(� ts�'����v��q�}���?I)��(��l�`�*����c�.��4����J� PUe�-��ߩ�-��h��E�n�Ic���.��BG�aM@�/�5����]�+�BzS�8��lu��ά��8�B���r9x�IM��i�,0��)�_�D4��#�,�BS0�u��.��6��+�'1�+y�����ᠳ��Oct��mG��eo����h���ǈb/<��q�N=n���FYHIf�ݠ���O;���D���������^s7;%��<w��t��s7�f?w�=q'U� �]-�㶇��ޔ�v�-1�N���PeQ�B�c	;�p{���������!���p ��Ѡ��	<����w�Z��0C�ءTm���,e8�t����;4�?L�R9���[�fNlC� ��������^Q-R7P�Z��/ޜWQ�z:U�t.��C���0�fl��t��n�j6 2
��j���Ǐ�˟|��_WA���kG��W��tv�� ���쭌z.r*�&o��e��/�gx2���n�������q��^�(Em	�R�1���k�N�@�:[[%��L��3*� H}�Q���G�1f���ƐD��#�����<�CׂȖ3��
��{�����ҤsM���>�2�<����g�5
�����sձ�!]�}��W텋P1��<ګ��^��G�X��y	,�j�(�JIm��6�)%$�h�}���`o���a�jz�4�`4>o �A&-�<D�rv����ލ��b����n<�^g]~�_�ّ��h��Y�����z�Qk�1�lj�����<H$�%R0"�#�+��i~���݂Į@�����TJ(����8�o?pa���}X����J6E_��� "���b�����9'X�Jz=�g;�s�7�N%P�D�_�.~���)����ws��K�ɘV�ꏧ�[f�W^�|j蛣I�#rS/�Ҫ�"����l��.�>e�"��K��Z�-+�@�/jR��I�Y��/��I��ޅ������m�B�O4�m�8Y:�n�ݒhl��7�����>��o��{r�7�A���m/X۷f$��x���|����-
�-��=Z�E�B�D6�EhZ#Ю7K@�\k
�\3�/r���l���d�9mP�h%���Q� ��yiMs|�{�Q�U�Tx)^��n�QrOQ�dY�ᗹY&��Զ"�6�:\uF��0�˳^p�b +����v���=���1m
��2�ʡ�^�a���(��r����В�E���7��7r����6_K��UU�[��/��
ؠ�Eo��nxة$�c+��C@#�5����i�N9k�L�,��rgn`�{�VPI���^���r�e������x`����8��c���@�I�����͎Z:�������5C�4%�����,c�����h�ifB� 3(��vҁ�G�o����M^���4���>M��
��>0O����F���J£%/SU�2��]�/�L��(���4�\oj�d!���p�Oé5�:.�����.�0�;N��?�Q��;���J�F3X��wRd��w���)���~���3d`���{�<�0��$��W���S�������L5�N�}\��{��dڜV(d/[-�΍PE��c�pߘL�	������ �>�J������:,F$�u���l�����D]�C��~D�&	��U�!Id=�y�F�U$E C7�D�1a�4��W��$��h�Wh�E�F�D���T'�R_N�|Q��Q�lix�3�e�Ta�G�- �5N����A��a��>���`�2�E� q�avد��nd�`_�sYn؏��a�Z;�-���Sq�ͯ'�!����jJ�$B���:D�#i{�
u�M���D�£�e��O�J���Adn�Ė*��O)m�F�1xVx�x������1Id=��%5H�۸�p�jE&G��V3đ�%ʷ \G��k�w�|��<�Z�5�Ꮼ�0ܤ6d��}T��ڷM����5�#���7����c�H�2��{\�80��7��B���a�: I�8Lr�8���Dc�j�$'�3��a=$�SC�C��F&l�B&l2��L	*J��)�B�M}?v&] ��6��rѰN��:�Lu왪�����"�H����0�4X���] ��!�]7ˍE.�Ve���oד�L\O.��+�E����CA�O�h�T�<d6mAU�9G���FF���\{bpo�sM�B�ݧ������N6L�hײ��)�cde��u�����3 ���
endstreamendobj7 0 obj<< /Type /Page /Parent 568 0 R /Resources 11 0 R /Contents 12 0 R /MediaBox [ 0 0 612 792 ] /CropBox [ 0 0 612 792 ] /Rotate 0 /Annots 8 0 R >> endobj8 0 obj[ 112 0 R 113 0 R 114 0 R 115 0 R 116 0 R 117 0 R 118 0 R 119 0 R 120 0 R 121 0 R 122 0 R 123 0 R 124 0 R 125 0 R 126 0 R 127 0 R 128 0 R 129 0 R 130 0 R 131 0 R 132 0 R 133 0 R 134 0 R 135 0 R 136 0 R 137 0 R 138 0 R 139 0 R 140 0 R 141 0 R 142 0 R 143 0 R 144 0 R 145 0 R 146 0 R 147 0 R 148 0 R 149 0 R 150 0 R 151 0 R 152 0 R 153 0 R 154 0 R 155 0 R 156 0 R 157 0 R 158 0 R 159 0 R 160 0 R 161 0 R 162 0 R 163 0 R 164 0 R 165 0 R 166 0 R 174 0 R 175 0 R 176 0 R 177 0 R 178 0 R 179 0 R 180 0 R 181 0 R 182 0 R 183 0 R 184 0 R 185 0 R 186 0 R 187 0 R 188 0 R 189 0 R 190 0 R 191 0 R 192 0 R 193 0 R 194 0 R 195 0 R 196 0 R 197 0 R 198 0 R 199 0 R 200 0 R 201 0 R 202 0 R 203 0 R 204 0 R 205 0 R 206 0 R 207 0 R 208 0 R 209 0 R 210 0 R 211 0 R 212 0 R 213 0 R 214 0 R 215 0 R 216 0 R 217 0 R 218 0 R 219 0 R 220 0 R 221 0 R 222 0 R 9 0 R 10 0 R ]endobj9 0 obj<< /Type /Annot /Subtype /Popup /Rect [ 234.82428 -155.33214 434.82585 44.66943 ] /Open false /F 27 /Parent 10 0 R >> endobj10 0 obj<< /Type /Annot /Subtype /Stamp /Rect [ 235 7 379 45 ] /Popup 9 0 R /C [ 0.75294 0.75294 0.75294 ] /T (John H Yates)/Contents ()/M (D:20000322204826-07'00')/AP 421 0 R /F 4 /Name /Draft >> endobj11 0 obj<< /ProcSet [ /PDF /Text ] /Font << /F4 714 0 R /F6 728 0 R /F9 707 0 R /F10 19 0 R /F11 20 0 R /F14 21 0 R >> /ExtGState << /GS1 745 0 R >> >> endobj12 0 obj<< /Length 5510 /Filter /FlateDecode >> stream
H��Wɒ�F��+��v���ǲvx���M�$��P���������B�� pÚpȢ�d��r)��Dϋ?>R��,(*�BH���q��P�Q�Њ	T狧�gE��3e���b&/���n-�����ǿ�?~�Q�~Z(l5E��`�Z"a+�ͬ@����&�r�����_�e�����;���,������T3���3���{���in�1ьv���W�JI�YRk������~�s>#��U�+�CG�� h�`J���J{�z�a���s1(J&��\c���:H���Ƈ&������/��#F H�?ApRu�}Z�Ǘ�~`d�7�zB����5�~��}�6���|��k����y���� ��z�xt�q9�$�!i��K�l��0X(�;���9�TY��z��>��2�<��E�����-�䨁�rT��k�b���%��ºu�f��Voe� ��Ø�����$9���[ ��R�sl�"��P�G�����+�˰RN��'��B	މ���(��*:A���i ꧺzEm��sT�h��e�4(V�m�o�GH2Dߡ|C�E�3'�^ޟ�2��%P'r�]�<�A	�����Ƥ挫QL]8�y 0i@��q�;eӘ��3��>炨�;1�N���q(�=Ơ@��?��<�u^:i�9�/oڬ͇��dT�NưV15�'���6۽�����L���c���A0���0��)v�v���N� ��5(L��ѭ����;`�c=^,q��S5\-qͅ�¥Ɔ�����.��<D������
z+`$�*���'��c���TQ�/y���0�W+hB�� ����a��0��c��@�r�.DvO|��O=I�/;ܴ��/�4���8��3��C��q5��Z�|f
���:i�A��5jð1Pa�a�O[�gX�S�� �����6I���a�\�̀k=�^�.�����:ʮ��o�r��l�Ƹ��Ju�7�V2�&�A<��nI�/��(�w�kXt-ְ�n����1�Nꦸ�n��CQM��i<��`䶂�rﶊ>@p�������4�P��e'}1Xu�+ĤO {��>/��*t/��l8y�vaT��~c�B�R���0�?q9�"rl:Ɵ�v9*O�Sp����շ�І�mj
�PjéԨ��Zȟ�g�H�H *����;uI(��BVVrx��,����e�u�+�4�5/�j�6��j�W̞��L�n�\ ���F&�c�\�{�߇����F��Ox#�n��-���9!|������\��ꔪ�4|w0��Z����P�~��t.�#�`�	��6#"�,��ǐbx�!W�s	>T��|~6�^*��{R�%<M]~���OJ��Ӓ,W2 f?��#�H�O���&���]?^j5d8�8�N�3K�\�#���Ct�~�@�O7����/>�>� ��^��u�-�)�ܭ^�����oY��m���1��
�S��
~�m�����Q'夸���~� 8y89-ܓ��'dN]�R�z����T�0eV%���Io�~m_���r�.k޺�Y9{��N%�,d i-'�Kq����i�8��C� L�54��Q����,3��<1�/0�:�J�����b�R���n�3Jw�Z�kĽ���-�&��e��%a�B�[f@�h�؜��A�㪡�o@?�d5t�-t�]U�u�}s�0}����>K������2<-s���  :l���V3=i��f{P�������C�j���<�e��=���YA'�5?[<�b3���� 8�C����{ �[��ۀ���HnvD	����:��GL7�Prn �lT������>`ݠ:?d-4J�Og���_���9m�be�`|�9�r��q�0V��*��N�g�\����#�0�n�~��-���A�r7���-�vX�y8���)�AvUt���}�g��x滕?�_R�	�{�4�v�X���1t��~�	3��r%Q8�ĕ%
�>SD�n]�;��$� ���o�>�9�I�9�\h)���.x��M+����7q��vި�-w�G&M�e��Uc��%1(|L�Ufb5z��\ڨz�,��fI�����d.wi�_u��#V�B-IDu���o�H�дG<��W(�����?e� ��Cbv�PV�xBٶ���a���OЃ�r:��I2E�Rr��d���_|v�ĄG �!D�Jԋܡ�>�����A�=�3yxF^�-�|�ZHG��S���Qte�L�9��A��s@�](�v��L����tl
�{���X�������T#&����y�����O���)�g���}��4�lx�:����g���7�w�J#̅�O1��C����n_v?��+:fu[�u�R7�|})\��J�6�ϛ��R�#);��	�Ǻ:�5<V��lҁ�m��_�]��9, YK�H�]3��'�K�\/��I{�S��D{��y����x-O�9�"�/�KV�������Z�;,y����`�������r�\����ǟK���� @y� w3U������}=9G~2isy?�L��Q�ǑuS���(f	�\2�-���^5M��F���_�K�d��! �m�ٔ��-';>����83���BJ�ο�k|� ������ŀ �����&���cY�t8ԟ�1_��hW����^rL<��3�`�}�c��7;K���"�K&F�[x��ewWb�)�P�����k�"�>׻��im���a�۞j�\;��3�Ll\[�z��t��X�}{"h�,�yU��=�S����ph�R������=`��5��
��rմp�Ӭ,�E���2ș�S�����k�}Y ��b�|��e����(��4�In�t�7<a��F��d2f����2�6��h�I�옒�ήF��u9��C\�ݴ�������=H�����E޺�O��8t:���pq�&a�b	vJ�]	q�zh��d0��I8/8�B�+7���Q����ה��J��Pi�~9_^��tZ�� �B��gU_jO��0h`�F��0������Hu��ݡ�h������]�?�����b���lW��i�+3��O0�S͗�^U�n��+Bd�]��f�.M��'2i�
3�N�G��e�u�'׃��������-�/s&��;�c�ʒ���ȗ�$����fH�7�g$�ٝ�YddZ9r*���̤K�'B=���Ue��F|ew��B����}jg�*�os�Ы��u*�����ɨ|/���5c��3���~eAц��7���]�RJ�
��2O)��ݼb�6�u��.�����MSnR�V��,�7��L�W��+o��n�2�=��T����/�RyI�V��x�+��c۬�N֛_�݉PK�f�>���yŉ���Ԋ¤	_�'\Z^?\�W��L�9��=U�!ae�R�ȴ���I��'��Af"���������<lwVL>՝�ϳ�+8�e%��a�Q.���R�S)7_V,���İB�`2�P���#�rt�6���b���،�&=5)�ӇC�,ui��l��Z�=1X���+�Z���񼊧誙�^�R[X��(eu�(���z�=0\��L{4n�kBc�ջ�a]?�����:	��Z�R���h~喢�q�Ere�k�|<����(!F8a��gÎB� �9$4�?��ڧ�����6�<�����d�W�?��}7W�>b!��L�ɨ���NxбP���2w�t�A�	�
��O`}:���[?��'����-1���7D���\L�H�>̎��W�v�=6��1�?�`�Y3
y����b3���,"��.B�ge�P�b�+exB>3Ki'h�$�~~�^�[�6��)7�8�$�a冼�O�3��j�Nh��	cw�s�n��p>u����~y�6٧S}jR������tRX�"
>c���H��$�M�ZS��6�V�cA�\$��ǩ������&b]4-��4oL#�!ob�M��˴HS���3k��'Qj6�3o���^*癲r�M����l�F�I���~<��������B�ֿA�"a?�g��8�)~�(���A�#t�F�ՋW~^�\o7��q�[f�~�n�������s~���*��Wݬ�G�[(i����Y�T� �0�F�塗���lyY,��uq��Ohr&�����vg�
U��m�ٞ�fR��/�K!�H��R��%�()#�~R��q�Uj/Ê��Ƞ +]ew�g�I�!��eɃ�-��|��SB����1���RE�$j@T
��;�9��ȅ���"]�g�Yq]��-�f_�䇃!�)&c���9!��Ԏ���(T�@+��=��Bąx�v��=%*��pLL�]/��^P��ז���BŬ"Ϛ����xn��_��|F\����qF����Z�«���Z��66I�m�w]���I����]Hϛ�!Y"���g�0��å!g]����p~9�V�Y)�(0G���Y���@,�`'���]錷e��+x8�#����T^I{�5���6�l��d�l
I��f�����-����C�-I̮9�-T�����O/M�D3�����5KY��ۊ�~W��q�_�Ƿ:��'S%$!�#~�����p���M4�w��xX������N��$+�����9��C4ړ��{����}tr�'Y�On�ty�T�1�¹����qc���{ t]VȐt\Z�dٓ�|�Ӗ�B��cOK�qeg���=�2���_�����8�!a?�0)`�	�z��b+K(L
.��iG�L6��P(���lY28m*�ha8��/����76N�9���$��K6����k�?��NF��;�@̅�5��'օ�8�~0���V����)�?���k��2ݯ�^k��Vn�xx��4��]Ӎ/5&	��� !����g���&B�'�1��47 ����j$�u���t�F-$��1�X������N���L"����n]�=�ٱ��ߚ�5]�>��Ӷ�n��Z%=�g$�'%I��J�ԗ�|lǦ=�f���Ņ�(u^!^w\��p:�����j@�\���ڼUx�m��5�s�w�L�ҭ{E�qD*�)�Z2�.�M��2�\+3Q(���@=�_��!�O"�V��!rUx(8�s����e�c�d�����XC�+5��5�J��KF2�M�/+4�h/"e^*av�1����*�$%����QV�Hf�i��$����t���(�C���8�(9<M�UR(FtP8�z8�;r��kS�sCVH��G`��6Ox#}%��(�|+}W!��s��*�i��
V��d.̏��!�@����%[�<n_I\��ʳ#
�t�j�I��'��Q��n(>W %p�}4����A�����7x��H�
I��z�ՇC�O,�T�U�V�`<N��F�u%l�w�5�w�1�� ����
endstreamendobj13 0 obj<< /Type /Page /Parent 568 0 R /Resources 17 0 R /Contents 18 0 R /MediaBox [ 0 0 612 792 ] /CropBox [ 0 0 612 792 ] /Rotate 0 /Annots 14 0 R >> endobj14 0 obj[ 223 0 R 224 0 R 225 0 R 226 0 R 227 0 R 228 0 R 236 0 R 237 0 R 238 0 R 239 0 R 240 0 R 241 0 R 242 0 R 243 0 R 244 0 R 245 0 R 246 0 R 247 0 R 248 0 R 249 0 R 250 0 R 251 0 R 252 0 R 253 0 R 254 0 R 255 0 R 256 0 R 257 0 R 258 0 R 259 0 R 260 0 R 261 0 R 262 0 R 263 0 R 264 0 R 265 0 R 266 0 R 267 0 R 268 0 R 269 0 R 270 0 R 271 0 R 272 0 R 273 0 R 274 0 R 275 0 R 276 0 R 277 0 R 278 0 R 279 0 R 280 0 R 281 0 R 282 0 R 283 0 R 284 0 R 285 0 R 286 0 R 287 0 R 288 0 R 289 0 R 290 0 R 291 0 R 292 0 R 293 0 R 294 0 R 295 0 R 296 0 R 297 0 R 298 0 R 299 0 R 300 0 R 301 0 R 302 0 R 303 0 R 304 0 R 305 0 R 306 0 R 307 0 R 308 0 R 309 0 R 310 0 R 311 0 R 312 0 R 313 0 R 314 0 R 315 0 R 316 0 R 317 0 R 318 0 R 319 0 R 320 0 R 321 0 R 322 0 R 323 0 R 324 0 R 325 0 R 326 0 R 327 0 R 328 0 R 329 0 R 330 0 R 331 0 R 332 0 R 333 0 R 334 0 R 335 0 R 15 0 R 16 0 R ]endobj15 0 obj<< /Type /Annot /Subtype /Popup /Rect [ 234.82428 -156.22501 434.82585 43.77657 ] /Open false /F 27 /Parent 16 0 R >> endobj16 0 obj<< /Type /Annot /Subtype /Stamp /Rect [ 235 6 379 44 ] /Popup 15 0 R /C [ 0.75294 0.75294 0.75294 ] /T (John H Yates)/Contents ()/M (D:20000322204840-07'00')/AP 422 0 R /F 4 /Name /Draft >> endobj17 0 obj<< /ProcSet [ /PDF /Text ] /Font << /F1 704 0 R /F4 714 0 R /F6 728 0 R /F7 726 0 R /F10 19 0 R /F11 20 0 R /F16 22 0 R >> /ExtGState << /GS1 745 0 R >> >> endobj18 0 obj<< /Length 6258 /Filter /FlateDecode >> stream
H���[o�6���)��,6*�'�a��n�x�(&}Pl%Q�H�%Of�c��ﳇWQ��hQt�P����s!Ε@_|{C�CwAP�.�9�aIUN�D��+BѮ����c�}$�}�y���3���1K��B��
g[M�b5�[���9�6a�Ŝ��������� /���õx��x�w5p���F\�Գcw�?��u������׫�/�!�����Va���&8�uA8R<�������c��j�^.�ʇ�r��1E�)�kQk��*$����ȸ_z��8�,̱����M�{BK�n3����4�^��o����ί����<�}���J�$��N�OB�\ �0����}�V�.̖�Mf�3��<J�@Pi)���I�O"��'�.�e����cU�z�v�m�Иa9�`u��]��Y�!�;o{���8�.��~�����я{7��u� �����c��o+t���M��x8�\������6��q�7��1v眹�W8'X)s����U���������P�&���c6��bs:J.�c|)~dc�af��4��8�^����^���a�s��@�u�P7M�<����'��*w��4���f�����ٙ��~d����Һ�%�rkX#�7l���Mׁ�����9�� 4
,�&�-�f��J��Ԇ�����%M>��w�;/�/�mN�U��@s�[������.��W#ؐŇ9���ϑ�� ��Ѱ2&/2	�|MLld_��c8��G>}�)pÐ9����4n�2�#6#Y. \"3G�t(^�zqp�N�D�q�I�H���^d@�)a�\� ���ե��Rn*Դ}eR���u�o ݹ�����ݶ���0J\0�%���abQ<8d���4q�tNd��d�91A��ơ#r� 6�YN+U�q���������V��v����Tw�K0�r���0�:�a]M��hL��;�fŀ�����3�ɇ��z�|�����U�$��yadv�ztZ?r���z��i��6�d�d2�YL�����$&���79zh?V��	���n[?���/CSS6��	?�z���c�u_��%��Vh!����h�E�i��姫�S��ܣ�Z�wuo��H�BA�
�G��#g\Zꢽ�ͣ�bJD����HV����1�"?n���v���?B+	�\�ݔ�5@���a:*N����V�/׏����P�_����4>��a��鱬S�4�od���9�2��v�9#�f��̳���G�-q��ܢ��˾B۶\�!i�F��S'��4A6K��L	�9� ���ݳ6�V�T�D[C��z���+H{Cv��i�wޑ�49;����N�I�Y�!��Cfg��i�X��꟝�z��g���Z�}S=�um:1�,Ίz�ш�9�d��S��Q(8� ����8'���\�\��h�5l���i����X����m�>�k�[%0����ߡ=3�6��o�(�� 񂥚S�W���ϔ�"��y���q`���\!�n�g�C�i���c���AgÜ��a�r|����vbS'�h�̷�~���Z��G���]&25-3�OS��ߛ�;��n���F���gT>A]��k�pYq�Q(�X^���^�"�9Y%"(1�Ü(ԙ��ar5���팟o��l�!lo`j�f�ya��"�Fw\M��i2~�kQ>�x�tA0�i�|02�d��h��<M��ǃ�|�r��=�j01ɑl�[�s"��.�g6+���A����0�]�nPB�w��� ee��/��s�"��P*���E�@DI�7Q��f.�^��LJK�j{x�8��h(YLmheg�l
���M��,./f�o��~:s�Y�!ӗ�0'f���s��9� �5��$��A]o뾮\w�e�\d��o9GW�6�p�1�	�/"��t�f�n���\~6Y��V���̱�#��ú�t������9S6w�C$=yO�]�x��|�����͏���DZ��D�
�n�X6`�sU�0��1��Tb	A5͓úH0Ή���?��(AuB`R�yw���G�Dң$L0t�WOI��W�%x�4w�"^ɦx��	roq
//\��݂4�Dl���B۶l�e_�\R\IH	����f�a]$%��1����C31!�O�2Y�.�Q�C�9-J�1���)??p����a$�Ǧ}�0g1?��)��J�I `5��k��{�s��.�.tV]謺�Yu�gWXI4����5���]߸�}��溩,WR�����fpNU)�' �vm�i�m)_�����1�~`�|��ddV�HZ�M��r���2�AC�0��fxY�2zy�sa~lΓ�.	@5�h���q��X�\��S"i������zK�l��a	ݭ�0iVm�J�s- ���%�[-�BTӼК{9
���~��Ь�x���{��Y�O��޵]w{��!��������~����;��pŦ��kR@$�]o�����d�����_Tߣ���I ����t�js݋gg�q�Px1�x�tL��3�dC�II&�~6V�b?�z>6J�B%*����TC�S���M6�{Ȟ���Mʐ,��t�n�6��rH~~��W���O*m2b�M`����DG��п�z����6ܞ��n�,5{/����O~�축ѽ��.����~?���A�L����6WG"@QEv>#_�SU�}$e
0�E6��nw=OUa%��K��Z���s��CY,)9c�/wH�i~�|����R�lg���6q�U���n:<p=��?t��\ܑG���L���3��Ļ�ބ��*�bF���֏�������5$�!�)��u�-Ԝ��0��R��R��RwΥ�	^-I�?���=W��5�[�	?����x�� u�0L|����םv�ĵH�۹����hb4�����^0c�XW��q��X^��5vhX}D$����1D�qA���S��E�n_Q����>�R��۶��L���f�H+ԨrL0-��&*��]�W`X�L�J�[�d�h��<�����l&tn,�o�'��р¸� �ş@�0� �)D3�Ԙ>d쥳o1�@K��/�g����:UPRK�N�Ӧ�͉Z*�c��c�y�c�%8vv�ՙ��X���j�������3Yq��gi�cj�EB�	�Eh4̲@U�G�a�-c����[��s���876a��tЧ�"�<QB�JK�?Qk�C�+%���<	}ҝV����[.� ��p?�d��U��d�a��@sZ��lN\��6a�erk�D�r�(먱n�d
g"�0��\�5�A9-,����I�
2>|��Ghn�7l�\s�\y��6x}2��[���O�\�|}�Wo�~�ۯ�H(̱4T.V���мBqY(ב�:}��>�������R����Q~��@�b�����y�e�H� �Gx������M���n�/�z/ꫦ9�y���@Ӗ!�������V�����[�H����.y;W��`}�w^a�Ot��1#בS����ח�4l��j�����f����)�m�m��E���|�/F�:	�%����(��NS�d��;�7�/���eO��5-�t1vT]�rY��w��ˢ�3jZ�7h�kA��]����C�jO�fh���5� �P�W�*��u�U�P�L�����������D�ܗ�pgg��4�>n�%�i4ZL���"x���x$g��:��`2+���r�u2o(X�`pvM*�x�<�����z�ZU�H	`~��I\^�͑�B\������|��w���ՖV�.�;���l��k�1NR�LR��D��x��G�X�P?��[�l���;��Ei�|ְ��ΰ}��R�_�+6�*�����\V���Ɩ9�m%LD<�RǏ�
�4��*]?��?��i���B�pDZ�T�m^�||��Av��v匊xe��2�3ʴ{���C�3��Ռ&c��2WO=m�R�t�xO��/�0�'M�-M�-�u�Թy���D*��4�p�ni�Z��K��xU�!^��K�5�~i��9�M��>�y!��^kzT��L�`~A?�3Ҙ�NlOh-�,8�b�~�����{8l��<&y4���$oDWm4�[���V�	^��x�.�=������P�L^�El���������| ��<�������>����	��L�Խ���m]���2��a�I����qM������î+԰=<��)7u�@Jg������eO�-�c��MR*�	�2j1�W��7R�:�~g(�&p�J<����Do��'�8}�p$2�fS�v8D���9�>�l����v/�{��IU��텄xy��e��s�W�A�& �h��6hx{d����Ӥ�¥DDKvb�F�Z�l�kb� �	,QD8�g扰�<HD&���H�᯽�,���
#>wF�S>��Hs��㞏�aJ�ľR�mʑ]K��r$����򹏙IGw�[�M��2u��i<m@u��
d�����E@
1�,I�a]��k2��*��A�#{2�:������Y̋E6Z����q��g-��s�lJ����9k�bR�,$�Ba�i�3akʎ�1�	�9!1wEvb˪%JS��o���R���8���a3�2Hd"��.0��Q	e�4"�,ǎ�
�h�����"�T���P+��I&)��e6K�HA `	��9��=:f8�o'���-����bb�#hQ\��K)�bp�+4��3���(_��&ǆ-)5�aPq���ܒDXj
�ˁ4�V�"��8��1��~ʗ#�@���*�BgH�)����7�@R|�5\&>�*���8A��7HE�D��JFHç�s���1<��@%��+�De뫴g��Z��q�䉤��K�*��$55a",'��c���I��%�s�N�C-��S�D����R���)���0�]AZ
C%fDnC�dFf,���ʘ��!���2�L�Q�xVJ��щ�k�X�3M�O�$�F�k� �Jp1����@[���Ȯ%2� ��9��-~Lj%p� ��$'2i�TIH�����8U3��D$��\�� ss.X��C`��@F9^t�:��#�	>w�|0M�v�0f���v㐄���<��N`ӨB �8�4jRLp�4�D=����H
!m9պ�Y�׌ b�і�t��5�X�b�Q�-%�-�oi]m"��<��V���G��y��,�[#��k[ᠠ�E�QY /��4�R�JŔ�`��{���gl�_�Zk<Ց[�OT�x�2�@8��
�/�H#D2�w��M�Bj)\	��F9S�0���	/�)Q�i~X�0^~��THIk�����U7��)�0�c����)dR������j` ��f�L�2�2�0�,��C��ۚ�8�n�މ�F��i2.���TN��T���d����Ɏ�?�w�l�0!�XAn� g^��>t����q��c���|��><=�nv�m@?_w[0����a��ƫe�m���.���,KqoE�-X���\���5ہAӯ�P����^��RCN3��1�e�؜����-{j�
�P[�p�7�}�{2�F��ȭlQ��P��ϝ�v�i�o�9~t�ay}b|w���;T��01�J�B9Yf�{JC� 2Z#tS[t�Y���#G�/�6*��ŝ�����<�)�'1��я ���b���ʪ��>���4�gr��D���a�J�)�#���:y�~Ų̃Z�=��%6e_��|�ʎn������%o�����]�/���u�2A7!XFmQ�G��Sh����Eu�M���E����}���_ޗM�2g�EoyΓHy�П���g�,|�4����G�,�-��X7�OXI��]c�%Mi�X���Uc�AQX��"7 }k�K��}�g읐��g8���h1'�n��B�V^�M9��D��^��s�)�2y�l*�D����u���� ��tb�!-��F� �xZ٪�Q ���\�w��t�L�t�С�u���ݧ��i<�b��t�0�y�|J��<R���v���졓qs�����ʾ8yq-i\��n�SoE�Ǣ�sfL6a[�R��LX{�6Ŷ�$��~�������R��х�vhM���f�����G���X���$�js�뺉f�O�:|��T�bmG��ƒft3.�-�j.zjڊ�iX�L*���VG<Ƈ��TPTY杊�����PSp�G8}
endstreamendobj19 0 obj<< /Type /Font /Subtype /Type1 /FirstChar 32 /LastChar 181 /Widths [ 278 259 426 556 556 1000 630 278 259 259 352 600 278 389 278 333 556 556 556 556 556 556 556 556 556 556 278 278 600 600 600 556 800 648 685 722 704 611 574 759 722 259 519 667 556 871 722 760 648 760 685 648 574 722 611 926 611 648 611 259 333 259 600 500 222 537 593 537 593 537 296 574 556 222 222 519 222 853 556 574 593 593 333 500 315 556 500 758 518 500 480 333 222 333 600 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 556 556 278 278 278 278 278 800 278 278 278 278 278 278 278 600 278 278 278 556 ] /Encoding /WinAnsiEncoding /BaseFont /HelveticaNeue-Roman /FontDescriptor 705 0 R >> endobj20 0 obj<< /Type /Font /Subtype /Type1 /FirstChar 32 /LastChar 181 /Widths [ 278 278 463 556 556 1000 685 278 296 296 407 600 278 407 278 371 556 556 556 556 556 556 556 556 556 556 278 278 600 600 600 556 800 685 704 741 741 648 593 759 741 295 556 722 593 907 741 778 667 778 722 649 611 741 630 944 667 667 648 333 371 333 600 500 259 574 611 574 611 574 333 611 593 258 278 574 258 906 593 611 611 611 389 537 352 593 520 814 537 519 519 333 223 333 600 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 278 556 556 278 278 278 278 278 800 278 278 278 278 278 278 278 600 278 278 278 593 ] /Encoding /WinAnsiEncoding /BaseFont /HelveticaNeue-Bold /FontDescriptor 715 0 R >> endobj21 0 obj<< /Type /Font /Subtype /Type1 /FirstChar 32 /LastChar 181 /Widths [ 250 333 333 500 500 833 667 250 333 333 500 500 333 333 333 278 500 500 500 500 500 500 500 500 500 500 278 278 500 500 500 500 833 556 556 556 611 500 500 611 611 278 444 556 500 778 611 611 556 611 611 556 500 611 556 833 556 556 500 333 250 333 500 500 333 500 500 444 500 500 278 500 500 278 278 444 278 778 500 500 500 500 333 444 278 500 444 667 444 444 389 274 250 274 500 250 250 250 250 250 250 250 250 250 250 250 250 250 250 250 250 250 250 250 250 250 250 250 250 250 250 250 250 250 250 250 250 250 250 250 500 500 250 250 250 250 250 830 250 250 250 250 250 250 250 500 250 250 250 500 ] /Encoding /WinAnsiEncoding /BaseFont /Helvetica-Condensed-Bold /FontDescriptor 719 0 R >> endobj22 0 obj<< /Type /Font /Subtype /Type1 /FirstChar 32 /LastChar 181 /Widths [ 250 333 250 500 500 833 667 250 333 333 500 500 250 333 250 278 500 500 500 500 500 500 500 500 500 500 250 250 500 500 500 500 800 556 556 556 611 500 444 611 611 278 444 556 500 778 611 611 556 611 611 556 500 611 556 833 556 556 500 333 250 333 500 500 333 444 500 444 500 444 278 500 500 222 222 444 222 778 500 500 500 500 333 444 278 500 444 667 444 444 389 274 250 274 500 250 250 250 250 250 250 250 250 250 250 250 250 250 250 250 250 250 250 250 250 250 250 250 250 250 250 250 250 250 250 250 250 250 250 250 500 500 250 250 250 250 250 800 250 250 250 250 250 250 250 500 250 250 250 500 ] /Encoding /WinAnsiEncoding /BaseFont /Helvetica-Condensed /FontDescriptor 23 0 R >> endobj23 0 obj<< /Type /FontDescriptor /Ascent 750 /CapHeight 750 /Descent -189 /Flags 32 /FontBBox [ -174 -250 1071 990 ] /FontName /Helvetica-Condensed /ItalicAngle 0 /StemV 79 /XHeight 556 >> endobj24 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 481.49811 699.82921 544.16524 712.82928 ] /P 1 0 R /F 4 /T (f2-1)/FT /Tx /AA << >> /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj25 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 546.16525 699.16254 563.16541 713.16261 ] /P 1 0 R /F 4 /T (f2-2)/FT /Tx /AA << >> /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj26 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 481.49811 687.82784 544.16524 698.82791 ] /P 1 0 R /F 4 /T (f2-3)/FT /Tx /AA << >> /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj27 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 546.16525 687.16116 563.16541 699.16124 ] /P 1 0 R /F 4 /T (f2-4)/FT /Tx /AA << >> /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj28 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 481.49811 675.16118 544.16524 687.16125 ] /P 1 0 R /F 4 /T (f2-5)/FT /Tx /AA << >> /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj29 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 546.16525 675.49451 563.16541 686.49458 ] /P 1 0 R /F 4 /T (f2-6)/FT /Tx /AA << >> /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj30 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 481.49811 663.16116 544.16524 675.16124 ] /P 1 0 R /F 4 /T (f2-7)/FT /Tx /AA << >> /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj31 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 546.16525 663.49449 563.16541 674.49457 ] /P 1 0 R /F 4 /T (f2-8)/FT /Tx /AA << >> /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj32 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 481.49811 651.49451 544.16524 663.49458 ] /P 1 0 R /F 4 /T (f2-9)/FT /Tx /AA << >> /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj33 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 546.16525 651.82784 563.16541 662.82791 ] /P 1 0 R /F 4 /T (f2-10)/FT /Tx /AA << >> /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj34 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 481.49811 639.82784 544.16524 650.82791 ] /P 1 0 R /F 4 /T (f2-11)/FT /Tx /AA << >> /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj35 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 546.16525 639.16116 563.16541 651.16124 ] /P 1 0 R /F 4 /T (f2-12)/FT /Tx /AA << >> /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj36 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 481.49811 627.82784 544.16524 638.82791 ] /P 1 0 R /F 4 /T (f2-13)/FT /Tx /AA << >> /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj37 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 546.16525 628.16116 563.16541 639.16124 ] /P 1 0 R /F 4 /T (f2-14)/FT /Tx /AA << >> /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj38 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 481.49811 616.16116 544.16524 627.16124 ] /P 1 0 R /F 4 /T (f2-15)/FT /Tx /AA << >> /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj39 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 546.16525 615.49449 563.16541 627.49457 ] /P 1 0 R /F 4 /T (f2-16)/FT /Tx /AA << >> /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj40 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 84.07556 590.9978 92.28461 599.71429 ] /F 4 /P 1 0 R /AS /Off /MK << /CA (4)/AC (��)/RC (��)>> /AP << /N << /Yes 336 0 R >> /D << /Yes 337 0 R /Off 338 0 R >> >> /H /T /Parent 467 0 R >> endobj41 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 84.72723 579.80365 91.93628 587.52014 ] /DR 746 0 R /P 1 0 R /AS /Off /F 4 /H /T /MK << /CA (4)/AC (��)/RC (��)>> /T (c2-2)/FT /Btn /AA << >> /DA (/ZaDb 9 Tf 0 0 0.627 rg)/AP << /N << /Yes 339 0 R >> /D << /Yes 340 0 R /Off 341 0 R >> >> >> endobj42 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 84.72723 567.80365 91.93628 575.52014 ] /DR 746 0 R /P 1 0 R /AS /Off /F 4 /H /T /MK << /CA (4)/AC (��)/RC (��)>> /T (c2-3)/FT /Btn /AA << >> /DA (/ZaDb 9 Tf 0 0 0.627 rg)/AP << /N << /Yes 342 0 R >> /D << /Yes 343 0 R /Off 344 0 R >> >> >> endobj43 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 322.64532 567.37067 568.91669 581.05737 ] /F 4 /P 1 0 R /T (f2-17)/FT /Tx /DA (/HeBo 9 Tf 0 0 0.627 rg)/H /T /MK << /CA (4)/AC (��)/RC (��)>> >> endobj44 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 543.72723 555.92279 551.93628 563.63928 ] /DR 746 0 R /P 1 0 R /AS /Off /F 4 /H /T /MK << /CA (4)/AC (��)/RC (��)>> /DA (/ZaDb 9 Tf 0 0 0.627 rg)/T (c2-4)/FT /Btn /AA << >> /AP << /N << /Yes 417 0 R >> /D << /Yes 418 0 R /Off 419 0 R >> >> >> endobj45 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 543.72723 542.92279 551.93628 551.63928 ] /DR 746 0 R /P 1 0 R /AS /Off /F 4 /H /T /MK << /CA (4)/AC (��)/RC (��)>> /DA (/ZaDb 9 Tf 0 0 0.627 rg)/T (c2-5)/FT /Btn /AA << >> /AP << /N << /Yes 345 0 R >> /D << /Yes 346 0 R /Off 347 0 R >> >> >> endobj46 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 502.72723 531.92279 509.93628 539.63928 ] /DR 746 0 R /P 1 0 R /AS /Off /F 4 /H /T /MK << /CA (4)/AC (��)/RC (��)>> /T (c2-6)/FT /Btn /AA << >> /DA (/ZaDb 9 Tf 0 0 0.627 rg)/AP << /N << /Yes 50 0 R >> /D << /Yes 51 0 R /Off 52 0 R >> >> >> endobj47 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 543.72723 531.92279 551.93628 539.63928 ] /DR 746 0 R /P 1 0 R /AS /Off /F 4 /H /T /MK << /CA (4)/AC (��)/RC (��)>> /T (c2-7)/FT /Btn /AA << >> /DA (/ZaDb 9 Tf 0 0 0.627 rg)/AP << /N << /Yes 53 0 R >> /D << /Yes 54 0 R /Off 55 0 R >> >> >> endobj48 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 502.72723 519.92279 509.93628 527.63928 ] /DR 746 0 R /P 1 0 R /AS /Off /F 4 /H /T /MK << /CA (4)/AC (��)/RC (��)>> /DA (/ZaDb 9 Tf 0 0 0.627 rg)/T (c2-8)/FT /Btn /AA << >> /AP << /N << /Yes 56 0 R >> /D << /Yes 57 0 R /Off 58 0 R >> >> >> endobj49 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 543.72723 518.92279 551.93628 527.63928 ] /DR 746 0 R /P 1 0 R /AS /Off /F 4 /H /T /MK << /CA (4)/AC (��)/RC (��)>> /DA (/ZaDb 9 Tf 0 0 0.627 rg)/T (c2-9)/FT /Btn /AA << >> /AP << /N << /Yes 348 0 R >> /D << /Yes 349 0 R /Off 350 0 R >> >> >> endobj50 0 obj<< /Length 91 /Subtype /Form /BBox [ 0 0 7.20905 7.71649 ] /Resources << /ProcSet [ /PDF /Text ] /Font << /ZaDb 604 0 R >> >> >> stream
q 1 1 5.209 5.7165 re W n BT /ZaDb 9 Tf 0 0 0.627 rg  1 0 0 1 -0.2024 0.6228 Tm (4) Tj ET Qendstreamendobj51 0 obj<< /Length 119 /Subtype /Form /BBox [ 0 0 7.20905 7.71649 ] /Resources << /ProcSet [ /PDF /Text ] /Font << /ZaDb 604 0 R >> >> >> stream
0.749 g 0 0 7.209 7.7165 re f q 1 1 5.209 5.7165 re W n BT /ZaDb 9 Tf 0 0 0.627 rg  1 0 0 1 -0.2024 0.6228 Tm (4) Tj ETendstreamendobj52 0 obj<< /Length 29 /Subtype /Form /BBox [ 0 0 7.20905 7.71649 ] /Resources << /ProcSet [ /PDF ] >> >> stream
0.749 g 0 0 7.209 7.7165 re fendstreamendobj53 0 obj<< /Length 90 /Subtype /Form /BBox [ 0 0 8.20905 7.71649 ] /Resources << /ProcSet [ /PDF /Text ] /Font << /ZaDb 604 0 R >> >> >> stream
q 1 1 6.209 5.7165 re W n BT /ZaDb 9 Tf 0 0 0.627 rg  1 0 0 1 0.2976 0.6228 Tm (4) Tj ET Qendstreamendobj54 0 obj<< /Length 118 /Subtype /Form /BBox [ 0 0 8.20905 7.71649 ] /Resources << /ProcSet [ /PDF /Text ] /Font << /ZaDb 604 0 R >> >> >> stream
0.749 g 0 0 8.209 7.7165 re f q 1 1 6.209 5.7165 re W n BT /ZaDb 9 Tf 0 0 0.627 rg  1 0 0 1 0.2976 0.6228 Tm (4) Tj ETendstreamendobj55 0 obj<< /Length 29 /Subtype /Form /BBox [ 0 0 8.20905 7.71649 ] /Resources << /ProcSet [ /PDF ] >> >> stream
0.749 g 0 0 8.209 7.7165 re fendstreamendobj56 0 obj<< /Length 91 /Subtype /Form /BBox [ 0 0 7.20905 7.71649 ] /Resources << /ProcSet [ /PDF /Text ] /Font << /ZaDb 604 0 R >> >> >> stream
q 1 1 5.209 5.7165 re W n BT /ZaDb 9 Tf 0 0 0.627 rg  1 0 0 1 -0.2024 0.6228 Tm (4) Tj ET Qendstreamendobj57 0 obj<< /Length 119 /Subtype /Form /BBox [ 0 0 7.20905 7.71649 ] /Resources << /ProcSet [ /PDF /Text ] /Font << /ZaDb 604 0 R >> >> >> stream
0.749 g 0 0 7.209 7.7165 re f q 1 1 5.209 5.7165 re W n BT /ZaDb 9 Tf 0 0 0.627 rg  1 0 0 1 -0.2024 0.6228 Tm (4) Tj ETendstreamendobj58 0 obj<< /Length 29 /Subtype /Form /BBox [ 0 0 7.20905 7.71649 ] /Resources << /ProcSet [ /PDF ] >> >> stream
0.749 g 0 0 7.209 7.7165 re fendstreamendobj59 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 63.72723 447.51849 71.93628 455.23499 ] /DR 746 0 R /P 1 0 R /AS /Off /F 4 /H /T /MK << /CA (4)/AC (��)/RC (��)>> /T (c2-10)/FT /Btn /AA << >> /DA (/ZaDb 9 Tf 0 0 0.627 rg)/AP << /N << /Yes 351 0 R >> /D << /Yes 352 0 R /Off 353 0 R >> >> >> endobj60 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 229.72723 447.51849 236.93628 455.23499 ] /DR 746 0 R /P 1 0 R /AS /Off /F 4 /H /T /MK << /CA (4)/AC (��)/RC (��)>> /T (c2-11)/FT /Btn /AA << >> /DA (/ZaDb 9 Tf 0 0 0.627 rg)/AP << /N << /Yes 354 0 R >> /D << /Yes 355 0 R /Off 356 0 R >> >> >> endobj61 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 387.72723 447.51849 395.93628 455.23499 ] /DR 746 0 R /P 1 0 R /AS /Off /F 4 /H /T /MK << /CA (4)/AC (��)/RC (��)>> /T (c2-12)/FT /Btn /AA << >> /DA (/ZaDb 9 Tf 0 0 0.627 rg)/AP << /N << /Yes 64 0 R >> /D << /Yes 65 0 R /Off 66 0 R >> >> >> endobj62 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 63.72723 434.51849 71.93628 443.23499 ] /DR 746 0 R /P 1 0 R /AS /Off /F 4 /H /T /MK << /CA (4)/AC (��)/RC (��)>> /T (c2-13)/FT /Btn /AA << >> /DA (/ZaDb 9 Tf 0 0 0.627 rg)/AP << /N << /Yes 357 0 R >> /D << /Yes 358 0 R /Off 359 0 R >> >> >> endobj63 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 228.72723 434.51849 237.93628 443.23499 ] /DR 746 0 R /P 1 0 R /AS /Off /F 4 /H /T /MK << /CA (4)/AC (��)/RC (��)>> /T (c2-14)/FT /Btn /AA << >> /DA (/ZaDb 9 Tf 0 0 0.627 rg)/AP << /N << /Yes 360 0 R >> /D << /Yes 361 0 R /Off 362 0 R >> >> >> endobj64 0 obj<< /Length 90 /Subtype /Form /BBox [ 0 0 8.20905 7.71649 ] /Resources << /ProcSet [ /PDF /Text ] /Font << /ZaDb 604 0 R >> >> >> stream
q 1 1 6.209 5.7165 re W n BT /ZaDb 9 Tf 0 0 0.627 rg  1 0 0 1 0.2976 0.6228 Tm (4) Tj ET Qendstreamendobj65 0 obj<< /Length 118 /Subtype /Form /BBox [ 0 0 8.20905 7.71649 ] /Resources << /ProcSet [ /PDF /Text ] /Font << /ZaDb 604 0 R >> >> >> stream
0.749 g 0 0 8.209 7.7165 re f q 1 1 6.209 5.7165 re W n BT /ZaDb 9 Tf 0 0 0.627 rg  1 0 0 1 0.2976 0.6228 Tm (4) Tj ETendstreamendobj66 0 obj<< /Length 29 /Subtype /Form /BBox [ 0 0 8.20905 7.71649 ] /Resources << /ProcSet [ /PDF ] >> >> stream
0.749 g 0 0 8.209 7.7165 re fendstreamendobj67 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 287.80914 434.27966 512.90125 447.72754 ] /F 4 /P 1 0 R /T (f2-18)/FT /Tx /MK << /CA (4)/AC (��)/RC (��)>> /H /T /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj68 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 524.12518 423.33923 546.03583 434.29456 ] /F 4 /P 1 0 R /AP << /N << /Yes 363 0 R >> /D << /Yes 364 0 R /Off 365 0 R >> >> /AS /Off /AA << >> /H /T /MK << /CA (4)/AC (��)/RC (��)>> /Parent 468 0 R >> endobj69 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 545.76721 423.33923 567.91669 434.78711 ] /F 4 /P 1 0 R /AP << /N << /Yes 366 0 R >> /D << /Yes 367 0 R /Off 368 0 R >> >> /AS /Off /AA << >> /H /T /MK << /CA (4)/AC (��)/RC (��)>> /Parent 469 0 R >> endobj70 0 obj<< /Encoding 71 0 R /Font 73 0 R >> endobj71 0 obj<< /PDFDocEncoding 72 0 R >> endobj72 0 obj<< /Type /Encoding /Differences [ 24 /breve /caron /circumflex /dotaccent /hungarumlaut /ogonek /ring /tilde 39 /quotesingle 96 /grave 128 /bullet /dagger /daggerdbl /ellipsis /emdash /endash /florin /fraction /guilsinglleft /guilsinglright /minus /perthousand /quotedblbase /quotedblleft /quotedblright /quoteleft /quoteright /quotesinglbase /trademark /fi /fl /Lslash /OE /Scaron /Ydieresis /Zcaron /dotlessi /lslash /oe /scaron /zcaron 160 /Euro 164 /currency 166 /brokenbar 168 /dieresis /copyright /ordfeminine 172 /logicalnot /.notdef /registered /macron /degree /plusminus /twosuperior /threesuperior /acute /mu 183 /periodcentered /cedilla /onesuperior /ordmasculine 188 /onequarter /onehalf /threequarters 192 /Agrave /Aacute /Acircumflex /Atilde /Adieresis /Aring /AE /Ccedilla /Egrave /Eacute /Ecircumflex /Edieresis /Igrave /Iacute /Icircumflex /Idieresis /Eth /Ntilde /Ograve /Oacute /Ocircumflex /Otilde /Odieresis /multiply /Oslash /Ugrave /Uacute /Ucircumflex /Udieresis /Yacute /Thorn /germandbls /agrave /aacute /acircumflex /atilde /adieresis /aring /ae /ccedilla /egrave /eacute /ecircumflex /edieresis /igrave /iacute /icircumflex /idieresis /eth /ntilde /ograve /oacute /ocircumflex /otilde /odieresis /divide /oslash /ugrave /uacute /ucircumflex /udieresis /yacute /thorn /ydieresis ] >> endobj73 0 obj<< /Helv 74 0 R /HeBo 75 0 R /ZaDb 76 0 R >> endobj74 0 obj<< /Type /Font /Name /Helv /BaseFont /Helvetica /Subtype /Type1 /Encoding 72 0 R >> endobj75 0 obj<< /Type /Font /Name /HeBo /BaseFont /Helvetica-Bold /Subtype /Type1 /Encoding 72 0 R >> endobj76 0 obj<< /Type /Font /Name /ZaDb /BaseFont /ZapfDingbats /Subtype /Type1 >> endobj77 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 524.436 411.33151 545.34665 422.28683 ] /DR 70 0 R /P 1 0 R /AS /Off /F 4 /H /T /MK << /CA (4)/AC (��)/RC (��)>> /T (c2-17)/FT /Btn /AA << >> /DA (/ZaDb 9 Tf 0 0 0.627 rg)/AP << /N << /Yes 79 0 R >> /D << /Yes 80 0 R /Off 81 0 R >> >> >> endobj78 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 546.07803 411.33151 568.22751 422.77939 ] /DR 746 0 R /P 1 0 R /AS /Off /F 4 /H /T /MK << /CA (4)/AC (��)/RC (��)>> /T (c2-18)/FT /Btn /AA << >> /DA (/ZaDb 9 Tf 0 0 0.627 rg)/AP << /N << /Yes 369 0 R >> /D << /Yes 370 0 R /Off 371 0 R >> >> >> endobj79 0 obj<< /Length 92 /Subtype /Form /BBox [ 0 0 20.91064 10.95532 ] /Resources << /ProcSet [ /PDF /Text ] /Font << /ZaDb 604 0 R >> >> >> stream
q 1 1 18.9106 8.9553 re W n BT /ZaDb 9 Tf 0 0 0.627 rg  1 0 0 1 6.6483 2.2422 Tm (4) Tj ET Qendstreamendobj80 0 obj<< /Length 123 /Subtype /Form /BBox [ 0 0 20.91064 10.95532 ] /Resources << /ProcSet [ /PDF /Text ] /Font << /ZaDb 604 0 R >> >> >> stream
0.749 g 0 0 20.9106 10.9553 re f q 1 1 18.9106 8.9553 re W n BT /ZaDb 9 Tf 0 0 0.627 rg  1 0 0 1 6.6483 2.2422 Tm (4) Tj ETendstreamendobj81 0 obj<< /Length 32 /Subtype /Form /BBox [ 0 0 20.91064 10.95532 ] /Resources << /ProcSet [ /PDF ] >> >> stream
0.749 g 0 0 20.9106 10.9553 re fendstreamendobj82 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 524.436 387.33151 545.34665 410.28683 ] /DR 70 0 R /P 1 0 R /AS /Off /F 4 /H /T /MK << /CA (4)/AC (��)/RC (��)>> /T (c2-19)/FT /Btn /AA << >> /DA (/ZaDb 9 Tf 0 0 0.627 rg)/AP << /N << /Yes 372 0 R >> /D << /Yes 373 0 R /Off 374 0 R >> >> >> endobj83 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 546.07803 387.33151 567.22751 410.77939 ] /DR 746 0 R /P 1 0 R /AS /Off /F 4 /H /T /MK << /CA (4)/AC (��)/RC (��)>> /T (c2-20)/FT /Btn /AA << >> /DA (/ZaDb 9 Tf 0 0 0.627 rg)/AP << /N << /Yes 375 0 R >> /D << /Yes 376 0 R /Off 377 0 R >> >> >> endobj84 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 524.436 303.80807 545.34665 314.7634 ] /DR 70 0 R /P 1 0 R /AS /Off /F 4 /H /T /MK << /CA (4)/AC (��)/RC (��)>> /T (c2-21)/FT /Btn /AA << >> /DA (/ZaDb 9 Tf 0 0 0.627 rg)/AP << /N << /Yes 378 0 R >> /D << /Yes 379 0 R /Off 380 0 R >> >> >> endobj85 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 546.07803 303.80807 568.22751 315.25595 ] /DR 746 0 R /P 1 0 R /AS /Off /F 4 /H /T /MK << /CA (4)/AC (��)/RC (��)>> /T (c2-22)/FT /Btn /AA << >> /DA (/ZaDb 9 Tf 0 0 0.627 rg)/AP << /N << /Yes 381 0 R >> /D << /Yes 382 0 R /Off 383 0 R >> >> >> endobj86 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 524.436 291.80807 545.34665 303.7634 ] /DR 70 0 R /P 1 0 R /AS /Off /F 4 /H /T /MK << /CA (4)/AC (��)/RC (��)>> /T (c2-23)/FT /Btn /AA << >> /DA (/ZaDb 9 Tf 0 0 0.627 rg)/AP << /N << /Yes 92 0 R >> /D << /Yes 93 0 R /Off 94 0 R >> >> >> endobj87 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 546.07803 291.80807 568.22751 303.25595 ] /DR 746 0 R /P 1 0 R /AS /Off /F 4 /H /T /MK << /CA (4)/AC (��)/RC (��)>> /T (c2-24)/FT /Btn /AA << >> /DA (/ZaDb 9 Tf 0 0 0.627 rg)/AP << /N << /Yes 384 0 R >> /D << /Yes 385 0 R /Off 386 0 R >> >> >> endobj88 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 524.436 279.04636 545.34665 291.00168 ] /DR 70 0 R /P 1 0 R /AS /Off /F 4 /H /T /MK << /CA (4)/AC (��)/RC (��)>> /T (c2-25)/FT /Btn /AA << >> /DA (/ZaDb 9 Tf 0 0 0.627 rg)/AP << /N << /Yes 95 0 R >> /D << /Yes 96 0 R /Off 97 0 R >> >> >> endobj89 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 546.07803 279.04636 568.22751 291.49423 ] /DR 746 0 R /P 1 0 R /AS /Off /F 4 /H /T /MK << /CA (4)/AC (��)/RC (��)>> /T (c2-26)/FT /Btn /AA << >> /DA (/ZaDb 9 Tf 0 0 0.627 rg)/AP << /N << /Yes 387 0 R >> /D << /Yes 388 0 R /Off 389 0 R >> >> >> endobj90 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 524.436 267.04636 545.34665 279.00168 ] /AP << /N << /Yes 98 0 R >> /D << /Yes 99 0 R /Off 100 0 R >> >> /P 1 0 R /AS /Off /F 4 /H /T /MK << /CA (4)/AC (��)/RC (��)>> /AA << >> /Parent 470 0 R >> endobj91 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 546.07803 267.04636 568.22751 278.49423 ] /AP << /N << /Yes 390 0 R >> /D << /Yes 391 0 R /Off 392 0 R >> >> /P 1 0 R /AS /Off /F 4 /H /T /MK << /CA (4)/AC (��)/RC (��)>> /AA << >> /Parent 471 0 R >> endobj92 0 obj<< /Length 92 /Subtype /Form /BBox [ 0 0 20.91064 11.95532 ] /Resources << /ProcSet [ /PDF /Text ] /Font << /ZaDb 604 0 R >> >> >> stream
q 1 1 18.9106 9.9553 re W n BT /ZaDb 9 Tf 0 0 0.627 rg  1 0 0 1 6.6483 2.7422 Tm (4) Tj ET Qendstreamendobj93 0 obj<< /Length 123 /Subtype /Form /BBox [ 0 0 20.91064 11.95532 ] /Resources << /ProcSet [ /PDF /Text ] /Font << /ZaDb 604 0 R >> >> >> stream
0.749 g 0 0 20.9106 11.9553 re f q 1 1 18.9106 9.9553 re W n BT /ZaDb 9 Tf 0 0 0.627 rg  1 0 0 1 6.6483 2.7422 Tm (4) Tj ETendstreamendobj94 0 obj<< /Length 32 /Subtype /Form /BBox [ 0 0 20.91064 11.95532 ] /Resources << /ProcSet [ /PDF ] >> >> stream
0.749 g 0 0 20.9106 11.9553 re fendstreamendobj95 0 obj<< /Length 92 /Subtype /Form /BBox [ 0 0 20.91064 11.95532 ] /Resources << /ProcSet [ /PDF /Text ] /Font << /ZaDb 604 0 R >> >> >> stream
q 1 1 18.9106 9.9553 re W n BT /ZaDb 9 Tf 0 0 0.627 rg  1 0 0 1 6.6483 2.7422 Tm (4) Tj ET Qendstreamendobj96 0 obj<< /Length 123 /Subtype /Form /BBox [ 0 0 20.91064 11.95532 ] /Resources << /ProcSet [ /PDF /Text ] /Font << /ZaDb 604 0 R >> >> >> stream
0.749 g 0 0 20.9106 11.9553 re f q 1 1 18.9106 9.9553 re W n BT /ZaDb 9 Tf 0 0 0.627 rg  1 0 0 1 6.6483 2.7422 Tm (4) Tj ETendstreamendobj97 0 obj<< /Length 32 /Subtype /Form /BBox [ 0 0 20.91064 11.95532 ] /Resources << /ProcSet [ /PDF ] >> >> stream
0.749 g 0 0 20.9106 11.9553 re fendstreamendobj98 0 obj<< /Length 92 /Subtype /Form /BBox [ 0 0 20.91064 11.95532 ] /Resources << /ProcSet [ /PDF /Text ] /Font << /ZaDb 604 0 R >> >> >> stream
q 1 1 18.9106 9.9553 re W n BT /ZaDb 9 Tf 0 0 0.627 rg  1 0 0 1 6.6483 2.7422 Tm (4) Tj ET Qendstreamendobj99 0 obj<< /Length 123 /Subtype /Form /BBox [ 0 0 20.91064 11.95532 ] /Resources << /ProcSet [ /PDF /Text ] /Font << /ZaDb 604 0 R >> >> >> stream
0.749 g 0 0 20.9106 11.9553 re f q 1 1 18.9106 9.9553 re W n BT /ZaDb 9 Tf 0 0 0.627 rg  1 0 0 1 6.6483 2.7422 Tm (4) Tj ETendstreamendobj100 0 obj<< /Length 32 /Subtype /Form /BBox [ 0 0 20.91064 11.95532 ] /Resources << /ProcSet [ /PDF ] >> >> stream
0.749 g 0 0 20.9106 11.9553 re fendstreamendobj101 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 235.33093 218.35193 513.67731 230.30725 ] /F 4 /P 1 0 R /T (f2-19)/FT /Tx /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj102 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 524.436 219.67349 545.34665 235.62881 ] /DR 70 0 R /P 1 0 R /AS /Off /F 4 /H /T /MK << /CA (4)/AC (��)/RC (��)>> /T (c2-29)/FT /Btn /AA << >> /DA (/ZaDb 9 Tf 0 0 0.627 rg)/AP << /N << /Yes 393 0 R >> /D << /Yes 394 0 R /Off 395 0 R >> >> >> endobj103 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 546.07803 219.67349 568.22751 235.12137 ] /DR 746 0 R /P 1 0 R /AS /Off /F 4 /H /T /MK << /CA (4)/AC (��)/RC (��)>> /T (c2-30)/FT /Btn /AA << >> /DA (/ZaDb 9 Tf 0 0 0.627 rg)/AP << /N << /Yes 396 0 R >> /D << /Yes 397 0 R /Off 398 0 R >> >> >> endobj104 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 524.436 195.67349 545.34665 218.62881 ] /DR 70 0 R /P 1 0 R /AS /Off /F 4 /H /T /MK << /CA (4)/AC (��)/RC (��)>> /T (c2-31)/FT /Btn /AA << >> /DA (/ZaDb 9 Tf 0 0 0.627 rg)/AP << /N << /Yes 399 0 R >> /D << /Yes 400 0 R /Off 401 0 R >> >> >> endobj105 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 546.07803 195.67349 568.22751 219.12137 ] /DR 746 0 R /P 1 0 R /AS /Off /F 4 /H /T /MK << /CA (4)/AC (��)/RC (��)>> /T (c2-32)/FT /Btn /AA << >> /DA (/ZaDb 9 Tf 0 0 0.627 rg)/AP << /N << /Yes 402 0 R >> /D << /Yes 403 0 R /Off 404 0 R >> >> >> endobj106 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 524.436 159.67349 545.34665 194.62881 ] /DR 70 0 R /P 1 0 R /AS /Off /F 4 /H /T /MK << /CA (4)/AC (��)/RC (��)>> /T (c2-33)/FT /Btn /AA << >> /DA (/ZaDb 9 Tf 0 0 0.627 rg)/AP << /N << /Yes 405 0 R >> /D << /Yes 406 0 R /Off 407 0 R >> >> >> endobj107 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 546.07803 159.67349 568.22751 195.12137 ] /DR 746 0 R /P 1 0 R /AS /Off /F 4 /H /T /MK << /CA (4)/AC (��)/RC (��)>> /T (c2-34)/FT /Btn /AA << >> /DA (/ZaDb 9 Tf 0 0 0.627 rg)/AP << /N << /Yes 408 0 R >> /D << /Yes 409 0 R /Off 410 0 R >> >> >> endobj108 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 127.1059 101.20135 380.86981 117.63434 ] /F 4 /P 1 0 R /T (f2-20)/FT /Tx /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj109 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 457.69165 100.20135 568.66296 117.63434 ] /F 4 /P 1 0 R /T (f2-21)/FT /Tx /Q 1 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj110 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 128.1059 87.0072 567.67786 99.21625 ] /F 4 /P 1 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)/Q 0 /Parent 472 0 R >> endobj111 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 128.21655 75.05763 567.78851 87.26668 ] /P 1 0 R /F 4 /T (f2-23)/FT /Tx /AA << >> /Q 0 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj112 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 481.84113 710.89465 544.28955 722.84998 ] /F 4 /P 7 0 R /Parent 473 0 R >> endobj113 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 546.33752 711.66606 566.00433 722.99947 ] /F 4 /P 7 0 R /Parent 474 0 R >> endobj114 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 482.25426 699.61273 543.70268 710.56805 ] /P 7 0 R /F 4 /AA << >> /Parent 475 0 R >> endobj115 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 545.75066 699.38414 565.41747 710.71754 ] /P 7 0 R /F 4 /AA << >> /Parent 476 0 R >> endobj116 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 374.0477 687.36798 436.49612 699.3233 ] /P 7 0 R /F 4 /T (f3-5)/FT /Tx /AA << >> /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj117 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 438.5441 687.13939 458.21091 699.47279 ] /P 7 0 R /F 4 /T (f3-6)/FT /Tx /AA << >> /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj118 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 373.46083 675.08606 436.90926 687.04138 ] /P 7 0 R /F 4 /T (f3-7)/FT /Tx /AA << >> /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj119 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 438.95723 674.85747 457.62404 687.19087 ] /P 7 0 R /F 4 /T (f3-8)/FT /Tx /AA << >> /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj120 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 482.25426 663.22702 543.70268 676.18234 ] /P 7 0 R /F 4 /T (f3-9)/FT /Tx /AA << >> /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj121 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 545.75066 663.99843 564.41747 676.33183 ] /P 7 0 R /F 4 /T (f3-10)/FT /Tx /AA << >> /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj122 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 482.0477 639.36798 544.49612 653.3233 ] /P 7 0 R /F 4 /T (f3-11)/FT /Tx /AA << >> /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj123 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 546.5441 639.13939 564.21091 653.47279 ] /P 7 0 R /F 4 /T (f3-12)/FT /Tx /AA << >> /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj124 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 482.33368 627.81909 544.27466 639.01324 ] /P 7 0 R /F 4 /T (f3-13)/FT /Tx /AA << >> /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj125 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 545.95723 626.85747 563.62404 639.19087 ] /P 7 0 R /F 4 /T (f3-14)/FT /Tx /AA << >> /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj126 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 482.0477 615.36798 544.49612 627.3233 ] /P 7 0 R /F 4 /T (f3-15)/FT /Tx /AA << >> /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj127 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 546.5441 615.13939 564.21091 627.47279 ] /P 7 0 R /F 4 /T (f3-16)/FT /Tx /AA << >> /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj128 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 482.33701 603.66522 544.67082 615.66531 ] /P 7 0 R /F 4 /T (f3-17)/FT /Tx /AA << >> /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj129 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 545.95723 602.85747 563.62404 615.19087 ] /P 7 0 R /F 4 /T (f3-18)/FT /Tx /AA << >> /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj130 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 194.00148 578.66504 286.33554 590.99846 ] /F 4 /P 7 0 R /T (f3-19)/FT /Tx /Q 1 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj131 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 482.0477 578.70163 544.49612 592.65695 ] /P 7 0 R /F 4 /AA << >> /Parent 483 0 R >> endobj132 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 546.5441 579.47304 564.21091 592.80644 ] /P 7 0 R /F 4 /AA << >> /Parent 484 0 R >> endobj133 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 481.46083 567.41971 544.90926 578.37503 ] /P 7 0 R /F 4 /AA << >> /Parent 485 0 R >> endobj134 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 545.95723 567.19112 563.62404 578.52452 ] /P 7 0 R /F 4 /AA << >> /Parent 486 0 R >> endobj135 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 482.3812 555.70163 544.82962 566.65695 ] /P 7 0 R /F 4 /AA << >> /Parent 487 0 R >> endobj136 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 545.87759 555.47304 564.5444 566.80644 ] /P 7 0 R /F 4 /AA << >> /Parent 488 0 R >> endobj137 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 481.79433 543.41971 544.24275 554.37503 ] /P 7 0 R /F 4 /AA << >> /Parent 477 0 R >> endobj138 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 546.29073 543.19112 564.95753 554.52452 ] /P 7 0 R /F 4 /AA << >> /Parent 478 0 R >> endobj139 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 481.3812 531.36789 544.82962 543.32321 ] /P 7 0 R /F 4 /AA << >> /Parent 479 0 R >> endobj140 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 545.87759 531.1393 564.5444 542.4727 ] /P 7 0 R /F 4 /AA << >> /Parent 480 0 R >> endobj141 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 481.79433 519.08597 544.24275 531.04129 ] /P 7 0 R /F 4 /AA << >> /Parent 481 0 R >> endobj142 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 546.29073 519.85738 564.95753 531.19078 ] /P 7 0 R /F 4 /AA << >> /Parent 482 0 R >> endobj143 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 482.46083 507.72656 544.90926 518.68188 ] /P 7 0 R /F 4 /AA << >> /Parent 489 0 R >> endobj144 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 545.95723 507.49797 564.62404 518.83138 ] /P 7 0 R /F 4 /AA << >> /Parent 490 0 R >> endobj145 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 482.0477 495.67474 544.49612 506.63007 ] /P 7 0 R /F 4 /AA << >> /Parent 491 0 R >> endobj146 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 546.5441 495.44615 564.21091 506.77956 ] /P 7 0 R /F 4 /AA << >> /Parent 492 0 R >> endobj147 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 482.46083 483.39282 544.90926 495.34814 ] /P 7 0 R /F 4 /AA << >> /Parent 493 0 R >> endobj148 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 545.95723 483.16423 563.62404 495.49763 ] /P 7 0 R /F 4 /AA << >> /Parent 494 0 R >> endobj149 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 482.04779 459.71434 544.49622 472.66966 ] /P 7 0 R /F 4 /AA << >> /Parent 497 0 R >> endobj150 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 546.54419 459.48575 563.211 472.81915 ] /P 7 0 R /F 4 /AA << >> /Parent 498 0 R >> endobj151 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 482.46092 447.43242 544.90935 459.38774 ] /P 7 0 R /F 4 /AA << >> /Parent 499 0 R >> endobj152 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 546.33751 447.3307 564.00432 459.66412 ] /P 7 0 R /F 4 /AA << >> /Parent 500 0 R >> endobj153 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 482.38129 434.71434 544.82971 447.66966 ] /P 7 0 R /F 4 /AA << >> /Parent 501 0 R >> endobj154 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 545.87769 435.48575 563.54449 447.81915 ] /P 7 0 R /F 4 /AA << >> /Parent 502 0 R >> endobj155 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 481.79442 423.43242 544.24284 434.38774 ] /P 7 0 R /F 4 /AA << >> /Parent 503 0 R >> endobj156 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 546.29082 423.20383 563.95763 434.53723 ] /P 7 0 R /F 4 /AA << >> /Parent 504 0 R >> endobj157 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 481.38129 411.3806 544.82971 422.33592 ] /P 7 0 R /F 4 /AA << >> /Parent 505 0 R >> endobj158 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 545.87769 411.15201 563.54449 422.48541 ] /P 7 0 R /F 4 /AA << >> /Parent 506 0 R >> endobj159 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 481.79442 399.09868 544.24284 411.054 ] /P 7 0 R /F 4 /AA << >> /Parent 507 0 R >> endobj160 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 546.00417 398.99699 564.00432 410.66376 ] /P 7 0 R /F 4 /AA << >> /Parent 508 0 R >> endobj161 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 482.46092 387.73927 544.90935 398.6946 ] /P 7 0 R /F 4 /AA << >> /Parent 509 0 R >> endobj162 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 546.33751 387.33025 564.00432 398.66367 ] /P 7 0 R /F 4 /AA << >> /Parent 510 0 R >> endobj163 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 482.04779 375.68745 544.49622 386.64278 ] /AA << >> /F 4 /P 7 0 R /Parent 511 0 R >> endobj164 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 546.54419 375.45886 564.211 386.79227 ] /AA << >> /F 4 /P 7 0 R /Parent 512 0 R >> endobj165 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 482.46092 363.40553 544.90935 375.36086 ] /AA << >> /F 4 /P 7 0 R /Parent 495 0 R >> endobj166 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 545.95732 363.17694 563.62413 374.51035 ] /AA << >> /F 4 /P 7 0 R /Parent 496 0 R >> endobj167 0 obj<< /Encoding 168 0 R /Font 170 0 R >> endobj168 0 obj<< /PDFDocEncoding 169 0 R >> endobj169 0 obj<< /Type /Encoding /Differences [ 24 /breve /caron /circumflex /dotaccent /hungarumlaut /ogonek /ring /tilde 39 /quotesingle 96 /grave 128 /bullet /dagger /daggerdbl /ellipsis /emdash /endash /florin /fraction /guilsinglleft /guilsinglright /minus /perthousand /quotedblbase /quotedblleft /quotedblright /quoteleft /quoteright /quotesinglbase /trademark /fi /fl /Lslash /OE /Scaron /Ydieresis /Zcaron /dotlessi /lslash /oe /scaron /zcaron 160 /Euro 164 /currency 166 /brokenbar 168 /dieresis /copyright /ordfeminine 172 /logicalnot /.notdef /registered /macron /degree /plusminus /twosuperior /threesuperior /acute /mu 183 /periodcentered /cedilla /onesuperior /ordmasculine 188 /onequarter /onehalf /threequarters 192 /Agrave /Aacute /Acircumflex /Atilde /Adieresis /Aring /AE /Ccedilla /Egrave /Eacute /Ecircumflex /Edieresis /Igrave /Iacute /Icircumflex /Idieresis /Eth /Ntilde /Ograve /Oacute /Ocircumflex /Otilde /Odieresis /multiply /Oslash /Ugrave /Uacute /Ucircumflex /Udieresis /Yacute /Thorn /germandbls /agrave /aacute /acircumflex /atilde /adieresis /aring /ae /ccedilla /egrave /eacute /ecircumflex /edieresis /igrave /iacute /icircumflex /idieresis /eth /ntilde /ograve /oacute /ocircumflex /otilde /odieresis /divide /oslash /ugrave /uacute /ucircumflex /udieresis /yacute /thorn /ydieresis ] >> endobj170 0 obj<< /Helv 171 0 R /HeBo 172 0 R /ZaDb 173 0 R >> endobj171 0 obj<< /Type /Font /Name /Helv /BaseFont /Helvetica /Subtype /Type1 /Encoding 169 0 R >> endobj172 0 obj<< /Type /Font /Name /HeBo /BaseFont /Helvetica-Bold /Subtype /Type1 /Encoding 169 0 R >> endobj173 0 obj<< /Type /Font /Name /ZaDb /BaseFont /ZapfDingbats /Subtype /Type1 >> endobj174 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 482.33701 351.32997 545.00415 362.66339 ] /P 7 0 R /F 4 /AA << >> /Parent 513 0 R >> endobj175 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 546.08424 351.33012 563.75105 362.66353 ] /P 7 0 R /F 4 /AA << >> /Parent 514 0 R >> endobj176 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 482.17322 339.96913 544.62164 350.92445 ] /P 7 0 R /F 4 /T (f3-58)/FT /Tx /AA << >> /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj177 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 545.66962 339.74054 563.33643 351.07394 ] /P 7 0 R /F 4 /T (f3-59)/FT /Tx /AA << >> /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj178 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 481.58635 327.68721 544.03477 338.64253 ] /P 7 0 R /F 4 /T (f3-60)/FT /Tx /AA << >> /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj179 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 546.46294 327.58549 563.12975 338.91891 ] /P 7 0 R /F 4 /T (f3-61)/FT /Tx /AA << >> /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj180 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 482.33702 315.66302 544.33749 327.66312 ] /P 7 0 R /F 4 /T (f3-62)/FT /Tx /AA << >> /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj181 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 546.00311 315.74054 563.66992 327.07394 ] /P 7 0 R /F 4 /T (f3-63)/FT /Tx /AA << >> /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj182 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 481.91985 303.68721 544.36827 315.64253 ] /P 7 0 R /F 4 /T (f3-64)/FT /Tx /AA << >> /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj183 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 546.41624 303.45862 564.08305 314.79202 ] /P 7 0 R /F 4 /T (f3-65)/FT /Tx /AA << >> /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj184 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 481.50671 290.63539 544.95514 303.59071 ] /P 7 0 R /F 4 /T (f3-66)/FT /Tx /AA << >> /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj185 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 546.00311 291.4068 563.66992 303.7402 ] /P 7 0 R /F 4 /T (f3-67)/FT /Tx /AA << >> /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj186 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 481.91985 279.35347 544.36827 290.30879 ] /P 7 0 R /F 4 /T (f3-68)/FT /Tx /AA << >> /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj187 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 546.12959 279.25179 564.12975 290.91855 ] /P 7 0 R /F 4 /T (f3-69)/FT /Tx /AA << >> /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj188 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 481.58635 266.99406 545.03477 278.94939 ] /P 7 0 R /F 4 /T (f3-70)/FT /Tx /AA << >> /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj189 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 546.46294 267.58504 563.12975 278.91846 ] /P 7 0 R /F 4 /T (f3-71)/FT /Tx /AA << >> /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj190 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 482.17322 254.94225 544.62164 266.89757 ] /P 7 0 R /F 4 /AA << >> /Parent 519 0 R >> endobj191 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 545.66962 255.71365 563.33643 267.04706 ] /P 7 0 R /F 4 /AA << >> /Parent 520 0 R >> endobj192 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 481.58635 243.66032 545.03477 254.61565 ] /P 7 0 R /F 4 /AA << >> /Parent 515 0 R >> endobj193 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 546.08275 243.43173 563.74956 254.76514 ] /P 7 0 R /F 4 /AA << >> /Parent 516 0 R >> endobj194 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 482.46243 231.58476 545.12958 242.91818 ] /P 7 0 R /F 4 /AA << >> /Parent 517 0 R >> endobj195 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 546.20967 231.58492 563.87648 242.91832 ] /P 7 0 R /F 4 /AA << >> /Parent 518 0 R >> endobj196 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 167.16602 218.35193 447.76611 231.29236 ] /F 4 /P 7 0 R /T (f3-78)/FT /Tx /Q 0 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj197 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 279.33548 206.99554 448.33675 218.66228 ] /F 4 /P 7 0 R /T (f3-79)/FT /Tx /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj198 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 481.58611 195.14749 545.03453 208.10281 ] /P 7 0 R /F 4 /T (f3-80)/FT /Tx /AA << >> /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj199 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 546.0825 195.9189 563.74931 208.2523 ] /P 7 0 R /F 4 /T (f3-81)/FT /Tx /AA << >> /Q 2 /DR 167 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj200 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 482.46219 184.07193 545.12933 195.40535 ] /P 7 0 R /F 4 /T (f3-82)/FT /Tx /AA << >> /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj201 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 546.20943 184.07208 563.87624 195.40549 ] /P 7 0 R /F 4 /T (f3-83)/FT /Tx /AA << >> /Q 2 /DR 167 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj202 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 229.33508 171.66193 238.33514 179.66197 ] /F 4 /P 7 0 R /T (c3-1)/FT /Btn /DA (/ZaDb 9 Tf 0 0 0.627 rg)/H /T /MK << /CA (4)/AC (��)/RC (��)>> /AS /Off /AP << /N << /Yes 411 0 R >> /D << /Yes 412 0 R /Off 413 0 R >> >> >> endobj203 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 265.33536 170.99525 272.33542 179.66199 ] /F 4 /P 7 0 R /T (c3-2)/FT /Btn /DA (/ZaDb 9 Tf 0 0 0.627 rg)/H /T /MK << /CA (4)/AC (��)/RC (��)>> /AS /Off /AP << /N << /Yes 414 0 R >> /D << /Yes 415 0 R /Off 416 0 R >> >> >> endobj204 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 482.17297 172.19669 544.6214 183.15201 ] /P 7 0 R /F 4 /T (f3-84)/FT /Tx /AA << >> /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj205 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 545.66937 171.96809 563.33618 183.3015 ] /P 7 0 R /F 4 /T (f3-85)/FT /Tx /AA << >> /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj206 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 481.58611 159.91476 545.03453 170.87009 ] /P 7 0 R /F 4 /T (f3-86)/FT /Tx /AA << >> /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj207 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 546.0825 159.68617 563.74931 171.01958 ] /P 7 0 R /F 4 /T (f3-87)/FT /Tx /AA << >> /Q 2 /DR 167 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj208 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 482.46219 147.8392 545.12933 159.17262 ] /P 7 0 R /F 4 /T (f3-88)/FT /Tx /AA << >> /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj209 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 546.20943 147.83936 563.87624 159.17276 ] /P 7 0 R /F 4 /T (f3-89)/FT /Tx /AA << >> /Q 2 /DR 167 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj210 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 251.33525 134.66167 399.33638 147.66174 ] /F 4 /P 7 0 R /T (f3-90)/FT /Tx /Q 0 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj211 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 482.2541 135.30164 544.70253 147.25696 ] /P 7 0 R /F 4 /T (f3-91)/FT /Tx /AA << >> /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj212 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 545.7505 135.07304 563.41731 147.40645 ] /P 7 0 R /F 4 /T (f3-92)/FT /Tx /AA << >> /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj213 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 481.66724 123.01971 545.11566 134.97504 ] /P 7 0 R /F 4 /T (f3-93)/FT /Tx /AA << >> /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj214 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 546.54382 122.918 563.21063 134.25142 ] /P 7 0 R /F 4 /T (f3-94)/FT /Tx /AA << >> /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj215 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 481.5876 111.30164 545.03603 122.25696 ] /P 7 0 R /F 4 /T (f3-95)/FT /Tx /AA << >> /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj216 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 546.084 111.07304 563.75081 122.40645 ] /P 7 0 R /F 4 /T (f3-96)/FT /Tx /AA << >> /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj217 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 482.00073 99.01971 544.44916 110.97504 ] /P 7 0 R /F 4 /T (f3-97)/FT /Tx /AA << >> /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj218 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 546.49713 99.79112 564.16394 111.12453 ] /P 7 0 R /F 4 /T (f3-98)/FT /Tx /AA << >> /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj219 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 481.5876 86.9679 545.03603 98.92322 ] /P 7 0 R /F 4 /T (f3-99)/FT /Tx /AA << >> /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj220 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 546.084 86.7393 564.75081 99.07271 ] /P 7 0 R /F 4 /T (f3-100)/FT /Tx /AA << >> /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj221 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 482.00073 75.68597 544.44916 86.6413 ] /P 7 0 R /F 4 /T (f3-101)/FT /Tx /AA << >> /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj222 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 546.21048 75.58429 564.21063 87.25105 ] /P 7 0 R /F 4 /T (f3-102)/FT /Tx /AA << >> /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj223 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 481.33702 710.9994 544.33748 724.66615 ] /F 4 /P 13 0 R /T (f4-1)/FT /Tx /Q 2 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj224 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 546.33752 711.66606 566.00433 724.99947 ] /F 4 /P 13 0 R /T (f4-2)/FT /Tx /Q 2 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj225 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 135.33438 675.66579 207.00157 686.66586 ] /F 4 /P 13 0 R /Parent 521 0 R >> endobj226 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 208.50235 675.83199 278.16954 686.83206 ] /P 13 0 R /F 4 /AA << >> /Parent 522 0 R >> endobj227 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 279.50235 675.83199 350.16954 686.83206 ] /P 13 0 R /F 4 /AA << >> /Parent 523 0 R >> endobj228 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 352.50235 675.33199 422.16954 687.33206 ] /P 13 0 R /F 4 /AA << >> /Parent 524 0 R >> endobj229 0 obj<< /Encoding 230 0 R /Font 232 0 R >> endobj230 0 obj<< /PDFDocEncoding 231 0 R >> endobj231 0 obj<< /Type /Encoding /Differences [ 24 /breve /caron /circumflex /dotaccent /hungarumlaut /ogonek /ring /tilde 39 /quotesingle 96 /grave 128 /bullet /dagger /daggerdbl /ellipsis /emdash /endash /florin /fraction /guilsinglleft /guilsinglright /minus /perthousand /quotedblbase /quotedblleft /quotedblright /quoteleft /quoteright /quotesinglbase /trademark /fi /fl /Lslash /OE /Scaron /Ydieresis /Zcaron /dotlessi /lslash /oe /scaron /zcaron 160 /Euro 164 /currency 166 /brokenbar 168 /dieresis /copyright /ordfeminine 172 /logicalnot /.notdef /registered /macron /degree /plusminus /twosuperior /threesuperior /acute /mu 183 /periodcentered /cedilla /onesuperior /ordmasculine 188 /onequarter /onehalf /threequarters 192 /Agrave /Aacute /Acircumflex /Atilde /Adieresis /Aring /AE /Ccedilla /Egrave /Eacute /Ecircumflex /Edieresis /Igrave /Iacute /Icircumflex /Idieresis /Eth /Ntilde /Ograve /Oacute /Ocircumflex /Otilde /Odieresis /multiply /Oslash /Ugrave /Uacute /Ucircumflex /Udieresis /Yacute /Thorn /germandbls /agrave /aacute /acircumflex /atilde /adieresis /aring /ae /ccedilla /egrave /eacute /ecircumflex /edieresis /igrave /iacute /icircumflex /idieresis /eth /ntilde /ograve /oacute /ocircumflex /otilde /odieresis /divide /oslash /ugrave /uacute /ucircumflex /udieresis /yacute /thorn /ydieresis ] >> endobj232 0 obj<< /Helv 233 0 R /HeBo 234 0 R /ZaDb 235 0 R >> endobj233 0 obj<< /Type /Font /Name /Helv /BaseFont /Helvetica /Subtype /Type1 /Encoding 231 0 R >> endobj234 0 obj<< /Type /Font /Name /HeBo /BaseFont /Helvetica-Bold /Subtype /Type1 /Encoding 231 0 R >> endobj235 0 obj<< /Type /Font /Name /ZaDb /BaseFont /ZapfDingbats /Subtype /Type1 >> endobj236 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 423.50235 675.33199 494.16954 687.33206 ] /P 13 0 R /F 4 /AA << >> /Parent 525 0 R >> endobj237 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 496.50235 675.33199 566.16954 687.33206 ] /P 13 0 R /F 4 /AA << >> /DA (/HeBo 9 Tf 0 0 0.627 rg)/Parent 526 0 R >> endobj238 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 135.75162 663.91579 206.41881 674.91586 ] /P 13 0 R /F 4 /T (f4-9)/FT /Tx /AA << >> /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj239 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 207.91959 663.08199 278.58678 675.08206 ] /P 13 0 R /F 4 /T (f4-10)/FT /Tx /AA << >> /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj240 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 279.91959 663.08199 350.58678 675.08206 ] /P 13 0 R /F 4 /T (f4-11)/FT /Tx /AA << >> /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj241 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 351.91959 663.58199 422.58678 674.58206 ] /P 13 0 R /F 4 /T (f4-12)/FT /Tx /AA << >> /Q 2 /DR 229 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj242 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 423.91959 663.58199 494.58678 674.58206 ] /P 13 0 R /F 4 /T (f4-13)/FT /Tx /AA << >> /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj243 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 495.91959 663.58199 566.58678 674.58206 ] /P 13 0 R /F 4 /T (f4-14)/FT /Tx /AA << >> /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj244 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 337.33592 615.66533 414.00313 627.66541 ] /F 4 /P 13 0 R /Parent 527 0 R >> endobj245 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 488.66908 615.83199 566.33629 626.83206 ] /P 13 0 R /F 4 /AA << >> /Parent 530 0 R >> endobj246 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 265.66908 603.49849 335.33629 615.49857 ] /P 13 0 R /F 4 /AA << >> /Parent 528 0 R >> endobj247 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 416.66908 603.49849 486.33629 615.49857 ] /P 13 0 R /F 4 /AA << >> /Parent 529 0 R >> endobj248 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 265.16908 591.49849 334.83629 603.49857 ] /P 13 0 R /F 4 /AA << >> /Parent 535 0 R >> endobj249 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 337.66908 591.49849 414.33629 603.49857 ] /P 13 0 R /F 4 /AA << >> /Parent 531 0 R >> endobj250 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 416.66908 591.49849 486.33629 603.49857 ] /P 13 0 R /F 4 /AA << >> /Parent 536 0 R >> endobj251 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 489.16908 591.99849 566.83629 602.99857 ] /P 13 0 R /F 4 /AA << >> /Parent 532 0 R >> endobj252 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 337.41908 579.49849 414.08629 591.49857 ] /P 13 0 R /F 4 /AA << >> /Parent 533 0 R >> endobj253 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 488.91908 578.99849 566.58629 590.99857 ] /P 13 0 R /F 4 /AA << >> /Parent 534 0 R >> endobj254 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 337.41908 567.49849 414.08629 578.49857 ] /P 13 0 R /F 4 /T (f4-25)/FT /Tx /AA << >> /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj255 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 488.91908 566.99849 566.58629 578.99857 ] /P 13 0 R /F 4 /T (f4-26)/FT /Tx /AA << >> /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj256 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 337.16908 555.49849 413.83629 566.49857 ] /P 13 0 R /F 4 /T (f4-27)/FT /Tx /AA << >> /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj257 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 488.66908 554.99849 566.33629 566.99857 ] /P 13 0 R /F 4 /T (f4-28)/FT /Tx /AA << >> /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj258 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 337.54408 543.49849 414.21129 554.49857 ] /P 13 0 R /F 4 /T (f4-29)/FT /Tx /AA << >> /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj259 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 489.04408 542.99849 566.71129 554.99857 ] /P 13 0 R /F 4 /T (f4-30)/FT /Tx /AA << >> /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj260 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 337.29408 531.49849 413.96129 542.49857 ] /P 13 0 R /F 4 /T (f4-31)/FT /Tx /AA << >> /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj261 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 488.79408 530.99849 566.46129 542.99857 ] /P 13 0 R /F 4 /T (f4-32)/FT /Tx /AA << >> /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj262 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 337.29408 519.49849 413.96129 530.49857 ] /P 13 0 R /F 4 /AA << >> /Parent 538 0 R >> endobj263 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 488.79408 518.99849 566.46129 530.99857 ] /P 13 0 R /F 4 /AA << >> /Parent 540 0 R >> endobj264 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 265.91908 507.49849 335.58629 518.49857 ] /P 13 0 R /F 4 /AA << >> /Parent 537 0 R >> endobj265 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 416.41908 507.49849 487.08629 518.49857 ] /P 13 0 R /F 4 /AA << >> /Parent 539 0 R >> endobj266 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 264.73158 495.24849 335.39879 507.24857 ] /P 13 0 R /F 4 /AA << >> /Parent 541 0 R >> endobj267 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 337.10658 495.24849 414.77379 507.24857 ] /P 13 0 R /F 4 /AA << >> /Parent 543 0 R >> endobj268 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 416.23158 495.24849 486.89879 507.24857 ] /P 13 0 R /F 4 /AA << >> /Parent 542 0 R >> endobj269 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 488.60658 495.74849 566.27379 506.74857 ] /P 13 0 R /F 4 /AA << >> /Parent 544 0 R >> endobj270 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 264.91908 483.99849 335.58629 494.99857 ] /P 13 0 R /F 4 /T (f4-41)/FT /Tx /AA << >> /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj271 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 416.41908 483.99849 487.08629 494.99857 ] /P 13 0 R /F 4 /T (f4-42)/FT /Tx /AA << >> /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj272 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 265.73158 471.91426 335.39879 482.91434 ] /P 13 0 R /F 4 /AA << >> /Parent 547 0 R >> endobj273 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 337.10658 471.91426 414.77379 482.91434 ] /P 13 0 R /F 4 /AA << >> /Parent 545 0 R >> endobj274 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 416.23158 471.91426 486.89879 482.91434 ] /P 13 0 R /F 4 /AA << >> /Parent 548 0 R >> endobj275 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 488.60658 471.41426 567.27379 483.41434 ] /P 13 0 R /F 4 /AA << >> /Parent 546 0 R >> endobj276 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 336.91908 459.66426 414.58629 471.66434 ] /P 13 0 R /F 4 /T (f4-47)/FT /Tx /AA << >> /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj277 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 488.41908 460.16426 567.08629 471.16434 ] /P 13 0 R /F 4 /T (f4-48)/FT /Tx /AA << >> /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj278 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 265.91908 447.66426 335.58629 459.66434 ] /P 13 0 R /F 4 /T (f4-49)/FT /Tx /AA << >> /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj279 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 416.41908 447.66426 487.08629 459.66434 ] /P 13 0 R /F 4 /T (f4-50)/FT /Tx /AA << >> /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj280 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 265.73158 434.66377 335.39879 447.66385 ] /P 13 0 R /F 4 /T (f4-51)/FT /Tx /AA << >> /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj281 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 337.10658 434.66377 414.77379 447.66385 ] /P 13 0 R /F 4 /AA << >> /Parent 549 0 R >> endobj282 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 416.23158 434.66377 486.89879 447.66385 ] /P 13 0 R /F 4 /T (f4-53)/FT /Tx /AA << >> /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj283 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 488.60658 435.16377 567.27379 447.16385 ] /P 13 0 R /F 4 /AA << >> /Parent 550 0 R >> endobj284 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 336.91908 423.41377 414.58629 434.41385 ] /P 13 0 R /F 4 /AA << >> /Parent 551 0 R >> endobj285 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 488.41908 422.91377 567.08629 434.91385 ] /P 13 0 R /F 4 /AA << >> /Parent 552 0 R >> endobj286 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 336.91908 411.41377 414.58629 422.41385 ] /P 13 0 R /F 4 /AA << >> /Parent 553 0 R >> endobj287 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 488.41908 410.91377 567.08629 422.91385 ] /P 13 0 R /F 4 /AA << >> /Parent 554 0 R >> endobj288 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 337.67958 387.28926 414.34679 399.28934 ] /P 13 0 R /F 4 /AA << >> /Parent 555 0 R >> endobj289 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 489.17958 387.78926 566.84679 398.78934 ] /P 13 0 R /F 4 /AA << >> /Parent 556 0 R >> endobj290 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 337.49208 375.03926 414.15929 387.03934 ] /P 13 0 R /F 4 /AA << >> /Parent 557 0 R >> endobj291 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 488.99208 375.53926 566.65929 386.53934 ] /P 13 0 R /F 4 /AA << >> /Parent 558 0 R >> endobj292 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 337.49208 363.03926 414.15929 375.03934 ] /P 13 0 R /F 4 /AA << >> /Parent 559 0 R >> endobj293 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 488.99208 363.53926 566.65929 374.53934 ] /P 13 0 R /F 4 /AA << >> /DA (/HeBo 9 Tf 0 0 0.627 rg)/Parent 560 0 R >> endobj294 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 337.17958 351.37129 413.84679 363.37137 ] /P 13 0 R /F 4 /T (f4-65)/FT /Tx /AA << >> /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj295 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 488.67958 351.87129 566.34679 362.87137 ] /P 13 0 R /F 4 /T (f4-66)/FT /Tx /AA << >> /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj296 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 336.99208 340.12129 414.65929 351.12137 ] /P 13 0 R /F 4 /T (f4-67)/FT /Tx /AA << >> /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj297 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 488.49208 339.62129 566.15929 350.62137 ] /P 13 0 R /F 4 /T (f4-68)/FT /Tx /AA << >> /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj298 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 336.99208 328.12129 414.65929 339.12137 ] /P 13 0 R /F 4 /T (f4-69)/FT /Tx /AA << >> /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj299 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 488.49208 327.62129 566.15929 339.62137 ] /P 13 0 R /F 4 /T (f4-70)/FT /Tx /AA << >> /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj300 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 337.58583 316.24629 415.25304 327.24637 ] /P 13 0 R /F 4 /T (f4-71)/FT /Tx /AA << >> /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj301 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 489.08583 315.74629 566.75304 326.74637 ] /P 13 0 R /F 4 /T (f4-72)/FT /Tx /AA << >> /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj302 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 337.58583 304.24629 415.25304 315.24637 ] /P 13 0 R /F 4 /T (f4-73)/FT /Tx /AA << >> /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj303 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 489.08583 303.74629 566.75304 315.74637 ] /P 13 0 R /F 4 /T (f4-74)/FT /Tx /AA << >> /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj304 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 236.00182 266.996 300.00227 278.66275 ] /F 4 /P 13 0 R /Parent 561 0 R >> endobj305 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 143.33443 230.99573 229.33511 243.9958 ] /F 4 /P 13 0 R /T (f4-76)/FT /Tx /Q 0 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj306 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 236.00197 231.49525 300.00243 245.162 ] /P 13 0 R /F 4 /T (f4-77)/FT /Tx /AA << >> /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj307 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 236.00197 207.49525 300.00243 221.162 ] /P 13 0 R /F 4 /T (f4-78)/FT /Tx /AA << >> /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj308 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 125.00096 158.99518 227.33511 171.66193 ] /F 4 /P 13 0 R /T (f4-79)/FT /Tx /Q 2 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj309 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 173.00136 146.99507 229.33508 159.66182 ] /F 4 /P 13 0 R /T (f4-80)/FT /Tx /Q 2 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj310 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 67.16492 134.53009 229.10699 147.2168 ] /F 4 /P 13 0 R /T (f4-81)/FT /Tx /Q 0 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj311 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 236.33516 134.66167 300.33562 148.66174 ] /F 4 /P 13 0 R /Parent 562 0 R >> endobj312 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 236.00197 123.49513 300.00243 134.49521 ] /P 13 0 R /F 4 /T (f4-83)/FT /Tx /AA << >> /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj313 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 236.00197 99.49513 300.00243 110.49521 ] /P 13 0 R /F 4 /T (f4-84)/FT /Tx /AA << >> /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj314 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 236.00197 87.49513 300.00243 98.49521 ] /P 13 0 R /F 4 /T (f4-85)/FT /Tx /AA << >> /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj315 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 236.00197 75.49513 300.00243 86.49521 ] /P 13 0 R /F 4 /AA << >> /Parent 563 0 R >> endobj316 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 170.33463 62.6611 231.33513 75.99452 ] /F 4 /P 13 0 R /DR 746 0 R /Q 0 /T (f4-87)/FT /Tx /AA << >> /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj317 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 67.0005 50.66101 233.3351 62.6611 ] /F 4 /P 13 0 R /T (f4-88)/FT /Tx /Q 0 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj318 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 236.00197 51.49513 300.00243 64.49521 ] /P 13 0 R /F 4 /T (f4-89)/FT /Tx /AA << >> /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj319 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 236.00197 39.49513 300.00243 51.49521 ] /P 13 0 R /F 4 /T (f4-90)/FT /Tx /AA << >> /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj320 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 414.3365 242.99582 492.3371 254.66257 ] /F 4 /P 13 0 R /T (f4-91)/FT /Tx /Q 2 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj321 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 324.33582 230.66238 492.3371 242.66248 ] /F 4 /P 13 0 R /T (f4-92)/FT /Tx /Q 0 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj322 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 503.33719 231.6624 567.33768 244.99582 ] /F 4 /P 13 0 R /Parent 565 0 R >> endobj323 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 386.33629 182.66202 492.3371 194.66211 ] /F 4 /P 13 0 R /T (f4-94)/FT /Tx /Q 2 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj324 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 324.33582 170.99527 494.3371 182.66202 ] /F 4 /P 13 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)/Q 0 /Parent 564 0 R >> endobj325 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 324.66881 159.16179 494.67009 170.82854 ] /P 13 0 R /F 4 /T (f4-96)/FT /Tx /AA << >> /Q 0 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj326 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 502.6692 159.82846 566.66969 173.16188 ] /P 13 0 R /F 4 /T (f4-97)/FT /Tx /AA << >> /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj327 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 502.6692 147.82846 566.66969 159.16188 ] /P 13 0 R /F 4 /T (f4-98)/FT /Tx /AA << >> /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj328 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 502.6692 122.82846 566.66969 136.16188 ] /P 13 0 R /F 4 /T (f4-99)/FT /Tx /AA << >> /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj329 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 502.6692 99.82846 566.66969 111.16188 ] /P 13 0 R /F 4 /T (f4-100)/FT /Tx /AA << >> /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj330 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 502.6692 87.82846 566.66969 99.16188 ] /P 13 0 R /F 4 /AA << >> /Parent 566 0 R >> endobj331 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 432.33662 74.66119 494.33711 87.99461 ] /F 4 /P 13 0 R /T (f4-102)/FT /Tx /Q 0 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj332 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 324.3358 62.99445 494.3371 75.66119 ] /F 4 /P 13 0 R /T (f4-103)/FT /Tx /Q 0 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj333 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 502.6692 63.82846 566.66969 77.16188 ] /P 13 0 R /F 4 /T (f4-104)/FT /Tx /AA << >> /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj334 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 502.6692 51.82846 566.66969 63.16188 ] /P 13 0 R /F 4 /T (f4-105)/FT /Tx /AA << >> /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj335 0 obj<< /Type /Annot /Subtype /Widget /Rect [ 502.6692 39.82846 566.66969 51.16188 ] /P 13 0 R /F 4 /T (f4-106)/FT /Tx /AA << >> /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj336 0 obj<< /Length 90 /Subtype /Form /BBox [ 0 0 8.20905 8.71649 ] /Resources << /ProcSet [ /PDF /Text ] /Font << /ZaDb 604 0 R >> >> >> stream
q 1 1 6.209 6.7165 re W n BT /ZaDb 9 Tf 0 0 0.627 rg  1 0 0 1 0.2976 1.1228 Tm (4) Tj ET Qendstreamendobj337 0 obj<< /Length 118 /Subtype /Form /BBox [ 0 0 8.20905 8.71649 ] /Resources << /ProcSet [ /PDF /Text ] /Font << /ZaDb 604 0 R >> >> >> stream
0.749 g 0 0 8.209 8.7165 re f q 1 1 6.209 6.7165 re W n BT /ZaDb 9 Tf 0 0 0.627 rg  1 0 0 1 0.2976 1.1228 Tm (4) Tj ETendstreamendobj338 0 obj<< /Length 29 /Subtype /Form /BBox [ 0 0 8.20905 8.71649 ] /Resources << /ProcSet [ /PDF ] >> >> stream
0.749 g 0 0 8.209 8.7165 re fendstreamendobj339 0 obj<< /Length 91 /Subtype /Form /BBox [ 0 0 7.20905 7.71649 ] /Resources << /ProcSet [ /PDF /Text ] /Font << /ZaDb 604 0 R >> >> >> stream
q 1 1 5.209 5.7165 re W n BT /ZaDb 9 Tf 0 0 0.627 rg  1 0 0 1 -0.2024 0.6228 Tm (4) Tj ET Qendstreamendobj340 0 obj<< /Length 119 /Subtype /Form /BBox [ 0 0 7.20905 7.71649 ] /Resources << /ProcSet [ /PDF /Text ] /Font << /ZaDb 604 0 R >> >> >> stream
0.749 g 0 0 7.209 7.7165 re f q 1 1 5.209 5.7165 re W n BT /ZaDb 9 Tf 0 0 0.627 rg  1 0 0 1 -0.2024 0.6228 Tm (4) Tj ETendstreamendobj341 0 obj<< /Length 29 /Subtype /Form /BBox [ 0 0 7.20905 7.71649 ] /Resources << /ProcSet [ /PDF ] >> >> stream
0.749 g 0 0 7.209 7.7165 re fendstreamendobj342 0 obj<< /Length 91 /Subtype /Form /BBox [ 0 0 7.20905 7.71649 ] /Resources << /ProcSet [ /PDF /Text ] /Font << /ZaDb 604 0 R >> >> >> stream
q 1 1 5.209 5.7165 re W n BT /ZaDb 9 Tf 0 0 0.627 rg  1 0 0 1 -0.2024 0.6228 Tm (4) Tj ET Qendstreamendobj343 0 obj<< /Length 119 /Subtype /Form /BBox [ 0 0 7.20905 7.71649 ] /Resources << /ProcSet [ /PDF /Text ] /Font << /ZaDb 604 0 R >> >> >> stream
0.749 g 0 0 7.209 7.7165 re f q 1 1 5.209 5.7165 re W n BT /ZaDb 9 Tf 0 0 0.627 rg  1 0 0 1 -0.2024 0.6228 Tm (4) Tj ETendstreamendobj344 0 obj<< /Length 29 /Subtype /Form /BBox [ 0 0 7.20905 7.71649 ] /Resources << /ProcSet [ /PDF ] >> >> stream
0.749 g 0 0 7.209 7.7165 re fendstreamendobj345 0 obj<< /Length 90 /Subtype /Form /BBox [ 0 0 8.20905 8.71649 ] /Resources << /ProcSet [ /PDF /Text ] /Font << /ZaDb 604 0 R >> >> >> stream
q 1 1 6.209 6.7165 re W n BT /ZaDb 9 Tf 0 0 0.627 rg  1 0 0 1 0.2976 1.1228 Tm (4) Tj ET Qendstreamendobj346 0 obj<< /Length 118 /Subtype /Form /BBox [ 0 0 8.20905 8.71649 ] /Resources << /ProcSet [ /PDF /Text ] /Font << /ZaDb 604 0 R >> >> >> stream
0.749 g 0 0 8.209 8.7165 re f q 1 1 6.209 6.7165 re W n BT /ZaDb 9 Tf 0 0 0.627 rg  1 0 0 1 0.2976 1.1228 Tm (4) Tj ETendstreamendobj347 0 obj<< /Length 29 /Subtype /Form /BBox [ 0 0 8.20905 8.71649 ] /Resources << /ProcSet [ /PDF ] >> >> stream
0.749 g 0 0 8.209 8.7165 re fendstreamendobj348 0 obj<< /Length 90 /Subtype /Form /BBox [ 0 0 8.20905 8.71649 ] /Resources << /ProcSet [ /PDF /Text ] /Font << /ZaDb 604 0 R >> >> >> stream
q 1 1 6.209 6.7165 re W n BT /ZaDb 9 Tf 0 0 0.627 rg  1 0 0 1 0.2976 1.1228 Tm (4) Tj ET Qendstreamendobj349 0 obj<< /Length 118 /Subtype /Form /BBox [ 0 0 8.20905 8.71649 ] /Resources << /ProcSet [ /PDF /Text ] /Font << /ZaDb 604 0 R >> >> >> stream
0.749 g 0 0 8.209 8.7165 re f q 1 1 6.209 6.7165 re W n BT /ZaDb 9 Tf 0 0 0.627 rg  1 0 0 1 0.2976 1.1228 Tm (4) Tj ETendstreamendobj350 0 obj<< /Length 29 /Subtype /Form /BBox [ 0 0 8.20905 8.71649 ] /Resources << /ProcSet [ /PDF ] >> >> stream
0.749 g 0 0 8.209 8.7165 re fendstreamendobj351 0 obj<< /Length 90 /Subtype /Form /BBox [ 0 0 8.20905 7.71649 ] /Resources << /ProcSet [ /PDF /Text ] /Font << /ZaDb 604 0 R >> >> >> stream
q 1 1 6.209 5.7165 re W n BT /ZaDb 9 Tf 0 0 0.627 rg  1 0 0 1 0.2976 0.6228 Tm (4) Tj ET Qendstreamendobj352 0 obj<< /Length 118 /Subtype /Form /BBox [ 0 0 8.20905 7.71649 ] /Resources << /ProcSet [ /PDF /Text ] /Font << /ZaDb 604 0 R >> >> >> stream
0.749 g 0 0 8.209 7.7165 re f q 1 1 6.209 5.7165 re W n BT /ZaDb 9 Tf 0 0 0.627 rg  1 0 0 1 0.2976 0.6228 Tm (4) Tj ETendstreamendobj353 0 obj<< /Length 29 /Subtype /Form /BBox [ 0 0 8.20905 7.71649 ] /Resources << /ProcSet [ /PDF ] >> >> stream
0.749 g 0 0 8.209 7.7165 re fendstreamendobj354 0 obj<< /Length 91 /Subtype /Form /BBox [ 0 0 7.20905 7.71649 ] /Resources << /ProcSet [ /PDF /Text ] /Font << /ZaDb 604 0 R >> >> >> stream
q 1 1 5.209 5.7165 re W n BT /ZaDb 9 Tf 0 0 0.627 rg  1 0 0 1 -0.2024 0.6228 Tm (4) Tj ET Qendstreamendobj355 0 obj<< /Length 119 /Subtype /Form /BBox [ 0 0 7.20905 7.71649 ] /Resources << /ProcSet [ /PDF /Text ] /Font << /ZaDb 604 0 R >> >> >> stream
0.749 g 0 0 7.209 7.7165 re f q 1 1 5.209 5.7165 re W n BT /ZaDb 9 Tf 0 0 0.627 rg  1 0 0 1 -0.2024 0.6228 Tm (4) Tj ETendstreamendobj356 0 obj<< /Length 29 /Subtype /Form /BBox [ 0 0 7.20905 7.71649 ] /Resources << /ProcSet [ /PDF ] >> >> stream
0.749 g 0 0 7.209 7.7165 re fendstreamendobj357 0 obj<< /Length 90 /Subtype /Form /BBox [ 0 0 8.20905 8.71649 ] /Resources << /ProcSet [ /PDF /Text ] /Font << /ZaDb 604 0 R >> >> >> stream
q 1 1 6.209 6.7165 re W n BT /ZaDb 9 Tf 0 0 0.627 rg  1 0 0 1 0.2976 1.1228 Tm (4) Tj ET Qendstreamendobj358 0 obj<< /Length 118 /Subtype /Form /BBox [ 0 0 8.20905 8.71649 ] /Resources << /ProcSet [ /PDF /Text ] /Font << /ZaDb 604 0 R >> >> >> stream
0.749 g 0 0 8.209 8.7165 re f q 1 1 6.209 6.7165 re W n BT /ZaDb 9 Tf 0 0 0.627 rg  1 0 0 1 0.2976 1.1228 Tm (4) Tj ETendstreamendobj359 0 obj<< /Length 29 /Subtype /Form /BBox [ 0 0 8.20905 8.71649 ] /Resources << /ProcSet [ /PDF ] >> >> stream
0.749 g 0 0 8.209 8.7165 re fendstreamendobj360 0 obj<< /Length 90 /Subtype /Form /BBox [ 0 0 9.20905 8.71649 ] /Resources << /ProcSet [ /PDF /Text ] /Font << /ZaDb 604 0 R >> >> >> stream
q 1 1 7.209 6.7165 re W n BT /ZaDb 9 Tf 0 0 0.627 rg  1 0 0 1 0.7976 1.1228 Tm (4) Tj ET Qendstreamendobj361 0 obj<< /Length 118 /Subtype /Form /BBox [ 0 0 9.20905 8.71649 ] /Resources << /ProcSet [ /PDF /Text ] /Font << /ZaDb 604 0 R >> >> >> stream
0.749 g 0 0 9.209 8.7165 re f q 1 1 7.209 6.7165 re W n BT /ZaDb 9 Tf 0 0 0.627 rg  1 0 0 1 0.7976 1.1228 Tm (4) Tj ETendstreamendobj362 0 obj<< /Length 29 /Subtype /Form /BBox [ 0 0 9.20905 8.71649 ] /Resources << /ProcSet [ /PDF ] >> >> stream
0.749 g 0 0 9.209 8.7165 re fendstreamendobj363 0 obj<< /Length 92 /Subtype /Form /BBox [ 0 0 21.91064 10.95532 ] /Resources << /ProcSet [ /PDF /Text ] /Font << /ZaDb 604 0 R >> >> >> stream
q 1 1 19.9106 8.9553 re W n BT /ZaDb 9 Tf 0 0 0.627 rg  1 0 0 1 7.1483 2.2422 Tm (4) Tj ET Qendstreamendobj364 0 obj<< /Length 123 /Subtype /Form /BBox [ 0 0 21.91064 10.95532 ] /Resources << /ProcSet [ /PDF /Text ] /Font << /ZaDb 604 0 R >> >> >> stream
0.749 g 0 0 21.9106 10.9553 re f q 1 1 19.9106 8.9553 re W n BT /ZaDb 9 Tf 0 0 0.627 rg  1 0 0 1 7.1483 2.2422 Tm (4) Tj ETendstreamendobj365 0 obj<< /Length 32 /Subtype /Form /BBox [ 0 0 21.91064 10.95532 ] /Resources << /ProcSet [ /PDF ] >> >> stream
0.749 g 0 0 21.9106 10.9553 re fendstreamendobj366 0 obj<< /Length 92 /Subtype /Form /BBox [ 0 0 22.14948 11.44788 ] /Resources << /ProcSet [ /PDF /Text ] /Font << /ZaDb 604 0 R >> >> >> stream
q 1 1 20.1495 9.4479 re W n BT /ZaDb 9 Tf 0 0 0.627 rg  1 0 0 1 7.2678 2.4885 Tm (4) Tj ET Qendstreamendobj367 0 obj<< /Length 123 /Subtype /Form /BBox [ 0 0 22.14948 11.44788 ] /Resources << /ProcSet [ /PDF /Text ] /Font << /ZaDb 604 0 R >> >> >> stream
0.749 g 0 0 22.1495 11.4479 re f q 1 1 20.1495 9.4479 re W n BT /ZaDb 9 Tf 0 0 0.627 rg  1 0 0 1 7.2678 2.4885 Tm (4) Tj ETendstreamendobj368 0 obj<< /Length 32 /Subtype /Form /BBox [ 0 0 22.14948 11.44788 ] /Resources << /ProcSet [ /PDF ] >> >> stream
0.749 g 0 0 22.1495 11.4479 re fendstreamendobj369 0 obj<< /Length 92 /Subtype /Form /BBox [ 0 0 22.14948 11.44788 ] /Resources << /ProcSet [ /PDF /Text ] /Font << /ZaDb 604 0 R >> >> >> stream
q 1 1 20.1495 9.4479 re W n BT /ZaDb 9 Tf 0 0 0.627 rg  1 0 0 1 7.2678 2.4885 Tm (4) Tj ET Qendstreamendobj370 0 obj<< /Length 123 /Subtype /Form /BBox [ 0 0 22.14948 11.44788 ] /Resources << /ProcSet [ /PDF /Text ] /Font << /ZaDb 604 0 R >> >> >> stream
0.749 g 0 0 22.1495 11.4479 re f q 1 1 20.1495 9.4479 re W n BT /ZaDb 9 Tf 0 0 0.627 rg  1 0 0 1 7.2678 2.4885 Tm (4) Tj ETendstreamendobj371 0 obj<< /Length 32 /Subtype /Form /BBox [ 0 0 22.14948 11.44788 ] /Resources << /ProcSet [ /PDF ] >> >> stream
0.749 g 0 0 22.1495 11.4479 re fendstreamendobj372 0 obj<< /Length 93 /Subtype /Form /BBox [ 0 0 20.91064 22.95532 ] /Resources << /ProcSet [ /PDF /Text ] /Font << /ZaDb 604 0 R >> >> >> stream
q 1 1 18.9106 20.9553 re W n BT /ZaDb 9 Tf 0 0 0.627 rg  1 0 0 1 6.6483 8.2422 Tm (4) Tj ET Qendstreamendobj373 0 obj<< /Length 124 /Subtype /Form /BBox [ 0 0 20.91064 22.95532 ] /Resources << /ProcSet [ /PDF /Text ] /Font << /ZaDb 604 0 R >> >> >> stream
0.749 g 0 0 20.9106 22.9553 re f q 1 1 18.9106 20.9553 re W n BT /ZaDb 9 Tf 0 0 0.627 rg  1 0 0 1 6.6483 8.2422 Tm (4) Tj ETendstreamendobj374 0 obj<< /Length 32 /Subtype /Form /BBox [ 0 0 20.91064 22.95532 ] /Resources << /ProcSet [ /PDF ] >> >> stream
0.749 g 0 0 20.9106 22.9553 re fendstreamendobj375 0 obj<< /Length 93 /Subtype /Form /BBox [ 0 0 21.14948 23.44788 ] /Resources << /ProcSet [ /PDF /Text ] /Font << /ZaDb 604 0 R >> >> >> stream
q 1 1 19.1495 21.4479 re W n BT /ZaDb 9 Tf 0 0 0.627 rg  1 0 0 1 6.7678 8.4885 Tm (4) Tj ET Qendstreamendobj376 0 obj<< /Length 124 /Subtype /Form /BBox [ 0 0 21.14948 23.44788 ] /Resources << /ProcSet [ /PDF /Text ] /Font << /ZaDb 604 0 R >> >> >> stream
0.749 g 0 0 21.1495 23.4479 re f q 1 1 19.1495 21.4479 re W n BT /ZaDb 9 Tf 0 0 0.627 rg  1 0 0 1 6.7678 8.4885 Tm (4) Tj ETendstreamendobj377 0 obj<< /Length 32 /Subtype /Form /BBox [ 0 0 21.14948 23.44788 ] /Resources << /ProcSet [ /PDF ] >> >> stream
0.749 g 0 0 21.1495 23.4479 re fendstreamendobj378 0 obj<< /Length 92 /Subtype /Form /BBox [ 0 0 20.91064 10.95532 ] /Resources << /ProcSet [ /PDF /Text ] /Font << /ZaDb 604 0 R >> >> >> stream
q 1 1 18.9106 8.9553 re W n BT /ZaDb 9 Tf 0 0 0.627 rg  1 0 0 1 6.6483 2.2422 Tm (4) Tj ET Qendstreamendobj379 0 obj<< /Length 123 /Subtype /Form /BBox [ 0 0 20.91064 10.95532 ] /Resources << /ProcSet [ /PDF /Text ] /Font << /ZaDb 604 0 R >> >> >> stream
0.749 g 0 0 20.9106 10.9553 re f q 1 1 18.9106 8.9553 re W n BT /ZaDb 9 Tf 0 0 0.627 rg  1 0 0 1 6.6483 2.2422 Tm (4) Tj ETendstreamendobj380 0 obj<< /Length 32 /Subtype /Form /BBox [ 0 0 20.91064 10.95532 ] /Resources << /ProcSet [ /PDF ] >> >> stream
0.749 g 0 0 20.9106 10.9553 re fendstreamendobj381 0 obj<< /Length 92 /Subtype /Form /BBox [ 0 0 22.14948 11.44788 ] /Resources << /ProcSet [ /PDF /Text ] /Font << /ZaDb 604 0 R >> >> >> stream
q 1 1 20.1495 9.4479 re W n BT /ZaDb 9 Tf 0 0 0.627 rg  1 0 0 1 7.2678 2.4885 Tm (4) Tj ET Qendstreamendobj382 0 obj<< /Length 123 /Subtype /Form /BBox [ 0 0 22.14948 11.44788 ] /Resources << /ProcSet [ /PDF /Text ] /Font << /ZaDb 604 0 R >> >> >> stream
0.749 g 0 0 22.1495 11.4479 re f q 1 1 20.1495 9.4479 re W n BT /ZaDb 9 Tf 0 0 0.627 rg  1 0 0 1 7.2678 2.4885 Tm (4) Tj ETendstreamendobj383 0 obj<< /Length 32 /Subtype /Form /BBox [ 0 0 22.14948 11.44788 ] /Resources << /ProcSet [ /PDF ] >> >> stream
0.749 g 0 0 22.1495 11.4479 re fendstreamendobj384 0 obj<< /Length 92 /Subtype /Form /BBox [ 0 0 22.14948 11.44788 ] /Resources << /ProcSet [ /PDF /Text ] /Font << /ZaDb 604 0 R >> >> >> stream
q 1 1 20.1495 9.4479 re W n BT /ZaDb 9 Tf 0 0 0.627 rg  1 0 0 1 7.2678 2.4885 Tm (4) Tj ET Qendstreamendobj385 0 obj<< /Length 123 /Subtype /Form /BBox [ 0 0 22.14948 11.44788 ] /Resources << /ProcSet [ /PDF /Text ] /Font << /ZaDb 604 0 R >> >> >> stream
0.749 g 0 0 22.1495 11.4479 re f q 1 1 20.1495 9.4479 re W n BT /ZaDb 9 Tf 0 0 0.627 rg  1 0 0 1 7.2678 2.4885 Tm (4) Tj ETendstreamendobj386 0 obj<< /Length 32 /Subtype /Form /BBox [ 0 0 22.14948 11.44788 ] /Resources << /ProcSet [ /PDF ] >> >> stream
0.749 g 0 0 22.1495 11.4479 re fendstreamendobj387 0 obj<< /Length 93 /Subtype /Form /BBox [ 0 0 22.14948 12.44788 ] /Resources << /ProcSet [ /PDF /Text ] /Font << /ZaDb 604 0 R >> >> >> stream
q 1 1 20.1495 10.4479 re W n BT /ZaDb 9 Tf 0 0 0.627 rg  1 0 0 1 7.2678 2.9885 Tm (4) Tj ET Qendstreamendobj388 0 obj<< /Length 124 /Subtype /Form /BBox [ 0 0 22.14948 12.44788 ] /Resources << /ProcSet [ /PDF /Text ] /Font << /ZaDb 604 0 R >> >> >> stream
0.749 g 0 0 22.1495 12.4479 re f q 1 1 20.1495 10.4479 re W n BT /ZaDb 9 Tf 0 0 0.627 rg  1 0 0 1 7.2678 2.9885 Tm (4) Tj ETendstreamendobj389 0 obj<< /Length 32 /Subtype /Form /BBox [ 0 0 22.14948 12.44788 ] /Resources << /ProcSet [ /PDF ] >> >> stream
0.749 g 0 0 22.1495 12.4479 re fendstreamendobj390 0 obj<< /Length 92 /Subtype /Form /BBox [ 0 0 22.14948 11.44788 ] /Resources << /ProcSet [ /PDF /Text ] /Font << /ZaDb 604 0 R >> >> >> stream
q 1 1 20.1495 9.4479 re W n BT /ZaDb 9 Tf 0 0 0.627 rg  1 0 0 1 7.2678 2.4885 Tm (4) Tj ET Qendstreamendobj391 0 obj<< /Length 123 /Subtype /Form /BBox [ 0 0 22.14948 11.44788 ] /Resources << /ProcSet [ /PDF /Text ] /Font << /ZaDb 604 0 R >> >> >> stream
0.749 g 0 0 22.1495 11.4479 re f q 1 1 20.1495 9.4479 re W n BT /ZaDb 9 Tf 0 0 0.627 rg  1 0 0 1 7.2678 2.4885 Tm (4) Tj ETendstreamendobj392 0 obj<< /Length 32 /Subtype /Form /BBox [ 0 0 22.14948 11.44788 ] /Resources << /ProcSet [ /PDF ] >> >> stream
0.749 g 0 0 22.1495 11.4479 re fendstreamendobj393 0 obj<< /Length 93 /Subtype /Form /BBox [ 0 0 20.91064 15.95532 ] /Resources << /ProcSet [ /PDF /Text ] /Font << /ZaDb 604 0 R >> >> >> stream
q 1 1 18.9106 13.9553 re W n BT /ZaDb 9 Tf 0 0 0.627 rg  1 0 0 1 6.6483 4.7422 Tm (4) Tj ET Qendstreamendobj394 0 obj<< /Length 124 /Subtype /Form /BBox [ 0 0 20.91064 15.95532 ] /Resources << /ProcSet [ /PDF /Text ] /Font << /ZaDb 604 0 R >> >> >> stream
0.749 g 0 0 20.9106 15.9553 re f q 1 1 18.9106 13.9553 re W n BT /ZaDb 9 Tf 0 0 0.627 rg  1 0 0 1 6.6483 4.7422 Tm (4) Tj ETendstreamendobj395 0 obj<< /Length 32 /Subtype /Form /BBox [ 0 0 20.91064 15.95532 ] /Resources << /ProcSet [ /PDF ] >> >> stream
0.749 g 0 0 20.9106 15.9553 re fendstreamendobj396 0 obj<< /Length 93 /Subtype /Form /BBox [ 0 0 22.14948 15.44788 ] /Resources << /ProcSet [ /PDF /Text ] /Font << /ZaDb 604 0 R >> >> >> stream
q 1 1 20.1495 13.4479 re W n BT /ZaDb 9 Tf 0 0 0.627 rg  1 0 0 1 7.2678 4.4885 Tm (4) Tj ET Qendstreamendobj397 0 obj<< /Length 124 /Subtype /Form /BBox [ 0 0 22.14948 15.44788 ] /Resources << /ProcSet [ /PDF /Text ] /Font << /ZaDb 604 0 R >> >> >> stream
0.749 g 0 0 22.1495 15.4479 re f q 1 1 20.1495 13.4479 re W n BT /ZaDb 9 Tf 0 0 0.627 rg  1 0 0 1 7.2678 4.4885 Tm (4) Tj ETendstreamendobj398 0 obj<< /Length 32 /Subtype /Form /BBox [ 0 0 22.14948 15.44788 ] /Resources << /ProcSet [ /PDF ] >> >> stream
0.749 g 0 0 22.1495 15.4479 re fendstreamendobj399 0 obj<< /Length 93 /Subtype /Form /BBox [ 0 0 20.91064 22.95532 ] /Resources << /ProcSet [ /PDF /Text ] /Font << /ZaDb 604 0 R >> >> >> stream
q 1 1 18.9106 20.9553 re W n BT /ZaDb 9 Tf 0 0 0.627 rg  1 0 0 1 6.6483 8.2422 Tm (4) Tj ET Qendstreamendobj400 0 obj<< /Length 124 /Subtype /Form /BBox [ 0 0 20.91064 22.95532 ] /Resources << /ProcSet [ /PDF /Text ] /Font << /ZaDb 604 0 R >> >> >> stream
0.749 g 0 0 20.9106 22.9553 re f q 1 1 18.9106 20.9553 re W n BT /ZaDb 9 Tf 0 0 0.627 rg  1 0 0 1 6.6483 8.2422 Tm (4) Tj ETendstreamendobj401 0 obj<< /Length 32 /Subtype /Form /BBox [ 0 0 20.91064 22.95532 ] /Resources << /ProcSet [ /PDF ] >> >> stream
0.749 g 0 0 20.9106 22.9553 re fendstreamendobj402 0 obj<< /Length 93 /Subtype /Form /BBox [ 0 0 22.14948 23.44788 ] /Resources << /ProcSet [ /PDF /Text ] /Font << /ZaDb 604 0 R >> >> >> stream
q 1 1 20.1495 21.4479 re W n BT /ZaDb 9 Tf 0 0 0.627 rg  1 0 0 1 7.2678 8.4885 Tm (4) Tj ET Qendstreamendobj403 0 obj<< /Length 124 /Subtype /Form /BBox [ 0 0 22.14948 23.44788 ] /Resources << /ProcSet [ /PDF /Text ] /Font << /ZaDb 604 0 R >> >> >> stream
0.749 g 0 0 22.1495 23.4479 re f q 1 1 20.1495 21.4479 re W n BT /ZaDb 9 Tf 0 0 0.627 rg  1 0 0 1 7.2678 8.4885 Tm (4) Tj ETendstreamendobj404 0 obj<< /Length 32 /Subtype /Form /BBox [ 0 0 22.14948 23.44788 ] /Resources << /ProcSet [ /PDF ] >> >> stream
0.749 g 0 0 22.1495 23.4479 re fendstreamendobj405 0 obj<< /Length 94 /Subtype /Form /BBox [ 0 0 20.91064 34.95532 ] /Resources << /ProcSet [ /PDF /Text ] /Font << /ZaDb 604 0 R >> >> >> stream
q 1 1 18.9106 32.9553 re W n BT /ZaDb 9 Tf 0 0 0.627 rg  1 0 0 1 6.6483 14.2422 Tm (4) Tj ET Qendstreamendobj406 0 obj<< /Length 125 /Subtype /Form /BBox [ 0 0 20.91064 34.95532 ] /Resources << /ProcSet [ /PDF /Text ] /Font << /ZaDb 604 0 R >> >> >> stream
0.749 g 0 0 20.9106 34.9553 re f q 1 1 18.9106 32.9553 re W n BT /ZaDb 9 Tf 0 0 0.627 rg  1 0 0 1 6.6483 14.2422 Tm (4) Tj ETendstreamendobj407 0 obj<< /Length 32 /Subtype /Form /BBox [ 0 0 20.91064 34.95532 ] /Resources << /ProcSet [ /PDF ] >> >> stream
0.749 g 0 0 20.9106 34.9553 re fendstreamendobj408 0 obj<< /Length 94 /Subtype /Form /BBox [ 0 0 22.14948 35.44788 ] /Resources << /ProcSet [ /PDF /Text ] /Font << /ZaDb 604 0 R >> >> >> stream
q 1 1 20.1495 33.4479 re W n BT /ZaDb 9 Tf 0 0 0.627 rg  1 0 0 1 7.2678 14.4885 Tm (4) Tj ET Qendstreamendobj409 0 obj<< /Length 125 /Subtype /Form /BBox [ 0 0 22.14948 35.44788 ] /Resources << /ProcSet [ /PDF /Text ] /Font << /ZaDb 604 0 R >> >> >> stream
0.749 g 0 0 22.1495 35.4479 re f q 1 1 20.1495 33.4479 re W n BT /ZaDb 9 Tf 0 0 0.627 rg  1 0 0 1 7.2678 14.4885 Tm (4) Tj ETendstreamendobj410 0 obj<< /Length 32 /Subtype /Form /BBox [ 0 0 22.14948 35.44788 ] /Resources << /ProcSet [ /PDF ] >> >> stream
0.749 g 0 0 22.1495 35.4479 re fendstreamendobj411 0 obj<< /Length 86 /Subtype /Form /BBox [ 0 0 9.00006 8.00005 ] /Resources << /ProcSet [ /PDF /Text ] /Font << /ZaDb 604 0 R >> >> >> stream
q 1 1 7.0001 6 re W n BT /ZaDb 9 Tf 0 0 0.627 rg  1 0 0 1 0.6931 0.7646 Tm (4) Tj ET Qendstreamendobj412 0 obj<< /Length 110 /Subtype /Form /BBox [ 0 0 9.00006 8.00005 ] /Resources << /ProcSet [ /PDF /Text ] /Font << /ZaDb 604 0 R >> >> >> stream
0.749 g 0 0 9.0001 8 re f q 1 1 7.0001 6 re W n BT /ZaDb 9 Tf 0 0 0.627 rg  1 0 0 1 0.6931 0.7646 Tm (4) Tj ETendstreamendobj413 0 obj<< /Length 25 /Subtype /Form /BBox [ 0 0 9.00006 8.00005 ] /Resources << /ProcSet [ /PDF ] >> >> stream
0.749 g 0 0 9.0001 8 re fendstreamendobj414 0 obj<< /Length 92 /Subtype /Form /BBox [ 0 0 7.00006 8.66673 ] /Resources << /ProcSet [ /PDF /Text ] /Font << /ZaDb 604 0 R >> >> >> stream
q 1 1 5.0001 6.6667 re W n BT /ZaDb 9 Tf 0 0 0.627 rg  1 0 0 1 -0.3069 1.0979 Tm (4) Tj ET Qendstreamendobj415 0 obj<< /Length 121 /Subtype /Form /BBox [ 0 0 7.00006 8.66673 ] /Resources << /ProcSet [ /PDF /Text ] /Font << /ZaDb 604 0 R >> >> >> stream
0.749 g 0 0 7.0001 8.6667 re f q 1 1 5.0001 6.6667 re W n BT /ZaDb 9 Tf 0 0 0.627 rg  1 0 0 1 -0.3069 1.0979 Tm (4) Tj ETendstreamendobj416 0 obj<< /Length 30 /Subtype /Form /BBox [ 0 0 7.00006 8.66673 ] /Resources << /ProcSet [ /PDF ] >> >> stream
0.749 g 0 0 7.0001 8.6667 re fendstreamendobj417 0 obj<< /Length 90 /Subtype /Form /BBox [ 0 0 8.20905 7.71649 ] /Resources << /ProcSet [ /PDF /Text ] /Font << /ZaDb 604 0 R >> >> >> stream
q 1 1 6.209 5.7165 re W n BT /ZaDb 9 Tf 0 0 0.627 rg  1 0 0 1 0.2976 0.6228 Tm (4) Tj ET Qendstreamendobj418 0 obj<< /Length 118 /Subtype /Form /BBox [ 0 0 8.20905 7.71649 ] /Resources << /ProcSet [ /PDF /Text ] /Font << /ZaDb 604 0 R >> >> >> stream
0.749 g 0 0 8.209 7.7165 re f q 1 1 6.209 5.7165 re W n BT /ZaDb 9 Tf 0 0 0.627 rg  1 0 0 1 0.2976 0.6228 Tm (4) Tj ETendstreamendobj419 0 obj<< /Length 29 /Subtype /Form /BBox [ 0 0 8.20905 7.71649 ] /Resources << /ProcSet [ /PDF ] >> >> stream
0.749 g 0 0 8.209 7.7165 re fendstreamendobj420 0 obj<< /N 698 0 R >> endobj421 0 obj<< /N 698 0 R >> endobj422 0 obj<< /N 698 0 R >> endobj423 0 obj<< /T (f1-4)/Kids [ 582 0 R ] /FT /Tx /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj424 0 obj<< /T (f1-7)/Kids [ 588 0 R ] /FT /Tx /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj425 0 obj<< /T (c1-1)/Kids [ 601 0 R ] /FT /Btn /DA (/ZaDb 9 Tf 0 0 0.627 rg)>> endobj426 0 obj<< /T (c1-2)/Kids [ 606 0 R ] /FT /Btn /DR 746 0 R /DA (/ZaDb 9 Tf 0 0 0.627 rg)/AA << >> >> endobj427 0 obj<< /T (c1-4)/Kids [ 614 0 R ] /FT /Btn /DR 746 0 R /DA (/ZaDb 9 Tf 0 0 0.627 rg)/AA << >> >> endobj428 0 obj<< /T (f1-15)/Kids [ 630 0 R ] /FT /Tx /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj429 0 obj<< /T (f1-17)/Kids [ 632 0 R ] /FT /Tx /Q 2 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj430 0 obj<< /T (f1-18)/Kids [ 633 0 R ] /FT /Tx /Q 2 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj431 0 obj<< /T (f1-19)/Kids [ 634 0 R ] /FT /Tx /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj432 0 obj<< /T (f1-20)/Kids [ 635 0 R ] /FT /Tx /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj433 0 obj<< /T (f1-23)/Kids [ 638 0 R ] /FT /Tx /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj434 0 obj<< /T (f1-24)/Kids [ 639 0 R ] /FT /Tx /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj435 0 obj<< /T (f1-21)/Kids [ 636 0 R ] /FT /Tx /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj436 0 obj<< /T (f1-22)/Kids [ 637 0 R ] /FT /Tx /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj437 0 obj<< /T (f1-25)/Kids [ 640 0 R ] /FT /Tx /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj438 0 obj<< /T (f1-26)/Kids [ 641 0 R ] /FT /Tx /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj439 0 obj<< /T (f1-27)/Kids [ 642 0 R ] /FT /Tx /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj440 0 obj<< /T (f1-28)/Kids [ 643 0 R ] /FT /Tx /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj441 0 obj<< /T (f1-29)/Kids [ 644 0 R ] /FT /Tx /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj442 0 obj<< /T (f1-30)/Kids [ 645 0 R ] /FT /Tx /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj443 0 obj<< /T (f1-31)/Kids [ 646 0 R ] /FT /Tx /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj444 0 obj<< /T (f1-32)/Kids [ 647 0 R ] /FT /Tx /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj445 0 obj<< /T (f1-43)/Kids [ 658 0 R ] /FT /Tx /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj446 0 obj<< /T (f1-44)/Kids [ 659 0 R ] /FT /Tx /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj447 0 obj<< /T (f1-45)/Kids [ 660 0 R ] /FT /Tx /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj448 0 obj<< /T (f1-46)/Kids [ 661 0 R ] /FT /Tx /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj449 0 obj<< /T (f1-47)/Kids [ 662 0 R ] /FT /Tx /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj450 0 obj<< /T (f1-48)/Kids [ 663 0 R ] /FT /Tx /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj451 0 obj<< /T (f1-49)/Kids [ 664 0 R ] /FT /Tx /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj452 0 obj<< /T (f1-50)/Kids [ 665 0 R ] /FT /Tx /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj453 0 obj<< /T (f1-55)/Kids [ 670 0 R ] /FT /Tx /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj454 0 obj<< /T (f1-56)/Kids [ 671 0 R ] /FT /Tx /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj455 0 obj<< /T (f1-63)/Kids [ 678 0 R ] /FT /Tx /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj456 0 obj<< /T (f1-64)/Kids [ 679 0 R ] /FT /Tx /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj457 0 obj<< /T (c1-7)/Kids [ 626 0 R ] /FT /Btn /DR 746 0 R /DA (/ZaDb 9 Tf 0 0 0.627 rg)>> endobj458 0 obj<< /T (f1-70)/Kids [ 689 0 R ] /FT /Tx /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj459 0 obj<< /T (f1-35)/Kids [ 650 0 R ] /FT /Tx /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj460 0 obj<< /T (f1-36)/Kids [ 651 0 R ] /FT /Tx /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj461 0 obj<< /T (f1-37)/Kids [ 652 0 R ] /FT /Tx /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj462 0 obj<< /T (f1-38)/Kids [ 653 0 R ] /FT /Tx /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj463 0 obj<< /T (f1-39)/Kids [ 654 0 R ] /FT /Tx /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj464 0 obj<< /T (f1-40)/Kids [ 655 0 R ] /FT /Tx /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj465 0 obj<< /T (f1-41)/Kids [ 656 0 R ] /FT /Tx /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj466 0 obj<< /T (f1-42)/Kids [ 657 0 R ] /FT /Tx /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj467 0 obj<< /T (c2-1)/Kids [ 40 0 R ] /FT /Btn /DA (/ZaDb 9 Tf 0 0 0.627 rg)>> endobj468 0 obj<< /T (c2-15)/Kids [ 68 0 R ] /FT /Btn /DR 70 0 R /DA (/ZaDb 9 Tf 0 0 0.627 rg)>> endobj469 0 obj<< /T (c2-16)/Kids [ 69 0 R ] /FT /Btn /DR 746 0 R /DA (/ZaDb 9 Tf 0 0 0.627 rg)>> endobj470 0 obj<< /T (c2-27)/Kids [ 90 0 R ] /FT /Btn /DR 70 0 R /DA (/ZaDb 9 Tf 0 0 0.627 rg)>> endobj471 0 obj<< /T (c2-28)/Kids [ 91 0 R ] /FT /Btn /DR 746 0 R /DA (/ZaDb 9 Tf 0 0 0.627 rg)>> endobj472 0 obj<< /T (f2-22)/Kids [ 110 0 R ] /FT /Tx /Q 1 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj473 0 obj<< /T (f3-1)/Kids [ 112 0 R ] /FT /Tx /Q 2 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj474 0 obj<< /T (f3-2)/Kids [ 113 0 R ] /FT /Tx /Q 2 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj475 0 obj<< /T (f3-3)/Kids [ 114 0 R ] /FT /Tx /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj476 0 obj<< /T (f3-4)/Kids [ 115 0 R ] /FT /Tx /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj477 0 obj<< /T (f3-26)/Kids [ 137 0 R ] /FT /Tx /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj478 0 obj<< /T (f3-27)/Kids [ 138 0 R ] /FT /Tx /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj479 0 obj<< /T (f3-28)/Kids [ 139 0 R ] /FT /Tx /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj480 0 obj<< /T (f3-29)/Kids [ 140 0 R ] /FT /Tx /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj481 0 obj<< /T (f3-30)/Kids [ 141 0 R ] /FT /Tx /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj482 0 obj<< /T (f3-31)/Kids [ 142 0 R ] /FT /Tx /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj483 0 obj<< /T (f3-20)/Kids [ 131 0 R ] /FT /Tx /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj484 0 obj<< /T (f3-21)/Kids [ 132 0 R ] /FT /Tx /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj485 0 obj<< /T (f3-22)/Kids [ 133 0 R ] /FT /Tx /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj486 0 obj<< /T (f3-23)/Kids [ 134 0 R ] /FT /Tx /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj487 0 obj<< /T (f3-24)/Kids [ 135 0 R ] /FT /Tx /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj488 0 obj<< /T (f3-25)/Kids [ 136 0 R ] /FT /Tx /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj489 0 obj<< /T (f3-32)/Kids [ 143 0 R ] /FT /Tx /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj490 0 obj<< /T (f3-33)/Kids [ 144 0 R ] /FT /Tx /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj491 0 obj<< /T (f3-34)/Kids [ 145 0 R ] /FT /Tx /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj492 0 obj<< /T (f3-35)/Kids [ 146 0 R ] /FT /Tx /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj493 0 obj<< /T (f3-36)/Kids [ 147 0 R ] /FT /Tx /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj494 0 obj<< /T (f3-37)/Kids [ 148 0 R ] /FT /Tx /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj495 0 obj<< /T (f3-54)/Kids [ 165 0 R ] /FT /Tx /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj496 0 obj<< /T (f3-55)/Kids [ 166 0 R ] /FT /Tx /Q 2 /DR 167 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj497 0 obj<< /T (f3-38)/Kids [ 149 0 R ] /FT /Tx /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj498 0 obj<< /T (f3-39)/Kids [ 150 0 R ] /FT /Tx /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj499 0 obj<< /T (f3-40)/Kids [ 151 0 R ] /FT /Tx /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj500 0 obj<< /T (f3-41)/Kids [ 152 0 R ] /FT /Tx /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj501 0 obj<< /T (f3-42)/Kids [ 153 0 R ] /FT /Tx /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj502 0 obj<< /T (f3-43)/Kids [ 154 0 R ] /FT /Tx /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj503 0 obj<< /T (f3-44)/Kids [ 155 0 R ] /FT /Tx /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj504 0 obj<< /T (f3-45)/Kids [ 156 0 R ] /FT /Tx /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj505 0 obj<< /T (f3-46)/Kids [ 157 0 R ] /FT /Tx /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj506 0 obj<< /T (f3-47)/Kids [ 158 0 R ] /FT /Tx /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj507 0 obj<< /T (f3-48)/Kids [ 159 0 R ] /FT /Tx /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj508 0 obj<< /T (f3-49)/Kids [ 160 0 R ] /FT /Tx /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj509 0 obj<< /T (f3-50)/Kids [ 161 0 R ] /FT /Tx /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj510 0 obj<< /T (f3-51)/Kids [ 162 0 R ] /FT /Tx /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj511 0 obj<< /T (f3-52)/Kids [ 163 0 R ] /FT /Tx /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj512 0 obj<< /T (f3-53)/Kids [ 164 0 R ] /FT /Tx /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj513 0 obj<< /T (f3-56)/Kids [ 174 0 R ] /FT /Tx /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj514 0 obj<< /T (f3-57)/Kids [ 175 0 R ] /FT /Tx /Q 2 /DR 167 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj515 0 obj<< /T (f3-74)/Kids [ 192 0 R ] /FT /Tx /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj516 0 obj<< /T (f3-75)/Kids [ 193 0 R ] /FT /Tx /Q 2 /DR 167 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj517 0 obj<< /T (f3-76)/Kids [ 194 0 R ] /FT /Tx /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj518 0 obj<< /T (f3-77)/Kids [ 195 0 R ] /FT /Tx /Q 2 /DR 167 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj519 0 obj<< /T (f3-72)/Kids [ 190 0 R ] /FT /Tx /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj520 0 obj<< /T (f3-73)/Kids [ 191 0 R ] /FT /Tx /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj521 0 obj<< /T (f4-3)/Kids [ 225 0 R ] /FT /Tx /Q 2 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj522 0 obj<< /T (f4-4)/Kids [ 226 0 R ] /FT /Tx /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj523 0 obj<< /T (f4-5)/Kids [ 227 0 R ] /FT /Tx /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj524 0 obj<< /T (f4-6)/Kids [ 228 0 R ] /FT /Tx /Q 2 /DR 229 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj525 0 obj<< /T (f4-7)/Kids [ 236 0 R ] /FT /Tx /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj526 0 obj<< /T (f4-8)/Kids [ 237 0 R ] /FT /Tx /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj527 0 obj<< /T (f4-15)/Kids [ 244 0 R ] /FT /Tx /Q 2 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj528 0 obj<< /T (f4-17)/Kids [ 246 0 R ] /FT /Tx /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj529 0 obj<< /T (f4-18)/Kids [ 247 0 R ] /FT /Tx /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj530 0 obj<< /T (f4-16)/Kids [ 245 0 R ] /FT /Tx /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj531 0 obj<< /T (f4-20)/Kids [ 249 0 R ] /FT /Tx /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj532 0 obj<< /T (f4-22)/Kids [ 251 0 R ] /FT /Tx /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj533 0 obj<< /T (f4-23)/Kids [ 252 0 R ] /FT /Tx /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj534 0 obj<< /T (f4-24)/Kids [ 253 0 R ] /FT /Tx /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj535 0 obj<< /T (f4-19)/Kids [ 248 0 R ] /FT /Tx /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj536 0 obj<< /T (f4-21)/Kids [ 250 0 R ] /FT /Tx /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj537 0 obj<< /T (f4-35)/Kids [ 264 0 R ] /FT /Tx /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj538 0 obj<< /T (f4-33)/Kids [ 262 0 R ] /FT /Tx /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj539 0 obj<< /T (f4-36)/Kids [ 265 0 R ] /FT /Tx /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj540 0 obj<< /T (f4-34)/Kids [ 263 0 R ] /FT /Tx /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj541 0 obj<< /T (f4-37)/Kids [ 266 0 R ] /FT /Tx /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj542 0 obj<< /T (f4-39)/Kids [ 268 0 R ] /FT /Tx /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj543 0 obj<< /T (f4-38)/Kids [ 267 0 R ] /FT /Tx /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj544 0 obj<< /T (f4-40)/Kids [ 269 0 R ] /FT /Tx /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj545 0 obj<< /T (f4-44)/Kids [ 273 0 R ] /FT /Tx /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj546 0 obj<< /T (f4-46)/Kids [ 275 0 R ] /FT /Tx /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj547 0 obj<< /T (f4-43)/Kids [ 272 0 R ] /FT /Tx /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj548 0 obj<< /T (f4-45)/Kids [ 274 0 R ] /FT /Tx /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj549 0 obj<< /T (f4-52)/Kids [ 281 0 R ] /FT /Tx /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj550 0 obj<< /T (f4-54)/Kids [ 283 0 R ] /FT /Tx /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj551 0 obj<< /T (f4-55)/Kids [ 284 0 R ] /FT /Tx /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj552 0 obj<< /T (f4-56)/Kids [ 285 0 R ] /FT /Tx /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj553 0 obj<< /T (f4-57)/Kids [ 286 0 R ] /FT /Tx /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj554 0 obj<< /T (f4-58)/Kids [ 287 0 R ] /FT /Tx /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj555 0 obj<< /T (f4-59)/Kids [ 288 0 R ] /FT /Tx /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj556 0 obj<< /T (f4-60)/Kids [ 289 0 R ] /FT /Tx /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj557 0 obj<< /T (f4-61)/Kids [ 290 0 R ] /FT /Tx /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj558 0 obj<< /T (f4-62)/Kids [ 291 0 R ] /FT /Tx /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj559 0 obj<< /T (f4-63)/Kids [ 292 0 R ] /FT /Tx /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj560 0 obj<< /T (f4-64)/Kids [ 293 0 R ] /FT /Tx /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj561 0 obj<< /T (f4-75)/Kids [ 304 0 R ] /FT /Tx /Q 2 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj562 0 obj<< /T (f4-82)/Kids [ 311 0 R ] /FT /Tx /Q 2 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj563 0 obj<< /T (f4-86)/Kids [ 315 0 R ] /FT /Tx /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj564 0 obj<< /T (f4-95)/Kids [ 324 0 R ] /FT /Tx /Q 2 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj565 0 obj<< /T (f4-93)/Kids [ 322 0 R ] /FT /Tx /Q 2 /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj566 0 obj<< /T (f4-101)/Kids [ 330 0 R ] /FT /Tx /Q 2 /DR 746 0 R /DA (/HeBo 9 Tf 0 0 0.627 rg)>> endobj567 0 obj<< /CreationDate (D:19991123120305)/Producer (Acrobat Distiller 4.0 for Windows)/Creator (Mecca III\(TM\) 9.40)/Title (1999 Form 1065)/Subject (U.S. Partnership Return of Income)/Author (T:FP)/ModDate (D:20000322205152-07'00')>> endobj568 0 obj<< /Type /Pages /Kids [ 574 0 R 1 0 R 7 0 R 13 0 R ] /Count 4 >> endobj569 0 obj<< /Names [ (�� D r a f t - E N U - 0)698 0 R ] >> endobjxref0 570 0000000000 65535 f
0000057988 00000 n
0000058155 00000 n
0000058604 00000 n
0000058744 00000 n
0000058961 00000 n
0000059113 00000 n
0000064334 00000 n
0000064503 00000 n
0000065382 00000 n
0000065523 00000 n
0000065741 00000 n
0000065906 00000 n
0000071491 00000 n
0000071662 00000 n
0000072559 00000 n
0000072701 00000 n
0000072920 00000 n
0000073098 00000 n
0000079431 00000 n
0000080223 00000 n
0000081014 00000 n
0000081810 00000 n
0000082600 00000 n
0000082809 00000 n
0000083011 00000 n
0000083213 00000 n
0000083415 00000 n
0000083617 00000 n
0000083819 00000 n
0000084021 00000 n
0000084223 00000 n
0000084425 00000 n
0000084627 00000 n
0000084830 00000 n
0000085033 00000 n
0000085236 00000 n
0000085439 00000 n
0000085642 00000 n
0000085845 00000 n
0000086048 00000 n
0000086304 00000 n
0000086618 00000 n
0000086932 00000 n
0000087146 00000 n
0000087462 00000 n
0000087778 00000 n
0000088091 00000 n
0000088404 00000 n
0000088717 00000 n
0000089033 00000 n
0000089289 00000 n
0000089574 00000 n
0000089736 00000 n
0000089991 00000 n
0000090275 00000 n
0000090437 00000 n
0000090693 00000 n
0000090978 00000 n
0000091140 00000 n
0000091455 00000 n
0000091772 00000 n
0000092086 00000 n
0000092401 00000 n
0000092718 00000 n
0000092973 00000 n
0000093257 00000 n
0000093419 00000 n
0000093633 00000 n
0000093903 00000 n
0000094173 00000 n
0000094229 00000 n
0000094277 00000 n
0000095626 00000 n
0000095692 00000 n
0000095799 00000 n
0000095911 00000 n
0000096003 00000 n
0000096314 00000 n
0000096631 00000 n
0000096890 00000 n
0000097181 00000 n
0000097348 00000 n
0000097662 00000 n
0000097979 00000 n
0000098292 00000 n
0000098609 00000 n
0000098919 00000 n
0000099236 00000 n
0000099547 00000 n
0000099864 00000 n
0000100130 00000 n
0000100400 00000 n
0000100659 00000 n
0000100950 00000 n
0000101117 00000 n
0000101376 00000 n
0000101667 00000 n
0000101834 00000 n
0000102093 00000 n
0000102384 00000 n
0000102552 00000 n
0000102726 00000 n
0000103041 00000 n
0000103359 00000 n
0000103674 00000 n
0000103992 00000 n
0000104307 00000 n
0000104625 00000 n
0000104798 00000 n
0000104978 00000 n
0000105151 00000 n
0000105353 00000 n
0000105494 00000 n
0000105635 00000 n
0000105787 00000 n
0000105939 00000 n
0000106140 00000 n
0000106342 00000 n
0000106545 00000 n
0000106748 00000 n
0000106951 00000 n
0000107155 00000 n
0000107357 00000 n
0000107560 00000 n
0000107764 00000 n
0000107968 00000 n
0000108170 00000 n
0000108373 00000 n
0000108577 00000 n
0000108781 00000 n
0000108961 00000 n
0000109112 00000 n
0000109263 00000 n
0000109415 00000 n
0000109567 00000 n
0000109718 00000 n
0000109869 00000 n
0000110021 00000 n
0000110173 00000 n
0000110324 00000 n
0000110473 00000 n
0000110625 00000 n
0000110777 00000 n
0000110929 00000 n
0000111081 00000 n
0000111232 00000 n
0000111383 00000 n
0000111535 00000 n
0000111687 00000 n
0000111839 00000 n
0000111989 00000 n
0000112141 00000 n
0000112292 00000 n
0000112444 00000 n
0000112596 00000 n
0000112748 00000 n
0000112900 00000 n
0000113051 00000 n
0000113203 00000 n
0000113353 00000 n
0000113505 00000 n
0000113656 00000 n
0000113808 00000 n
0000113960 00000 n
0000114110 00000 n
0000114262 00000 n
0000114414 00000 n
0000114473 00000 n
0000114523 00000 n
0000115873 00000 n
0000115943 00000 n
0000116052 00000 n
0000116166 00000 n
0000116259 00000 n
0000116411 00000 n
0000116563 00000 n
0000116767 00000 n
0000116971 00000 n
0000117175 00000 n
0000117379 00000 n
0000117583 00000 n
0000117787 00000 n
0000117991 00000 n
0000118195 00000 n
0000118399 00000 n
0000118601 00000 n
0000118805 00000 n
0000119009 00000 n
0000119213 00000 n
0000119417 00000 n
0000119569 00000 n
0000119721 00000 n
0000119873 00000 n
0000120025 00000 n
0000120177 00000 n
0000120329 00000 n
0000120509 00000 n
0000120683 00000 n
0000120887 00000 n
0000121088 00000 n
0000121292 00000 n
0000121496 00000 n
0000121789 00000 n
0000122082 00000 n
0000122285 00000 n
0000122488 00000 n
0000122692 00000 n
0000122895 00000 n
0000123098 00000 n
0000123302 00000 n
0000123482 00000 n
0000123685 00000 n
0000123888 00000 n
0000124092 00000 n
0000124294 00000 n
0000124497 00000 n
0000124699 00000 n
0000124902 00000 n
0000125105 00000 n
0000125305 00000 n
0000125505 00000 n
0000125707 00000 n
0000125910 00000 n
0000126089 00000 n
0000126269 00000 n
0000126411 00000 n
0000126564 00000 n
0000126717 00000 n
0000126870 00000 n
0000126929 00000 n
0000126979 00000 n
0000128329 00000 n
0000128399 00000 n
0000128508 00000 n
0000128622 00000 n
0000128715 00000 n
0000128868 00000 n
0000129051 00000 n
0000129255 00000 n
0000129460 00000 n
0000129665 00000 n
0000129870 00000 n
0000130075 00000 n
0000130280 00000 n
0000130422 00000 n
0000130575 00000 n
0000130728 00000 n
0000130881 00000 n
0000131034 00000 n
0000131187 00000 n
0000131340 00000 n
0000131493 00000 n
0000131646 00000 n
0000131799 00000 n
0000132004 00000 n
0000132209 00000 n
0000132414 00000 n
0000132619 00000 n
0000132824 00000 n
0000133029 00000 n
0000133234 00000 n
0000133439 00000 n
0000133592 00000 n
0000133745 00000 n
0000133898 00000 n
0000134051 00000 n
0000134204 00000 n
0000134357 00000 n
0000134510 00000 n
0000134663 00000 n
0000134868 00000 n
0000135073 00000 n
0000135226 00000 n
0000135379 00000 n
0000135532 00000 n
0000135685 00000 n
0000135890 00000 n
0000136095 00000 n
0000136300 00000 n
0000136505 00000 n
0000136710 00000 n
0000136863 00000 n
0000137068 00000 n
0000137221 00000 n
0000137374 00000 n
0000137527 00000 n
0000137680 00000 n
0000137833 00000 n
0000137986 00000 n
0000138139 00000 n
0000138292 00000 n
0000138445 00000 n
0000138598 00000 n
0000138781 00000 n
0000138986 00000 n
0000139191 00000 n
0000139396 00000 n
0000139601 00000 n
0000139806 00000 n
0000140011 00000 n
0000140216 00000 n
0000140421 00000 n
0000140626 00000 n
0000140831 00000 n
0000140971 00000 n
0000141151 00000 n
0000141354 00000 n
0000141557 00000 n
0000141738 00000 n
0000141919 00000 n
0000142098 00000 n
0000142240 00000 n
0000142445 00000 n
0000142649 00000 n
0000142852 00000 n
0000143003 00000 n
0000143205 00000 n
0000143380 00000 n
0000143583 00000 n
0000143786 00000 n
0000143965 00000 n
0000144145 00000 n
0000144286 00000 n
0000144466 00000 n
0000144643 00000 n
0000144848 00000 n
0000145052 00000 n
0000145256 00000 n
0000145460 00000 n
0000145664 00000 n
0000145814 00000 n
0000145994 00000 n
0000146172 00000 n
0000146375 00000 n
0000146578 00000 n
0000146781 00000 n
0000147037 00000 n
0000147322 00000 n
0000147485 00000 n
0000147742 00000 n
0000148028 00000 n
0000148191 00000 n
0000148448 00000 n
0000148734 00000 n
0000148897 00000 n
0000149153 00000 n
0000149438 00000 n
0000149601 00000 n
0000149857 00000 n
0000150142 00000 n
0000150305 00000 n
0000150561 00000 n
0000150846 00000 n
0000151009 00000 n
0000151266 00000 n
0000151552 00000 n
0000151715 00000 n
0000151971 00000 n
0000152256 00000 n
0000152419 00000 n
0000152675 00000 n
0000152960 00000 n
0000153123 00000 n
0000153383 00000 n
0000153675 00000 n
0000153843 00000 n
0000154103 00000 n
0000154395 00000 n
0000154563 00000 n
0000154823 00000 n
0000155115 00000 n
0000155283 00000 n
0000155544 00000 n
0000155837 00000 n
0000156005 00000 n
0000156266 00000 n
0000156559 00000 n
0000156727 00000 n
0000156987 00000 n
0000157279 00000 n
0000157447 00000 n
0000157707 00000 n
0000157999 00000 n
0000158167 00000 n
0000158427 00000 n
0000158719 00000 n
0000158887 00000 n
0000159148 00000 n
0000159441 00000 n
0000159609 00000 n
0000159869 00000 n
0000160161 00000 n
0000160329 00000 n
0000160590 00000 n
0000160883 00000 n
0000161051 00000 n
0000161312 00000 n
0000161605 00000 n
0000161773 00000 n
0000162034 00000 n
0000162327 00000 n
0000162495 00000 n
0000162756 00000 n
0000163049 00000 n
0000163217 00000 n
0000163479 00000 n
0000163773 00000 n
0000163941 00000 n
0000164203 00000 n
0000164497 00000 n
0000164665 00000 n
0000164917 00000 n
0000165194 00000 n
0000165353 00000 n
0000165611 00000 n
0000165899 00000 n
0000166063 00000 n
0000166319 00000 n
0000166604 00000 n
0000166767 00000 n
0000166804 00000 n
0000166841 00000 n
0000166878 00000 n
0000166971 00000 n
0000167064 00000 n
0000167158 00000 n
0000167276 00000 n
0000167394 00000 n
0000167488 00000 n
0000167588 00000 n
0000167688 00000 n
0000167801 00000 n
0000167914 00000 n
0000168027 00000 n
0000168140 00000 n
0000168253 00000 n
0000168366 00000 n
0000168479 00000 n
0000168592 00000 n
0000168705 00000 n
0000168818 00000 n
0000168931 00000 n
0000169044 00000 n
0000169157 00000 n
0000169270 00000 n
0000169383 00000 n
0000169496 00000 n
0000169609 00000 n
0000169722 00000 n
0000169835 00000 n
0000169948 00000 n
0000170061 00000 n
0000170174 00000 n
0000170287 00000 n
0000170400 00000 n
0000170513 00000 n
0000170626 00000 n
0000170733 00000 n
0000170827 00000 n
0000170940 00000 n
0000171053 00000 n
0000171166 00000 n
0000171279 00000 n
0000171392 00000 n
0000171505 00000 n
0000171618 00000 n
0000171731 00000 n
0000171824 00000 n
0000171930 00000 n
0000172037 00000 n
0000172143 00000 n
0000172250 00000 n
0000172350 00000 n
0000172449 00000 n
0000172548 00000 n
0000172660 00000 n
0000172772 00000 n
0000172885 00000 n
0000172998 00000 n
0000173111 00000 n
0000173224 00000 n
0000173337 00000 n
0000173450 00000 n
0000173563 00000 n
0000173676 00000 n
0000173789 00000 n
0000173902 00000 n
0000174015 00000 n
0000174128 00000 n
0000174241 00000 n
0000174354 00000 n
0000174467 00000 n
0000174580 00000 n
0000174693 00000 n
0000174806 00000 n
0000174919 00000 n
0000175032 00000 n
0000175145 00000 n
0000175258 00000 n
0000175371 00000 n
0000175484 00000 n
0000175597 00000 n
0000175710 00000 n
0000175823 00000 n
0000175936 00000 n
0000176049 00000 n
0000176162 00000 n
0000176275 00000 n
0000176388 00000 n
0000176501 00000 n
0000176614 00000 n
0000176727 00000 n
0000176840 00000 n
0000176953 00000 n
0000177066 00000 n
0000177179 00000 n
0000177292 00000 n
0000177405 00000 n
0000177518 00000 n
0000177631 00000 n
0000177744 00000 n
0000177843 00000 n
0000177955 00000 n
0000178067 00000 n
0000178179 00000 n
0000178291 00000 n
0000178403 00000 n
0000178503 00000 n
0000178616 00000 n
0000178729 00000 n
0000178842 00000 n
0000178955 00000 n
0000179068 00000 n
0000179181 00000 n
0000179294 00000 n
0000179407 00000 n
0000179520 00000 n
0000179633 00000 n
0000179746 00000 n
0000179859 00000 n
0000179972 00000 n
0000180085 00000 n
0000180198 00000 n
0000180311 00000 n
0000180424 00000 n
0000180537 00000 n
0000180650 00000 n
0000180763 00000 n
0000180876 00000 n
0000180989 00000 n
0000181102 00000 n
0000181215 00000 n
0000181328 00000 n
0000181441 00000 n
0000181554 00000 n
0000181667 00000 n
0000181780 00000 n
0000181893 00000 n
0000182006 00000 n
0000182119 00000 n
0000182232 00000 n
0000182332 00000 n
0000182432 00000 n
0000182545 00000 n
0000182645 00000 n
0000182745 00000 n
0000182859 00000 n
0000183114 00000 n
0000183201 00000 n
trailer<</Size 570/ID[<7082243b0dfb3ee468e8d873148787cd><7082243b0dfb3ee468e8d873148787cd>]>>startxref173%%EOF
!!! Base Root Pointer !!!
571 0 R
!!! Base Size !!!
754
!!! Base Xref Offset !!!
173
!!! Xlator Set Class !!!
Bivio::UI::PDF::Form::F1065::Y1999::XlatorSet
!!! Field Text !!!
423 0 obj
<< /T (f1-4) /Kids [ 582 0 R ] /FT /Tx /DA (/HeBo 9 Tf 0 0 0.627 rg) >>
endobj
582 0 obj
<<
/Type /Annot
/Subtype /Widget
/Rect [ 179.00137 698.99931 462.33687 714.66608 ]
/F 4
/P 574 0 R
/AP << /N 583 0 R >>
/Parent 423 0 R
>>
endobj
584 0 obj
<<
/Type /Annot
/Subtype /Widget
/Rect [ 178.66747 675.49866 462.00296 691.16542 ]
/P 574 0 R
/F 4
/T (f1-5)
/FT /Tx
/AA << >>
/DR 746 0 R
/DA (/HeBo 9 Tf 0 0 0.627 rg)
/AP << /N 585 0 R >>
>>
endobj
586 0 obj
<<
/Type /Annot
/Subtype /Widget
/Rect [ 178.66747 647.49866 462.00296 667.16542 ]
/P 574 0 R
/F 4
/T (f1-6)
/FT /Tx
/AA << >>
/DR 746 0 R
/DA (/HeBo 9 Tf 0 0 0.627 rg)
/AP << /N 587 0 R >>
>>
endobj
424 0 obj
<< /T (f1-7) /Kids [ 588 0 R ] /FT /Tx /DA (/HeBo 9 Tf 0 0 0.627 rg) >>
endobj
588 0 obj
<<
/Type /Annot
/Subtype /Widget
/Rect [ 50.00038 698.9993 134.00099 712.66606 ]
/F 4
/P 574 0 R
/AP << /N 589 0 R >>
/Parent 424 0 R
>>
endobj
590 0 obj
<<
/Type /Annot
/Subtype /Widget
/Rect [ 49.3349 675.49866 134.33551 690.16542 ]
/P 574 0 R
/F 4
/T (f1-8)
/FT /Tx
/AA << >>
/DR 746 0 R
/DA (/HeBo 9 Tf 0 0 0.627 rg)
/AP << /N 591 0 R >>
>>
endobj
592 0 obj
<<
/Type /Annot
/Subtype /Widget
/Rect [ 41.3349 646.49866 134.33551 661.16542 ]
/P 574 0 R
/F 4
/T (f1-9)
/FT /Tx
/AA << >>
/Q 1
/DR 746 0 R
/DA (/HeBo 9 Tf 0 0 0.627 rg)
/AP << /N 593 0 R >>
>>
endobj
594 0 obj
<<
/Type /Annot
/Subtype /Widget
/Rect [ 467.36346 699.71539 493.78156 714.64093 ]
/F 4
/P 574 0 R
/T (f1-10)
/FT /Tx
/Q 2
/AP << /N 595 0 R >>
/DA (/HeBo 9 Tf 0 0 0.627 rg)
>>
endobj
596 0 obj
<<
/Type /Annot
/Subtype /Widget
/Rect [ 498.0038 699.66597 567.33768 714.66606 ]
/F 4
/P 574 0 R
/T (f1-11)
/FT /Tx
/Q 0
/AP << /N 597 0 R >>
/DA (/HeBo 9 Tf 0 0 0.627 rg)
>>
endobj
598 0 obj
<<
/Type /Annot
/Subtype /Widget
/Rect [ 468.00363 674.99911 568.33766 690.66589 ]
/F 4
/P 574 0 R
/T (f1-12)
/FT /Tx
/Q 1
/DA (/HeBo 9 Tf 0 0 0.627 rg)
>>
endobj
610 0 obj
<<
/Type /Annot
/Subtype /Widget
/Rect [ 359.16885 627.832 366.83557 634.83206 ]
/DR 746 0 R
/P 574 0 R
/AS /Off
/F 4
/H /T
/MK << /CA (4) /AC (��) /RC (��) >>
/T (c1-3)
/FT /Btn
/AA << >>
/DA (/ZaDb 9 Tf 0 0 0.627 rg)
/AP << /N << /Yes 613 0 R >> /D << /Yes 611 0 R /Off 612 0 R >> >>
>>
endobj
427 0 obj
<<
/T (c1-4)
/Kids [ 614 0 R ]
/FT /Btn
/DR 746 0 R
/DA (/ZaDb 9 Tf 0 0 0.627 rg)
/AA << >>
>>
endobj
614 0 obj
<<
/Type /Annot
/Subtype /Widget
/Rect [ 481.00584 627.39325 488.67256 635.39331 ]
/DA (/ZaDb 9 Tf 0 0 0.627 rg)
/P 574 0 R
/AS /Off
/F 4
/H /T
/MK << /CA (4) /AC (��) /RC (��) >>
/AP << /N << /Yes 617 0 R >> /D << /Yes 615 0 R /Off 616 0 R >> >>
/DR 746 0 R
/Parent 427 0 R
>>
endobj
425 0 obj
<< /T (c1-1) /Kids [ 601 0 R ] /FT /Btn /DA (/ZaDb 9 Tf 0 0 0.627 rg) >>
endobj
601 0 obj
<<
/Type /Annot
/Subtype /Widget
/Rect [ 171.33466 627.66541 180.00137 634.66547 ]
/F 4
/P 574 0 R
/AS /Off
/AP << /N << /Yes 605 0 R >> /D << /Yes 602 0 R /Off 603 0 R >> >>
/DA (/ZaDb 9 Tf 0 0 0.627 rg)
/H /T
/MK << /CA (4) /AC (��) /RC (��) >>
/Parent 425 0 R
>>
endobj
426 0 obj
<<
/T (c1-2)
/Kids [ 606 0 R ]
/FT /Btn
/DR 746 0 R
/DA (/ZaDb 9 Tf 0 0 0.627 rg)
/AA << >>
>>
endobj
606 0 obj
<<
/Type /Annot
/Subtype /Widget
/Rect [ 265.16885 626.832 273.83557 635.83206 ]
/DR 744 0 R
/P 574 0 R
/AS /Off
/F 4
/H /T
/MK << /CA (4) /AC (��) /RC (��) >>
/DA (/ZaDb 9 Tf 0 0 0.627 rg)
/AP << /N << /Yes 609 0 R >> /D << /Yes 607 0 R /Off 608 0 R >> >>
/AA << >>
/Parent 426 0 R
>>
endobj
622 0 obj
<<
/Type /Annot
/Subtype /Widget
/Rect [ 265.16885 614.832 273.83557 623.83206 ]
/DR 746 0 R
/P 574 0 R
/AS /Off
/F 4
/H /T
/MK << /CA (4) /AC (��) /RC (��) >>
/AA << >>
/T (c1-6)
/FT /Btn
/DA (/ZaDb 9 Tf 0 0 0.627 rg)
/AP << /N << /Yes 625 0 R >> /D << /Yes 623 0 R /Off 624 0 R >> >>
>>
endobj
618 0 obj
<<
/Type /Annot
/Subtype /Widget
/Rect [ 171.16885 614.832 179.83557 623.83206 ]
/DR 746 0 R
/P 574 0 R
/AS /Off
/F 4
/H /T
/MK << /CA (4) /AC (��) /RC (��) >>
/AA << >>
/T (c1-5)
/FT /Btn
/DA (/ZaDb 9 Tf 0 0 0.627 rg)
/AP << /N << /Yes 621 0 R >> /D << /Yes 619 0 R /Off 620 0 R >> >>
>>
endobj
457 0 obj
<<
/T (c1-7)
/Kids [ 626 0 R ]
/FT /Btn
/DR 746 0 R
/DA (/ZaDb 9 Tf 0 0 0.627 rg)
>>
endobj
626 0 obj
<<
/Type /Annot
/Subtype /Widget
/Rect [ 358.00584 615.39325 367.67256 623.39331 ]
/AP << /N << /Yes 629 0 R >> /D << /Yes 627 0 R /Off 628 0 R >> >>
/P 574 0 R
/AS /Off
/F 4
/H /T
/MK << /CA (4) /AC (��) /RC (��) >>
/AA << >>
/Parent 457 0 R
>>
endobj
631 0 obj
<<
/Type /Annot
/Subtype /Widget
/Rect [ 439.16879 603.49855 567.50308 615.49863 ]
/P 574 0 R
/F 4
/T (f1-16)
/FT /Tx
/AA << >>
/DR 746 0 R
/DA (/HeBo 9 Tf 0 0 0.627 rg)
>>
endobj
63 0 obj
<<
/Type /Annot
/Subtype /Widget
/Rect [ 228.72723 434.51849 237.93628 443.23499 ]
/DR 746 0 R
/P 1 0 R
/AS /Off
/F 4
/H /T
/MK << /CA (4) /AC (��) /RC (��) >>
/T (c2-14)
/FT /Btn
/AA << >>
/DA (/ZaDb 9 Tf 0 0 0.627 rg)
/AP << /N << /Yes 360 0 R >> /D << /Yes 361 0 R /Off 362 0 R >> >>
>>
endobj
61 0 obj
<<
/Type /Annot
/Subtype /Widget
/Rect [ 387.72723 447.51849 395.93628 455.23499 ]
/DR 746 0 R
/P 1 0 R
/AS /Off
/F 4
/H /T
/MK << /CA (4) /AC (��) /RC (��) >>
/T (c2-12)
/FT /Btn
/AA << >>
/DA (/ZaDb 9 Tf 0 0 0.627 rg)
/AP << /N << /Yes 64 0 R >> /D << /Yes 65 0 R /Off 66 0 R >> >>
>>
endobj
59 0 obj
<<
/Type /Annot
/Subtype /Widget
/Rect [ 63.72723 447.51849 71.93628 455.23499 ]
/DR 746 0 R
/P 1 0 R
/AS /Off
/F 4
/H /T
/MK << /CA (4) /AC (��) /RC (��) >>
/T (c2-10)
/FT /Btn
/AA << >>
/DA (/ZaDb 9 Tf 0 0 0.627 rg)
/AP << /N << /Yes 351 0 R >> /D << /Yes 352 0 R /Off 353 0 R >> >>
>>
endobj
60 0 obj
<<
/Type /Annot
/Subtype /Widget
/Rect [ 229.72723 447.51849 236.93628 455.23499 ]
/DR 746 0 R
/P 1 0 R
/AS /Off
/F 4
/H /T
/MK << /CA (4) /AC (��) /RC (��) >>
/T (c2-11)
/FT /Btn
/AA << >>
/DA (/ZaDb 9 Tf 0 0 0.627 rg)
/AP << /N << /Yes 354 0 R >> /D << /Yes 355 0 R /Off 356 0 R >> >>
>>
endobj
62 0 obj
<<
/Type /Annot
/Subtype /Widget
/Rect [ 63.72723 434.51849 71.93628 443.23499 ]
/DR 746 0 R
/P 1 0 R
/AS /Off
/F 4
/H /T
/MK << /CA (4) /AC (��) /RC (��) >>
/T (c2-13)
/FT /Btn
/AA << >>
/DA (/ZaDb 9 Tf 0 0 0.627 rg)
/AP << /N << /Yes 357 0 R >> /D << /Yes 358 0 R /Off 359 0 R >> >>
>>
endobj
469 0 obj
<<
/T (c2-16)
/Kids [ 69 0 R ]
/FT /Btn
/DR 746 0 R
/DA (/ZaDb 9 Tf 0 0 0.627 rg)
>>
endobj
69 0 obj
<<
/Type /Annot
/Subtype /Widget
/Rect [ 545.76721 423.33923 567.91669 434.78711 ]
/F 4
/P 1 0 R
/AP << /N << /Yes 366 0 R >> /D << /Yes 367 0 R /Off 368 0 R >> >>
/AS /Off
/AA << >>
/H /T
/MK << /CA (4) /AC (��) /RC (��) >>
/Parent 469 0 R
>>
endobj
468 0 obj
<<
/T (c2-15)
/Kids [ 68 0 R ]
/FT /Btn
/DR 70 0 R
/DA (/ZaDb 9 Tf 0 0 0.627 rg)
>>
endobj
68 0 obj
<<
/Type /Annot
/Subtype /Widget
/Rect [ 524.12518 423.33923 546.03583 434.29456 ]
/F 4
/P 1 0 R
/AP << /N << /Yes 363 0 R >> /D << /Yes 364 0 R /Off 365 0 R >> >>
/AS /Off
/AA << >>
/H /T
/MK << /CA (4) /AC (��) /RC (��) >>
/Parent 468 0 R
>>
endobj
78 0 obj
<<
/Type /Annot
/Subtype /Widget
/Rect [ 546.07803 411.33151 568.22751 422.77939 ]
/DR 746 0 R
/P 1 0 R
/AS /Off
/F 4
/H /T
/MK << /CA (4) /AC (��) /RC (��) >>
/T (c2-18)
/FT /Btn
/AA << >>
/DA (/ZaDb 9 Tf 0 0 0.627 rg)
/AP << /N << /Yes 369 0 R >> /D << /Yes 370 0 R /Off 371 0 R >> >>
>>
endobj
77 0 obj
<<
/Type /Annot
/Subtype /Widget
/Rect [ 524.436 411.33151 545.34665 422.28683 ]
/DR 70 0 R
/P 1 0 R
/AS /Off
/F 4
/H /T
/MK << /CA (4) /AC (��) /RC (��) >>
/T (c2-17)
/FT /Btn
/AA << >>
/DA (/ZaDb 9 Tf 0 0 0.627 rg)
/AP << /N << /Yes 79 0 R >> /D << /Yes 80 0 R /Off 81 0 R >> >>
>>
endobj
83 0 obj
<<
/Type /Annot
/Subtype /Widget
/Rect [ 546.07803 387.33151 567.22751 410.77939 ]
/DR 746 0 R
/P 1 0 R
/AS /Off
/F 4
/H /T
/MK << /CA (4) /AC (��) /RC (��) >>
/T (c2-20)
/FT /Btn
/AA << >>
/DA (/ZaDb 9 Tf 0 0 0.627 rg)
/AP << /N << /Yes 375 0 R >> /D << /Yes 376 0 R /Off 377 0 R >> >>
>>
endobj
82 0 obj
<<
/Type /Annot
/Subtype /Widget
/Rect [ 524.436 387.33151 545.34665 410.28683 ]
/DR 70 0 R
/P 1 0 R
/AS /Off
/F 4
/H /T
/MK << /CA (4) /AC (��) /RC (��) >>
/T (c2-19)
/FT /Btn
/AA << >>
/DA (/ZaDb 9 Tf 0 0 0.627 rg)
/AP << /N << /Yes 372 0 R >> /D << /Yes 373 0 R /Off 374 0 R >> >>
>>
endobj
108 0 obj
<<
/Type /Annot
/Subtype /Widget
/Rect [ 127.1059 101.20135 380.86981 117.63434 ]
/F 4
/P 1 0 R
/T (f2-20)
/FT /Tx
/DA (/HeBo 9 Tf 0 0 0.627 rg)
>>
endobj
109 0 obj
<<
/Type /Annot
/Subtype /Widget
/Rect [ 457.69165 100.20135 568.66296 117.63434 ]
/F 4
/P 1 0 R
/T (f2-21)
/FT /Tx
/Q 1
/DA (/HeBo 9 Tf 0 0 0.627 rg)
>>
endobj
472 0 obj
<< /T (f2-22) /Kids [ 110 0 R ] /FT /Tx /Q 1 /DA (/HeBo 9 Tf 0 0 0.627 rg) >>
endobj
110 0 obj
<<
/Type /Annot
/Subtype /Widget
/Rect [ 128.1059 87.0072 567.67786 99.21625 ]
/F 4
/P 1 0 R
/DA (/HeBo 9 Tf 0 0 0.627 rg)
/Q 0
/Parent 472 0 R
>>
endobj
111 0 obj
<<
/Type /Annot
/Subtype /Widget
/Rect [ 128.21655 75.05763 567.78851 87.26668 ]
/P 1 0 R
/F 4
/T (f2-23)
/FT /Tx
/AA << >>
/Q 0
/DR 746 0 R
/DA (/HeBo 9 Tf 0 0 0.627 rg)
>>
endobj
85 0 obj
<<
/Type /Annot
/Subtype /Widget
/Rect [ 546.07803 303.80807 568.22751 315.25595 ]
/DR 746 0 R
/P 1 0 R
/AS /Off
/F 4
/H /T
/MK << /CA (4) /AC (��) /RC (��) >>
/T (c2-22)
/FT /Btn
/AA << >>
/DA (/ZaDb 9 Tf 0 0 0.627 rg)
/AP << /N << /Yes 381 0 R >> /D << /Yes 382 0 R /Off 383 0 R >> >>
>>
endobj
84 0 obj
<<
/Type /Annot
/Subtype /Widget
/Rect [ 524.436 303.80807 545.34665 314.7634 ]
/DR 70 0 R
/P 1 0 R
/AS /Off
/F 4
/H /T
/MK << /CA (4) /AC (��) /RC (��) >>
/T (c2-21)
/FT /Btn
/AA << >>
/DA (/ZaDb 9 Tf 0 0 0.627 rg)
/AP << /N << /Yes 378 0 R >> /D << /Yes 379 0 R /Off 380 0 R >> >>
>>
endobj
87 0 obj
<<
/Type /Annot
/Subtype /Widget
/Rect [ 546.07803 291.80807 568.22751 303.25595 ]
/DR 746 0 R
/P 1 0 R
/AS /Off
/F 4
/H /T
/MK << /CA (4) /AC (��) /RC (��) >>
/T (c2-24)
/FT /Btn
/AA << >>
/DA (/ZaDb 9 Tf 0 0 0.627 rg)
/AP << /N << /Yes 384 0 R >> /D << /Yes 385 0 R /Off 386 0 R >> >>
>>
endobj
86 0 obj
<<
/Type /Annot
/Subtype /Widget
/Rect [ 524.436 291.80807 545.34665 303.7634 ]
/DR 70 0 R
/P 1 0 R
/AS /Off
/F 4
/H /T
/MK << /CA (4) /AC (��) /RC (��) >>
/T (c2-23)
/FT /Btn
/AA << >>
/DA (/ZaDb 9 Tf 0 0 0.627 rg)
/AP << /N << /Yes 92 0 R >> /D << /Yes 93 0 R /Off 94 0 R >> >>
>>
endobj
89 0 obj
<<
/Type /Annot
/Subtype /Widget
/Rect [ 546.07803 279.04636 568.22751 291.49423 ]
/DR 746 0 R
/P 1 0 R
/AS /Off
/F 4
/H /T
/MK << /CA (4) /AC (��) /RC (��) >>
/T (c2-26)
/FT /Btn
/AA << >>
/DA (/ZaDb 9 Tf 0 0 0.627 rg)
/AP << /N << /Yes 387 0 R >> /D << /Yes 388 0 R /Off 389 0 R >> >>
>>
endobj
88 0 obj
<<
/Type /Annot
/Subtype /Widget
/Rect [ 524.436 279.04636 545.34665 291.00168 ]
/DR 70 0 R
/P 1 0 R
/AS /Off
/F 4
/H /T
/MK << /CA (4) /AC (��) /RC (��) >>
/T (c2-25)
/FT /Btn
/AA << >>
/DA (/ZaDb 9 Tf 0 0 0.627 rg)
/AP << /N << /Yes 95 0 R >> /D << /Yes 96 0 R /Off 97 0 R >> >>
>>
endobj
471 0 obj
<<
/T (c2-28)
/Kids [ 91 0 R ]
/FT /Btn
/DR 746 0 R
/DA (/ZaDb 9 Tf 0 0 0.627 rg)
>>
endobj
91 0 obj
<<
/Type /Annot
/Subtype /Widget
/Rect [ 546.07803 267.04636 568.22751 278.49423 ]
/AP << /N << /Yes 390 0 R >> /D << /Yes 391 0 R /Off 392 0 R >> >>
/P 1 0 R
/AS /Off
/F 4
/H /T
/MK << /CA (4) /AC (��) /RC (��) >>
/AA << >>
/Parent 471 0 R
>>
endobj
470 0 obj
<<
/T (c2-27)
/Kids [ 90 0 R ]
/FT /Btn
/DR 70 0 R
/DA (/ZaDb 9 Tf 0 0 0.627 rg)
>>
endobj
90 0 obj
<<
/Type /Annot
/Subtype /Widget
/Rect [ 524.436 267.04636 545.34665 279.00168 ]
/AP << /N << /Yes 98 0 R >> /D << /Yes 99 0 R /Off 100 0 R >> >>
/P 1 0 R
/AS /Off
/F 4
/H /T
/MK << /CA (4) /AC (��) /RC (��) >>
/AA << >>
/Parent 470 0 R
>>
endobj
103 0 obj
<<
/Type /Annot
/Subtype /Widget
/Rect [ 546.07803 219.67349 568.22751 235.12137 ]
/DR 746 0 R
/P 1 0 R
/AS /Off
/F 4
/H /T
/MK << /CA (4) /AC (��) /RC (��) >>
/T (c2-30)
/FT /Btn
/AA << >>
/DA (/ZaDb 9 Tf 0 0 0.627 rg)
/AP << /N << /Yes 396 0 R >> /D << /Yes 397 0 R /Off 398 0 R >> >>
>>
endobj
102 0 obj
<<
/Type /Annot
/Subtype /Widget
/Rect [ 524.436 219.67349 545.34665 235.62881 ]
/DR 70 0 R
/P 1 0 R
/AS /Off
/F 4
/H /T
/MK << /CA (4) /AC (��) /RC (��) >>
/T (c2-29)
/FT /Btn
/AA << >>
/DA (/ZaDb 9 Tf 0 0 0.627 rg)
/AP << /N << /Yes 393 0 R >> /D << /Yes 394 0 R /Off 395 0 R >> >>
>>
endobj
101 0 obj
<<
/Type /Annot
/Subtype /Widget
/Rect [ 235.33093 218.35193 513.67731 230.30725 ]
/F 4
/P 1 0 R
/T (f2-19)
/FT /Tx
/DA (/HeBo 9 Tf 0 0 0.627 rg)
>>
endobj
105 0 obj
<<
/Type /Annot
/Subtype /Widget
/Rect [ 546.07803 195.67349 568.22751 219.12137 ]
/DR 746 0 R
/P 1 0 R
/AS /Off
/F 4
/H /T
/MK << /CA (4) /AC (��) /RC (��) >>
/T (c2-32)
/FT /Btn
/AA << >>
/DA (/ZaDb 9 Tf 0 0 0.627 rg)
/AP << /N << /Yes 402 0 R >> /D << /Yes 403 0 R /Off 404 0 R >> >>
>>
endobj
104 0 obj
<<
/Type /Annot
/Subtype /Widget
/Rect [ 524.436 195.67349 545.34665 218.62881 ]
/DR 70 0 R
/P 1 0 R
/AS /Off
/F 4
/H /T
/MK << /CA (4) /AC (��) /RC (��) >>
/T (c2-31)
/FT /Btn
/AA << >>
/DA (/ZaDb 9 Tf 0 0 0.627 rg)
/AP << /N << /Yes 399 0 R >> /D << /Yes 400 0 R /Off 401 0 R >> >>
>>
endobj
107 0 obj
<<
/Type /Annot
/Subtype /Widget
/Rect [ 546.07803 159.67349 568.22751 195.12137 ]
/DR 746 0 R
/P 1 0 R
/AS /Off
/F 4
/H /T
/MK << /CA (4) /AC (��) /RC (��) >>
/T (c2-34)
/FT /Btn
/AA << >>
/DA (/ZaDb 9 Tf 0 0 0.627 rg)
/AP << /N << /Yes 408 0 R >> /D << /Yes 409 0 R /Off 410 0 R >> >>
>>
endobj
106 0 obj
<<
/Type /Annot
/Subtype /Widget
/Rect [ 524.436 159.67349 545.34665 194.62881 ]
/DR 70 0 R
/P 1 0 R
/AS /Off
/F 4
/H /T
/MK << /CA (4) /AC (��) /RC (��) >>
/T (c2-33)
/FT /Btn
/AA << >>
/DA (/ZaDb 9 Tf 0 0 0.627 rg)
/AP << /N << /Yes 405 0 R >> /D << /Yes 406 0 R /Off 407 0 R >> >>
>>
endobj
122 0 obj
<<
/Type /Annot
/Subtype /Widget
/Rect [ 482.0477 639.36798 544.49612 653.3233 ]
/P 7 0 R
/F 4
/T (f3-11)
/FT /Tx
/AA << >>
/Q 2
/DR 746 0 R
/DA (/HeBo 9 Tf 0 0 0.627 rg)
>>
endobj
123 0 obj
<<
/Type /Annot
/Subtype /Widget
/Rect [ 546.5441 639.13939 564.21091 653.47279 ]
/P 7 0 R
/F 4
/T (f3-12)
/FT /Tx
/AA << >>
/Q 2
/DR 746 0 R
/DA (/HeBo 9 Tf 0 0 0.627 rg)
>>
endobj
124 0 obj
<<
/Type /Annot
/Subtype /Widget
/Rect [ 482.33368 627.81909 544.27466 639.01324 ]
/P 7 0 R
/F 4
/T (f3-13)
/FT /Tx
/AA << >>
/Q 2
/DR 746 0 R
/DA (/HeBo 9 Tf 0 0 0.627 rg)
>>
endobj
125 0 obj
<<
/Type /Annot
/Subtype /Widget
/Rect [ 545.95723 626.85747 563.62404 639.19087 ]
/P 7 0 R
/F 4
/T (f3-14)
/FT /Tx
/AA << >>
/Q 2
/DR 746 0 R
/DA (/HeBo 9 Tf 0 0 0.627 rg)
>>
endobj
128 0 obj
<<
/Type /Annot
/Subtype /Widget
/Rect [ 482.33701 603.66522 544.67082 615.66531 ]
/P 7 0 R
/F 4
/T (f3-17)
/FT /Tx
/AA << >>
/Q 2
/DR 746 0 R
/DA (/HeBo 9 Tf 0 0 0.627 rg)
>>
endobj
129 0 obj
<<
/Type /Annot
/Subtype /Widget
/Rect [ 545.95723 602.85747 563.62404 615.19087 ]
/P 7 0 R
/F 4
/T (f3-18)
/FT /Tx
/AA << >>
/Q 2
/DR 746 0 R
/DA (/HeBo 9 Tf 0 0 0.627 rg)
>>
endobj
483 0 obj
<<
/T (f3-20)
/Kids [ 131 0 R ]
/FT /Tx
/Q 2
/DR 746 0 R
/DA (/HeBo 9 Tf 0 0 0.627 rg)
>>
endobj
131 0 obj
<<
/Type /Annot
/Subtype /Widget
/Rect [ 482.0477 578.70163 544.49612 592.65695 ]
/P 7 0 R
/F 4
/AA << >>
/Parent 483 0 R
>>
endobj
484 0 obj
<<
/T (f3-21)
/Kids [ 132 0 R ]
/FT /Tx
/Q 2
/DR 746 0 R
/DA (/HeBo 9 Tf 0 0 0.627 rg)
>>
endobj
132 0 obj
<<
/Type /Annot
/Subtype /Widget
/Rect [ 546.5441 579.47304 564.21091 592.80644 ]
/P 7 0 R
/F 4
/AA << >>
/Parent 484 0 R
>>
endobj
485 0 obj
<<
/T (f3-22)
/Kids [ 133 0 R ]
/FT /Tx
/Q 2
/DR 746 0 R
/DA (/HeBo 9 Tf 0 0 0.627 rg)
>>
endobj
133 0 obj
<<
/Type /Annot
/Subtype /Widget
/Rect [ 481.46083 567.41971 544.90926 578.37503 ]
/P 7 0 R
/F 4
/AA << >>
/Parent 485 0 R
>>
endobj
486 0 obj
<<
/T (f3-23)
/Kids [ 134 0 R ]
/FT /Tx
/Q 2
/DR 746 0 R
/DA (/HeBo 9 Tf 0 0 0.627 rg)
>>
endobj
134 0 obj
<<
/Type /Annot
/Subtype /Widget
/Rect [ 545.95723 567.19112 563.62404 578.52452 ]
/P 7 0 R
/F 4
/AA << >>
/Parent 486 0 R
>>
endobj
491 0 obj
<<
/T (f3-34)
/Kids [ 145 0 R ]
/FT /Tx
/Q 2
/DR 746 0 R
/DA (/HeBo 9 Tf 0 0 0.627 rg)
>>
endobj
145 0 obj
<<
/Type /Annot
/Subtype /Widget
/Rect [ 482.0477 495.67474 544.49612 506.63007 ]
/P 7 0 R
/F 4
/AA << >>
/Parent 491 0 R
>>
endobj
492 0 obj
<<
/T (f3-35)
/Kids [ 146 0 R ]
/FT /Tx
/Q 2
/DR 746 0 R
/DA (/HeBo 9 Tf 0 0 0.627 rg)
>>
endobj
146 0 obj
<<
/Type /Annot
/Subtype /Widget
/Rect [ 546.5441 495.44615 564.21091 506.77956 ]
/P 7 0 R
/F 4
/AA << >>
/Parent 492 0 R
>>
endobj
513 0 obj
<<
/T (f3-56)
/Kids [ 174 0 R ]
/FT /Tx
/Q 2
/DR 746 0 R
/DA (/HeBo 9 Tf 0 0 0.627 rg)
>>
endobj
174 0 obj
<<
/Type /Annot
/Subtype /Widget
/Rect [ 482.33701 351.32997 545.00415 362.66339 ]
/P 7 0 R
/F 4
/AA << >>
/Parent 513 0 R
>>
endobj
514 0 obj
<<
/T (f3-57)
/Kids [ 175 0 R ]
/FT /Tx
/Q 2
/DR 167 0 R
/DA (/HeBo 9 Tf 0 0 0.627 rg)
>>
endobj
175 0 obj
<<
/Type /Annot
/Subtype /Widget
/Rect [ 546.08424 351.33012 563.75105 362.66353 ]
/P 7 0 R
/F 4
/AA << >>
/Parent 514 0 R
>>
endobj
176 0 obj
<<
/Type /Annot
/Subtype /Widget
/Rect [ 482.17322 339.96913 544.62164 350.92445 ]
/P 7 0 R
/F 4
/T (f3-58)
/FT /Tx
/AA << >>
/Q 2
/DR 746 0 R
/DA (/HeBo 9 Tf 0 0 0.627 rg)
>>
endobj
177 0 obj
<<
/Type /Annot
/Subtype /Widget
/Rect [ 545.66962 339.74054 563.33643 351.07394 ]
/P 7 0 R
/F 4
/T (f3-59)
/FT /Tx
/AA << >>
/Q 2
/DR 746 0 R
/DA (/HeBo 9 Tf 0 0 0.627 rg)
>>
endobj
196 0 obj
<<
/Type /Annot
/Subtype /Widget
/Rect [ 167.16602 218.35193 447.76611 231.29236 ]
/F 4
/P 7 0 R
/T (f3-78)
/FT /Tx
/Q 0
/DA (/HeBo 9 Tf 0 0 0.627 rg)
>>
endobj
197 0 obj
<<
/Type /Annot
/Subtype /Widget
/Rect [ 279.33548 206.99554 448.33675 218.66228 ]
/F 4
/P 7 0 R
/T (f3-79)
/FT /Tx
/DA (/HeBo 9 Tf 0 0 0.627 rg)
>>
endobj
198 0 obj
<<
/Type /Annot
/Subtype /Widget
/Rect [ 481.58611 195.14749 545.03453 208.10281 ]
/P 7 0 R
/F 4
/T (f3-80)
/FT /Tx
/AA << >>
/Q 2
/DR 746 0 R
/DA (/HeBo 9 Tf 0 0 0.627 rg)
>>
endobj
199 0 obj
<<
/Type /Annot
/Subtype /Widget
/Rect [ 546.0825 195.9189 563.74931 208.2523 ]
/P 7 0 R
/F 4
/T (f3-81)
/FT /Tx
/AA << >>
/Q 2
/DR 167 0 R
/DA (/HeBo 9 Tf 0 0 0.627 rg)
>>
endobj
203 0 obj
<<
/Type /Annot
/Subtype /Widget
/Rect [ 265.33536 170.99525 272.33542 179.66199 ]
/F 4
/P 7 0 R
/T (c3-2)
/FT /Btn
/DA (/ZaDb 9 Tf 0 0 0.627 rg)
/H /T
/MK << /CA (4) /AC (��) /RC (��) >>
/AS /Off
/AP << /N << /Yes 414 0 R >> /D << /Yes 415 0 R /Off 416 0 R >> >>
>>
endobj
202 0 obj
<<
/Type /Annot
/Subtype /Widget
/Rect [ 229.33508 171.66193 238.33514 179.66197 ]
/F 4
/P 7 0 R
/T (c3-1)
/FT /Btn
/DA (/ZaDb 9 Tf 0 0 0.627 rg)
/H /T
/MK << /CA (4) /AC (��) /RC (��) >>
/AS /Off
/AP << /N << /Yes 411 0 R >> /D << /Yes 412 0 R /Off 413 0 R >> >>
>>
endobj
204 0 obj
<<
/Type /Annot
/Subtype /Widget
/Rect [ 482.17297 172.19669 544.6214 183.15201 ]
/P 7 0 R
/F 4
/T (f3-84)
/FT /Tx
/AA << >>
/Q 2
/DR 746 0 R
/DA (/HeBo 9 Tf 0 0 0.627 rg)
>>
endobj
205 0 obj
<<
/Type /Annot
/Subtype /Widget
/Rect [ 545.66937 171.96809 563.33618 183.3015 ]
/P 7 0 R
/F 4
/T (f3-85)
/FT /Tx
/AA << >>
/Q 2
/DR 746 0 R
/DA (/HeBo 9 Tf 0 0 0.627 rg)
>>
endobj
213 0 obj
<<
/Type /Annot
/Subtype /Widget
/Rect [ 481.66724 123.01971 545.11566 134.97504 ]
/P 7 0 R
/F 4
/T (f3-93)
/FT /Tx
/AA << >>
/Q 2
/DR 746 0 R
/DA (/HeBo 9 Tf 0 0 0.627 rg)
>>
endobj
214 0 obj
<<
/Type /Annot
/Subtype /Widget
/Rect [ 546.54382 122.918 563.21063 134.25142 ]
/P 7 0 R
/F 4
/T (f3-94)
/FT /Tx
/AA << >>
/Q 2
/DR 746 0 R
/DA (/HeBo 9 Tf 0 0 0.627 rg)
>>
endobj
219 0 obj
<<
/Type /Annot
/Subtype /Widget
/Rect [ 481.5876 86.9679 545.03603 98.92322 ]
/P 7 0 R
/F 4
/T (f3-99)
/FT /Tx
/AA << >>
/Q 2
/DR 746 0 R
/DA (/HeBo 9 Tf 0 0 0.627 rg)
>>
endobj
220 0 obj
<<
/Type /Annot
/Subtype /Widget
/Rect [ 546.084 86.7393 564.75081 99.07271 ]
/P 7 0 R
/F 4
/T (f3-100)
/FT /Tx
/AA << >>
/Q 2
/DR 746 0 R
/DA (/HeBo 9 Tf 0 0 0.627 rg)
>>
endobj
221 0 obj
<<
/Type /Annot
/Subtype /Widget
/Rect [ 482.00073 75.68597 544.44916 86.6413 ]
/P 7 0 R
/F 4
/T (f3-101)
/FT /Tx
/AA << >>
/Q 2
/DR 746 0 R
/DA (/HeBo 9 Tf 0 0 0.627 rg)
>>
endobj
222 0 obj
<<
/Type /Annot
/Subtype /Widget
/Rect [ 546.21048 75.58429 564.21063 87.25105 ]
/P 7 0 R
/F 4
/T (f3-102)
/FT /Tx
/AA << >>
/Q 2
/DR 746 0 R
/DA (/HeBo 9 Tf 0 0 0.627 rg)
>>
endobj
223 0 obj
<<
/Type /Annot
/Subtype /Widget
/Rect [ 481.33702 710.9994 544.33748 724.66615 ]
/F 4
/P 13 0 R
/T (f4-1)
/FT /Tx
/Q 2
/DA (/HeBo 9 Tf 0 0 0.627 rg)
>>
endobj
224 0 obj
<<
/Type /Annot
/Subtype /Widget
/Rect [ 546.33752 711.66606 566.00433 724.99947 ]
/F 4
/P 13 0 R
/T (f4-2)
/FT /Tx
/Q 2
/DA (/HeBo 9 Tf 0 0 0.627 rg)
>>
endobj
522 0 obj
<<
/T (f4-4)
/Kids [ 226 0 R ]
/FT /Tx
/Q 2
/DR 746 0 R
/DA (/HeBo 9 Tf 0 0 0.627 rg)
>>
endobj
226 0 obj
<<
/Type /Annot
/Subtype /Widget
/Rect [ 208.50235 675.83199 278.16954 686.83206 ]
/P 13 0 R
/F 4
/AA << >>
/Parent 522 0 R
>>
endobj
523 0 obj
<<
/T (f4-5)
/Kids [ 227 0 R ]
/FT /Tx
/Q 2
/DR 746 0 R
/DA (/HeBo 9 Tf 0 0 0.627 rg)
>>
endobj
227 0 obj
<<
/Type /Annot
/Subtype /Widget
/Rect [ 279.50235 675.83199 350.16954 686.83206 ]
/P 13 0 R
/F 4
/AA << >>
/Parent 523 0 R
>>
endobj
!!! Data End !!!
