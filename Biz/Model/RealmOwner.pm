# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
# Generated by ../generate.PL on Wed Aug 18  7:57:50 1999
# from tables.sql,v 1.13 1999/08/13 17:06:21 moeller Exp 
package Bivio::Biz::Model::RealmOwner;
use strict;
$Bivio::Biz::Model::RealmOwner::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Biz::Model::RealmOwner::VERSION;

=head1 NAME

Bivio::Biz::Model::RealmOwner - interface to realm_owner_t SQL table

=head1 SYNOPSIS

    use Bivio::Biz::Model::RealmOwner;
    Bivio::Biz::Model::RealmOwner->new($req);

=cut

=head1 EXTENDS

L<Bivio::Biz::PropertyModel>

=cut

use Bivio::Biz::PropertyModel;
@Bivio::Biz::Model::RealmOwner::ISA = qw(Bivio::Biz::PropertyModel);

=head1 DESCRIPTION

C<Bivio::Biz::Model::RealmOwner> is the create, read, update,
and delete interface to the C<realm_owner_t> table.

=cut

use Bivio::Type::RealmName;

=head1 CONSTANTS

=cut

=for html <a name="SHADOW_PREFIX"></a>

=head2 SHADOW_PREFIX : string

Returns prefix character for shadow users

=cut

sub SHADOW_PREFIX {
    return Bivio::Type::RealmName::SHADOW_PREFIX();
}

=for html <a name="SHADOW_WITHDRAWN_PREFIX"></a>

=head2 SHADOW_WITHDRAWN_PREFIX : string

Returns prefix character for a withdrawn shadow user

=cut

sub SHADOW_WITHDRAWN_PREFIX {
    return SHADOW_PREFIX().'(';
}

=for html <a name="SHADOW_WITHDRAWN_SUFFIX"></a>

=head2 SHADOW_WITHDRAWN_SUFFIX : string

Returns the suffix character for a withdrawn shadow user

=cut

sub SHADOW_WITHDRAWN_SUFFIX {
    return ')';
}

#=IMPORTS
use Bivio::Die;
use Bivio::Agent::TaskId;
use Bivio::Auth::RealmType;
use Bivio::Biz::Accounting::Audit;
use Bivio::Biz::Model::Email;
use Bivio::IO::Trace;
use Bivio::SQL::Connection;
use Bivio::Type::Amount;
use Bivio::Type::Date;
use Bivio::Type::DateTime;
use Bivio::Type::EntryClass;
use Bivio::Type::RealmName;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;
use vars ('$_TRACE');
Bivio::IO::Trace->register;
my($_SQL_DATE_VALUE) = Bivio::Type::DateTime->to_sql_value('?');
my($_DEMO_SUFFIX) = Bivio::Type::RealmName::DEMO_CLUB_SUFFIX();
my($_DEMO_THRESHOLD) = Bivio::Type::RealmName->get_width
	- length($_DEMO_SUFFIX);
my($_SHADOW_PREFIX) = SHADOW_PREFIX();
my($_M) = 'Bivio::Type::Amount';
my(%_HOME_TASK_MAP) = (
    Bivio::Auth::RealmType::CLUB() => Bivio::Agent::TaskId::CLUB_HOME(),
    Bivio::Auth::RealmType::USER() => Bivio::Agent::TaskId::USER_HOME(),
);
my($_MAIL_HOST);

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(Bivio::Agent::Request req) : Bivio::Biz::Model::RealmOwner

Creates a RealmOwner.

=cut

sub new {
    my($self) = &Bivio::Biz::PropertyModel::new(@_);
    $self->{$_PACKAGE} = {};
    return $self;
}

=head1 METHODS

=cut

=for html <a name="audit_units"></a>

=head2 audit_units(string date)

Recalculates and adjusts member entries which affect units after the
specified date.

Deprecated, use Bivio::Biz::Accounting::Audit->new()->audit_units($date)

=cut

sub audit_units {
    my($self, $date) = @_;
    Bivio::Biz::Accounting::Audit->new($self->get_request)->audit_units($date);
    return;
}

=for html <a name="cascade_delete"></a>

=head2 cascade_delete()

Deletes this realm and any realm specific information (email, phone, address,
roles). This method will not remove a realm from RealmUser. If the user/realm
is a club member this method will die.

=cut

sub cascade_delete {
    my($self) = @_;
    my($id) = $self->get('realm_id');

    # delete related records
    my($params) = [$id];
    foreach my $table (qw(email_t phone_t address_t realm_role_t
            realm_decor_t realm_notice_t tax_id_t preferences_t tax_1065_t
            password_request_t)) {
	Bivio::SQL::Connection->execute('
                DELETE FROM '.$table.'
                WHERE realm_id=?',
		$params);
    }

    # Delete any links from visitor_t
    Bivio::SQL::Connection->execute('
            UPDATE visitor_t
            SET referer_realm_id = NULL
            WHERE referer_realm_id=?',
	    $params);

    $self->delete();
    return;
}

=for html <a name="clear_instrument_cache"></a>

=head2 clear_instrument_cache()

Clears all cached instrument info.

#TODO: move this an instrument calculations to a separate class.

=cut

sub clear_instrument_cache {
    my($self) = @_;
    # clear any cached values
    $self->{$_PACKAGE} = {};
    return;
}

=for html <a name="create"></a>

=head2 create(hash_ref new_values)

Sets I<creation_date_time>, I<password> (to invalid),
and I<display_name> if not set, then calls SUPER.

=cut

sub create {
    my($self, $values) = @_;
    $values->{display_name} = $values->{name}
	    unless defined($values->{display_name});
    $values->{creation_date_time} = Bivio::Type::DateTime->now()
	    unless defined($values->{creation_date_time});
    $values->{password} = Bivio::Type::Password->INVALID()
	    unless defined($values->{password});
    return $self->SUPER::create($values);
}

=for html <a name="format_demo_club_name"></a>

=head2 format_demo_club_name() : string

Formats demo club name for this user.

=cut

sub format_demo_club_name {
    my($self) = @_;
    my($n) = $self->get('name');

    # This is a legitimate realm name, but users can't enter it because
    # it begins with a number and ends with the demo suffix.
    # See Type::RealmName
    $n = $self->get('realm_id') if length($n) > $_DEMO_THRESHOLD;
    return $n.Bivio::Type::RealmName::DEMO_CLUB_SUFFIX();
}

=for html <a name="format_email"></a>

=head2 format_email() : string

=head2 static format_email(Bivio::Biz::ListModel list_model, string model_prefix) : string

Returns fully-qualified email address for this realm or '' if the
realm is an accounting shadow user.

See L<format_name|"format_name"> for params.

=cut

sub format_email {
    my($proto) = shift;
    my($list_model) = @_;
    my($m) = $list_model || $proto;
    my($name) = $proto->format_name(@_);
    return $name ? $m->get_request->format_email($name) : '';
}

=for html <a name="format_http"></a>

=head2 format_http() : string

=head2 static format_http(Bivio::Biz::ListModel list_model, string model_prefix) : string

Returns the absolute URL (with http) to access (the root of) this realm.

HACK!

See L<format_name|"format_name"> for params.

=cut

sub format_http {
    my($proto) = shift;
    my($list_model) = @_;
    my($m) = $list_model || $proto;
    return $m->get_request->format_http_prefix.$proto->format_uri(@_);
}

=for html <a name="format_mailto"></a>

=head2 format_mailto() : string

=head2 static format_mailto(Bivio::Biz::ListModel list_model, string model_prefix) : string

Returns email address with C<mailto:> prefix.

See L<format_name|"format_name"> for params.

=cut

sub format_mailto {
    my($proto) = shift;
    my($list_model) = @_;
    my($m) = $list_model || $proto;
    return $m->get_request->format_mailto($proto->format_email(@_));
}

=for html <a name="format_name"></a>

=head2 format_name() : string

=head2 static format_name(Bivio::Biz::ListModel list_model, string model_prefix) : string

Returns the name formatted for display. Accounting shadow users
return ''.

In the second form, I<list_model> is used to get the values, not I<self>.
List Models can declare a method of the form:

    sub format_name {
	my($self) = shift;
	Bivio::Biz::Model::Address->format($self, 'RealmOwner.', @_);
    }

=cut

sub format_name {
    my($self, $list_model, $model_prefix) = @_;
    my($p) = $model_prefix || '';
    my($m) = $list_model || $self;
    my($name) = $m->get($p.'name');

    if ($name =~ /^$_SHADOW_PREFIX/o) {

#TODO: couldn't use constants because the '(' screw up the regex...
	if ($name =~ /^=\(/o) {

	    # show a withdrawn shadow name in ()
	    $name =~ s/^=(\(\w+\))\d+/$1/;
	}
	else {
	    $name = '';
	}
    }
    return $name;
}

=for html <a name="format_uri"></a>

=head2 format_uri() : string

=head2 static format_uri(Bivio::Biz::ListModel list_model, string model_prefix) : string

Returns the URI to access the HOME task for this realm.

See L<format_name|"format_name"> for params.

=cut

sub format_uri {
    my($proto) = shift;
    my($list_model, $model_prefix) = @_;
    my($m) = $list_model || $proto;
    my($p) = $model_prefix || '';
    my($name) = $proto->format_name(@_);
    Bivio::Die->die($m->get($p.'name'),
	    ': must not be shadow user') unless $name;
    my($t) = $_HOME_TASK_MAP{$m->get($p.'realm_type')};
    Bivio::Die->die($m->get($p.'name'), ', ',
	    $m->get($p.'realm_type'), ': invalid realm type') unless $t;
    return $m->get_request->format_uri($t, undef, $name, undef);
}

=for html <a name="get_instruments_info"></a>

=head2 get_instruments_info() : array_ref

Returns an array of realm instrument records (id, name, symbol, instrument_id).

=cut

sub get_instruments_info {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    my($cache) = $fields->{get_instruments_info};
    return $cache if $cache;

#TODO: make this a ListModel
    my($query) = <<'EOF';
	SELECT realm_instrument_t.realm_instrument_id,
	    realm_instrument_t.name || instrument_t.name cat_name,
	    realm_instrument_t.ticker_symbol || instrument_t.ticker_symbol,
            realm_instrument_t.instrument_id,
            realm_instrument_t.average_cost_method
	FROM realm_instrument_t, instrument_t
        WHERE realm_instrument_t.instrument_id = instrument_t.instrument_id (+)
	AND realm_id=?
	ORDER BY cat_name
EOF
    my($sth) = Bivio::SQL::Connection->execute($query,
	    [$self->get('realm_id')]);

    my($result) = [];

    while (my $row = $sth->fetchrow_arrayref) {
	my($id, $name, $symbol, $instrument_id, $ave_cost) = @$row;
	push(@$result, [$id, $name, $symbol, $instrument_id, $ave_cost]);
    }
    $fields->{get_instruments_info} = $result;
    return $result;
}

=for html <a name="get_cost_per_share"></a>

=head2 get_cost_per_share(string date) : hash_ref

Returns the total cost per share for all the RealmInstruments owned
by the realm. Returns realm_instrument_id => [cost per share, total cost].

=cut

sub get_cost_per_share {
    my($self, $date) = @_;
    $date = Bivio::Type::Date->to_local_date($date);

#TODO: THIS SHOULD ALL BE DONE IN SQL!
#      very clumsy with cost basis of fractional shares
#      need to separate shares returned (ignored)
#      from the value of the returned shares (affects total_cost)
    my($query) = <<"EOF";
	SELECT realm_instrument_entry_t.realm_instrument_id,
	    entry_t.amount,
	    realm_instrument_entry_t.count,
	    entry_t.entry_type,
	    entry_t.tax_basis,
	    entry_t.tax_category
	FROM realm_transaction_t, entry_t, realm_instrument_entry_t
	WHERE realm_transaction_t.realm_transaction_id
	    = entry_t.realm_transaction_id
	AND entry_t.entry_id = realm_instrument_entry_t.entry_id
	AND realm_transaction_t.realm_id = ?
	AND realm_transaction_t.date_time <= $_SQL_DATE_VALUE
EOF
    my($sth) = Bivio::SQL::Connection->execute($query,
	   [$self->get('realm_id'),
		   Bivio::Type::DateTime->to_sql_param($date)]);

    my($result) = {};
    while (my $row = $sth->fetchrow_arrayref()) {
	my($id, $cost, $count, $type, $basis, $tax) = @$row;
	my($pair) = $result->{$id};
	unless ($pair) {
	    $pair = $result->{$id} = [0, 0],
	}

	if ($basis) {
	    $pair->[0] = $_M->add($pair->[0], $cost);
	}
	elsif ($tax == Bivio::Type::TaxCategory->NOT_TAXABLE->as_int()
#TODO: ugh - consider consolidating SHARES_AS_CASH types
		&& ($type == Bivio::Type::EntryType
			->INSTRUMENT_SPLIT_SHARES_AS_CASH->as_int()
#TODO: whoa! removed these, definitely not consistent here.
# the import is going to have to do a better job here
# probably want to adjust instrument split cost
#		    || $type == Bivio::Type::EntryType
#			->INSTRUMENT_SPINOFF_SHARES_AS_CASH->as_int()
#		    || $type == Bivio::Type::EntryType
#			->INSTRUMENT_MERGER_SHARES_AS_CASH->as_int())
	       )) {
	    $pair->[0] = $_M->add($pair->[0], $cost);
	}

	if ($basis) {
	    $pair->[1] = $_M->add($pair->[1], $count);
	}
    }
    foreach my $id (keys(%$result)) {
	my($total_cost, $total_count) = @{$result->{$id}};
	next if $total_count == 0;
	$result->{$id} = [$_M->div($total_cost, $total_count), $total_cost];
    }
    return $result;
}

=for html <a name="get_number_of_shares"></a>

=head2 get_number_of_shares(string date) : hash_ref

Returns the number of shares of RealmInstruments owned by the realm on the
specified date. Returns a hash of realm_instrument_id => count.

=cut

sub get_number_of_shares {
    my($self, $date) = @_;
    my($fields) = $self->{$_PACKAGE};
    $date = Bivio::Type::Date->to_local_date($date);
    my($cache) = $fields->{'get_number_of_shares'.$date};
    return $cache if $cache;

    # note: doesn't include fractional shares paid in cash (not tax basis)
    my($query) = <<"EOF";
	SELECT realm_instrument_entry_t.realm_instrument_id,
	    sum(realm_instrument_entry_t.count)
	FROM realm_transaction_t,
	    entry_t,
	    realm_instrument_entry_t
	WHERE
            realm_transaction_t.realm_id = ?
	    AND realm_transaction_t.realm_transaction_id
		    = entry_t.realm_transaction_id
	    AND entry_t.entry_id = realm_instrument_entry_t.entry_id
	    AND entry_t.tax_basis = 1
	    AND realm_transaction_t.date_time <= $_SQL_DATE_VALUE
	GROUP BY realm_instrument_entry_t.realm_instrument_id
EOF
    my($sth) = Bivio::SQL::Connection->execute($query,
	   [$self->get('realm_id'),
	       Bivio::Type::DateTime->to_sql_param($date)]);

    my($result) = {};
    while (my $row = $sth->fetchrow_arrayref()) {
	my($id, $count) = @$row;
	$result->{$id} = $count;
    }
    $fields->{'get_number_of_shares'.$date} = $result;
    return $result;
}

=for html <a name="get_share_price_and_date"></a>

=head2 get_share_price_and_date(string date) : hash_ref

Returns a hash of realm_instrument_id => [value, date, is_local] for the all
the RealmInstruments on the specified date.

=cut

sub get_share_price_and_date {
    my($self, $date) = @_;
    my($fields) = $self->{$_PACKAGE};
    $date = Bivio::Type::Date->to_local_date($date);
    my($cache) = $fields->{'get_share_price_and_date'.$date};
    return $cache if $cache;

    my($result) = {};

    # valuation algorithm:
    #   if realm_instrument_valuation_t exists for the date, use it
    #   if not in global quotes use local (realm_instrument_valuation_t).
    #   otherwise get most recent value from realm_instrument_valuation_t
    #    or instrument_valuation_t

    # look on exactly that date, allows a local override
    my($sth) = Bivio::SQL::Connection->execute("
            SELECT realm_instrument_id, price_per_share
            FROM realm_instrument_valuation_t
            WHERE realm_id=?
            AND date_time=$_SQL_DATE_VALUE",
	    [$self->get('realm_id'), $date]);
    while (my $row = $sth->fetchrow_arrayref) {
	my($id, $value) = @$row;
	$result->{$id} = [$value, $date, 1];
    }

    # search last 8 days
    my($j, undef) = $date =~ /^(.*)\s(.*)$/;
    for (1..8) {
	my($search_date) = $j--.' '.Bivio::Type::DateTime::DEFAULT_TIME();

	$sth = Bivio::SQL::Connection->execute("
	        SELECT realm_instrument_t.realm_instrument_id,
                    instrument_valuation_t.closing_price
	        FROM realm_instrument_t, instrument_valuation_t
	        WHERE realm_instrument_t.instrument_id
            	    =instrument_valuation_t.instrument_id
                AND instrument_valuation_t.closing_date=$_SQL_DATE_VALUE
                AND realm_instrument_t.realm_id=?",
		[$search_date, $self->get('realm_id')]);

	my($found_quote) = 0;
	while (my $row = $sth->fetchrow_arrayref) {
	    my($id, $value) = @$row;

	    unless (exists($result->{$id})) {
		$result->{$id} = [$value, $search_date, 0];
	    }
	    $found_quote = 1;
	}
	last if $found_quote;
    }

    # make sure that valuations exists for every realm instrument
    # if not, then get the latest value from the local or global
    # quote tables, depending on whether the instrument is local

    $sth = Bivio::SQL::Connection->execute('
            SELECT realm_instrument_t.realm_instrument_id,
                realm_instrument_t.instrument_id
            FROM realm_instrument_t
            WHERE realm_instrument_t.realm_id=?',
	    [$self->get('realm_id')]);

    while (my $row = $sth->fetchrow_arrayref) {
	my($id, $inst_id) = @$row;

	next if exists($result->{$id});

	if (defined($inst_id)) {
	    # find the max global date
	    my($d) = Bivio::Type::DateTime->from_sql_value(
		    'instrument_valuation_t.closing_date');
	    my($sth2) = Bivio::SQL::Connection->execute("
                    SELECT instrument_valuation_t.closing_price,
                    $d
                    FROM instrument_valuation_t
                    WHERE instrument_valuation_t.instrument_id=?
                    AND instrument_valuation_t.closing_date=(
                        SELECT MAX(instrument_valuation_t.closing_date)
                        FROM instrument_valuation_t
                        WHERE instrument_valuation_t.instrument_id=?
                        AND instrument_valuation_t.closing_date
                            <= $_SQL_DATE_VALUE)",
		    [$inst_id, $inst_id, $date]);
	    my($row2);
	    while (my $row2 = $sth2->fetchrow_arrayref) {
		my($value, $val_date) = @$row2;
		$result->{$id} = [$value, $val_date, 0];
	    }
	    next if exists($result->{$id});
	}

	# find the max local date
	my($d) = Bivio::Type::DateTime->from_sql_value(
		'realm_instrument_valuation_t.date_time');
	my($sth2) = Bivio::SQL::Connection->execute("
                SELECT realm_instrument_valuation_t.price_per_share,
                $d
                FROM realm_instrument_valuation_t
                WHERE realm_instrument_valuation_t.realm_instrument_id=?
                AND realm_instrument_valuation_t.date_time=(
                    SELECT MAX(realm_instrument_valuation_t.date_time)
                    FROM realm_instrument_valuation_t
                    WHERE realm_instrument_valuation_t.realm_instrument_id=?
                    AND realm_instrument_valuation_t.date_time
                        <= $_SQL_DATE_VALUE)",
		[$id, $id, $date]);
	my($row2);
	while (my $row2 = $sth2->fetchrow_arrayref) {
	    my($value, $val_date) = @$row2;
	    $result->{$id} = [$value, $val_date, 1];
	}
    }

    $fields->{'get_share_price_and_date'.$date} = $result;
    return $result;
}

=for html <a name="has_valid_password"></a>

=head2 has_valid_password() : boolean

Returns true if self's password is valid.

=cut

sub has_valid_password {
    my($self) = @_;
    return Bivio::Type::Password->is_valid($self->get('password'));
}

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : hash_ref

B<FOR INTERNAL USE ONLY>

=cut

sub internal_initialize {
    return {
	version => 1,
	table_name => 'realm_owner_t',
	columns => {
            realm_id => ['PrimaryId', 'PRIMARY_KEY'],
            name => ['RealmName', 'NOT_NULL_UNIQUE'],
            password => ['Password', 'NOT_NULL'],
            realm_type => ['Bivio::Auth::RealmType', 'NOT_NULL'],
	    display_name => ['Line', 'NOT_NULL'],
	    creation_date_time => ['DateTime', 'NOT_NULL'],
        },
	auth_id => 'realm_id',
	other => [
	    [qw(realm_id Club.club_id User.user_id)],
	],
    };
}

=for html <a name="invalidate_password"></a>

=head2 invalidate_password()

Invalidates I<self>'s password. Deletes any outstanding password requests.

=cut

sub invalidate_password {
    my($self) = @_;
    $self->update({password => Bivio::Type::Password->INVALID});
    Bivio::Biz::Model->get_instance('PasswordRequest')->delete({});
    return;
}

=for html <a name="is_default"></a>

=head2 is_default() : boolean

Returns true if the realm is one of the default realms (general,
user, club).

=cut

sub is_default {
    my($self) = @_;
    # Default realms have ids same as their types as_int.
    return $self->get('realm_type')->as_int eq $self->get('realm_id') ? 1 : 0;
}

=for html <a name="is_demo_club"></a>

=head2 is_demo_club() : boolean

=head2 static is_demo_club(string name) : boolean

=head2 static is_demo_club(Bivio::Biz::ListModel list_model, string model_prefix) : boolean

Returns true if demo_club.  Gets I<name> from I<self> if not provided.

=cut

sub is_demo_club {
    my($self, $list_model, $model_prefix) = @_;
    my($name) = defined($model_prefix)
	    ? $list_model->get($model_prefix.'name')
		    : defined($list_model)
			    ? $list_model : $self->get('name');
    return $name =~ /$_DEMO_SUFFIX$/o ? 1 : 0;
}

=for html <a name="is_name_eq_email"></a>

=head2 static is_name_eq_email(Bivio::Agent::Request req, string name, string email) : boolean

If I<name> points to I<email>, returns true.  Caller should
put error C<EMAIL_LOOP> on the email.  If I<name> or I<email>
C<undef>, returns false.

=cut

sub is_name_eq_email {
    my(undef, $req, $name, $email) = @_;
    return 0 unless defined($name) && defined($email);
    $_MAIL_HOST = $req->get('mail_host') unless $_MAIL_HOST;
#TODO: ANY OTHER mail_host aliases?
    return $email eq $name.'@'.$_MAIL_HOST
	    || $email eq $name.'@www.'.$_MAIL_HOST;
}

=for html <a name="is_shadow_user"></a>

=head2 is_shadow_user() : boolean

=head2 static is_shadow_user(Bivio::Biz::ListModel list_model, string model_prefix) : boolean

Returns true if is a shadow realm.

See L<format_name|"format_name"> for params.

=cut

sub is_shadow_user {
    my($self, $list_model, $model_prefix) = @_;
    my($p) = $model_prefix || '';
    my($m) = $list_model || $self;
    my($name) = $m->get($p.'name');
    return $name =~ /^$_SHADOW_PREFIX/o ? 1 : 0;
}

=for html <a name="is_super_user"></a>

=head2 is_super_user() : boolean

Returns true if I<self> is a super user.

=cut

sub is_super_user {
    my($self) = @_;
#TODO: Need to encapsulate GENERAL->as_int.  I guess it is good enough here.
    # If it loads, then the user is certainly special
    return Bivio::Biz::Model->new($self->get_request, 'RealmUser')
	    ->unauth_load(
		    realm_id => Bivio::Auth::RealmType::GENERAL->as_int,
		    user_id => $self->get('realm_id'));
}

=for html <a name="unauth_load_by_email"></a>

=head2 unauth_load_by_email(string email) : boolean

=head2 unauth_load_by_email(string email, hash query) : boolean

Tries to load this realm using I<email> and any other I<query> parameters,
e.g. (realm_type, Bivio::Auth::RealmType::USER()).

I<email> is interpreted as follows:

=over 4

=item *

An C<Bivio::Biz::Model::Email> is loaded with I<email>.  If found,
loads the I<realm_id> of the model.

=item *

Parsed for the I<mail_host> associated with this request.
If it matches, the mailhost is stripped and the (syntactically
valid realm) name is used to find a realm owner.

=item *

Returns false.

=back

=cut

sub unauth_load_by_email {
    my($self, $email, @query) = @_;
    my($req) = $self->get_request;
    # Emails are always lower case
    $email = lc($email);

    # Load the email.  Return the result of the next unauth_load, just in case
    my($em) = Bivio::Biz::Model::Email->new($req);
    return $self->unauth_load(@query, realm_id => $em->get('realm_id'))
	    if $em->unauth_load(email => $email);

    # Strip off @mail_host and validate resulting name
    my($mh) = '@'.$req->get('mail_host');
    return 0 unless $email =~ s/\Q$mh\E$//i;
    my($name) = Bivio::Type::RealmName->from_literal($email);
    return 0 unless defined($name);

    # Is it a valid user/club?
    return $self->unauth_load(@query, name => $name);
}

=for html <a name="unauth_load_by_email_id_or_name"></a>

=head2 unauth_load_by_email_id_or_name(string email_id_or_name) : boolean

If email_id_or_name has an '@', will try to unauth_load_by_email.
Otherwise, tries to load by id or name.

=cut

sub unauth_load_by_email_id_or_name {
    my($self, $email_id_or_name) = @_;
    return $self->unauth_load_by_email($email_id_or_name)
	    if $email_id_or_name =~ /@/;
    return $self->unauth_load(realm_id => $email_id_or_name)
	    if $email_id_or_name =~ /^\d+$/;
    return $self->unauth_load(name => lc($email_id_or_name));
}

=for html <a name="unauth_load_by_id_or_name_or_die"></a>

=head2 unauth_load_by_id_or_name_or_die(string id_or_name) : Bivio::Biz::Model::RealmOwner

=head2 unauth_load_by_id_or_name_or_die(string id_or_name, any realm_type) : Bivio::Biz::Model::RealmOwner

Loads I<id_or_name> or dies with NOT_FOUND.  If I<realm_type> is specified, further qualifies the query.

=cut

sub unauth_load_by_id_or_name_or_die {
    my($self, $id_or_name, $realm_type) = @_;
    return $self->unauth_load_or_die(
	    ($id_or_name =~ /^\d+$/ ? 'realm_id' : 'name') => lc($id_or_name),
	    $realm_type
	    ? (realm_type => Bivio::Auth::RealmType->from_any($realm_type))
	    : ());
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
