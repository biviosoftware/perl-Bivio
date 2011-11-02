# Copyright (c) 2000-2008 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Ext::HTTPCookies;
use strict;
use base 'HTTP::Cookies';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_F) = Bivio::UNIVERSAL->use('IO.File');
my($_D) = Bivio::UNIVERSAL->use('Bivio.Die');

# sub clone {
#     my($self) = @_;
#     my($tmp) = $_F->temp_file;
#     my($res) = return $_D->eval_or_die(sub {
#         $self->save($tmp);
# 	my($clone) = ref($self)->new(
# 	    map(
# 		($_ => $self->{$_}),
# 		grep($_ ne 'COOKIES', keys(%$self)),
# 	    ),
# 	);
# 	$clone->load($tmp);
# 	return $clone;
#     });
#     unlink($tmp);
#     return $res;
# }
