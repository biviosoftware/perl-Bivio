# Copyright (c) 2009 bivio Software Inc.  All Rights Reserved.
# $Id$
package Bivio::Util::Spider;
use strict;
use Bivio::Base 'Collection.Attributes';
use URI ();
use HTML::Parser ();
use LWP::RobotUA ();

my($_IDI) = __PACKAGE__->instance_data_index;
sub EXCLUDE_PATTERNS {
    return [
        qr{\.pdf$},
        qr{\.png$},
        qr{\.gif$},
        qr{\.jpg$},
        qr{\.jpeg$},
        qr{\.mov$},
    ];
}

sub new {
    my($self) = shift->SUPER::new(@_);
    Bivio::Die->die('must define "base" with an absolute URL')
            unless $self->unsafe_get('base')
                && (my $base = URI->new_abs('', $self->unsafe_get('base')));
    my($fields) = $self->[$_IDI] = {
        seen => {},
        queue => [],
        in_queue => {},
        page_links => [],
    };
    $fields->{parser} = HTML::Parser->new(
        api_version => 3,
        start_h => [sub {
            my($attr) = @_;
            return
                unless $attr->{href}
                    && (my $uri = $self->local_uri($attr->{href}));
            push(@{$fields->{page_links}}, $uri);
            return;
        }, 'attr'],
    );
    $fields->{parser}->report_tags('a');
    $self->put(user_agent => LWP::RobotUA->new(
        agent => __PACKAGE__,
        from => $self->get_if_defined_else_put(
            from_email => 'software@bivio.biz'),
        cookie_jar => {
#TODO: need to cleanup tmp files	    
#            file => $self->get_if_defined_else_put(
#                cookies => b_use('IO.File')->temp_file),
#            autosave => 1,
            ignore_discard => 1,
        },
    ))
        unless $self->has_keys('user_agent');
    $self->put(visitor => sub {print(shift, "\n")})
        unless $self->has_keys('visitor');
    return $self;
}

sub assert_absolute_and_bivio {
    shift;
    my($uri) =  URI->new(shift);
    Bivio::Die->die($uri,
                    ': not an absolute http URI or not in bivio.biz domain')
	unless $uri->scheme
            && $uri->authority =~ /bivio.biz$/;
    return $uri;
}

sub dequeue_uri {
    my($fields) = shift->[$_IDI];
    my($link) = shift(@{$fields->{queue}});
    delete($fields->{in_queue}->{$link})
        if $link;
    return $link;
}

sub enqueue_uri {
    my($self, @links) = @_;
    my($fields) = shift->[$_IDI];
    foreach my $link (@links) {
        next
            if !$link || $fields->{in_queue}->{$link};
        push(@{$fields->{queue}}, $link);
        $fields->{in_queue}->{$link} = 1;
    }
    return;
}

sub local_uri {
    my($self, $raw) = @_;
    my($base) = URI->new($self->get('base'));
    $raw =~ s{/$}{};
    my($uri) = URI->new_abs($raw, $base)->canonical;
    $uri->query(undef);
    return
        unless $uri->scheme =~ /https?/
            && $uri->host eq $base->host
            && !grep($uri->as_string =~ $_,
                     @{$self->get_or_default('exclude',
                                             $self->EXCLUDE_PATTERNS)})
            && grep($uri->as_string =~ $_,
                    @{$self->get_or_default('include', [qr{.}])});
    return $uri->as_string;
}

sub login {
    # saves to the cookies file specified in the constructor
    my($self, $username, $password) = @_;
    return $self->get('user_agent')->post($self->local_uri('/pub/login'), {
        v => 1,
        x1 => $username,
        x2 => $password,
    });
}

sub parse_links {
    my($self, $content_ref) = @_;
    my($fields) = $self->[$_IDI];
    @{$fields->{page_links}} = ();
    my($fh);
    open($fh, '<', $content_ref);
    $fields->{parser}->parse_file($fh);
    close($fh);
    return;
}

sub visit {
    my($self) = shift;
    my($fields) = $self->[$_IDI];
    $self->enqueue_uri($self->get('base'));
    my($limit) = -1;
    my($visitor) = $self->get('visitor');
    while ($limit-- && (my $link = dequeue_uri($self))) {
        my($res);
        next
            unless !$fields->{seen}->{$link}++
                && ($res = $self->get('user_agent')->get($link))
                && $res->is_success;
        next
            unless $res->header('Content-Type') eq 'text/html';
        my($content_ref) = $res->content_ref;
        $self->parse_links($content_ref);
        $self->enqueue_uri(map(local_uri($self, $_),
                                @{$fields->{page_links}}));
        $visitor->($link, $content_ref);
    }
    return;
}

sub _bunit_get_field {
    return shift->[$_IDI]->{shift()};
}

1;
