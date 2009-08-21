# Copyright (c) 1999-2008 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Biz::Util::RealmRole;
use strict;
use Bivio::Base 'Bivio::ShellUtil';
use Bivio::IO::Trace;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my(@_DATA);
my($_IDI) = __PACKAGE__->instance_data_index;
use vars qw($_TRACE);
Bivio::IO::Trace->register;
my($_CATEGORY_MAP);
Bivio::IO::Config->register(my $_CFG = {
    category_map => sub {[]},
});
my($_R) = __PACKAGE__->use('Auth.Role');
my($_P) = __PACKAGE__->use('Auth.Permission');
my($_PS) = __PACKAGE__->use('Auth.PermissionSet');
my($_AR) = __PACKAGE__->use('Auth.Realm');
my($_RT) = __PACKAGE__->use('Auth.RealmType');

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
    copy_all src dst -- copies all records from src to dst realm
    edit role operation ... -- changes the permissions for realm/role
    edit_categories [category_op ...] -- disable or enable permission categories
    list_all_categories -- lists all defined permission categories
    list_enabled_categories -- list enabled permission categories for this realm
    list [role] -- lists permissions for this realm and role or all
    list_all [realm_type] -- lists permissions for all realms of realm_type
    make_super_user -- gives current user super_user privileges
    set_same old new - copies permission old to new for ALL realms
    unmake_super_user -- drops current user's super_user privileges
EOF
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

sub edit {
    my($self, $role_name, @operations) = @_;
    $self->usage('missing operations')
	unless @operations;
    my($req) = $self->get_request;
    my($realm) = $req->get('auth_realm');
    my($realm_id) = $realm->get('id');
    $self->model('RealmRole')->initialize_permissions(
	$realm->get('owner'),
    ) unless $realm->is_default;
    my($role) = $_R->from_any($role_name);
    my($ps) = _get_permission_set($self, $realm_id, $role, 1);
    _trace('current ', $role, ' ', $_PS->to_literal($ps))
	if $_TRACE;
    foreach my $op (@operations) {
	$self->usage_error("$op: invalid operation syntax")
	    unless $op =~ /^([-+])(\w*)$/;
	my($which, $operand) = ($1, uc($2));
	if (length($operand)) {
	    my($p) = $_P->unsafe_from_any($operand);
	    Bivio::Die->die($p, ': cannot set TRANSIENT permissions')
	        if $which eq '+' && $p && $p->get_name =~ /TRANSIENT/;
	    if ($p && $p->get_name eq $operand) {
		vec($ps, $p->as_int, 1) = $which eq '+' ? 1 : 0;
	    }
	    else {
		my($r) = $_R->unsafe_from_any($operand);
		$self->usage($op, ': neither a Role nor Permission')
			unless $r && $r->get_name eq $operand;
		my($s) = _get_permission_set($self, $realm_id, $r, 0);
		_trace($which, $r, ' ',
		    $_PS->to_literal($s)) if $_TRACE;
		# Set lengths must match for ~$s to work properly
		Bivio::Die->die(
		    'ASSERTION FAULT: set lengths differ: ',
		    length($s), ' != ', length($ps)
		) if length($s) != length($ps);
		$ps = $which eq '+' ? ($ps | $s) : ($ps & ~$s);
	    }
	}
	else {
	    $ps = $which eq '+'
		? $_PS->get_max
		: $_PS->get_min;
	}
    }
    my($rr) = $self->model('RealmRole');
    $rr->unauth_load(realm_id => $realm_id, role => $role)
	? $rr->update({permission_set => $ps})
	: $rr->create({
	    realm_id => $realm_id,
	    role => $role,
	    permission_set => $ps,
	});
    return;
}

sub edit_categories {
    my($self, $category_ops) = _edit_categories_args(@_);
    return unless @$category_ops;
    my($req) = $self->get_request;
    my($rr) = $self->model('RealmRole');
    my($o) = $req->get('auth_realm')->get('owner');
    foreach my $category_op (@$category_ops) {
	my($op, $cat) = $category_op =~ /^(-|\+)(\w+)$/;
	$self->usage_error($_, ': unknown category operation')
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

sub list {
    # (self, string) : undef
    # Print the permission sets so they can be used as input to this program.
    # If I<role_name> is C<undef>, gets all roles.
    my($self, $role_name) = @_;
    return _list_one($self, $self->get_request->get('auth_realm'),
	    _roles($role_name));
}

sub list_all {
    # (self, string) : string_ref
    # Lists all realms of I<realm_type>.  If no I<realm_type> is supplied,
    # all types are listed in order by I<realm_id>.  The first three realms
    # are the defaults, so we list them first.
    my($self, $realm_type) = @_;
    $realm_type = $_RT->from_any($realm_type)
	if defined($realm_type);
    my($sep) = '';
    my($ro) = $self->model('RealmOwner');
    my($it) = $ro->unauth_iterate_start('realm_id',
	    $realm_type ? {realm_type => $realm_type} : ());
    my($roles) = _roles();
    my($res) = '';
    while ($ro->iterate_next_and_load($it)) {
	# Roles are ascending, so can use $prev_role to shorten lists
	my($p) = _list_one($self, $_AR->new($ro), $roles);
	next unless $$p;
	$res .= <<"EOF".$$p;
$sep#
# @{[$ro->get('name')]} - Permissions
#
EOF
	$sep = "\n";
    }
    return \$res;
}

sub list_all_categories {
    # (self) : string_ref
    # Print all defined permission categories.
    my($self) = @_;
    my($res) = '';
    foreach my $x (@{$self->CATEGORIES}) {
	$res .= "$x\n";
    }
    return \$res;
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

sub make_super_user {
    # (self) : undef
    # Makes current user an super_user (administrator of general realm).
    my($self) = @_;
    $self->model('RealmUser')->unauth_create_or_update({
	realm_id => $_RT->GENERAL->as_int,
	user_id => $self->req('auth_user_id'),
	role => $_R->ADMINISTRATOR,
    });
    return;
}

sub new {
    # (proto) : Util.RealmRole
    # Initializes fields.
    my($self) = shift->SUPER::new(@_);
    $self->[$_IDI] = {};
    return $self;
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

sub unmake_super_user {
    # (self) : undef
    # Drops current user as super_user.  See L<make_super_user|"make_super_user">.
    my($self) = @_;
    my($req) = $self->get_request;
    $self->model('RealmUser')->unauth_delete({
	realm_id => $_RT->GENERAL->as_int,
	user_id => $req->get('auth_user_id')
	    || $self->usage_error('user not set'),
	role => $_R->ADMINISTRATOR,
    });
    return;
}

sub _category_map {
    # () : hash_ref
    # Returns initialized $_CATEGORY_MAP.
    my($proto) = @_;
    return $_CATEGORY_MAP ||= {map({
	my($cat, @ops) = @$_;
	($cat => {
	    map({
		my($op) = $_;
		($op => [
		    map({
			my($roles, $perms, @rest) = map(ref($_) ? $_ : [$_], @$_);
			Bivio::Die->die(
			    $cat,
			    ': invalid category_map entry; extra params: ',
			    \@rest,
			) if @rest;
			$roles = [map(
			    $_ eq '*' ? $_R->get_non_zero_list
				: $_R->from_any($_),
			    @$roles,
			)];
			map({
			    my($x) = $_;
			    [
				($x =~ s/^-// xor $op eq '-')
				    ? 'remove_permissions' : 'add_permissions',
				$roles,
				${$_PS->set($_PS->get_min, $_P->$x())},
			    ];
			} @$perms);
		    } @ops),
		]);
	    } qw(+ -)),
	});
    } @{$_CFG->{category_map}->()})};
}

sub _edit_categories_args {
    # (self, any) : array_ref
    # Returns a list of permission_categories, which have been  properly sorted
    # such that categories to be enabled following any categories to be disabled.
    # 
    # See edit_categories for more info on I<category_ops>.
    my($self) = shift;
    $self->usage('missing category_ops')
	unless @_;
    return $self, [reverse(sort(map({
	my($a) = $_;
	ref($a) eq 'ARRAY' ? @$a
	    : ref($a) eq 'HASH' ? map(($a->{$_} ? '+' : '-') . $_,
				      sort(keys(%$a)))
		: $a;
    } @_)))];
}

sub _get_permission_set {
    # (self, string, Auth.Role, boolean) : string
    # Returns the permission_set for the realm and role.
    my($self, $realm_id, $role, $dont_die) = @_;
    my($rr) = $self->model('RealmRole');
    return $rr->get('permission_set')
	    if $rr->unauth_load(realm_id => $realm_id, role => $role);
    # Make sure the initial value is correct
    return $_PS->get_min if $dont_die;
    $self->usage($role->as_string, ": not set for realm");
    # DOES NOT RETURN
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

sub _roles {
    # (string) : array_ref
    # Returns the list of all roles or just role I<name>.
    my($name) = @_;
    return defined($name)
	    ? [$_R->from_any($name)]
	    : [sort {$a->as_int <=> $b->as_int} $_R->get_list];
}

1;
