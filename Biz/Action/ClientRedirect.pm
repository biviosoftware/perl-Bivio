# Copyright (c) 1999-2011 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Action::ClientRedirect;
use strict;
use Bivio::Base 'Biz.Action';
b_use('IO.ClassLoaderAUTOLOAD');

my($_HTTP_MOVED_PERMANENTLY) = b_use('Ext.ApacheConstants')->HTTP_MOVED_PERMANENTLY;
my($_DOMAINS);
my($_CONST_DOMAINS) = [qw(
    bivio.biz
    bivio.com
    extremeperl.org
)];

b_use('IO.Config')->register(my $_CFG = {
    permanent_map => {},
    valid_domains => [],
});


sub QUERY_TAG {
   return 'x';
}

sub execute_cancel {
    my(undef, $req) = @_;
    return 'cancel';
}

sub execute_home_page_if_site_root {
    my($proto, $req) = @_;
    return {
        uri => _uri(
            $req,
            b_use('FacadeComponent.Text')->get_value('home_page_uri', $req),
        ),
        query => undef,
    } if $req->get('uri') =~ m{^/?$};
    return;
}

sub execute_next {
    return 'next';
}

sub execute_next_stateless {
    my(undef, $req) = @_;
    return {
        task_id => 'next',
        query => undef,
    };
}

sub execute_permanent_map {
    my($proto, $req) = @_;
    b_die('NOT_FOUND')
        unless my $new = $_CFG->{permanent_map}->{$req->get('uri')};
    return {
        uri => $new,
        query => $req->get('query'),
        http_status_code => $_HTTP_MOVED_PERMANENTLY,
    };
}

sub execute_query {
    my($proto, $req) = @_;
    my($query) = $req->unsafe_get('query');
    return 'next'
        unless $query && defined(my $uri = delete($query->{$proto->QUERY_TAG}));
    $uri =~ s,^(?!\w+:|\/),\/,;
    return {
        uri => _uri($req, $uri),
        query => undef,
    };
}

sub execute_query_or_path_info {
    my($proto, $req) = @_;
    return shift->execute_query(@_)
        if ($req->unsafe_get('query') || {})->{$proto->QUERY_TAG};
    return  $req->get('path_info') ? {
        uri => _uri($req, $req->get('path_info')),
        query => $req->get('query'),
    } : {
        task_id => 'next',
        query => undef,
    };
}

sub execute_query_redirect {
    my($proto, $req) = @_;
    my($query) = $req->get('query');
    b_die('NOT_FOUND', 'missing QUERY_TAG')
        unless my $value = delete($query->{$proto->QUERY_TAG});
    my($uri, $err) = Type_HTTPURI()->from_literal($value);
    if ($err) {
        if (! $req->unsafe_get('referer')
            || ($req->ureq('Type.UserAgent')
                && $req->req('Type.UserAgent')->is_robot)) {
            # ignore robots with bad uris, ignore missing referer
            $uri = '/';
        }
        else {
            b_die('invalid query redirect uri: ', $value)
        }
    }
    else {
        _assert_external_uri($uri, $req);
    }
    return {
        uri => $uri,
    };
}

sub execute_unauth_role_in_realm {
    my($proto, $req) = @_;
    my($us) = $req->get('user_state');
    return {
        query => undef,
        path_info => undef,
        task_id => _role_in_realm_user_state($req),
    };
}

sub get_realm_for_task {
    my($proto, $task, $req) = @_;
    my($t) = b_use('Agent.Task')->get_by_id($task);
    my($rt) = $t->get('realm_type');
    my($done);
    return $req->map_user_realms(sub {
         my($row) = @_;
         return
             if $done;
         my($realm) = b_use('Auth.Realm')->new($row->{'RealmOwner.name'}, $req);
         return $realm->can_user_execute_task($t, $req) ? $realm : ();
    }, {
        'RealmOwner.realm_type' => $rt->self_or_any_group,
    })->[0] || $rt->eq_general && b_use('Auth.Realm')->get_general
    || b_use('Bivio.Die')->throw(NOT_FOUND => {
        entity => $task,
        message => 'no appropriate realm for task',
    });
}

sub handle_config {
    my(undef, $cfg) = @_;
    $_CFG = $cfg;
    return;
}

sub _assert_external_uri {
    my($uri, $req) = @_;
    if ($uri =~ m{^/}) {
        return;
    }
    my($d) = $uri =~ m{^https?://([^/]+)}i;
    if (! $d) {
        b_warn('not http uri=', $uri);
        b_die('NOT_FOUND');
    }
    $d = _second_level_domain($d);
    $_DOMAINS ||= _domains($req);
    if (! grep($_ eq $d, @$_DOMAINS)) {
        b_warn('invalid domain=', $d);
        b_die('NOT_FOUND');
    }
    return;
}

sub _domains {
    my($req) = @_;
    my($s) = {};
    return [map(
        {
            my($x) = _second_level_domain($_);
            $s->{$x}++ ? () : $x;
        }
        @{UI_Facade()->map_iterate_with_setup_request(
            $req,
            sub {return shift->get('http_host')},
        )},
        @$_CONST_DOMAINS,
        @{$_CFG->{valid_domains}},
    )];
}

sub _role_in_realm {
    my($req) = @_;
    my($t) = $req->get('task');
    my($r) = [grep(
        $t->unsafe_get_attr_as_id($_),
        map(lc($_->get_name) . '_task', @{$req->get_auth_roles}),
    )];
    return @$r == 0 ? 'next'
        : @$r == 1 ? $r->[0]
        : b_die($r, ': too many roles match task attributes');
}

sub _role_in_realm_user_state {
    my($req) = @_;
    my($us) = $req->get('user_state');
    return $us->eq_just_visitor ? 'just_visitor_task'
        : $us->eq_logged_in ? _role_in_realm($req)
        : $req->with_user(
            b_use('Biz.Model')->new($req, 'UserLoginForm')
                ->unsafe_get_cookie_user_id($req),
            sub {_role_in_realm($req)},
        );
}

sub _second_level_domain {
    my($domain) = @_;
    # only happens on dev
    $domain =~ s{:.*}{};
    return lc($1)
        if $domain =~ m{([^\.]+\.[^\.]+)$};
    # not a valid domain
    b_die('NOT_FOUND');
}

sub _uri {
    my($req, $uri) = @_;
    _assert_external_uri($uri, $req);
    return $req->format_uri({uri => $uri, query => undef, path_info => undef});
}

1;
