# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Search::Parser::RealmFile::MessageRFC822;
use strict;
use Bivio::Base 'Bivio::UNIVERSAL';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_MPL) = __PACKAGE__->use('Model.MailPartList');
my($_RF) = __PACKAGE__->use('SearchParser.RealmFile');

sub CONTENT_TYPE_LIST {
    return 'message/rfc822';
}

sub handle_parse {
    my($proto, $parseable) = @_;
    my($subject) = '';
    my($msg) = join(
	"\n\n",
	@{$_MPL->new($parseable->get('req'))->load_from_content(
	    $parseable->get_content,
	)->map_rows(sub {
	    my($it) = @_;
	    my($mt) = $it->get('mime_type');
	    if ($mt eq 'x-message/rfc822-headers') {
		$subject ||= $it->get_header('subject');
		return join("\n", map(
		    $_ . ': ' . $it->get_header($_),
		    qw(subject to from),
		));
	    }
	    my($attr) = $_RF->parse(
		$parseable->new({
		    req => $parseable->req,
		    content_type => $mt,
		    content => \($it->get_body),
		}),
	    );
	    return $attr ? ${$attr->{text}} : ();
        })},
    );
    return ['message/rfc822', $subject, \$msg];
}


1;
