# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::BlogList;
use strict;
use base 'Bivio::Biz::ListModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_BC) = Bivio::Type->get_instance('BlogContent');
my($_BFN) = Bivio::Type->get_instance('BlogFileName');
my($_WT) = Bivio::Type->get_instance('WikiText');
my($_DT) = Bivio::Type->get_instance('DateTime');
my($_RF) = Bivio::Biz::Model->get_instance('RealmFile');

sub PAGE_SIZE {
    return 5;
}

sub execute_load_this {
    my($proto, $req) = @_;
    my($self) = $proto->new($req);
    my($query) = $self->parse_query_from_request;
    unless ($query->unsafe_get('this')) {
	my($t) = $_BFN->from_literal($req->unsafe_get('path_info'));
	return shift->SUPER::execute_load_this(@_)
	    unless $t;
	$query->put(this => [$t]);
    }
    $self->load_this($query);
    return 0;
}

sub get_creation_date_time {
    return $_DT->from_literal_or_die(shift->get('path_info'));
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	can_iterate => 1,
        auth_id => 'RealmFile.realm_id',
        primary_key => [{
	    name => 'path_info',
	    type => 'BlogFileName',
	    in_select => 1,
	    # Handles PUBLIC/PRIVATE sorting by blog creation date
	    select_value =>
		qq{SUBSTRING(path_lc FROM '\%#"@{[$_BFN->SQL_LIKE_BASE]}#"' FOR '#') as path_info},
	    sort_order => 0,
	}],
	order_by => [qw(
	    path_info
	    RealmFile.modified_date_time
	)],
	other => [qw(
	    RealmFile.is_public
	    RealmFile.realm_file_id
        ),
	    [qw(RealmFile.user_id RealmOwner.realm_id Email.realm_id)],
	    'Email.email',
	    'RealmOwner.display_name',
	    {
		name => 'title',
		type => 'BlogTitle',
		constraint => 'NOT_NULL',
	    },
	    {
		name => 'body',
		type => 'BlogBody',
		constraint => 'NOT_NULL',
	    },
	],
    });
}

sub internal_post_load_row {
    my($self, $row) = @_;
    $row->{path_info} = $_BFN->from_literal_or_die($row->{path_info});
    ($row->{title}, $row->{body}) = $_BC->split(
	$_RF->get_content($self, 'RealmFile.', $row),
    );
    return 1;
}

sub internal_prepare_statement {
    my($self, $stmt) = @_;
    my($am) = $self->get_request->get('Type.AccessMode');
    $stmt->where(
	$stmt->AND(
	    $stmt->OR(
		map(
		    $stmt->LIKE(
			'RealmFile.path_lc', $_BFN->to_sql_like_path($_),
		    ),
		    1,
		    ($am->eq_private ? 0 : ())),
	    ),
	    $am->eq_public ? ['RealmFile.is_public', [1]] : (),
	),
	['Email.location', [$self->get_instance('Email')->DEFAULT_LOCATION]],
    );
    return;
}

sub render_html {
    my($self, $body) = @_;
    return $_WT->render_html({
	value => $body || $self->get('body'),
	name => $self->get('path_info'),
	req => $self->get_request,
	task_id => undef,
	map(($_ => $self->get("RealmFile.$_")), qw(is_public realm_id)),
	no_auto_links => 1,
    });
}

sub render_html_excerpt {
    my($self) = @_;
    my($body) = $self->get('body');
#TODO: Split on words
    $body = substr($body, 0, 300);
#TODO: Is this good enough?
    $body =~ s/\n[^\n]*$//s;
    return $self->render_html($body);
}

1;
