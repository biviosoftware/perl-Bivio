# Copyright (c) 2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::ClassWrapper::TupleTag;
use strict;
use Bivio::Base 'Bivio.ClassWrapper';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_CL);
my($_FS);
my($_LQ);
my($_NONE);
my($_NOT_NULL);
my($_S);
my($_SA);
my($_TCL);
my($_TSL);
my($_TSLA);
my($_TSN);
my($_TST);
my($_CLASSES) = {};

sub handle_class_loader_delete_require {
    my($self) = @_;
    # Have to delete packages that were wrapped, or code will be
    # executing that half-exists.
    $self->map_invoke(delete_require => [keys(%$_CLASSES)]);
    return;
}

sub wrap_methods {
    my($proto, $wrap_pkg, $info) = @_;
    _init();
#TODO: Does not work with two TupleTags (different monikers) in the same class
    b_die($wrap_pkg, ': already wrapped')
	if $_CLASSES->{$wrap_pkg}++;
    my($bc) = $wrap_pkg->isa('Bivio::Biz::ListFormModel')
	? b_die($wrap_pkg, ': ListFormModel not supported')
	: (grep($wrap_pkg->isa("Bivio::Biz::$_"),
		qw(FormModel ListModel PropertyModel)))[0]
	|| b_die($wrap_pkg, ': unsupported base class');
    if ($info->{is_list_model} = $bc eq 'ListModel' ? 1 : 0) {
	$info->{primary_id_model}
	    = $_S->extract_model_prefix($info->{primary_id_field})
	    || b_die($info->{primary_id_field},
		': primary_id_field must specify model');
    }
    $proto->SUPER::wrap_methods(
	$wrap_pkg,
	$info,
	$bc eq 'PropertyModel' ? {
	    create => \&_wrap_create,
	} : {
	    map({
		my($n) = $_;
		($n =~ ($info->{is_list_model}
		    ? qr{^execute} : qr{^internal_prepare}))
		    ? () : ($n => \&{"_wrap_$n"});
		}
		grep(
		    $_ !~ /^create$/,
		    @{$proto->grep_subroutines(qr{^_wrap_(.+)})},
		),
	    ),
	},
    );
    return;
}

sub handle_internal_unsafe_lc_get_value {
    my($proto, $fc, $name, $value) = @_;
    return
	unless $fc->simple_package_name eq 'Text'
	and !$value
	and my $n = _parse_field($name);
    (my $x = $n->{field}) =~ s/_/ /g;
    return {value => $x};
}

sub _cache {
    my($key, $compute) = @_;
#    To test with caching off
#    return $compute->()
    return $key->[0]->req->realm_cache([(caller)[2], @$key], $compute);
}

sub _def_id {
    my($defs) = @_;
    return $defs->get_query->get('parent_id');
}

sub _defs {
    my($self, $wp) = @_;
    return _cache([$wp], sub {
	my($tu) = $wp->new_other('TupleUse');
	return undef
	    unless $tu->unsafe_load({moniker => $self->get('moniker')});
	return $tu->load_tuple_slot_def_list;
    });
}

sub _field_check {
    my($self, $wp, $check) = @_;
    return _cache([$wp, @$check], sub {
	return []
	    unless my $tsdl = _defs($self, $wp);
	my($labels) = _labels($self, $wp, $tsdl);
	return []
	    unless @$labels;
	my($moniker) = $self->get('moniker');
	my($fields) = [map(_prefix($moniker, $_), @$labels)];
	return $fields
	    unless @$check;
	return $_SA->new($check)->intersect($fields)->as_array;
    });
}

sub _field_info {
    my($self, $wp, $field) = @_;
#TODO: Needs to work with explicit ListField field values TupleTag.slot1_1
    return _cache([$wp, $field], sub {
	return undef
	    unless my $parsed = _parse_field($field);
	b_die($field, ': field not found')
	    unless @{_field_check($self, $wp, [$field])};
	my($d) = _defs($self, $wp);
	$parsed ||= _parse_field($field);
	b_die($field, ': field not found in defs??')
	    unless $d->find_row_by_label($parsed->{field});
	my($t) = $d->type_class_instance;
	my($c) = $d->get('TupleSlotType.choices');
	my($sn) = $d->get('TupleSlotDef.tuple_slot_num');
	my($moniker) = $self->get('moniker');
	my($sfq) = _prefix($moniker, $_TSN->field_name($sn));
	return {
	    tuple_tag_slot_field => $_TSN->field_name($sn),
	    tuple_tag_slot_field_qualified => $sfq,
	    tuple_tag_slot_num => $sn,
	    name => $field,
	    constraint => $d->get('TupleSlotDef.is_required')
		? $_NOT_NULL : $_NONE,
	    sort_order =>  $_LQ->get_sort_order_for_type($t),
	    type => $c->is_specified ? $_TCL->new($c->as_array) : $t,
	    default_value => $d->get('TupleSlotType.default_value'),
	    form_name => $wp->get_field_info($sfq)->{form_name},
	};
    });
}

sub _labels {
    my($self, $wp, $tsdl) = @_;
    return _cache([$wp], sub {
	my($rsl) = $wp->new_other('RealmSettingList');
	my($all) = $_TSLA->new(
	    $tsdl->map_rows(sub {shift->get('TupleSlotDef.label')}));
	my($labels) = $rsl->get_setting(
	    'TupleTag',
	    $wp->simple_package_name,
	    my $moniker = $self->get('moniker'),
	    'TupleSlotLabelArray',
	    $all,
	);
	return $labels->map_iterate(sub {
	    my($check) = @_;
	    my($res) = @{$all->map_iterate(sub {
		my($label) = @_;
		return lc($check) eq lc($label) ? $label : ();
	    })};
	    $rsl->setting_error($check, ": no such label in ", $moniker)
		unless $res;
	    return $res;
	});
    });
}

sub _init {
    return
	if $_CL;
    $_CL = b_use('IO.ClassLoader');
    $_FS = b_use('SQL.FormSupport');
    $_LQ = b_use('SQL.ListQuery');
    $_NONE = b_use('SQL.Constraint')->NONE;
    $_NOT_NULL = b_use('SQL.Constraint')->NOT_NULL;
    $_S = b_use('SQL.Support');
    $_SA = b_use('Type.StringArray');
    $_TCL = b_use('Type.TupleChoiceList');
    $_TSL = b_use('Type.TupleSlotLabel');
    $_TSLA = b_use('Type.TupleSlotLabelArray');
    $_TSN = b_use('Type.TupleSlotNum');
    $_TST = b_use('Type.TupleSlotType');
    b_use('UI.FacadeComponent')->register_handler(__PACKAGE__);
    return;
}

sub _load_defaults {
    my($self, $wp, $fields) = @_;
    foreach my $f (@$fields) {
	my($i) = _field_info($self, $wp, $f);
	$wp->internal_put_field(
	    $i->{tuple_tag_slot_field_qualified} => $i->{default_value});
    }
    return;
}

sub _load_properties {
    my($self, $wp, $fields) = @_;
    return 0
	unless my $pif = $wp->unsafe_get($self->get('primary_id_field'));
    my($tt) = $wp->new_other('TupleTag');
    return 0
	unless $tt->unsafe_load({
	    primary_id => $pif,
	    tuple_def_id => _def_id(_defs($self, $wp)),
	});
    foreach my $f (@$fields) {
	my($i) = _field_info($self, $wp, $f);
	$wp->internal_put_field($i->{tuple_tag_slot_field_qualified} =>
	    $tt->get($i->{tuple_tag_slot_field}));
    }
    return 1;
}

sub _map_keys {
    my($self, $args) = @_;
    my($wp) = shift(@$args);
    return $self->call_method([$wp, map({
	my($info) = _field_info($self, $wp, $_);
	$info ? $info->{tuple_tag_slot_field_qualified} : $_;
    } @$args)]);
}

sub _parse_field {
    my($field) = @_;
    return undef
	unless my $n = $_FS->parse_qualified_field($field);
    return undef
	unless $n->{model} eq 'TupleTag'
	&& $_TSL->is_specified_literal($n->{field});
    return $n;
}

sub _prefix {
    my($moniker, $field) = @_;
    return $field ? "$moniker.TupleTag.$field" : "$moniker.TupleTag";
}

# sub _wrap_filter_keys {
#     my() = @_;
#     QuerySearchBaseForm
#     return;
# }

sub _update_properties {
    my($self, $wp) = @_;
    return
	unless my $d = _defs($self, $wp);
    my($fields) = _field_check($self, $wp, []);
    my($v) = {
	primary_id => $wp->get($self->get('primary_id_field')),
	tuple_def_id => _def_id($d),
	# Need this for "just created" check
	realm_id => $self->req('auth_id'),
    };
    my($tt, $exists);
    # If the TupleTag was just created (see _wrap_create), we need to not
    # override default values with undef
    if ($tt = $wp->ureq('Model.TupleTag')) {
	$tt = undef
	    unless grep($tt->get($_) eq $v->{$_}, keys(%$v)) == keys(%$v);
    }
    unless ($tt) {
	$tt = $wp->new_other('TupleTag');
	$exists = $tt->unsafe_load($v);
    }
    foreach my $f (@$fields) {
	my($i) = _field_info($self, $wp, $f);
#TODO: Need to type check the values!!!
	$v->{$i->{tuple_tag_slot_field}}
	    = $wp->unsafe_get($i->{tuple_tag_slot_field_qualified});
    }
    if ($exists) {
	$tt->update($v);
	return;
    }
    $d->do_rows(sub {
	my($it) = @_;
	my($n) = $_TSN->field_name($it->get('TupleSlotDef.tuple_slot_num'));
        $v->{$n} = $it->get('TupleSlotType.default_value')
	    unless exists($v->{$n});
	return 1;
    });
    my($method) = $tt->is_loaded ? 'update' : 'create';
    $tt->$method($v);
    return;
}

sub _wrap_create {
    my($self, $args) = @_;
    my($wp) = $self->call_method($args);
    if (my $d = _defs($self, $wp)) {
	# See _update_properties for special case
	$wp->new_other('TupleTag')->create({
	    primary_id => $wp->get($self->get('primary_id_field')),
	    tuple_def_id => _def_id($d),
	    @{$d->map_rows(sub {
	        my($it) = @_;
		return ($it->field_from_num
		    => $it->get('TupleSlotType.default_value'));
	    })},
	});
    }
    return $wp;
}

sub _wrap_execute_empty {
    my($self, $args) = @_;
    my($wp) = $args->[0];
    my($res) = $self->call_method($args);
    my($fields) = _field_check($self, $wp, []);
    _load_defaults($self, $wp, $fields)
	unless !@$fields || _load_properties($self, $wp, $fields);
    return $res;
}

sub _wrap_execute_ok {
    my($self, $args) = @_;
    my($wp) = $args->[0];
    my($res) = $self->call_method($args);
    # Always update in case the record doesn't exist
    _update_properties($self, $wp);
    return $res;
}

sub _wrap_get {
    return _map_keys(@_);
}

sub _wrap_get_field_info {
    my($self, $args) = @_;
    my($wp, $field, $which) = @$args;
    return $self->call_method($args)
	unless my $info = _field_info($self, $wp, $field);
    return $which ? $info->{$which} : $info;
}

# sub _wrap_get_info {
#     # visible_field_names  for QuerySearchBaseForm
#     return;
# }

# sub _wrap_get_select_attrs {
#     QuerySearchBaseForm for fields that match
#     return;
# }

sub _wrap_has_fields {
    return _map_keys(@_);
}

sub _wrap_has_keys {
    return _map_keys(@_);
}

sub _wrap_internal_initialize {
    my($self, $args) = @_;
    my($wp) = $args->[0];
    my($info) = $self->call_method($args);
    my($moniker) = $self->get('moniker');
    if ($self->get('is_list_model')) {
	push(@{$info->{order_by} ||= []},
	     @{$_TSN->map_list(sub {_prefix($moniker, shift(@_))})},
	);
    }
    else {
	push(@{$info->{visible} ||= []},
	     @{$_TSN->map_list(sub {+{
		 name => _prefix($moniker, shift(@_)),
		 type => $_TST,
	     }})},
	);
    }
    return $info;
}

sub _wrap_internal_prepare_statement {
    my($self, $args) = @_;
    my($wp, $stmt) = @$args;
    my($pif, $pim, $moniker)
	= $self->get(qw(primary_id_field primary_id_model moniker));
    $stmt->from(
	$stmt->LEFT_JOIN_ON($pim, , _prefix($moniker), [
	    [$pif, _prefix($moniker, 'primary_id')],
	]),
    );
#     if ($wp->can('LIST_QUERY_FORM_CLASS')
# 	and my $qf = $wp->ureq($wp->LIST_QUERY_FORM_CLASS)) {
# 	$_TSN->map_list(sub {
# 	    my($name) = @_;
# 	    my($v) = $qf->unsafe_get('tt_' . $name);
# 	    $stmt->where(["$_TUPLE_TAG." . $name, [$v]])
# 		if defined($v);
# 	    return;
# 	});
    return $self->call_method($args);
}

sub _wrap_tuple_tag_field_check {
    my($self, $args) = @_;
    return @{_field_check($self, shift(@$args), $args)};
}

sub _wrap_unsafe_get {
    return _map_keys(@_);
}

1;

__END__

QuerySearchBaseForm only works with GET. Cannot parse incoming form.
Always an Aux form anyway.  Special type of form: GetForm?

sub _tuple_value_list {
    my($proto, $field) = @_;
    $field =~ s/^tt_//;
    my($slot) = 'TupleTag.' . $field;
    return Bivio::Biz::ListModel->new_anonymous({
        primary_key => [$slot],
	want_select_distinct => 1,
	other => [
	    [qw(CRMThread.thread_root_id TupleTag.primary_id)],
	    map(+{
		name => $_,
		in_select => 0,
	    }, qw(CRMThread.crm_thread_num TupleTag.tuple_def_id
                CRMThread.thread_root_id)),
	],
        order_by => [$slot],
	auth_id => ['CRMThread.realm_id'],
    })->load_all;
}

