# Copyright (c) 1999-2001 bivio Inc.  All rights reserved.
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

=for html <a name="USAGE"></a>

=head2 USAGE : string

Returns:

    usage: b-realm-role [options] command [args...]
    commands:
	edit role operation ... -- changes the permissions for realm/role
	list [role] -- lists permissions for this realm and role or all
	list_all [realm_type] -- lists permissions for all realms of realm_type
	set_same old new - copies permission old to new for ALL realms

=cut

sub USAGE {
    return <<'EOF';
usage: b-realm-role [options] command [args...]
commands:
    edit role operation ... -- changes the permissions for realm/role
    list [role] -- lists permissions for this realm and role or all
    list_all [realm_type] -- lists permissions for all realms of realm_type
    set_same old new - copies permission old to new for ALL realms
EOF
}

#=IMPORTS
use Bivio::Auth::Permission;
use Bivio::Auth::PermissionSet;
use Bivio::Auth::RealmType;
use Bivio::Auth::Role;
use Bivio::Biz::Model::RealmOwner;
use Bivio::Biz::Model::RealmRole;
use Bivio::IO::Trace;

#=VARIABLES
my(@_DATA);
my($_PACKAGE) = __PACKAGE__;
use vars qw($_TRACE);
Bivio::IO::Trace->register;


=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::Biz::Util::RealmRole

Initializes fields.

=cut

sub new {
    my($self) = Bivio::ShellUtil::new(@_);
    $self->{$_PACKAGE} = {};
    return $self;
}

=head1 METHODS

=cut

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
    $self->usage('missing operations') unless @operations;
    my($req) = $self->get_request;
    my($realm) = $req->get('auth_realm');
    my($realm_id) = $realm->get('id');
    Bivio::Biz::Model->new($req, 'RealmRole')->initialize_permissions(
	    Bivio::Biz::Model->new($req, 'RealmOwner')
	    ->unauth_load_or_die(realm_id => $realm_id))
		unless $realm->is_default;
    my($role) = Bivio::Auth::Role->from_name($role_name);

    # Get the database value or an empty set
    my($ps) = _get_permission_set($self, $realm_id, $role, 1);
    _trace('current ', $role, ' ', Bivio::Auth::PermissionSet->to_literal($ps))
	    if $_TRACE;

    # Modify the initial value
    foreach my $op (@operations) {
	$self->usage("$op: invalid operation syntax")
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
			length($s), ' != ', length($ps))
			    if length($s) != length($ps);
		$ps = $which eq '+' ? ($ps | $s) : ($ps & ~$s);
	    }
	}
	else {
	    $ps = $which eq '+' ? Bivio::Auth::PermissionSet->get_max
		    : Bivio::Auth::PermissionSet->get_min;
	}
    }
    my($rr) = Bivio::Biz::Model::RealmRole->new();
    $rr->unauth_load(realm_id => $realm_id, role => $role)
	    ? $rr->update({permission_set => $ps})
	    : $rr->create({realm_id => $realm_id, role => $role,
		permission_set => $ps});
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

#=PRIVATE METHODS

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
    my($fields) = $self->{$_PACKAGE};

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
	    # print $realm_name, ' ', $role->get_name, ": not set\n";
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

Copyright (c) 1999-2001 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
