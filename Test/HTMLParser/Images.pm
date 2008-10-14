# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Test::HTMLParser::Images;
use strict;
use Bivio::Base 'Bivio::Test::HTMLParser';
use Bivio::IO::Trace;

# models the images on a page.

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
our($_TRACE);
my($_IDI) = __PACKAGE__->instance_data_index;
__PACKAGE__->register(['Cleaner']);
my($_FP) = b_use('Type.FilePath');

sub html_parser_start {
    # (self, string, hash_ref, array_ref, string) : undef
    # Dispatches to the _start_XXX routines.
    my($self, $tag, $attr) = @_;
    my($fields) = $self->[$_IDI];
    return unless $tag eq 'img';
    my($label) = $attr->{alt} || $_FP->get_base($attr->{src});
    $self->get('elements')->{$label} = {
        label => $label,
        src => $attr->{src},
        alt => $attr->{alt},
    };
    return;
}

sub new {
    my($proto) = @_;
    my($self) = $proto->SUPER::new;
    $self->[$_IDI] = {};
    return $self;
}

1;
