# Copyright (c) 2007-2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Util::Wiki;
use strict;
use Bivio::Base 'Bivio.ShellUtil';
b_use('IO.Trace');

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
our($_TRACE);

sub USAGE {
    return <<'EOF';
usage: b-wiki [options] command [args..]
commands
  from_xhtml file.html ... - converts file.html to file (wiki)
  validate_all_realms - call validate_realm for all realms with wiki/blog files
  validate_realm [email] - call Action.WikiValidator; send email if $email
EOF
}

sub from_xhtml {
    my($self, @files) = @_;
    $self->use('XML::Parser');
    $self->use('HTML::Entities');
    $self->use('Bivio::IO::File');
    foreach my $in (@files) {
	(my $out = $in) =~ s/\.html$//;
	my($html) = ${Bivio::IO::File->read($in)};
	$html =~ s{\&reg\;}{(r)}g;
	_recurse(
	    $self,
	    \&_extract_content,
	    XML::Parser->new(Style => 'Tree')->parse($html));
	my($wiki) = _recurse($self, \&_from_xhtml, $self->get('content'));
	$wiki =~ s{\n{2,}}{\n}sg;
	$wiki =~ s{\n{3,}}{\n\n}sg;
	Bivio::IO::File->write($out, \$wiki);
    }
    return;
}

sub validate_all_realms {
    my($self) = @_;
    my($req) = $self->initialize_fully;
    my($wv) = b_use('Action.WikiValidator');
    my($realms) = b_use('Type.StringArray')->sort_unique(
	$self->model('RealmFile')->map_iterate(
	    sub {shift->get('realm_id')},
	    'unauth_iterate_start',
	    {path_lc => [map({
		my($type) = $_;
		map(lc($type->to_absolute(undef, $_)), 0, 1),
	    } $wv->TYPE_LIST)]},
	),
    );
#TODO: need to know which realm is in which facade(?)
    return [sort(map({
	$req->with_realm($_, sub {
	    my($die);
	    my($res) = Bivio::Die->catch_quietly(
		sub {
		    return $self->validate_realm(
			$self->model('EventEmailSettingList')
			    ->event_email_for_auth_realm('WikiValidator'),
		    );
		},
		\$die,
	    );
	    $self->commit_or_rollback($die && 1);
	    my($msg) = join(
		': ',
		$self->req(qw(auth_realm owner_name)),
		$res || $die->as_string,
	    );
	    _trace($msg) if $_TRACE;
	    return $msg;
	});
    } @$realms))];
}

sub validate_realm {
    my($self, $email) = @_;
    my($req) = $self->initialize_fully;
    my($wv) = b_use('Action.WikiValidator')->validate_realm($req);
    return 'ok'
	unless my $errors = $wv->get('errors');
    return $errors
	unless $email;
    $wv->send_mail($email);
    return scalar(@$errors) . ' errors';
}

sub _extract_content {
    my($self, $tag, $children) = @_;
    return
	unless $tag;
    my($copy) = [@$children];
    $self->put(content => $copy)
	if (shift(@$copy)->{class} || '') =~ /^(?:main_middle|main_body)$/;
    _recurse($self, \&_extract_content, $copy);
    return;
}

sub _from_xhtml {
    my($self, $tag, $children) = @_;
    unless ($tag) {
	$children .= "\n"
	    unless $children =~ /\n$/s;
	return $children;
    }
    my($attr) = shift(@$children);
    delete($attr->{target});
    $attr->{href} =~ s/[\?\&]fc=[^&]+//
	if $attr->{href};
    my($value) = _recurse($self, \&_from_xhtml, $children);
    $value = "\n"
	unless defined($value) && length($value);
    return join('',
	'@',
	join(' ', $tag, map(
	    $attr->{$_} =~ /\s/ ? qq{$_="$attr->{$_}"} : qq{$_=$attr->{$_}},
	    sort(keys(%$attr)))),
	($value =~ /\@|\n.*\n/s ? ("\n", $value, '@/', $tag, "\n") : " $value"),
    );
}

sub _recurse {
    my($self, $op, $children) = @_;
    return join('', @{$self->map_by_two(sub {$op->($self, @_)}, $children)});
}

1;
