# Copyright (c) 2008-2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Search::Parser;
use strict;
use Bivio::Base 'Collection.Attributes';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_DT) = __PACKAGE__->use('Type.DateTime');
my($_M) = b_use('Biz.Model');
my($_P) = b_use('Search.Parseable');

sub handle_new_excerpt {
    my($proto, $parseable, @rest) = @_;
    return undef
	unless my $self = ref($proto) ? $proto
	: $proto->new_text($parseable, @rest);
#TODO: Split on paragraphs first.  Google groups seems to do this
    my($max) = 45;
    my($words) = [grep(
	length($_),
	split(' ', ${$self->get('text')}, $max),
    )];
    if (@$words >= $max) {
	pop(@$words);
	push(@$words, '...');
    }
    return $self->put(excerpt => join(' ', @$words));
}

sub new_text {
    return _do(@_);
}

sub new_excerpt {
    return _do(@_);
}

sub xapian_terms_and_postings {
    my($proto, $model) = @_;
    return
	unless my $self = $proto->new_excerpt($model);
    return $self->put(
	terms => _terms($self),
	postings => _postings(
	    \($self->get('path')),
	    \($self->get('title')),
	    $self->get('text'),
	),
    );
}

sub _do {
    my($proto, $model) = @_;
    my($parseable) = $_P->is_blessed($model) ? $model : $_P->new($model);
    $model = $parseable->get('model');
    my($method) = 'handle_' . $proto->my_caller;
    return
	unless my $self = Bivio::Die->eval_or_die(sub {
	    return b_use(SearchParser => $parseable->get('class'))
		->$method($parseable);
	});
    $parseable->map_each(sub {
        shift;
        return $self->put_unless_exists(@_);
    });
    return $self->put_unless_exists(
	'RealmOwner.realm_id' => $model->get_auth_id,
	author => '',
	author_email => '',
	author_user_id => $model->get_auth_user_id,
	excerpt => '',
	modified_date_time => sub {$_DT->now},
	path => '',
	primary_id => $model->get_primary_id,
	simple_class => $model->simple_package_name,
	title => '',
    );
}

sub _field_term {
    my($m, $f, $t) = @_;
    ($t = $f) =~ s/[^a-z]//ig
	unless $t;
    return 'X' . uc($t) . ':' . lc($m->get_or_default($f, ''));
}

sub _omega_terms {
    my($self) = @_;
    my($d) = $_DT->to_local_file_name($self->get('modified_date_time'));
    return (
	 # Q set by caller, since used in general to delete/add docs
	 'S' . lc($self->get('title')),
	 'T' . lc($self->get('content_type')),
	 'P' . lc($self->get_or_default('path', '')),
	 map({
	     my($t, $l) = split(//, $_);
	     $t . substr($d, 0, $l);
	 } qw(D8 M6 Y4)),
    );
}

sub _postings {
    use bytes;
    return [
	map(
	    map(
		map(
		    length($_) ? lc($_) : (),
		    $_ =~ /^[\W_]*((?:[A-Z]\.){2,10})[\W_]*$/ ? $1 : split(/[\W_]+/, $_),
		),
		split(' ', $$_),
	    ),
	    @_,
	),
    ];
}

sub _terms {
    my($self) = @_;
    return [
	_field_term($self, 'realm_id'),
	_field_term($self, 'user_id'),
	_field_term($self, 'is_public'),
	_omega_terms($self),
    ];
}

1;

