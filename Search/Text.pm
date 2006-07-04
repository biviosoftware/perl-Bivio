# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Search::Text;
use strict;
use base 'Bivio::UNIVERSAL';
use Bivio::Type;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_FP) = Bivio::Type->get_instance('FilePath');

sub parse {
    my($proto, $realm_file) = @_;
    (my $ct = $realm_file->get_content_type) =~ s/\W+/_/g;
    my($op) = \&{'_from_' . $ct};
    unless (defined(&$op)) {
	Bivio::IO::Alert->info($realm_file, ': unhandled content type')
	    if $ct =~ /^(?:text|application)_/;
	return;
    }
    my($attr) = $op->($proto, $realm_file);
    return $attr ? {map(($_ => shift(@$attr)), qw(type title text))} : ();
}

sub _from_application_x_bwiki {
    my($proto, $rf) = @_;
    my($text) = $rf->get_content;
    $$text =~ s/(?:^|\n)\@h\d+\s+([^\n]+)\n//s;
    my($title) = $1;
    $$text =~ s/^\@\S+(?:\s*\w+=\S+)*\s*//mg;
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
	"\n",
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
		return map(
		    ($_ . ': ' . $it->get_header($_)),
		    qw(subject to from),
		);
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
    my($title) = $1;
    $title =~ s/^\s+|\s+$//gs
	if defined($title);
    return [
	'text/html',
	$title || '',
	$proto->use('Bivio::HTML::Scraper')->to_text($t),
    ];
}

sub _from_text_plain {
    my(undef, $rf) = @_;
    my($ct) = $rf->get_content_type;
    return [
	$ct eq 'application/octet' ? 'text/plain' : $ct,
	'',
	$rf->get_content,
    ];
}

sub _from_text_tab_separated_values {
    return _from_text_plain(@_);
}

1;
