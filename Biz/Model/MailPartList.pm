# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::MailPartList;
use strict;
use base 'Bivio::Biz::ListModel';
use MIME::Parser ();

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	@{$self->internal_initialize_local_fields(
	    primary_key => [[qw(index Integer)]],
	    other => [
		[qw(mime_type Line)],
		[qw(mime_entity Object)],
	    ],
	    undef, 'NOT_NULL',
	)},
	parent_id => 'RealmFile.realm_file_id',
	auth_id => 'RealmFile.realm_id',
	# Testing hook
	other_query_keys => [qw(content_ref)],
    });
}

sub internal_load_rows {
    my($self, $query) = @_;
    my($index) = 0;
    return [map({
	$_->{index} = $index++;
	$_;
    } @{_walk(
	_parser(
	    "Content-Type: message/rfc822\n\n"
	    . ${$query->unsafe_get('content_ref')
	        || $self->new_other('RealmFile')->unauth_load_or_die({
		    realm_id => $query->get('auth_id'),
		    realm_file_id => $query->get('parent_id'),
		})->get_content},
	))},
    )];
}

sub _parser {
    my($m) = MIME::Parser->new;
    $m->output_to_core(1);
    $m->tmp_to_core(1);
    return $m->parse_data(\$_[0]);
}

sub _walk {
    my($me) = @_;
    $me->head->unfold;
    my($parts) = [$me->parts];
    my($ct) = $me->mime_type;
    my($res) = [];
    if ($ct eq 'message/rfc822') {
	Bivio::Die->die($parts, ': expected one part')
	    unless 1 == @$parts;
	my($h) = $parts->[0]->head->dup;
	$h->replace('Content-Type', 'x-message/rfc822-headers');
	unshift(@$parts, _parser($h->as_string . "\n"));
    }
    return @$parts ? [map(
	$ct eq 'x-message/rfc822-headers' ? $_
	    : $ct eq 'multipart/alternative' && $_->mime_type =~ m|^text/|
		&& $_->mime_type ne 'text/html'
	    ? ()
	    : @{_walk($_)},
	@$parts,
    )] : [{
	mime_type => $ct,
	mime_entity => $me,
    }];
}

1;
