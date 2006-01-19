# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::EmailAliasEditDAVList;
use strict;
use base 'Bivio::Biz::Model::EditDAVList';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub CSV_COLUMNS {
    return [qw(EmailAlias.incoming EmailAlias.outgoing primary_key)];
}

sub LIST_CLASS {
    return 'EmailAliasList';
}

sub row_create {
    return _op('create', @_);
}

sub row_delete {
    return _op('delete', @_);
}

sub row_update {
    my($self, $new, $old) = @_;
    $self->row_delete($old);
    $self->row_create($new);
    return;
}

sub _op {
    my($op, $self, $val) = @_;
    $self->new_other('EmailAlias')
	->$op({map(($_ => $val->{"EmailAlias.$_"}), qw(incoming outgoing))});
    return;
}

1;
