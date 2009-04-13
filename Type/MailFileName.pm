# Copyright (c) 2006-2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Type::MailFileName;
use strict;
use Bivio::Base 'Type.DocletFileName';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_DT) = b_use('Type.DateTime');
my($_UNIQUE);
my($_R) = b_use('Biz.Random');

sub PRIVATE_FOLDER {
    return shift->MAIL_FOLDER;
}

sub REGEX {
    return qr{(@{[shift->join('\d{4}-\d{2}', '[^/]*\d{14}-\d{3,5}.eml')]})}i;
}

sub to_unique_absolute {
    my($proto, $date, $is_public) = @_;
    return $proto->to_absolute(
	$proto->join(
	    sprintf('%04d-%02d', $_DT->get_parts($date, qw(year month))),
		$_DT->to_file_name($date)
		. '-'
		. _unique()
		. '.eml',
	),
	$is_public,
    );
}

sub _unique {
    return sprintf(
	'%05d',
	$_UNIQUE = (defined($_UNIQUE) ? ++$_UNIQUE : $_R->integer) % 100_000,
    );
}

1;
