# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Search::RealmFile;
use strict;
use base 'Bivio::UNIVERSAL';
use Bivio::Type;
use Bivio::IO::Trace;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
our($_TRACE);
my($_BFN) = Bivio::Type->get_instance('BlogFileName');
my($_DT) = Bivio::Type->get_instance('DateTime');
my($_FP) = Bivio::Type->get_instance('FilePath');
my($_WN) = Bivio::Type->get_instance('WikiName');
my($_TYPE_OK) = {};

sub parse_content {
    my($proto, $realm_file) = @_;
    my($ct) = $realm_file->get_content_type;
    (my $op = $ct) =~ s/\W+/_/g;
    $op = \&{'_from_' . $op};
    if (defined(&$op)
        and my $attr = Bivio::Die->eval(
	    # realm_file_id is useful in warning generated stack traces
	    sub {$op->($proto, $realm_file, $realm_file->get('realm_file_id'))})
    ) {
	$_TYPE_OK->{$ct} = 1;
	_trace($realm_file, ' => ', $attr) if $_TRACE;
	return $attr ? {map(($_ => shift(@$attr)), qw(type title text))} : ();
    }
    Bivio::IO::Alert->warn(
	$realm_file, ': unhandled content type or error parsing; ignoring'
    ) if $_TYPE_OK->{$ct} || !defined($_TYPE_OK->{$ct});
    $_TYPE_OK->{$ct} ||= 0;
    return;
}

sub parse_for_xapian {
    my($proto, $realm_file) = @_;
    return
	unless my $attr = $proto->parse_content($realm_file);
    return (
	_terms($proto, $realm_file, $attr),
	_postings(\$attr->{title}, $attr->{text}),
    );
}

sub _field_term {
    my($m, $f, $t) = @_;
    ($t = $f) =~ s/[^a-z]//ig
	unless $t;
    return 'X' . uc($t) . ':' . lc($m->get_or_default($f, ''));
}

sub _from_application_octet_stream {
    my($proto, $rf) = @_;
    if (-B $rf->get_os_path) {
	Bivio::IO::Alert->info($rf, ': unhandled binary file');
	return;
    }
    my($p) = $rf->get('path');
    return _from_application_x_bwiki($proto, $rf)
	if $_WN->is_absolute($p)
	|| $_BFN->is_absolute($p);
    return _from_text_plain($proto, $rf);
}


sub _from_application_pdf {
    my($proto, $rf) = @_;
    my($path) = $rf->get_os_path;
    my $x = `pdfinfo $path 2>&1`;
    my($title) = !$? && $x =~ /^Title:\s*(.*)/im ? $1 : undef;
    unless (defined($title)) {
	my($ct) = $rf->get_content_type;
	return if defined($_TYPE_OK->{$ct}) && !$_TYPE_OK->{$ct};
	Bivio::IO::Alert->warn($rf, ': pdfinfo error: ', $x);
	$title = '';
    }
    $x = `pdftotext $path - 2>&1`;
    if ($? || $x =~ /^Error:/s) {
	Bivio::IO::Alert->warn($rf, ': pdftotext error: ', $x);
	return;
    }
    $x =~ s/^\s*\n$//mg;
    return ['application/pdf', $title, \$x];
}

sub _from_application_x_bwiki {
    my($proto, $rf) = @_;
    my($text) = $rf->get_content;
    $$text =~ s/(?:^|\n)\@h\d+\s+([^\n]+)\n//s;
    my($title) = $1;
    $$text =~ s/(?=\@p)/\n/mg;
    $$text =~ s/^\@(?:\!.*\n|\S+(?:\s*\w+=\S+)*\s*)//mg;
    return [
	'text/plain',
	$title || $_FP->get_base($rf->get('path')),
	$text,
    ];
}

sub _from_message_rfc822 {
    my($proto, $rf) = @_;
    my($subject) = '';
    my($msg) = join(
	"\n\n",
	@{$rf->new_other('MailPartList')->load_from_content($rf->get_content)
	->map_rows(sub {
	    my($it) = @_;
	    my($mt) = $it->get('mime_type');
	    return $it->get_body
		if $mt eq 'text/plain';
	    return ${_from_text_html($proto, $it->get_body)->[2]}
		if $mt eq 'text/html';
	    # Subject must be first
	    if ($mt eq 'x-message/rfc822-headers') {
		$subject ||= $it->get_header('subject');
		return join("\n", map(
		    $_ . ': ' . $it->get_header($_),
		    qw(subject to from),
		));
	    }
#TODO: handle other parts like pdf, doc, zip, etc.
	    return '';
        })},
    );
    return ['message/rfc822', $subject, \$msg];
}

sub _from_text_csv {
    return _from_text_plain(@_);
}

sub _from_text_html {
    my($proto, $rf_or_text) = @_;
    my($t) = ref($rf_or_text) ? $rf_or_text->get_content : \$rf_or_text;
    $$t =~ s{<title\s*>([^<]+)</title\s*>}{}is;
    $$t =~ s/<p[^>]*>|<br[^>]*>\s*(&nbsp;?)*<br[^>]*>/ PARAGRAPH_SPLIT_HERE /isg;
    my($title) = $1;
    $title =~ s/^\s+|\s+$//gs
	if defined($title);
    $t = $proto->use('Bivio::HTML::Scraper')->to_text($t);
    $$t =~ s/\s+/ /sg;
    $$t =~ s/ *\bPARAGRAPH_SPLIT_HERE\b */\n\n/sg;
    return [
	'text/html',
	$title || '',
	$t,
    ];
}

sub _from_text_plain {
    my(undef, $rf) = @_;
    my($ct) = $rf->get_content_type;
    return [
	$ct eq 'application/octet-stream' ? 'text/plain' : $ct,
	'',
	$rf->get_content,
    ];
}

sub _from_text_tab_separated_values {
    return _from_text_plain(@_);
}

sub _omega_terms {
    my($proto, $rf, $attr, $author, $newsgroup) = @_;
    my($d) = $_DT->to_local_file_name($rf->get('modified_date_time'));
    return (
	 'A' . lc($author),
	 'G' . lc($newsgroup),
#TODO: 'H' . ?????
	 # Q set by caller, since used in general to delete/add docs
	 'P' . $rf->get('path_lc'),
	 $attr->{title} ? 'S' . lc($attr->{title}) : (),
	 'T' . lc($attr->{type}),
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
		    $_ =~ /^\W*((?:[A-Z]\.){2,10})\W*$/ ? $1 : split(/\W+/, $_),
		),
		split(/\s+/, $$_),
	    ),
	    @_,
	),
    ];
}

sub _terms {
    my($proto, $rf, $attr) = @_;
    my($e) = $rf->new_other('Email');
    my($r) = $rf->new_other('RealmOwner');
    my($newsgroup, $author);
    return [
	_field_term($rf, 'realm_id'),
	_field_term($rf, 'user_id'),
	_field_term($rf, 'is_public'),
	_field_term($rf, 'is_read_only'),
	$e->unauth_load({realm_id => $rf->get('user_id')})
	    ? _field_term($e, 'email') : (),
	map({
	    my($f) = $_;
	    $r->unauth_load_or_die({realm_id => $rf->get($f . '_id')});
	    $newsgroup ||= $r->get('name');
	    $author = $r->get('display_name');
	    (
		_field_term($r, 'name', $f),
		_field_term($r, 'display_name', $f . 'fullname'),
	    );
	} qw(realm user)),
	_omega_terms(
	    $proto,
	    $rf,
	    $attr,
	    $author . ' ' . $e->get_or_default('email', ''),
	    $newsgroup),
    ];
}

1;
