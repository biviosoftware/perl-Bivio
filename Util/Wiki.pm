# Copyright (c) 2007-2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Util::Wiki;
use strict;
use Bivio::Base 'Bivio.ShellUtil';
b_use('XML::Parser');
b_use('HTML::Entities');
b_use('IO.Trace');

our($_TRACE);
my($_BF) = b_use('Type.FilePath')->BLOG_FOLDER;
my($_VF) = b_use('Type.FilePath')->VERSIONS_FOLDER;
my($_WN) = b_use('Type.WikiName');
my($_WF) = $_WN->WIKI_FOLDER;
my($_F) = b_use('IO.File');

sub USAGE {
    return <<'EOF';
usage: b-wiki [options] command [args..]
commands
  from_xhtml file.html ... - converts file.html to file (wiki)
  upgrade_blog_titles -- converts H3 tag at the top of blog article to H1 tag
  upgrade_content -- upgrades WikiText to new format requiring explicit links
  validate_all_realms [email] - call validate_realm for all realms with wiki/blog files
  validate_realm [email] - call Action.WikiValidator; send email if $email
EOF
}

sub from_xhtml {
    my($self, @files) = @_;
    foreach my $in (@files) {
	(my $out = $in) =~ s/\.html$//;
	my($html) = ${$_F->read($in)};
	$html =~ s{\&reg\;}{(r)}g;
	_recurse(
	    $self,
	    \&_extract_content,
	    XML::Parser->new(Style => 'Tree')->parse($html));
	my($wiki) = _recurse($self, \&_from_xhtml, $self->get('content'));
	$wiki =~ s{\n{2,}}{\n}sg;
	$wiki =~ s{\n{3,}}{\n\n}sg;
	$_F->write($out, \$wiki);
    }
    return;
}

sub internal_check_path {
    my(undef, $path, $blog_only) = @_;
    return $path !~ /\Q$_VF\/\E/i
	&& ($path =~ /\Q$_BF\E\//i || ($blog_only xor $path =~ /\Q$_WF\/\E/i));
}

sub internal_upgrade_content {
    my($self, $content, $path_lc) = @_;
    return _update_b_tags($self, _update_caret_ampersand($self, $content));
}

sub upgrade_blog_titles {
    return _upgrade(
	shift,
	1,
	sub {
	    my($self, $rf, $content) = @_;
	    return _upgrade_title($self, $$content);
	},
    );
    return;
}

sub upgrade_content {
    return _upgrade(
	shift,
	0,
	sub {
	    my($self, $rf, $content) = @_;
	    return $self->internal_upgrade_content(
		$$content, $rf->get('path_lc'),
	    );
	},
    );
}

sub validate_all_realms {
    my($self, $email) = @_;
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
    my($all_txt);
    my($all_res) = [sort(map({
	$req->with_realm($_, sub {
	    return
		unless $req->req(qw(auth_realm type))->is_group;
	    my($die);
	    my($res) = Bivio::Die->catch_quietly(
		sub {$self->validate_realm},
		\$die,
	    );
	    $self->commit_or_rollback($die);
	    my($name) = $self->req(qw(auth_realm owner_name));
	    my($msg) = join(
		': ',
		$self->req(qw(auth_realm owner_name)),
		$res && $res->[1] || $die->as_string,
	    );
	    if ($res->[0]) {
		$all_txt .= "Errors in $name:\n";
		my($e) = ${$res->[0]};
		$e =~ s/^/  /mg;
		$all_txt .= $e . "\n";
	    }
	    _trace($msg) if $_TRACE;
	    return $msg;
	});
    } @$realms))];
    b_use('Action.WikiValidator')->new->put_on_request
	->send_all_mail(
	    $self->req(qw(auth_realm owner))->format_email,
	    $all_txt,
	);
    return [$all_res, $all_txt];
}

sub validate_realm {
    my($self) = @_;
    my($req) = $self->initialize_fully;
    my($wv) = b_use('Action.WikiValidator')->validate_realm($req);
    return [undef, 'ok']
	unless my $errors = $wv->get('errors');
    return [
	$wv->error_txt,
	scalar(@$errors) . ' errors',
    ];
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

sub _mutable_wikitext {
    my($self, $rf, $blog_only) = @_;
    return !$rf->get('is_folder') && $rf->get_content_type =~ /wiki/i
	&& $self->internal_check_path($rf->get('path_lc'), $blog_only);
}

sub _recurse {
    my($self, $op, $children) = @_;
    return join('', @{$self->map_by_two(sub {$op->($self, @_)}, $children)});
}

sub _update_caret_ampersand {
    my(undef, $content) = @_;
    $content =~ s/\^\&/\@\&/g;
    return $content;
}

sub _update_b_tags {
    my(undef, $content) = @_;
    $content
	=~ s/^\@b\-([a-z-]*)\s(?:value=)?(\S*)$/\@b-$1 value=$2/gmi;
   $content
	=~ s/^\@random\-img\s(?:value=)?(\S*)$/\@aa-random-image value=$1/gmi;
    $content
	=~ s/^\@(?:ins\-page|b\-embed)\s(?:value=)?(.*)$/\@b-embed value=$1/gmi;
    return $content;
}

sub _upgrade {
    my($self, $blog_only, $op) = @_;
    $self->are_you_sure('Upgrade all content?');
    $self->initialize_ui;
    $self->model('RealmFile')->do_iterate(
	sub {
	    my($rf) = @_;
	    return 1
		unless _mutable_wikitext($self, $rf, $blog_only);
	    _trace('CHECKING: ', $rf)
		if $_TRACE;
	    $self->req->with_realm(
		$rf->get('realm_id'),
		sub {
		    my($old) = $rf->get_content;
		    my($new) = $op->($self, $rf, $old);
		    return
			if $$old eq $new;
		    my($die) = Bivio::Die->catch(sub {
			_trace('CONTENT MODIFIED: ', $new)
			    if $_TRACE;
			$rf->update_with_content({
			    override_is_read_only => 1,
			}, \$new);
			return;
		    });
		    b_warn($rf, ': ', $die)
			if $die;
#TODO: Is this necessary?  Might commit after each realm, but each file?
		    $self->commit_or_rollback($die);
		    return;
		},
	    );
	    return 1;
	},
	$self->req('auth_realm')->is_general ? 'unauth_iterate_start' : (),
	'realm_file_id',
    );
    return;
}

sub _upgrade_title {
    my($self, $content) = @_;
    $content =~ s/^\s*\@h3/\@h1/;
    return $content;
}

1;
