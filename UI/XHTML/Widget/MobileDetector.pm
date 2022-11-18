# Copyright (c) 2011 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::XHTML::Widget::MobileDetector;
use strict;
use Bivio::Base 'XHTMLWidget.IfMobile';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($_TRACE);
b_use('IO.Trace');
my($_B) = b_use('Type.Boolean');
my($_QUERY_KEY) = 'b_mobile';
my($_COOKIE_KEY) = 'mobile';
my($_MOBILE_CLASS) = 'Mobile';
b_use('Agent.Task')->register(__PACKAGE__);
my($_SCRIPT) = _init_script(__PACKAGE__);

sub NEW_ARGS {
    return [];
}

sub uri_args_for {
    my($proto, $which, $req) = @_;
    b_die($which, ': must be desktop or mobile')
        unless $which =~ /^(?:desktop|mobile)$/;
    return {
        require_absolute => 1,
        task_id => $req->get('task_id'),
        query => {
            %{$req->unsafe_get('query') || {}},
            $_QUERY_KEY => $which eq 'mobile' ? 1 : 0,
        },
        carry_path_info => 1,
        control => b_use('UI.Facade')->get_from_source($req)
            ->get('Task')
            ->has_uri($req->get('task_id')),
    };
}

sub handle_pre_execute_task {
    my($proto, undef, $req) = @_;
    my($value) = _set($proto, $req);
    return
        unless defined($value);
    my($f) = b_use('UI.Facade')->get_from_source($req);
    return
        unless $value xor $f->equals_class_name($_MOBILE_CLASS);
    my($m) = $f->get_instance($_MOBILE_CLASS);
    $f = $value ? $m : $m->get('parent');
    _trace($f) if $_TRACE;
    $f->setup_request($req);
    return {
        method => 'client_redirect',
        %{$proto->uri_args_for($f == $m ? 'mobile' : 'desktop', $req)},
    };
}

sub initialize {
    my($self) = @_;
    $self->put(
        control => [
            sub {
                my($source, $key) = @_;
                return defined($source->ureq($key)) ? 0 : 1;
            },
            $self->REQ_KEY,
        ],
        control_on_value => SCRIPT({
            TYPE => 'text/javascript',
            value => $_SCRIPT,
        }),
    );
    return shift->SUPER::initialize(@_);
}

sub robot_redirect_for_desktop {
    my($proto, $req) = @_;
    my($f) = b_use('UI.Facade')->get_from_source($req);
    return
        unless $f->matches_class_name($_MOBILE_CLASS);
    $f->get('parent')->setup_request($req);
    if (my $cookie = $req->unsafe_get('cookie')) {
        $cookie->put($_COOKIE_KEY, 0);
    }
    return {
        require_absolute => 1,
        task_id => $req->get('task_id'),
        carry_query => 0,
        carry_path_info => 0,
        http_status_code => b_use('Ext.ApacheConstants')
            ->HTTP_MOVED_PERMANENTLY,
    };
}

sub _init_script {
    my($qk) = $_QUERY_KEY;
    return b_use('XHTMLWidget.JavaScript')->strip(<<"EOF");
(function() {
    if (screen.width > 460)
        return;
    var href = location.href;
    if (href.indexOf('?') < 0)
        href = href + '?';
    else if (href.indexOf('$qk=') >= 0)
        return;
    else
        href = href + '&';
    location.replace(href + '$qk=1');
    return;
})();
EOF
}

sub _set {
    my($proto, $req) = @_;
    my($query_value) = ($req->unsafe_get('query') || {})->{$_QUERY_KEY};
    my($cookie) = $req->unsafe_get('cookie');
    my($cookie_value) = $cookie && $cookie->unsafe_get($_COOKIE_KEY);
    my($value) = defined($query_value) ? $query_value
        : defined($cookie_value) ? $cookie_value
        : undef;
    _trace($value) if $_TRACE;
    $req->put_durable($proto->REQ_KEY, $value);
    return $value
        unless defined($value)
        && $cookie;
    return $value
        if $_B->is_equal($cookie_value, $value);
    _trace('set cookie') if $_TRACE;
    $cookie->put($_COOKIE_KEY, $value);
    return $value;
}

1;
