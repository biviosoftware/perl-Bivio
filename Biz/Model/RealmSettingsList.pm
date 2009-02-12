# Copyright (c) 2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::RealmSettingsList;
use strict;
use Bivio::Base 'Biz.ListModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_IDI) = __PACKAGE__->instance_data_index;
my($_S) = b_use('Type.String');
my($_DEFAULT_KEY) = undef;
my($_FP) = b_use('Type.FilePath');
my($_CSV) = b_use('ShellUtil.CSV');
my($_D) = b_use('Bivio.Die');
my($_A) = b_use('IO.Alert');

sub get_value {
    my($self, $base, $key, $default) = @_;
    return ref($default) eq 'CODE' ? $default->($key) : $default
	unless ($self = _base($self, $base))->find_row_by('key', $key)
	|| $self->find_row_by('key', $_DEFAULT_KEY);
    return $self->get('value');
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	$self->field_decl(
	    primary_key => [['key', 'Line', 'NOT_NULL']],
	    other => [['value', 'Text', 'NONE']],
	),
    });
}

sub internal_load_rows {
    my($self) = @_;
    my($base, $auth_id) = split(' ', $self->[$_IDI]);
    my($rf) = $self->new_other('RealmFile');
    return []
	unless $rf->unauth_load({realm_id => $auth_id, path => _path($base)});
    return [map(+{key => $_->[0], value => $_->[1]}, @{_parse($rf)})];
}

sub _base {
    my($self, $base) = @_;
    $base .= ' ' . $self->req('auth_id');
    return $self
	if $_S->is_equal($self->[$_IDI], $base);
    $self->[$_IDI] = $base;
    $self->load_all;
    return $self;
}

sub _parse {
    my($rf) = @_;
    my($rows);
    if (my $die = $_D->catch(sub {
        $rows = $_CSV->parse($rf->get_content);
	return;
    })) {
	$_A->warn_exactly_once($rf, ': ', $die);
	return [];
    }
    shift(@$rows);
    return $rows
}

sub _path {
    my($base) = @_;
    return $_FP->join($_FP->SETTINGS_FOLDER, "$base.csv");
}

1;
