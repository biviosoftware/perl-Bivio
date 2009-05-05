# Copyright (c) 2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::RealmSettingList;
use strict;
use Bivio::Base 'Biz.ListModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_IDI) = __PACKAGE__->instance_data_index;
my($_S) = b_use('Type.String');
my($_FP) = b_use('Type.FilePath');
my($_CSV) = b_use('ShellUtil.CSV');
my($_D) = b_use('Bivio.Die');
my($_A) = b_use('IO.Alert');
my($_T) = b_use('Bivio.Type');
my($_EMPTY) = '<undef>';

sub as_string {
    my($self) = @_;
    return shift->SUPER::as_string(@_)
	unless ref($self) && $self->[$_IDI];
    return $self->simple_package_name . "($self->[$_IDI])";
}

sub get_all_settings {
    my($self, $base, $columns) = @_;
    $self = _load($self, $base);
    my($keys) = $self->map_rows(
	sub {
	    my($k) = shift->get('key');
	    return defined($k) ? $k : ();
	},
    );
    return {map(
	($_ => $self->get_multiple_settings($base, $_, $columns)),
	@$keys,
    )};
}

sub get_multiple_settings {
    my($self, $base, $key, $columns) = @_;
    $self = _load($self, $base);
    return {map(($_->[0] => $self->get_setting($base, $key, @$_)), @$columns)};
}

sub get_setting {
    my($self, $base, $key, $column, $type, $default) = @_;
    $type = $_T->get_instance($type);
    $column = qr{\Q$column\E}is
	unless ref($column);
    return _default($default)
	unless ($self = _load($self, $base))->find_row_by('key', $key)
	|| $self->find_row_by('key', $key = undef);
    return _grep(
	$self,
	$column,
	$type,
	sub {
	    return _default($default, @_)
		unless defined($key)
		&& $self->find_row_by('key', undef);
	    return _grep($self, $column, $type, $default);
	},
    );
}

sub unauth_if_file_exists {
    my($self, $base, $realm_id) = @_;
    return $self->new_other('RealmFile')->unauth_load({
	path => _path($base),
	realm_id => $realm_id,
    });
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	$self->field_decl(
	    primary_key => [['key', 'Line', 'NOT_NULL']],
	    other => [['value', 'Hash', 'NONE']],
	),
    });
}

sub internal_load_rows {
    my($self, $query) = @_;
    my($auth_id, $base) = split(/:/, $self->[$_IDI], 2);
    my($rf) = $self->new_other('RealmFile');
    return []
	unless $rf->unauth_load({realm_id => $auth_id, path => _path($base)});
    return _parse($self, $rf);
}

sub setting_error {
    my($self, @msg) = @_;
    $_A->warn_exactly_once($self, ': ', @msg);
    return;
}

sub _default {
    my($default) = shift;
    return ref($default) eq 'CODE' ? $default->(@_) : $default
}

sub _grep {
    my($self, $pat, $type, $default) = @_;
    my($hash) = $self->get('value');
    my($k) = [grep($_ =~ $pat, keys(%$hash))];
    my($e);
    if (@$k == 1) {
	my($literal) = $hash->{$k->[0]};
	return ($type->from_literal(''))[0]
	    if ($literal || '') eq $_EMPTY;
        my($v, $te) = $type->from_literal($literal);
	return $v
	    if $type->is_specified($v);
	$e = 'type ' . $type->simple_package_name . ' error ' . $te->get_name
	    if $te;
	my($x) = $default;
	$v = $te ? $hash->{$k->[0]} : undef;
	$default = sub {_default($x, $v)};
    }
    else {
	$e = @$k ? 'matched multiple columns' : 'column not found';
    }
    $self->setting_error($pat, ': ', $e)
	if $e;
    return _default($default);

}

sub _load {
    my($self, $base) = @_;
    $base = $self->req('auth_id') . ":$base";
    return $self
	if $_S->is_equal($self->[$_IDI], $base);
    $self->[$_IDI] = $base;
    $self->load_all;
    return $self;
}

sub _parse {
    my($self, $rf) = @_;
    my($rows);
    if (my $die = $_D->catch(sub {
	my($heading) = [];
        $rows = [map(+{
	    key => length($_->{$heading->[0]}) ? $_->{$heading->[0]} : undef,
	    value => $_,
	}, @{$_CSV->parse_records($rf->get_content, undef, $heading)})];
	return;
    })) {
	$self->setting_error($rf, ': ', $die);
	return [];
    }
    return $rows
}

sub _path {
    my($base) = @_;
    return $_FP->join($_FP->SETTINGS_FOLDER, "$base.csv");
}

1;
