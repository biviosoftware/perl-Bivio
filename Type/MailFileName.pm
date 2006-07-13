# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Type::MailFileName;
use strict;
use base 'Bivio::Type::DocletFileName';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_MS) = Bivio::Type->get_instance('MailSubject');
my($_DT) = Bivio::Type->get_instance('DateTime');

sub PRIVATE_FOLDER {
    return shift->MAIL_FOLDER;
}

sub REGEX {
    return qr{@{[shift->join('\d{4}-\d{2}', '[^/]+ \d{17}.eml')]}}i;
}

sub to_unique_absolute {
    my($proto, $date, $subject, $is_public) = @_;
    return $proto->to_absolute(
	$proto->join(
	    sprintf('%04d-%02d', $_DT->get_parts($date, qw(year month))),
	    $_MS->clean_and_trim($subject)
		. ' '
		. $_DT->to_file_name($date)
		. sprintf('%03d', int(rand(1_000)))
		. '.eml',
	),
	$is_public,
    );
}

1;
