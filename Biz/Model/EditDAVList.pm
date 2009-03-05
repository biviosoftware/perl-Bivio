# Copyright (c) 2005-2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::EditDAVList;
use strict;
use base 'Bivio::Biz::Model::AnyTaskDAVList';
use Bivio::IO::Ref;
use Bivio::IO::Trace;
use Bivio::Util::CSV;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
our($_TRACE);

sub LOAD_ALL_SIZE {
    return 5000;
}

sub dav_is_read_only {
    return 0;
}

sub dav_put {
    my($self, $content) = @_;
    my($req) = $self->get_request;
    my($num) = 1;
    _e($self, $num, $content, 'no header line')
	unless $$content =~ s/^.*?\r?\n//;
    my($lm) = $req->get('Model.' . $self->LIST_CLASS);
    my($pk, $other_pk) = @{$lm->get_info('primary_key_names')};
    $lm->die('primary_key must be exactly one column')
	if $other_pk;
    my($old) = {@{$lm->map_rows(
	sub {
	    my($row) = shift->get_shallow_copy;
	    return ($row->{$pk} => $row);
	})}};
    my($cols) = $self->CSV_COLUMNS;
    $self->die('primary key must be last column: ', $cols)
	unless $cols->[$#$cols] eq $pk;
    my($ops) = {create_row => [], update_row => []};
    my($types) = [map($lm->get_field_type($_), @$cols)];
    foreach my $new (
	map({
	    $num++;
	    my($l) = $_;
	    _e($self, $num, $l, 'too many columns')
		if @$l > @$cols;
	    grep($_ =~ /\S/, @$l) ? +{
		_line_num => $num,
		map({
		    my($v, $e) = $types->[$_]->from_literal($l->[$_]);
		    _e($self, $num, $l, "$cols->[$_] invalid: " . $e->get_name
                           . ' ' . defined($l->[$_]) ? $l->[$_] : '<undef>')
			if $e;
		    ($cols->[$_] => $v);
		} 0 .. $#$cols),
	    } : ();
	} @{Bivio::Util::CSV->parse($content)})
    ) {
	my($o) = defined($new->{$pk}) && delete($old->{$new->{$pk}});
	$o->{_line_num} = $new->{_line_num}
	    if $o;
	push(@{$ops->{$o ? 'row_update' : 'row_create'}}, [$new, $o])
	    unless $o && Bivio::IO::Ref->nested_equals($o, $new);
    }
    $ops->{row_delete} = [map([$_], values(%$old))];
    my($realm) = $self->new_other('RealmOwner')->unauth_load_or_die({
	realm_id => $self->get_auth_id,
    });
    foreach my $op (qw(row_delete row_update row_create)) {
	foreach my $args (@{$ops->{$op}}) {
	    $req->set_realm($realm);
	    _trace($op, $args) if $_TRACE;
	    my($e) = $self->$op(@$args);
	    _e($self, $args->[0]->{_line_num}, $args, "$op failed: $e")
		if $e;
	}
    }
    return;
}

sub dav_reply_get {
    my($self) = @_;
    Bivio::UI::View->execute(\(<<"EOF"), shift->get_request);
view_class_map('TextWidget');
view_main(CSV(
    '@{[$self->LIST_CLASS]}',
    ${Bivio::IO::Ref->to_string($self->CSV_COLUMNS)}
));
EOF
    return 1;
}

sub row_create {
    return;
}

sub row_delete {
    return;
}

sub row_update {
    return;
}

sub _e {
    my($self, $num, $line, $msg) = @_;
    $self->throw_die(CORRUPT_FORM => {
	row_num => $num,
	row => $line,
	message => $msg,
	program_error => 1,
    });
    # DOES NOT RETURN
}

1;
