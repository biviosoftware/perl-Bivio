# Copyright (c) 2005 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::CalendarEvent;
use strict;
use base 'Bivio::Biz::PropertyModel';
use Bivio::MIME::Calendar;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_DT) = Bivio::Type->get_instance('DateTime');
my($_UID) = 'bce';
my($_RO) = Bivio::Biz::Model->get_instance('RealmOwner');

#TODO: Refactor to merge dupe code in class
sub create_realm {
    my($self, $calendar_event, $realm_owner) = @_;
    $self->create({
        modified_date_time => $_DT->now,
        %$calendar_event,
        realm_id => $self->get_request->get('auth_id'),
    });
    my($ro) = $self->new_other('RealmOwner')->create({
	name => $self->id_to_uid,
	%$realm_owner,
	realm_type => Bivio::Auth::RealmType->CALENDAR_EVENT,
	realm_id => $self->get('calendar_event_id'),
#	%$rv,
    });
    $self->new_other('RealmUserAddForm')
	->copy_admins($self->get('calendar_event_id'));
    return ($self, $ro);
}

sub create_from_vevent {
    my($self, $vevent) = @_;
    my($sv, $rv) = _from_vevent($self, $vevent);
    my($req) = $self->get_request;
    $self->new_other('RealmOwner')->create({
	realm_type => Bivio::Auth::RealmType->CALENDAR_EVENT,
	realm_id => $self->create({
	    modified_date_time => $_DT->now,
	    %$sv,
	    realm_id => $req->get('auth_id'),
	})->get('calendar_event_id'),
	%$rv,
	name => $self->id_to_uid,
    });
    $self->new_other('RealmUserAddForm')
	->copy_admins($self->get('calendar_event_id'));
#TODO: update perms based on class
    return $self;
}

# Move to RealmBase
sub delete_all {
    my($self, $query) = @_;
    return shift->SUPER::delete_all(@_)
	if $query;
    my($i) = 0;
    foreach my $id (@{$self->map_iterate(
	sub {shift->get('calendar_event_id')},
	'calendar_event_id'
    )}) {
	$self->new->load({calendar_event_id => $id})->cascade_delete;
	$i++;
    }
    return $i;
}

sub id_to_uid {
    my($self, $id) = @_;
    return $_UID . ($id || $self->get('calendar_event_id'));
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
	table_name => 'calendar_event_t',
        columns => {
	    calendar_event_id => ['RealmOwner.realm_id', 'PRIMARY_KEY'],
	    # Don't couple
            realm_id => ['PrimaryId', 'NOT_NULL'],
	    modified_date_time => ['DateTime', 'NOT_NULL'],
	    dtstart => ['DateTime', 'NOT_NULL'],
	    dtend => ['DateTime', 'NOT_NULL'],
	    time_zone => ['TimeZone', 'NONE'],
	    location => ['Text', 'NONE'],
	    description => ['LongText', 'NONE'],
	    url => ['HTTPURI', 'NONE'],
# 	    rrule_freq
# 		rrule_until
# 		rrule_count
# 	        rrule_interval
# 		rrule_bymonth
# 	    occurance, freq
	},
	auth_id => ['realm_id'],
	other => [
	    [qw(calendar_event_id RealmOwner.realm_id)],
	],
    });
}

sub update_from_vevent {
    my($self, $vevent) = @_;
    my($sv, $rv) = _from_vevent($self, $vevent);
    # Need to do this by hand, because we don't want to just set
    # modified_date_time without knowing if anything has changed
    my($ok) = 0;
    my($ro) = $self->get_model('RealmOwner');
    $ok = $ro->get('display_name') eq $rv->{display_name} ? 0
	: $ro->update($rv);
#TODO: update perms based on class
    return $ok || grep(
	!$self->get_field_type($_)->is_equal($sv->{$_}, $self->get($_)),
	keys(%$sv)
    ) ? $self->SUPER::update({modified_date_time => $_DT->now, %$sv}) : $self;
}

sub _from_vevent {
    my($self, $vevent) = @_;
    return ({
	_map_field($self, $vevent, [qw(dtstart dtend location url description)]),
    }, {
	_map_field($_RO, $vevent, [qw(summary:display_name)]),
    });
}

sub _map_field {
    my($m, $vevent, $fields) = @_;
    return map({
	my($from, $to) = split(/:/, $_);
	$to ||= $from;
	my($t) = $m->get_field_type($to);
	# Dates are converted "twice", but we that's ok, because date
	# internal format can be converted from literal
	my($v, $e) = $t->from_literal($vevent->{$from});
	if ($e) {
	    ($v, $e) = $t->from_literal(
		substr($vevent->{$from}, 0, $t->get_width)
	    ) if $t->isa('Bivio::Type::String');
	    Bivio::Die->die(
		$from, '=', $vevent->{$from}, ': ', $e, ' of ', $vevent
	    ) if $e;
	}
	($to => $v);
    } @$fields);
}

1;
