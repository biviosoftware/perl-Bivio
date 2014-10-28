# Copyright (c) 2009-2010 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::RealmSettingList;
use strict;
use Bivio::Base 'Biz.ListModel';

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
    return shift->unauth_get_all_settings(undef, @_);
}

sub get_file_path {
    my($self, $base) = @_;
    $base ||= $self->FILE_PATH_BASE;
    return $_FP->join($_FP->SETTINGS_FOLDER, "$base.csv");
}

sub get_multiple_settings {
    return shift->unauth_get_multiple_settings(undef, @_);
}

sub get_setting {
    return shift->unauth_get_setting(undef, @_);
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
    my($rf) = $self->new_other('RealmFile')->set_ephemeral;
    return []
	unless $rf->unauth_load({realm_id => $auth_id, path => $self->get_file_path($base)});
    return _parse($self, $rf);
}

sub setting_error {
    my($self, @msg) = @_;
    $_A->warn_exactly_once($self, ': ', @msg);
    return;
}

sub unauth_get_all_settings {
    my($self, $realm_id, $base, $columns) = @_;
    $self = _load($self, $realm_id, $base);
    my($keys) = $self->map_rows(
	sub {
	    my($k) = shift->get('key');
	    return defined($k) ? $k : ();
	},
    );
    return {map(
        ($_ => $self->unauth_get_multiple_settings(
	    $realm_id, $base, $_, $columns)),
	@$keys,
    )};
}

sub unauth_get_multiple_settings {
    my($self, $realm_id, $base, $key, $columns) = @_;
    $self = _load($self, $realm_id, $base);
    return {map(
	($_->[0] => $self->unauth_get_setting(
	    $realm_id, $base, $key, @$_)),
	@$columns,
    )};
}

sub unauth_get_setting {
    my($self, $realm_id, $base, $key, $column, $type, $default) = @_;
    $type = $_T->get_instance($type);
    $column = qr{\Q$column\E}is
	unless ref($column);
    return _default($default)
	unless ($self = _load($self, $realm_id, $base))->find_row_by('key', $key)
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
	path => $self->get_file_path($base),
	realm_id => $realm_id,
    });
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
    my($self, $realm_id, $base) = @_;
    $base ||= $self->FILE_PATH_BASE;
    $realm_id ||= $self->req('auth_id');
    $base = $realm_id . ":$base";
    return $self
	if $_S->is_equal($self->[$_IDI], $base);
    $self->[$_IDI] = $base;
    $self->unauth_load_all;
    return $self;
}

sub _parse {
    my($self, $rf) = @_;
    my($rows);
    if (my $die = $_D->catch(sub {
	my($heading) = [];
        $rows = [map(
	    (_parse_record($_, $heading)),
	    @{$_CSV->parse_records($rf->get_content, undef, $heading)},
	)];
	return;
    })) {
	$self->setting_error($rf, ': ', $die);
	return [];
    }
    return $rows;
}

sub _parse_record {
    my($row, $heading) = @_;
    return {
	key => length($row->{$heading->[0]}) ? $row->{$heading->[0]} : undef,
	value => {
	    map((lc($_) => $row->{$_}), keys(%$row)),
	},
    };
}

sub _path {
}

1;
