# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Util::Xapian;
use strict;
use base 'Bivio::ShellUtil';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub USAGE {
    return <<'EOF';
usage: b-xapian [options] command [args..]
commands
  realm_file_to_text file -- convert file to title (first line) and text
EOF
}

sub realm_file_to_text {
    my($self, $file) = @_;
    my($rf) = Bivio::Biz::Model->new($self->get_request, 'RealmFile');
    Bivio::Die->die($file, ': unable to load as RealmFile')
        unless $rf->unauth_load_by_os_path($file);
    my($op) = \&{
	'_from_'
	. $self->use('Type.FilePath')->get_suffix($rf->get('path_lc'))
    };
    $rf->throw_die(NOT_FOUND => {
	entity => $self->use('Type.FilePath')->get_suffix($rf->get('path_lc')),
	message => 'unknown suffix',
    }) unless defined(&$op);
    return join("\n", $op->($self, $file, $rf));
}

sub _from_ {
    my($self, $file, $rf) = @_;
    $rf->throw_die(IO_ERROR => {
	entity => $file,
	message => 'binary file',
    }) if -B $file;
    return _from_bwiki($self, $file, $rf)
	if $self->use('Type.WikiName')->is_absolute_path($rf->get('path'));
    return ('text/plain', '', ${$rf->get_content});
}

sub _from_bwiki {
    my($self, $file, $rf) = @_;
    my($text) = $rf->get_content;
    my($title) = $$text =~ /(?:^|\n)\@h\d+\s+([^\n]+)/s;
    $$text =~ s/^\@\S+\s*//mg;
    return (
	'application/x-bwiki',
	$title || $self->use('Type.FilePath')->get_base($rf->get('path')),
	$$text,
    );
}

sub _from_eml {
    my($self, $file, $rf) = @_;
    return (
        'message/rfc822',
	@{$rf->new_other('MailPartList')->load_all({
	    parent_id => $rf->get('realm_file_id'),
	})->map_rows(sub {
	    my($it) = @_;
	    my($mt) = $it->get('mime_type');
	    return $it->get_body
		if $mt eq 'text/plain';
	    return _html($self, $it->get_body)
		if $mt eq 'text/html';
	    # Subject must be first
	    return (map($it->get_header($_), qw(subject from_email)))
		if $mt eq 'x-message/rfc822-headers';
#TODO: handle other parts like pdf, doc, zip, etc.
	    return '';
        })},
    );
}

sub _html {
    my($self, $text) = @_;
    return (
	'text/html',
	'',
	${$self->use('Bivio::HTML::Scraper')->to_text(\$text)},
    );
}

1;
