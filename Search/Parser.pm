# Copyright (c) 2008-2011 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Search::Parser;
use strict;
use Bivio::Base 'Collection.Attributes';

my($_DT) = b_use('Type.DateTime');
my($_M) = b_use('Biz.Model');
my($_P) = b_use('Search.Parseable');
my($_S) = b_use('Type.String');
my($_D) = b_use('Bivio.Die');

sub handle_new_excerpt {
    my($self, $parseable) = @_;
    $self = $self->new
        unless ref($self);
    $self->handle_new_text($parseable)
        unless $self->unsafe_get('text');
    return $self->put(excerpt => $parseable->get_excerpt);
}

sub handle_new_text {
    my($self, $parseable) = @_;
    $self = $self->new
        unless ref($self);
    return $self->put(text => $parseable->get_content);
}

sub new_text {
    return _do(@_);
}

sub new_excerpt {
    return _do(@_);
}

sub xapian_posting_synonyms {
    return [];
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
    my($parseable) = $_P->is_blesser_of($model) ? $model : $_P->new($model);
    $model = $parseable->get('model');
    my($method) = 'handle_' . $proto->my_caller;
    my($die);
    my($self) = $_D->catch(
        sub {
            return b_use(SearchParser => $parseable->get('class'))
                ->$method($parseable);
        },
        \$die,
    );
    b_warn('Could not parse file:', $die->get('attrs'))
        if $die;
    $self ||= $proto->new();
    $parseable->map_each(
        sub {
            shift;
            return $self->put_unless_exists(@_);
        },
    );
    my($no_text) = '';
    $self->put_unless_exists(
        'RealmOwner.realm_id' => $model->get_auth_id,
        req => $parseable->req,
        author => '',
        author_email => '',
        author_user_id => $model->get_auth_user_id,
        excerpt => '',
        modified_date_time => sub {
            return $model->unsafe_get('modified_date_time') || $_DT->now;
        },
        path => '',
        primary_id => $model->get_primary_id,
        simple_class => $model->simple_package_name,
        type => 'unparsed',
        title => '',
        text => \$no_text,
    );
    foreach my $v (values(%{$self->internal_get})) {
        $_S->canonicalize_charset(\$v)
            unless ref($v);
    }
    return $self;
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
                split(' ', ${$_S->canonicalize_charset($_)}),
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
        _field_term($self, 'simple_class'),
        _omega_terms($self),
    ];
}

1;
