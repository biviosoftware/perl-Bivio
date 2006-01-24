# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::MailPartList;
use strict;
use base 'Bivio::Biz::ListModel';
use MIME::Parser ();
use Bivio::Mail::Address;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_DT) = Bivio::Type->get_instance('DateTime');
my($_FN) = Bivio::Type->get_instance('FileName');;

sub execute_from_realm_mail_list {
    my($proto, $req) = @_;
    $proto->new($req)->load_all({
	parent_id => $req->get_nested(
	    qw(Model.RealmMailList RealmMail.realm_file_id)),
    });
    return;
}

sub execute_part {
    my($proto, $req) = @_;
    # It's bad to pull the result from the request, but it should be reliable
    $proto->execute_load_this($req);
    my($self) = $req->get(ref($proto) || $proto);
    $req->get('reply')
	->set_output_type($self->get('mime_type'))
	->set_output(\((
	    $self->get('mime_entity')->bodyhandle
		|| $self->throw_die('MODEL_NOT_FOUND')
	    )->as_string));
    return 1;
}

sub format_uri_for_part {
    my($self, $task_id) = @_;
    my($req) = $self->get_request;
    $self->die(
	$self->get('RealmFile.realm_id'), ': not same as auth_realm',
    ) unless $req->get('auth_id') eq $self->get('RealmFile.realm_id');
    return $self->get_request->format_uri({
	task_id => $task_id,
	path_info => $self->get_file_name,
	query => {
	    'ListQuery.parent_id' => $self->get_query->get('parent_id'),
	    'ListQuery.this' => $self->get('index'),
	},
    });
}

sub get_body {
    my($v) = shift->get('mime_entity')->bodyhandle;
    return $v ? $v->as_string : '';
}

sub get_file_name {
    my($self) = @_;
    return $_FN->get_tail(
	$self->get('mime_entity')->head->recommended_filename
	    || ('attachment' . $self->get('index') . '.'
	       . (Bivio::MIME::Type->to_extension(
		   $self->get('mime_type') || '')
		   || Bivio::MIME::Type->to_extension('application/octet'))));
}

sub get_header {
    my($self, $name) = @_;
    return ''
	unless defined(my $v = $self->get('mime_entity')->head->get(
	    $name =~ /^from_(name|email)$/ ? 'from' : $name));
    chomp($v);
    if ($name =~ /^from_(name|email)$/) {
	my($e, $n) = Bivio::Mail::Address->parse($v);
	return ($name eq 'from_name' ? $n : $e) || '';
    }
    return $name eq 'date' ? (Bivio::Type::DateTime->from_literal($v))[0] || ''
	: $v;
}

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
    my($rid) = $query->get('auth_id');
    my($res) = [map({
	$_->{index} = $index++;
	$_->{'RealmFile.realm_id'} = $rid;
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
    return $res
	unless my $t = $query->unsafe_get('this');
    return [$res->[$t->[0]] || $self->throw_die('MODEL_NOT_FOUND')];
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
