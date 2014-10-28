# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Search::Parser::RealmFile::MessageRFC822;
use strict;
use Bivio::Base 'SearchParser.RealmFile';

my($_MPL) = b_use('Model.MailPartList');
my($_RF) = b_use('SearchParser.RealmFile');
my($_A) = b_use('Mail.Address');

sub CONTENT_TYPE_LIST {
    return 'message/rfc822';
}

sub handle_realm_file_new_text {
    my($proto, $parseable) = @_;
    my($subject) = '';
    my($author, $author_email);
    my($msg) = join(
	"\n\n",
	@{$_MPL->new($parseable->get('req'))->load_from_content(
	    $parseable->get_content,
	)->map_rows(sub {
	    my($it) = @_;
	    my($mt) = $it->get('mime_type');
	    if ($mt eq 'x-message/rfc822-headers') {
		$subject ||= $it->get_header('subject');
		unless ($author_email) {
		    my($e, $n) = $_A->parse($it->get_header('from'));
		    if ($e) {
			$author = $n || $_A->parse_local_part($e);
			$author_email = $e;
		    }
		}
		return join("\n", map(
		    ucfirst($_) . ': ' . $it->get_header($_),
		    qw(subject to from),
		));
	    }
	    return
		unless my $p = $proto->new_text(
		    $parseable->new({
			class => 'RealmFile',
			req => $parseable->req,
			content_type => $mt,
			content => \($it->get_body),
			model => $parseable->get('model'),
		    }),
		);
	    return ${$p->get('text')};
        })},
    );
    return $proto->new({
	author_email => $author_email,
	author => $author,
	type => 'message/rfc822',
	title => $subject,
	text => \$msg,
    });
}

sub handle_realm_file_new_excerpt {
    my($proto) = shift;
    my($self) = ref($proto) ? $proto : $proto->new_text(@_);
    my($text) = $self->get('text');
    my($v) = (split(/\n\n/, $$text, 2))[1];
    $v = ''
	unless defined($v);
    $self->put(text => \$v);
    return $self->SUPER::handle_realm_file_new_excerpt(@_)
	->put(text => $text);
}

1;
