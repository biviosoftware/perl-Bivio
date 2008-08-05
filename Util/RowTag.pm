# Copyright (c) 2007-2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Util::RowTag;
use strict;
use Bivio::Base 'Bivio::ShellUtil';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_RTK) = __PACKAGE__->use('Type.RowTagKey');

sub USAGE {
    return <<'EOF';
usage: b-row-tag [options] command [args..]
commands
  replace_value key [value] -- calls RowTag->replace_value with auth_id
  list [key...] -- calls RowTag->replace_value with auth_id
EOF
}

sub list {
    my($self, @key) = (shift, @_
	? map($_RTK->from_name($_), @_)
	: grep(!$_->eq_unknown, $_RTK->get_list));
    my($rt) = $self->model('RowTag');
    my($id) = $self->req('auth_id');
    return join('', map(
	$_->get_name
	    . '='
	    . ${Bivio::IO::Ref->to_string($rt->get_value($id, $_))},
	@key));
}

sub replace_value {
    my($self, $key, $value) = shift->name_args([
	['RowTagKey'],
	[RowTagValue => undef, undef],
    ], \@_);
    $self->model('RowTag')->replace_value($self->req('auth_id'), $key, $value);
    return;
}

1;
