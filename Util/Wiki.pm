# Copyright (c) 2007-2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Util::Wiki;
use strict;
use Bivio::Base 'Bivio.ShellUtil';
b_use('IO.Trace');

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
our($_TRACE);
my($_BF) = b_use('Type.FilePath')->BLOG_FOLDER;
my($_VF) = b_use('Type.FilePath')->VERSIONS_FOLDER;
my($_WF) = b_use('Type.WikiName')->WIKI_FOLDER;

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

sub internal_upgrade_content {
    my($self, $content, $path_lc) = @_;
    $content = _update_caret_ampersand($self, $content);
    $content = _update_b_tags($self, $content);
    return $content;
}

sub upgrade_blog_titles {
    my($self) = @_;
    $self->assert_not_general;
    $self->initialize_ui;
    $self->model('RealmFile')->do_iterate(sub {
        my($it) = @_;
	return 1
	    unless _mutable_wikitext($self, $it, 1);
	_trace("***\nCHECKING: " . $it->get('path') . "\n") if $_TRACE;
	my($content) = _upgrade_title($self, ${$it->get_content});
	if (${$it->get_content} ne $content) {
	    my($die) = Bivio::Die->catch(
		sub {
		    _trace("CONTENT MODIFIED:\n" . $content . "\n") if $_TRACE;
		    $it->update_with_content({
			override_is_read_only => 1,
		    }, \$content);
		    $self->commit_or_rollback;
		}
	    );
	}
        return 1;
    });
    return;
}

sub upgrade_content {
    my($self) = @_;
    $self->assert_not_general;
    $self->initialize_ui;
    $self->model('RealmFile')->do_iterate(sub {
        my($it) = @_;
	return 1
	    unless _mutable_wikitext($self, $it);
	_trace("***\nCHECKING: " . $it->get('path') . "\n") if $_TRACE;
	my($content) = ${$it->get_content};
	$content = $self->internal_upgrade_content($content,
						   $it->get('path_lc'));
	if (${$it->get_content} ne $content) {
	    my($die) = Bivio::Die->catch(
		sub {
		    _trace("\nCONTENT MODIFIED:\n" . $content . "\n") if $_TRACE;
		    $it->update_with_content({
			override_is_read_only => 1,
		    }, \$content);
		    $self->commit_or_rollback;
		}
	    );
	}
        return 1;
    });
    return;
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
	    my($die);
	    my($res) = Bivio::Die->catch_quietly(
		sub {$self->validate_realm},
		\$die,
	    );
	    $self->commit_or_rollback($die && 1);
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
    return $all_res;
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
	&& _check_path($self, $rf->get('path_lc'), $blog_only);
}

sub _check_path {
    my(undef, $path, $blog_only) = @_;
    return $path !~ /\Q$_VF\/\E/i
	&& ($path =~ /\Q$_BF\E\//i || ($blog_only xor $path =~ /\Q$_WF\/\E/i));
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
	=~ s/^\@(?:ins\-page|b\-embed)\s(?:.*=)*(.*)$/\@b-embed value=$1/gm;
    $content
	=~ s/^\@b\-([a-z-]*)\s(?:\S*=)?(\S*)$/\@b-$1 value=$2/gm;
    $content
	=~ s/^\@random\-image\s(?:\S*=)?(\S*)$/\@random-image value=$1/gm;
    return $content;
}

sub _upgrade_title {
    my($self, $content) = @_;
    $content =~ s/^\s*\@h3/\@h1/;
    return $content;
}

1;
