# Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::EditDAVList;
use strict;
use base 'Bivio::Biz::Model::AnyTaskDAVList';
use Bivio::IO::Ref;
use Text::CSV ();

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub LOAD_ALL_SIZE {
    return 5000;
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

sub dav_is_read_only {
    return 0;
}

sub dav_put {
    my($self, $content) = @_;
    my($req) = $self->get_request;
    my($csv) = Text::CSV->new;
    $self->throw_die(CORRUPT_FORM => 'no header line')
	unless $$content =~ s/^.*?\r?\n//;
    my($l) = $req->get('Model.' . $self->LIST_CLASS);
    my($pk, $other_pk) = @{$l->get_info('primary_key_names')};
    $l->die('primary_key must be exactly one column')
	if $other_pk;
    my($old) = {@{$l->map_rows(
	sub {
	    my($row) = shift->get_shallow_copy;
	    return ($row->{$pk} => $row);
	})}};
    my($cols) = $self->CSV_COLUMNS;
    $self->die('primary key must be last column: ', $cols)
	unless $cols->[$#$cols] eq $pk;
    my($num) = 1;
    my($rows) = {create_row => [], update_row => []};
    foreach my $new (map({
	$num++;
	$self->throw_die(CORRUPT_FORM => "line, $num: unable to parse: ", $_)
	    unless $csv->parse($_);
	my($l) = [$csv->fields];
	$self->throw_die(CORRUPT_FORM => "line, $num: invalid columns: ", $l)
	    if @$l > @$cols;
	my($row) = {map(($cols->[$_] => $l->[$_]), 0 .. $#$l)};
	$row;
    } split(/^/m, $$content))) {
	my($o) = delete($old->{$new->{$pk} || ''});
	next if $o && Bivio::IO::Ref->nested_equals($o, $new);
	push(@{$rows->{$new->{$pk} ? 'row_update' : 'row_create'}}, $new);
    }
    $rows->{row_delete} = [values(%$old)];
    foreach my $op (qw(row_delete row_update row_create)) {
	foreach my $row (@{$rows->{$op}}) {
	    $self->$op($row);
	}
    }
    return;
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

1;
