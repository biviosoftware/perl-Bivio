# Copyright (c) 1999-2005 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Biz::Util::RealmRole;
use strict;
$Bivio::Biz::Util::RealmRole::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Biz::Util::RealmRole::VERSION;

=head1 NAME

Bivio::Biz::Util::RealmRole - manipulate realm_role_t database table

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::Biz::Util::RealmRole;

=cut

=head1 EXTENDS

L<Bivio::ShellUtil>

=cut

use Bivio::ShellUtil;
@Bivio::Biz::Util::RealmRole::ISA = ('Bivio::ShellUtil');

=head1 DESCRIPTION

C<Bivio::Biz::Util::RealmRole> manages the RealmRole table.

=cut

=head1 CONSTANTS

=cut

=for html <a name="CATEGORIES"></a>

=head2 CATEGORIES : array_ref

Returns categories in L<CATEGORY_MAP|"CATEGORY_MAP">

=cut

sub CATEGORIES {
    return [keys(%{_category_map(shift)})];
}

=for html <a name="USAGE"></a>

=head2 USAGE : string

Returns usage.

=cut

sub USAGE {
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

#=IMPORTS
use Bivio::Auth::Permission;
use Bivio::Auth::PermissionSet;
use Bivio::Auth::Realm;
use Bivio::Auth::RealmType;
use Bivio::Auth::Role;
use Bivio::Die;
use Bivio::IO::Config;
use Bivio::IO::Trace;

#=VARIABLES
my(@_DATA);
my($_IDI) = __PACKAGE__->instance_data_index;
use vars qw($_TRACE);
Bivio::IO::Trace->register;
my($_CATEGORY_MAP);
Bivio::IO::Config->register(my $_CFG = {
    category_map => sub {[]},
});

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::Biz::Util::RealmRole

Initializes fields.

=cut

sub new {
    my($self) = shift->SUPER::new(@_);
    $self->[$_IDI] = {};
    return $self;
}

=head1 METHODS

=cut

=for html <a name="copy_all"></a>

=head2 copy_all(any src, any dst)

Copies all role, permission tuples from I<src> to I<dst> realm.

=cut

sub copy_all {
    my($self, $src, $dst) = @_;
    my($req) = $self->get_request;
    ($src, $dst) = map(
	Bivio::Biz::Model->new($req, 'RealmOwner')
	    ->unauth_load_by_id_or_name_or_die($_)->get('realm_id'),
	$src, $dst,
    );
    Bivio::Biz::Model->new($self->get_request, 'RealmRole')->do_iterate(
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

=for html <a name="edit"></a>

=head2 edit(string role_name, string operation, ...)

Updates the database for I<role_name> in current realm.  I<operation>
begins with C<+> or C<-> and may have an I<operand> which is either
a L<Bivio::Auth::Role|Bivio::Auth::Role> or
a L<Bivio::Auth::Permission|Bivio::Auth::Permission>.
If there is no operand, the permission set is cleared (C<->) or
all set (C<+>).

Initializes the permissions for the realm if not already
initialized and not one of the default realms.

=cut

sub edit {
    my($self, $role_name, @operations) = @_;
    $self->usage('missing operations')
	unless @operations;
    my($req) = $self->get_request;
    my($realm) = $req->get('auth_realm');
    my($realm_id) = $realm->get('id');
    Bivio::Biz::Model->new($req, 'RealmRole')->initialize_permissions(
	$realm->get('owner'),
    ) unless $realm->is_default;
    my($role) = Bivio::Auth::Role->from_any($role_name);
    my($ps) = _get_permission_set($self, $realm_id, $role, 1);
    _trace('current ', $role, ' ', Bivio::Auth::PermissionSet->to_literal($ps))
	if $_TRACE;
    foreach my $op (@operations) {
	$self->usage_error("$op: invalid operation syntax")
	    unless $op =~ /^([-+])(\w*)$/;
	my($which, $operand) = ($1, uc($2));
	if (length($operand)) {
	    my($p) = Bivio::Auth::Permission->unsafe_from_any($operand);
	    Bivio::Die->die($p, ': cannot set TRANSIENT permissions')
	        if $which eq '+' && $p && $p->get_name =~ /TRANSIENT/;
	    if ($p && $p->get_name eq $operand) {
		vec($ps, $p->as_int, 1) = $which eq '+' ? 1 : 0;
	    }
	    else {
		my($r) = Bivio::Auth::Role->unsafe_from_any($operand);
		$self->usage($op, ': neither a Role nor Permission')
			unless $r && $r->get_name eq $operand;
		my($s) = _get_permission_set($self, $realm_id, $r, 0);
		_trace($which, $r, ' ',
		    Bivio::Auth::PermissionSet->to_literal($s)) if $_TRACE;
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
		? Bivio::Auth::PermissionSet->get_max
		: Bivio::Auth::PermissionSet->get_min;
	}
    }
    my($rr) = Bivio::Biz::Model->new($req, 'RealmRole');
    $rr->unauth_load(realm_id => $realm_id, role => $role)
	? $rr->update({permission_set => $ps})
	: $rr->create({
	    realm_id => $realm_id,
	    role => $role,
	    permission_set => $ps,
	});
    return;
}

=for html <a name="edit_categories"></a>

=head2 edit_categories(string category_ops, ...) : string

=head2 edit_categories(array_ref category_ops, ...) : string

Edits permissions for entire auth realm.  I<category_ops> looks like
normal
L<Bivio::Biz::Util::RealmRole::edit|Bivio::Biz::Util::RealmRole/"edit">.
operations (+foo, -foo), but they are defined for a particular class
of L<CATEGORIES|"CATEGORIES">.

If I<category_ops> is an array_ref, it's not an error for it to be empty.

Returns string of what operations were performed, including current realm.

=cut

sub edit_categories {
    my($self, $category_ops) = _edit_categories_args(@_);
    return unless @$category_ops;
    my($req) = $self->get_request;
    my($rr) = Bivio::Biz::Model->new($req, 'RealmRole');
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

=for html <a name="handle_config"></a>

=head2 static handle_config(hash cfg)

=over 4

=back

=cut

sub handle_config {
    my(undef, $cfg) = @_;
    $_CATEGORY_MAP = undef;
    $_CFG = $cfg;
    return;
}

=for html <a name="list"></a>

=head2 list(string role_name)

Print the permission sets so they can be used as input to this program.
If I<role_name> is C<undef>, gets all roles.

=cut

sub list {
    my($self, $role_name) = @_;
    return _list_one($self, $self->get_request->get('auth_realm'),
	    _roles($role_name));
}

=for html <a name="list_all"></a>

=head2 list_all(string realm_type) : string_ref

Lists all realms of I<realm_type>.  If no I<realm_type> is supplied,
all types are listed in order by I<realm_id>.  The first three realms
are the defaults, so we list them first.

=cut

sub list_all {
    my($self, $realm_type) = @_;
    $realm_type = Bivio::Auth::RealmType->from_any($realm_type)
	    if defined($realm_type);
    my($sep) = '';
    my($ro) = Bivio::Biz::Model->new($self->get_request, 'RealmOwner');
    my($it) = $ro->unauth_iterate_start('realm_id',
	    $realm_type ? {realm_type => $realm_type} : ());
    my($roles) = _roles();
    my($res) = '';
    while ($ro->iterate_next_and_load($it)) {
	# Roles are ascending, so can use $prev_role to shorten lists
	my($p) = _list_one($self, Bivio::Auth::Realm->new($ro), $roles);
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

=for html <a name="list_all_categories"></a>

=head2 list_all_categories() : string_ref

Print all defined permission categories.

=cut

sub list_all_categories {
    my($self) = @_;
    my($res) = '';
    foreach my $x (@{$self->CATEGORIES}) {
	$res .= "$x\n";
    }
    return \$res;
}

=for html <a name="list_enabled_categories"></a>

=head2 list_enabled_categories() : array_ref

Shows permission categories which are enabled for the current realm.

=cut

sub list_enabled_categories {
    my($self) = @_;
    my($req) = $self->get_request;
    my($rp) = Bivio::Biz::Model->new($req, 'RealmRole')
	->get_permission_map($req->get('auth_realm'));
    my($cm) = _category_map($self);
    return [map({
	my($k) = $_;
	my($ops) = $cm->{$k}->{'+'};
	@$ops == grep({
	    my($op, $roles, $permissions) = @$_;
	    @$roles == grep(
		((($rp->{$_} & $permissions) eq $permissions)
		    xor ($op eq 'remove_permissions')),
		@$roles);
	} @$ops) ? $k : ();
    } sort(keys(%$cm)))];
}

=for html <a name="make_super_user"></a>

=head2 make_super_user()

Makes current user an super_user (administrator of general realm).

=cut

sub make_super_user {
    my($self) = @_;
    $self->model('RealmUser')->unauth_create_or_update({
	realm_id => Bivio::Auth::RealmType->GENERAL->as_int,
	user_id => $self->req('auth_user_id'),
	role => Bivio::Auth::Role->ADMINISTRATOR,
    });
    return;
}

=for html <a name="set_same"></a>

=head2 set_same(string old, string new)

Sets I<new> permission to same value as I<old> permission.  This is used
to add new permissions to the permission_set of all realms and roles
in the database.  The I<old> permission is a model for the I<new>
permission.  If the I<old> permission is set, the I<new> permission for the
same realm/role combination.  It can be used to adjust existing permissions.

=cut

sub set_same {
    my($self, $old, $new) = @_;
    $self->usage('set_same: missing args')
	    unless defined($new) && defined($old);
    my($new_int) = Bivio::Auth::Permission->from_name($new)->as_int;
    my($old_int) = Bivio::Auth::Permission->from_name($old)->as_int;
    my($rr) = Bivio::Biz::Model::RealmRole->new($self->get_request);
    my($it) = $rr->unauth_iterate_start('realm_id, role');
    while ($rr->iterate_next_and_load($it)) {
	my($s) = $rr->get('permission_set');
	vec($s, $new_int, 1) = vec($s, $old_int, 1);
	$rr->update({permission_set => $s});
    }
    $rr->iterate_end($it);
    return;
}

=for html <a name="unmake_super_user"></a>

=head2 unmake_super_user()

Drops current user as super_user.  See L<make_super_user|"make_super_user">.

=cut

sub unmake_super_user {
    my($self) = @_;
    my($req) = $self->get_request;
    Bivio::Biz::Model->new($req, 'RealmUser')->unauth_delete({
	realm_id => Bivio::Auth::RealmType->GENERAL->as_int,
	user_id => $req->get('auth_user_id')
	    || $self->usage_error('user not set'),
	role => Bivio::Auth::Role->ADMINISTRATOR,
    });
    return;
}

#=PRIVATE METHODS

# _category_map() : hash_ref
#
# Returns initialized $_CATEGORY_MAP.
#
sub _category_map {
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
			$roles = [map(Bivio::Auth::Role->$_(), @$roles)];
			map({
			    my($x) = $_;
			    [
				($x =~ s/^-// xor $op eq '-')
				    ? 'remove_permissions' : 'add_permissions',
				$roles,
				${Bivio::Auth::PermissionSet->set(
				    Bivio::Auth::PermissionSet->get_min,
				    Bivio::Auth::Permission->$x(),
				)},
			    ];
			} @$perms);
		    } @ops),
		]);
	    } qw(+ -)),
	});
    } @{$_CFG->{category_map}->()})};
}

# _edit_categories_args(self, any category_ops) : array_ref
#
# Returns a list of permission_categories, which have been  properly sorted
# such that categories to be enabled following any categories to be disabled.
#
# See edit_categories for more info on I<category_ops>.
#
sub _edit_categories_args {
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

# _get_permission_set(self, string realm_id, Bivio::Auth::Role role, boolean dont_die) : string
#
# Returns the permission_set for the realm and role.
#
sub _get_permission_set {
    my($self, $realm_id, $role, $dont_die) = @_;
    my($rr) = Bivio::Biz::Model::RealmRole->new($self->get_request);
    return $rr->get('permission_set')
	    if $rr->unauth_load(realm_id => $realm_id, role => $role);
    # Make sure the initial value is correct
    return Bivio::Auth::PermissionSet->get_min if $dont_die;
    $self->usage($role->as_string, ": not set for realm");
    # DOES NOT RETURN
}

# _list_one(self, Bivio::Auth::Realm realm, array_ref roles) : string_ref
#
# Lists the roles for realm_id.
#
sub _list_one {
    my($self, $realm, $roles) = @_;
    my($fields) = $self->[$_IDI];

    $fields->{all_permissions} = [
	sort {
	    $a->get_name cmp $b->get_name
	} Bivio::Auth::Permission->get_list
    ] unless $fields->{all_permissions};

    my($rr) = Bivio::Biz::Model::RealmRole->new($self->get_request);
    my($res) = '';
    my($prev_ps, $prev_role);
    my($realm_id, $realm_name) = $realm->unsafe_get(qw(id owner_name));
    $realm_name = $realm->get('type')->get_name unless $realm_name;
    foreach my $role (@$roles) {
	unless ($rr->unauth_load(realm_id => $realm_id, role => $role)) {
	    next;
	}
	# Always clear the set before adding in values
	$res .= $0." -r $realm_name edit ".$role->get_name;
	my($ps) = $rr->get('permission_set');
	if ($ps eq Bivio::Auth::PermissionSet->get_max) {
	    $res .= ' +';
	}
	else {
	    $res .= ' -';
	    # If the previous role is a subset, delete those bits and
	    # just add the role to the output.
	    my($s) = $ps;
	    if (defined($prev_ps) && ($prev_ps & $ps) eq $prev_ps) {
		$res .= " \\\n    +$prev_role";
		$s &= ~$prev_ps;
	    }
	    foreach my $p (@{$fields->{all_permissions}}) {
		$res .= " \\\n    +".$p->get_name
			if vec($s, $p->as_int, 1);
	    }
	}
	$res .= "\n";
	$prev_role = $role->get_name;
	$prev_ps = $ps;
    }
    return \$res;
}

# _roles(string name) : array_ref
#
# Returns the list of all roles or just role I<name>.
#
sub _roles {
    my($name) = @_;
    return defined($name)
	    ? [Bivio::Auth::Role->from_any($name)]
	    : [sort {$a->as_int <=> $b->as_int} Bivio::Auth::Role->get_list];
}

=head1 COPYRIGHT

Copyright (c) 1999-2005 bivio Software, Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
