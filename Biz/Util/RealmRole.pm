# Copyright (c) 1999-2012 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Biz::Util::RealmRole;
use strict;
use Bivio::Base 'Bivio.ShellUtil';
b_use('IO.Trace');

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
our($_TRACE);
my($_IDI) = __PACKAGE__->instance_data_index;
Bivio::IO::Trace->register;
my($_CATEGORY_MAP);
b_use('IO.Config')->register(my $_CFG = {
    category_map => sub {[]},
});
my($_R) = b_use('Auth.Role');
my($_P) = b_use('Auth.Permission');
my($_PS) = b_use('Auth.PermissionSet');
my($_AR) = b_use('Auth.Realm');
my($_RT) = b_use('Auth.RealmType');
my($_SUPER_USER_QUERY) = {
    realm_id => $_RT->GENERAL->as_int,
    role => $_R->ADMINISTRATOR,
};

sub CATEGORIES {
    # : array_ref
    # Returns categories in L<CATEGORY_MAP|"CATEGORY_MAP">
    return [keys(%{_category_map(shift)})];
}

sub USAGE {
    # : string
    # Returns usage.
    return <<'EOF';
usage: b-realm-role [options] command [args...]
commands:
    audit_feature_categories -- audit enabled categories for a realm
    clear_unused_permissions -- clear permission named UNUSED_...
    copy_all src dst -- copies all records from src to dst realm
    edit role|group operation ... -- changes the permissions for realm/role|group
    edit_categories [category_op ...] -- disable or enable permission categories
    list [role|group] -- lists permissions for this realm and role|group, or all
    list_all [realm_type] -- lists permissions for all realms of realm_type
    list_all_categories -- lists all defined permission categories
    list_enabled_categories -- list enabled permission categories for this realm
    list_roles role|group -- roles for category role group designator
    make_super_user -- gives current user super_user privileges
    permission_count -- show count by permission used in entire database
    roles_for_permissions permission... -- list roles which have permission(s)
    set_same old new - copies permission old to new for ALL realms
    unmake_super_user -- drops current user's super_user privileges
EOF
}

sub audit_feature_categories {
    my($self) = @_;
    my($categories) = $self->list_enabled_categories;

    foreach my $perm (@{
	$_PS->to_array($self->model('RealmRole', {
	    role => $_R->ANONYMOUS,
	})->get('permission_set'))
    }) {
	my($name) = lc($perm->get_name);
	next unless $name =~ /^feature_/;
	next if grep($_ eq $name, @$categories);
	$self->print('corrupt feature: ', $name, "\n");
    }
    return;
}

sub clear_unused_permissions {
    my($self) = @_;
    my($perms) = [grep($_->get_name =~ /^UNUSED_\d+$/, $_P->get_list)];
    $self->model('RealmRole')->do_iterate(sub {
        my($rr) = @_;
	my($set) = $rr->get('permission_set');
	my($changed) = 0;

	foreach my $p (@$perms) {
	    next unless $_PS->is_set($set, [$p]);
	    $changed = 1;
	    b_info($p);
	    $set = $_PS->clear($set, [$p]);
	}

	if ($changed) {
	    $rr->update({
		permission_set => $$set,
	    });
	}
	return 1;
    }, 'unauth_iterate_start');
    return;
}

sub copy_all {
    my($self, $src, $dst) = @_;
    my($req) = $self->get_request;
    ($src, $dst) = map(
	$self->model('RealmOwner')
	    ->unauth_load_by_id_or_name_or_die($_)->get('realm_id'),
	$src, $dst,
    );
    $self->model('RealmRole')->do_iterate(
	sub {
	    my($m) = @_;
	    $m->new_other('RealmRole')->unauth_create_or_update({
		%{$m->get_shallow_copy},
		realm_id => $dst,
	    });
	    return 1;
	},
        unauth_iterate_start => ('realm_id', {realm_id => $src}),
    );
    return;
}

sub do_super_users {
    my($self, $op) = @_;
    return $self->model('RealmUser')->do_iterate(
	sub {
	    return $self->req->with_user(
		shift->get('user_id'),
		sub {
		    $op->();
		    return 1;
		},
	    );
	},
	'unauth_iterate_start',
	'user_id',
	{%$_SUPER_USER_QUERY},
    );
}

sub edit {
    sub EDIT {[[qw(role_or_group Line)], [qw(+operations Line)]]}
    my($self, $bp) = shift->parameters(\@_);
    my($roles) = $_R->calculate_expression($bp->{role_or_group});
    my($req) = $self->req;
    my($realm) = $req->get('auth_realm');
    my($realm_id) = $realm->get('id');
    $self->model('RealmRole')->initialize_permissions($realm->get('owner'));
    foreach my $role (@$roles) {
	my($ps) = _get_permission_set($self, $realm_id, $role, 1);
	_trace('current ', $role, ' ', $_PS->to_literal($ps))
	    if $_TRACE;
	foreach my $op (@{$bp->{operations}}) {
	    $self->usage_error("$op: invalid operation syntax")
		unless $op =~ /^([-+])(\w*)$/;
	    $ps = _edit_one($self, $1, uc($2), $ps, $op, $realm_id);
	}
	$self->model('RealmRole')->create_or_update({
	    role => $role,
	    permission_set => $ps,
	});
    }
    return;
}

sub edit_categories {
    my($self, $category_ops) = _edit_categories_args(@_);
    return
	unless @$category_ops;
    my($req) = $self->get_request;
    my($rr) = $self->model('RealmRole');
    my($o) = $req->get('auth_realm')->get('owner');
    foreach my $category_op (@$category_ops) {
	my($op, $cat) = $category_op =~ /^(-|\+)(\w+)$/;
	$self->usage_error($category_op, ': unknown category operation (missing "+"?)')
	    unless $op;
	foreach my $x (@{
	    _category_map($self)->{$cat}->{$op}
		|| $self->usage_error(
		    $cat, ': unknown category (case-sensitive)')
	}) {
	    my($method, $roles, $permissions) = @$x;
	    $rr->$method($o, $roles, $permissions);
	}
    }
    return join(' ', $o->get('name') . ':', @$category_ops) . "\n";
}

sub handle_config {
    # (proto, hash) : undef
    my(undef, $cfg) = @_;
    $_CATEGORY_MAP = undef;
    $_CFG = $cfg;
    return;
}

sub is_category {
    my($self, $value) = @_;
    return _category_map($self)->{$value} ? 1 : 0;
}

sub list {
    # (self, string) : undef
    # Print the permission sets so they can be used as input to this program.
    # If I<role_name> is C<undef>, gets all roles.
    my($self, $role_name) = @_;
    return _list_one(
	$self,
	$self->req('auth_realm'),
	$_R->calculate_expression($role_name),
    );
}

sub list_all {
    sub LIST_ALL {[[qw(?realm_type Auth.RealmType)]]}
    my($self, $bp) = shift->parameters(\@_);
    my($sep) = '';
    my($roles) = $_R->calculate_expression();
    my($res) = '';
    $self->model('RealmOwner')->do_iterate(
	sub {
	    my($it) = @_;
	    my($p) = _list_one($self, $_AR->new($it->clone), $roles);
	    return 1
		unless $$p;
	    $res .= <<"EOF" . $$p;
$sep#
# @{[$it->get('name')]} - Permissions
#
EOF
	    $sep = "\n";
	    return 1;
	},
	'unauth_iterate_start',
	'realm_id',
	$bp->{realm_type} ? {realm_type => $bp->{realm_type}} : (),
    );
    return \$res;
}

sub list_all_categories {
    return shift->CATEGORIES;
}

sub list_enabled_categories {
    # (self) : array_ref
    # Shows permission categories which are enabled for the current realm.
    my($self) = @_;
    my($req) = $self->get_request;
    my($rp) = $self->model('RealmRole')
	->get_permission_map($req->get('auth_realm'));
    my($cm) = _category_map($self);
    return [map({
	my($k) = $_;
	my($ops) = $cm->{$k}->{'+'};
	@$ops == grep({
	    my($op, $roles, $permissions) = @$_;
	    @$roles == grep(
		((defined($rp->{$_})
		    && (($rp->{$_} & $permissions) eq $permissions))
		    xor ($op eq 'remove_permissions')),
		@$roles);
	} @$ops) ? $k : ();
    } sort(keys(%$cm)))];
}

sub list_roles {
    my($self, $role_or_group) = @_;
    return [map($_->get_name, @{$_R->calculate_expression($role_or_group)})];
}

sub make_super_user {
    # (self) : undef
    # Makes current user an super_user (administrator of general realm).
    my($self) = @_;
    $self->model('RealmUser')->unauth_create_or_update({
	user_id => $self->req('auth_user_id'),
	%$_SUPER_USER_QUERY,
    });
    $self->req->set_user($self->req->get('auth_user'));
    return;
}

sub new {
    # (proto) : Util.RealmRole
    # Initializes fields.
    my($self) = shift->SUPER::new(@_);
    $self->[$_IDI] = {};
    return $self;
}

sub permission_count {
    my($self) = @_;
    my($perms) = [sort({$a->as_int <=> $b->as_int} $_P->get_list)];
    my($perm_count) = {
	map(($_->as_int => 0), @$perms),
    };
    $self->model('RealmRole')->do_iterate(sub {
        my($rr) = @_;
	my($set) = $rr->get('permission_set');

	foreach my $p (@$perms) {
	    $perm_count->{$p->as_int}++
		if $_PS->is_set($set, [$p]);
	}
	return 1;
    }, 'unauth_iterate_start');
    my($res) = [['count', 'permission']];

    foreach my $p (@$perms) {
	push(@$res, [$perm_count->{$p->as_int}, $p->get_name]);
    }
    return $self->new_other('CSV')->to_csv_text($res);
}

sub set_same {
    # (self, string, string) : undef
    # Sets I<new> permission to same value as I<old> permission.  This is used
    # to add new permissions to the permission_set of all realms and roles
    # in the database.  The I<old> permission is a model for the I<new>
    # permission.  If the I<old> permission is set, the I<new> permission for the
    # same realm/role combination.  It can be used to adjust existing permissions.
    my($self, $old, $new) = @_;
    $self->usage('set_same: missing args')
	    unless defined($new) && defined($old);
    my($new_int) = $_P->from_any($new)->as_int;
    my($old_int) = $_P->from_any($old)->as_int;
    my($rr) = $self->model('RealmRole');
    my($it) = $rr->unauth_iterate_start('realm_id, role');
    while ($rr->iterate_next_and_load($it)) {
	my($s) = $rr->get('permission_set');
	vec($s, $new_int, 1) = vec($s, $old_int, 1);
	$rr->update({permission_set => $s});
    }
    $rr->iterate_end($it);
    return;
}

sub roles_for_permissions {
    sub ROLES_FOR_PERMISSIONS {[[qw(+permission Auth.Permission)]]}
    my($self, $bp) = shift->parameters(\@_);
    my($ps) = ${$_PS->from_array($bp->{permission})};
    my($rp) = $self->model('RealmRole')
	->get_permission_map($self->req('auth_realm'));
    return [
	map(
	    defined($rp->{$_}) && ($rp->{$_} & $ps) eq $ps ? $_->get_name : (),
	    @{$_R->calculate_expression()},
	),
    ]
}

sub unmake_super_user {
    # (self) : undef
    # Drops current user as super_user.  See L<make_super_user|"make_super_user">.
    my($self) = @_;
    my($req) = $self->get_request;
    $self->model('RealmUser')->unauth_delete({
	user_id => $req->get('auth_user_id')
	    || $self->usage_error('user not set'),
	%$_SUPER_USER_QUERY,
    });
    $self->req->set_user($self->req->get('auth_user'));
    return;
}

sub _category_map {
    return $_CATEGORY_MAP ||= _init_category_map(@_);
}

sub _edit_categories_args {
    my($self) = shift;
    $self->usage('missing category_ops')
	unless @_;
    return ($self, [reverse(
	sort(
	    map(
		{
		    my($v) = $_;
		    ref($v) eq 'ARRAY' ? @$v
			: ref($v) eq 'HASH'
			    ? map(
				($v->{$_} ? '+' : '-') . $_,
				  sort(keys(%$v)),
			    )
			    : $v;
		}
	        @_,
	    ),
	),
    )]);
}

sub _edit_one {
    my($self, $which, $operand, $ps, $op, $realm_id) = @_;
    return $which eq '+' ? $_PS->get_max : $_PS->get_min
	unless length($operand);
    my($p) = $_P->unsafe_from_any($operand);
    b_die($p, ': cannot set TRANSIENT permissions')
	if $which eq '+' && $p && $p->get_name =~ /TRANSIENT/;
    if ($p && $p->get_name eq $operand) {
	vec($ps, $p->as_int, 1) = $which eq '+' ? 1 : 0;
	return $ps;
    }
    my($r) = $_R->unsafe_from_any($operand);
    $self->usage($op, ': neither a Role nor Permission')
	unless $r && $r->get_name eq $operand;
    my($s) = _get_permission_set($self, $realm_id, $r, 0);
    _trace($which, $r, ' ', $_PS->to_literal($s))
	if $_TRACE;
    # Set lengths must match for ~$s to work properly
    b_die(
	'ASSERTION FAULT: set lengths differ: ',
	length($s),
	' != ',
	length($ps),
    ) if length($s) != length($ps);
    return $which eq '+' ? ($ps | $s) : ($ps & ~$s);
}

sub _get_permission_set {
    my($self, $realm_id, $role, $dont_die) = @_;
    my($rr) = $self->model('RealmRole');
    return $rr->get('permission_set')
	if $rr->unauth_load(realm_id => $realm_id, role => $role);
    $self->usage($role->as_string, ": not set for realm: ", $realm_id)
	unless $dont_die;
    return $_PS->get_min;
}

sub _init_category_map {
    my($proto) = @_;
    my($map) = {};
    foreach my $x (@{$_CFG->{category_map}->()}) {
	my($cat, @ops) = @$x;
	$map->{$cat} = {map({
	    my($sign) = $_;
	    $sign => [map(
		ref($_) ? _init_category_map_op($proto, $cat, $sign, $_)
		    : _init_category_map_copy($proto, $cat, $sign, $_, $map),
		@ops,
	    )];
        } qw(+ -))};
    }
    return $map;
}

sub _init_category_map_copy {
    my($proto, $cat, $sign, $copy_cat, $map) = @_;
    $copy_cat =~ s/^\+//;
    my($reverse) = $copy_cat =~ s/^-//;
    return map({
	my($method, @rest) = @$_;
	[
	    $reverse ? $method eq 'add_permissions'
		? 'remove_permissions'
		: 'add_permissions'
		: $method,
	    @rest,
	];
    } @{($map->{$copy_cat} || b_die($copy_cat, ': not listed before ', $cat))
       ->{$sign}});
}

sub _init_category_map_op {
    my($proto, $cat, $sign, $op) = @_;
    my($roles, $perms, @rest) = map(ref($_) ? $_ : [$_], @$op);
    b_die(
	$cat,
	': invalid category_map entry; extra params: ',
	\@rest,
    ) if @rest;
    return map(
	{
	    my($x) = $_;
	    $x =~ s/^\+//;
	    [
		($x =~ s/^-// xor $sign eq '-')
		    ? 'remove_permissions' : 'add_permissions',
		[map(@{$_R->calculate_expression($_)}, @$roles)],
		${$_PS->set($_PS->get_min, $_P->$x())},
	    ];
	}
	@$perms,
    );
}

sub _list_one {
    # (self, Auth.Realm, array_ref) : string_ref
    # Lists the roles for realm_id.
    my($self, $realm, $roles) = @_;
    my($fields) = $self->[$_IDI];

    $fields->{all_permissions} = [
	sort {
	    $a->get_name cmp $b->get_name
	} $_P->get_list
    ] unless $fields->{all_permissions};

    my($rr) = $self->model('RealmRole');
    my($res) = "RealmRole();\n";
    my($prev_ps, $prev_role);
    my($realm_id, $realm_name) = $realm->unsafe_get(qw(id owner_name));
    $realm_name = $realm->get('type')->get_name unless $realm_name;
    foreach my $role (@$roles) {
	unless ($rr->unauth_load(realm_id => $realm_id, role => $role)) {
	    next;
	}
	# Always clear the set before adding in values
	$res .= "RealmRole(qw(-r $realm_name edit " . $role->get_name;
	my($ps) = $rr->get('permission_set');
	if ($ps eq $_PS->get_max) {
	    $res .= ' +';
	}
	else {
	    $res .= ' -';
	    # If the previous role is a subset, delete those bits and
	    # just add the role to the output.
	    my($s) = $ps;
	    if (defined($prev_ps) && ($prev_ps & $ps) eq $prev_ps) {
		$res .= "\n    +$prev_role";
		$s &= ~$prev_ps;
	    }
	    foreach my $p (@{$fields->{all_permissions}}) {
		$res .= "\n    +".$p->get_name
			if vec($s, $p->as_int, 1);
	    }
	}
	$res .= "\n));\n";
	$prev_role = $role->get_name;
	$prev_ps = $ps;
    }
    return \$res;
}

1;
