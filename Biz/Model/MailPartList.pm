# Copyright (c) 2006-2011 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::MailPartList;
use strict;
use Bivio::Base 'Biz.ListModel';

my($_IDI) = __PACKAGE__->instance_data_index;
my($_A) = b_use('Mail.Address');
my($_DT) = b_use('Type.DateTime');
my($_E) = b_use('Type.Email');
my($_FN) = b_use('Type.FileName');
my($_MP) = b_use('Ext.MIMEParser');
my($_RM) = b_use('Model.RealmMail');
my($_T) = b_use('MIME.Type');
my($_W) = b_use('MIME.Word');
my($_LFP) = b_use('Action.LocalFilePlain');

sub execute_from_realm_mail_list {
    my($proto, $req) = @_;
    $proto->new($req)->load_all({
	parent_id => $req->get_nested(
	    qw(Model.RealmMailList RealmMail.realm_file_id)),
    });
    return;
}

sub execute_from_realm_file_id {
    my($proto, $req, $rfid) = @_;
    $proto->new($req)->load_all({
	parent_id => $rfid,
    });
    return;
}

sub execute_part {
    my($proto, $req) = @_;
    my($self) = $proto->new($req);
    my($q) = $self->parse_query_from_request;
    if ($q->get('this')) {
	$self->load_this($q);
    }
    elsif (my $cid = $q->unsafe_get('mime_cid')) {
	$self->load_all($q);
	my($cursor) = $self->unsafe_get_cursor_for_mime_cid($cid);
	$self->throw_die(MODEL_NOT_FOUND => {
	    message => 'mime_cid not found',
	    entity => $cid,
	}) unless defined($cursor);
	$self->set_cursor($cursor);
    }
    else {
	$self->throw_die(CORRUPT_QUERY => {
	    message => 'missing this or mime_cid',
	    entity => $q,
	});
    }
    $_LFP->set_cacheable_output(
	\((
	    $self->get('mime_entity')->bodyhandle
		|| $self->throw_die('MODEL_NOT_FOUND')
	)->as_string),
	$self->get('mime_type'),
	$req,
    )->set_last_modified($self->get_nested(qw(realm_file modified_date_time)));
    return 1;
}

sub format_uri_for_mime_cid {
    my($self, $mime_cid, $task_id) = @_;
    # Don't bother verifying is in list(?)
    return $self->internal_format_uri($task_id, {mime_cid => $mime_cid});
}

sub format_uri_for_part {
    my($self, $task_id) = @_;
    return $self->internal_format_uri(
	$task_id, {'ListQuery.this' => $self->get('index')});
}

sub get_body {
    my($v) = shift->get('mime_entity')->bodyhandle;
    return $v ? $v->as_string : '';
}

sub get_file_name {
    my($self) = @_;
    my($fn) = $self->get('mime_entity')->head->recommended_filename;
    return $_FN->get_tail(
	$fn && $_W->decode($fn) || _default_file_name($self));
}

sub get_from_name {
    my($self) = @_;
    return $self->get_header('from_name')
	|| $_E->get_local_part($self->get_header('from_email'));
}

sub get_header {
    my($self, $name) = @_;
    my($from) = $name =~ s/^(from)_(name|email)$/$1/ && $2;
    return ''
	unless defined(my $v = $self->get('mime_entity')->head->get($name));
    chomp($v);
    $v = $_W->decode($v);
    return ($from ? ($_A->parse($v))[$from eq 'name' ? 1 : 0]
	: $name eq 'date' ? ($_DT->from_literal($v))[0]
	: $v
    ) || '';
}

sub has_mime_cid {
    return defined(shift->get('mime_cid')) ? 1 : 0;
}

sub internal_format_uri {
    my($self, $task_id, $other, $realm_name) = @_;
    my($req) = $self->get_request;
    $self->die(
	$self->get('RealmFile.realm_id'), ': not same as auth_realm',
    ) unless $realm_name
	|| $req->get('auth_id') eq $self->get('RealmFile.realm_id');
    return $self->get_request->format_uri({
	$realm_name ? (realm => $realm_name) : (),
	task_id => $task_id,
	path_info => $self->get_file_name,
	query => {
	    'ListQuery.parent_id' => $self->get_query->get('parent_id'),
	    %$other,
	},
    });
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	$self->field_decl(
	    primary_key => [[qw(index Integer)]],
	    other => [
		[qw(mime_type Line)],
		[qw(mime_entity Object)],
		[qw(mime_cid Line NONE)],
	    ],
	    undef, 'NOT_NULL',
	),
	parent_id => 'RealmFile.realm_file_id',
	auth_id => 'RealmFile.realm_id',
	other_query_keys => [qw(content_ref mime_cid)],
	other => [
	    $self->field_decl([[qw(realm_file Model.RealmFile)]]),
	],
    });
}

sub internal_load_rows {
    my($self, $query) = @_;
    my($index) = 0;
    my($rid) = $query->get('auth_id');
    b_die($rid, ': auth_id not same as auth_realm: ', $self->req('auth_realm'))
	unless $query->unsafe_get('content_ref') || $self->req('auth_id') eq $rid;
    my($rf);
    my($res) = [map({
	$_->{index} = $index++;
	$_->{'RealmFile.realm_id'} = $rid;
	$_->{realm_file} = $rf;
	$_;
    } @{_walk(
	_parser(
	    "Content-Type: message/rfc822\n\n"
	    . ${$query->unsafe_get('content_ref')
	        || ($rf = $self->new_other('RealmFile')->unauth_load_or_die({
		    realm_id => $query->get('auth_id'),
		    realm_file_id => $query->get('parent_id'),
		    $_RM->access_is_public_only($self->req)
			? (is_public => 1)
			: (),
		}))->get_content},
	))},
    )];
    return $res
	unless my $t = $query->unsafe_get('this');
    return [$res->[$t->[0]] || $self->throw_die('MODEL_NOT_FOUND')];
}

sub load_from_content {
    my($self, $content) = @_;
    return $self->load_all({
	content_ref => $content,
	parent_id => 1,
    });
}

sub set_attachment_visited {
    my($self, $mime_cid) = @_;
    my($fields) = $self->[$_IDI] ||= {
	visited => {},
    };
    $fields->{visited}->{$mime_cid} = 1;
    return;
}

sub show_as_attachment {
    my($self) = @_;
    return $self->get('index') > 1 ? 1 : 0;
}

sub unsafe_get_cursor_for_mime_cid {
    my($self, $mime_cid) = @_;
    return $self->save_excursion(sub {
	my($cursor);
	$mime_cid = "<$mime_cid>";
	$self->do_rows(sub {
	    my($it) = @_;
	    return 1
		unless my $cid = $it->unsafe_get('mime_cid');
	    chomp($cid);
	    return 1
		unless $mime_cid eq $cid;
	    $cursor = $it->get_cursor;
	    return 0;
	});
	return $cursor;
    });
}

sub was_attachment_visited {
    my($self) = @_;
    my($fields) = $self->[$_IDI];
    return 0 unless $fields && $self->unsafe_get('mime_cid');
    my($cid) = $self->get('mime_cid');
    $cid =~ s/^<|>\s*$//sg;
    return $fields->{visited} && $fields->{visited}->{$cid}
	? 1
	: 0;
}

sub _default_file_name {
    my($self) = @_;
    return 'attachment'
	. $self->get('index')
	. '.'
	. ($_T->to_extension($self->get('mime_type') || '')
	    || $_T->to_extension('application/octet')
	);
}

sub _parser {
    return $_MP->parse_data(\$_[0]);
}

sub _walk {
    my($me) = @_;
    $me->head->unfold;
    my($parts) = [$me->parts];
    my($ct) = $me->mime_type;
    if ($ct eq 'message/rfc822') {
#TODO: Do not die; ignore other parts(?)
	Bivio::Die->die($parts, ': expected one part')
	    unless 1 == @$parts;
	my($h) = $parts->[0]->head->dup;
	$h->replace('Content-Type', 'x-message/rfc822-headers');
	unshift(@$parts, _parser($h->as_string . "\n"));
    }
    my($related_index) = 0;
    return @$parts ? [map(
	$ct eq 'x-message/rfc822-headers'
	    ? $_
	    : $ct eq 'multipart/alternative' && $_->mime_type =~ m{^text/}
		&& $_->mime_type ne 'text/html'
	    ? ()
	    : @{_walk($_)},
	@$parts,
    )] : [{
	mime_type => $ct,
	mime_entity => $me,
	mime_cid => $me->head->get('content-id') || undef,
    }];
}

1;
