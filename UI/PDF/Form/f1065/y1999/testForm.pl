#!/usr/bin/perl -w
use strict;

print("Start\n");

use Bivio::UI::PDF::Form::f1065::y1999::Form;
use Bivio::UI::PDF::Form::Request;

Bivio::UI::PDF::Form::f1065::y1999::Form->initialize();

my($form_ref) = Bivio::UI::PDF::Form::f1065::y1999::Form->new();

my($request_ref) = Bivio::UI::PDF::Form::Request->new();

$form_ref->execute($request_ref);

my($text_ref) = $form_ref->emit();

open(OUT, '>out.pdf') or die("Open failure\n");
print(OUT ${$text_ref});
close(OUT);

print("Done\n");
