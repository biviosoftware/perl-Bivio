# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Search::Parser::RealmFile::MessageRFC822;
use strict;
use Bivio::Base 'SearchParser.RealmFile';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_MPL) = __PACKAGE__->use('Model.MailPartList');
my($_RF) = __PACKAGE__->use('SearchParser.RealmFile');
my($_A) = __PACKAGE__->use('Mail.Address');

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
    my($self) = shift->new_text(@_);
    $self->put(text => \((split(/\n\n/, ${$self->get('text')}, 2))[1]));
    return $self->SUPER::handle_realm_file_new_excerpt(@_);
}

1;
