# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::Util::RealmRole;
use strict;
$Bivio::Biz::Util::RealmRole::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Biz::Util::RealmRole - manipulate realm_role_t database table

=head1 SYNOPSIS

    use Bivio::Biz::Util::RealmRole;
    Bivio::Biz::Util::RealmRole->init();
    Bivio::Biz::Util::RealmRole->init_defaults();
    Bivio::Biz::Util::RealmRole->edit($realm, $role, @operations);
    Bivio::Biz::Util::RealmRole->list($realm, $role);
    Bivio::Biz::Util::RealmRole->set_same($new, $like);
    Bivio::Biz::Util::RealmRole->main(@ARGV);

=cut

use Bivio::UNIVERSAL;
@Bivio::Biz::Util::RealmRole::ISA = ('Bivio::UNIVERSAL');

=head1 DESCRIPTION

C<Bivio::Biz::Util::RealmRole>'s L<main|"main">
is used to manipulate the C<realm_role_t> in the
database.

In list mode, a realm with an optional role is specified and the
permissions that are set are listed.  The output can be used as
input to this program.  If no I<realm> is specified, the entire
table is dumped.  If no I<role> is specified, only the particular
realm is dumped.

In edit mode, the C<realm_role_t> is modified.  A role must be specified.  The
role is followed by one or more operations.  An operation either adds or
subtracts from the set in the table for the particular I<realm> and
I<role>.  The operand is either a I<role> or a I<permission> name.
If it is a I<permission>, only that permission is added or subtracted.
If it is a I<role>, the I<role>'s vector is added or subtracted.  The
I<role> operand can be tho same as the I<role> being modified in which
case C<+> (add) is a no-op and C<-> (subtract) clears the entire vector.

If there is no operand, then C<-> clears all permissions and
C<+> sets all permissions.

=head1 OPTIONS

=over 4

=item B<-n>

Do not commit the transaction.

=back

=cut

#=IMPORTS
use Bivio::Agent::Request;
use Bivio::Auth::Permission;
use Bivio::Auth::PermissionSet;
use Bivio::Auth::RealmType;
use Bivio::Auth::Role;
use Bivio::Biz::Model::RealmOwner;
use Bivio::Biz::Model::RealmRole;
use Bivio::Die;
use Bivio::DieCode;
use Bivio::IO::Config;
use Bivio::SQL::Connection;

#=VARIABLES
my(@_DATA);

=head1 METHODS

=cut

=for html <a name="edit"></a>

=head2 static edit(string realm_name, string role_name, string operation, ...)

Updates the databes for I<realm_name> and I<role_name>.  I<operation>
begins with C<+> or C<-> and may have an I<operand> which is either
a L<Bivio::Auth::Role|Bivio::Auth::Role> or
a L<Bivio::Auth::Permission|Bivio::Auth::Permission>.
If there is no operand, the permission set is cleared (C<->) or
all set (C<+>).

B<Does not commit changes to DB.>

=cut

sub edit {
    my(undef, $realm_name, $role_name, @operations) = @_;
    my($realm_id) = _get_realm_id($realm_name);
    $role_name = uc($role_name);
    my($role) = Bivio::Auth::Role->$role_name();

    # Get the database value or an empty set
    my($ps) = _get_permission_set($realm_id, $role, 1);

    # Modify the initial value
    foreach my $op (@operations) {
	_usage("$op: invalid operation syntax") unless $op =~ /^([-+])(\w*)$/;
	my($which, $operand) = ($1, uc($2));
	if (length($operand)) {
	    my($p) = Bivio::Auth::Permission->unsafe_from_any($operand);
	    if ($p && $p->get_name eq $operand) {
		vec($ps, $p->as_int, 1) = $which eq '+' ? 1 : 0;
	    }
	    else {
		my($r) = Bivio::Auth::Role->unsafe_from_any($operand);
		_usage("$op: neither a Role nor Permission")
			unless $r && $r->get_name eq $operand;
		my($s) = _get_permission_set($realm_id, $r, 0);
		# Set lengths must match for ~$s to work properly
		Bivio::DieCode::DIE()->die(
			'ASSERTION FAULT: set lengths differ')
			    unless length($s) eq length($ps);
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

=for html <a name="init"></a>

=head2 static init()

Initializes the defaults, demo_club, etc.

B<Does not commit changes to DB.>

=cut

sub init {
    return _init(0);
}

=for html <a name="init_defaults"></a>

=head2 static init_defaults()

Initializes the default roles for the three realm types only.

B<Does not commit changes to DB.>

=cut

sub init_defaults {
    return _init(1);
}

=for html <a name="list"></a>

=head2 static list(string realm_name, string role_name)

Print the permission sets so they can be used as input to this program.
If I<realm_name> is C<undef>, gets all realms.
If I<role_name> is C<undef>, gets all roles.

=cut

sub list {
    my(undef, $realm_name, $role_name) = @_;
    my($realms) = defined($realm_name)
	    ? {_get_realm_id($realm_name), $realm_name} : _get_realms();
    my(@roles) = defined($role_name)
	    ? Bivio::Auth::Role->from_any($role_name)
	    : sort {$a->as_int <=> $b->as_int} Bivio::Auth::Role->get_list;
    # sort keys numerically, we know they are positive so this trick works
    my(@realm_ids) = sort {
	my($i) = length($a) - length($b);
	$i ? $i : $a cmp $b
    } keys(%$realms);
    my($rr) = Bivio::Biz::Model::RealmRole->new;
    # Sort by name for easier readability
    my(@p_list) = sort {
	$a->get_name cmp $b->get_name
    } Bivio::Auth::Permission->get_list;
    my($sep) = '';
    foreach my $realm_id (@realm_ids) {
	my($prev_ps, $prev_role);
	my($realm_name) = $realms->{$realm_id};
	# Roles are ascending, so can use $prev_role to shorten lists
	print <<"EOF" if int(@realm_ids) > 1;
$sep#
# $realm_name Permissions
#
EOF
	$sep = "\n";
	foreach my $role (@roles) {
	    unless ($rr->unauth_load(realm_id => $realm_id, role => $role)) {
		# print $realm_name, ' ', $role->get_name, ": not set\n";
		next;
	    }
	    # Always clear the set before adding in values
	    my($res) = $0." $realm_name ".$role->get_name;
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
		foreach my $p (@p_list) {
		    $res .= " \\\n    +".$p->get_name
			    if vec($s, $p->as_int, 1);
		}
	    }
	    print $res, "\n";
	    $prev_role = $role->get_name;
	    $prev_ps = $ps;
	}
    }
    return;
}

=for html <a name="main"></a>

=head2 static main(array argv) : int

Parses its arguments.  If I<argv> contains is a valid method, will call it.

Calls L<Bivio::SQL::Connection::commit|Bivio::SQL::Connection/"commit">.

=cut

sub main {
    my($proto, @argv) = @_;
    Bivio::IO::Config->initialize(\@argv);
    Bivio::Agent::Request->get_current_or_new;

    # Parse -n flag
    my($execute) = 1;
    $execute = 0, shift(@argv) if @argv && $argv[0] eq '-n';

    # Parse operation
    # Execute method by name.  This will execute "main" if called that
    # way, but it is harmless to call main that way....
    if (@argv && $argv[0] =~ /^(\w+)$/ && $proto->can($1)) {
	shift(@argv);
	$proto->$1(@argv);
    }
    else {
	_usage('unknown command');
    }
    $execute && Bivio::SQL::Connection->commit();
    return;
}

=for html <a name="set_same"></a>

=head2 static set_same(string new, string like)

Sets I<new> permission to same value as I<like> permission.  This is used
to add new permissions to the permission_set of all realms and roles
in the database.  The I<like> permission is a model for the I<new>
permission.  If the I<like> permission is set, the I<new> permission for the
same realm/role combination.  It can be used to adjust existing permissions.

=cut

sub set_same {
    my($proto, $new, $like) = @_;
    my($new_int) = Bivio::Auth::Permission->from_name($new)->as_int;
    my($like_int) = Bivio::Auth::Permission->from_name($like)->as_int;
    my($rr) = Bivio::Biz::Model::RealmRole->new(
	    Bivio::Agent::Request->get_current_or_new);
    my($it) = $rr->unauth_iterate_start('realm_id, role');
    while ($rr->iterate_next_and_load($it)) {
	my($s) = $rr->get('permission_set');
	vec($s, $new_int, 1) = vec($s, $like_int, 1);
	$rr->update({permission_set => $s});
    }
    $rr->iterate_end($it);
    return;
}

#=PRIVATE METHODS

# _get_realm_id(string realm_name) : string
#
# Returns realm_id for realm_name or blows up.
#
sub _get_realm_id {
    my($realm_name) = @_;
    # Since from_any may map to anything, we check the type name
    # against realm_name exactly.
    my($rt) = Bivio::Auth::RealmType->unsafe_from_any($realm_name);
    return $rt->as_int if $rt && $rt->get_name eq uc($realm_name);

    # Look in the database
    my($ro) = Bivio::Biz::Model::RealmOwner->new;
    _usage($realm_name, ": realm not found")
	    unless $ro->unauth_load(name => $realm_name);
    return $ro->get('realm_id');
}

# _get_realms() : hash_ref
#
# Returns all realms in realm_role_t in a single hash (realm_id, name).
#
sub _get_realms {
    my(%res) = map {
	($_->as_int, $_->get_name)
    } Bivio::Auth::RealmType->get_list;
    my($statement) = Bivio::SQL::Connection->execute(<<'EOF');
	    SELECT distinct realm_role_t.realm_id, name
	      FROM realm_owner_t, realm_role_t
	      WHERE realm_role_t.realm_id = realm_owner_t.realm_id
EOF
    while (my($realm_id, $name) = $statement->fetchrow_array) {
	# Don't re-insert default realms
	next if $realm_id <= Bivio::Auth::RealmType->get_max;
	$res{$realm_id} = $name;
    }
    return \%res;
}

# _get_permission_set(string realm_id, Bivio::Auth::Role role, boolean dont_die) : string
#
# Returns the permission_set for the realm and role.
#
sub _get_permission_set {
    my($realm_id, $role, $dont_die) = @_;
    my($rr) = Bivio::Biz::Model::RealmRole->new();
    return $rr->get('permission_set')
	    if $rr->unauth_load(realm_id => $realm_id, role => $role);
    # Make sure the initial value is correct
    return Bivio::Auth::PermissionSet->get_min if $dont_die;
    _usage($role->as_string, ": not set for realm");
}

# _init(boolean defaults_only)
#
# Initializes the database with the values from __DATA__ section
# in this file.  If defaults_only, stops at "END DEFAULTS" flag in
# DATA section.
#
sub _init {
    my($defaults_only) = @_;
    unless (@_DATA) {
	@_DATA = <DATA>;
	chomp(@_DATA);
    }
    my($cmd);
    foreach my $line (@_DATA) {
	# Drop out if hit sentinel
	last if $defaults_only && $line =~ /^#\s*END\s+DEFAULTS/;

	# Skip comments and blank cmds
	next if $line =~ /^\s*(#|$)/;
	$cmd .= $line;

	# Continuation char at end of line?
	next if $cmd =~ s/\\$/ /;

	# Parse command
	my(@args) = split(' ', $cmd);

	# Delete the b-realm-role at the front
	shift(@args);
	edit(undef, @args);
        $cmd = '';
    }
    # Avoids error messages containing DATA
    close(DATA);
    return;
}

# _usage(array msg)
#
# Outputs a message and dies
#
sub _usage {
    Bivio::DieCode::DIE()->die(<<"EOF");
b-realm-role: @{[join('', @_)]}
usage: b-realm-role [-n] edit realm role (+|-)(permission|role)...
       b-realm-role list [realm [role]]
       b-realm-role [-n] init
       b-realm-role [-n] init_defaults
       b-realm-role [-n] set_same new_permission like_permission
EOF
}

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
__DATA__
#
# GENERAL Permissions
#
b-realm-role GENERAL ANONYMOUS - \
    +LOGIN \
    +DOCUMENT_READ \
    +MAIL_WRITE
b-realm-role GENERAL USER - \
    +ANONYMOUS \
    +ANY_USER \
    +MAIL_RECEIVE
b-realm-role GENERAL WITHDRAWN - \
    +USER
b-realm-role GENERAL GUEST - \
    +WITHDRAWN
b-realm-role GENERAL MEMBER - \
    +GUEST
b-realm-role GENERAL ACCOUNTANT - \
    +MEMBER
b-realm-role GENERAL ADMINISTRATOR +

#
# USER Permissions
#
b-realm-role USER ANONYMOUS - \
    +LOGIN \
    +MAIL_WRITE
b-realm-role USER USER - \
    +ANONYMOUS \
    +ANY_USER
b-realm-role USER WITHDRAWN - \
    +USER
b-realm-role USER GUEST - \
    +WITHDRAWN \
    +DOCUMENT_READ
b-realm-role USER MEMBER - \
    +GUEST
b-realm-role USER ACCOUNTANT - \
    +MEMBER
b-realm-role USER ADMINISTRATOR +

#
# CLUB Permissions
#
b-realm-role CLUB ANONYMOUS - \
    +LOGIN \
    +MAIL_WRITE
b-realm-role CLUB USER - \
    +ANONYMOUS \
    +ANY_USER
b-realm-role CLUB WITHDRAWN - \
    +USER
b-realm-role CLUB GUEST - \
    +WITHDRAWN \
    +ADMIN_READ \
    +ACCOUNTING_READ \
    +DOCUMENT_READ \
    +FINANCIAL_DATA_READ \
    +MAIL_READ \
    +MEMBER_READ \
    +MOTION_READ
#TODO: Model::Club assumes MAIL_RECEIVE set for MEMBER and above
b-realm-role CLUB MEMBER - \
    +GUEST \
    +DOCUMENT_WRITE \
    +MAIL_RECEIVE
b-realm-role CLUB ACCOUNTANT +
b-realm-role CLUB ADMINISTRATOR +
#END DEFAULTS -- this tag is used by init_defaults()

#
# Demo Club Permissions, everybody is like a GUEST of a normal club
#
b-realm-role demo_club ANONYMOUS - \
    +LOGIN \
    +MAIL_WRITE \
    +ANY_USER \
    +ADMIN_READ \
    +ACCOUNTING_READ \
    +DOCUMENT_READ \
    +FINANCIAL_DATA_READ \
    +MAIL_READ \
    +MEMBER_READ \
    +MOTION_READ
b-realm-role demo_club USER - \
    +ANONYMOUS
b-realm-role demo_club WITHDRAWN - \
    +USER
b-realm-role demo_club GUEST - \
    +WITHDRAWN
#TODO: Model::Club assumes MAIL_RECEIVE set for MEMBER and above
b-realm-role demo_club MEMBER - \
    +GUEST
b-realm-role demo_club ACCOUNTANT - \
    +MEMBER
b-realm-role demo_club ADMINISTRATOR - \
    +ACCOUNTANT

#
# ask_candis_publish Permissions (same as club except for MAIL_WRITE)
#
b-realm-role ask_candis_publish ANONYMOUS - \
    +LOGIN
b-realm-role ask_candis_publish USER - \
    +ANONYMOUS \
    +ANY_USER
b-realm-role ask_candis_publish WITHDRAWN - \
    +USER
b-realm-role ask_candis_publish GUEST - \
    +WITHDRAWN \
    +ADMIN_READ \
    +ACCOUNTING_READ \
    +DOCUMENT_READ \
    +FINANCIAL_DATA_READ \
    +MAIL_READ \
    +MEMBER_READ \
    +MOTION_READ
#TODO: Model::Club assumes MAIL_RECEIVE set for MEMBER and above
b-realm-role ask_candis_publish MEMBER - \
    +GUEST \
    +DOCUMENT_WRITE \
    +MAIL_RECEIVE \
    +MAIL_WRITE
b-realm-role CLUB ACCOUNTANT +
b-realm-role CLUB ADMINISTRATOR +

#
# trez_talk_publish Permissions (same as club except for MAIL_WRITE)
#
b-realm-role trez_talk_publish ANONYMOUS - \
    +LOGIN
b-realm-role trez_talk_publish USER - \
    +ANONYMOUS \
    +ANY_USER
b-realm-role trez_talk_publish WITHDRAWN - \
    +USER
b-realm-role trez_talk_publish GUEST - \
    +WITHDRAWN \
    +ADMIN_READ \
    +ACCOUNTING_READ \
    +DOCUMENT_READ \
    +FINANCIAL_DATA_READ \
    +MAIL_READ \
    +MEMBER_READ \
    +MOTION_READ
#TODO: Model::Club assumes MAIL_RECEIVE set for MEMBER and above
b-realm-role trez_talk_publish MEMBER - \
    +GUEST \
    +DOCUMENT_WRITE \
    +MAIL_RECEIVE \
    +MAIL_WRITE
b-realm-role CLUB ACCOUNTANT +
b-realm-role CLUB ADMINISTRATOR +
