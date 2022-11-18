# Copyright (c) 2005-2013 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::CalendarEvent;
use strict;
use Bivio::Base 'Model.RealmOwnerBase';
b_use('IO.ClassLoaderAUTOLOAD');

my($_DT) = b_use('Type.DateTime');
my($_RO);
my($_MC) = b_use('MIME.Calendar');
my($_REALM_OWNER_NAME_PREFIX) = 'bce';

sub create {
    my($self, $values) = (shift, shift);
    $values->{modified_date_time} ||= $_DT->now;
    $values->{realm_id} ||= $self->req('auth_id');
    $values->{uid} ||= Mail_Outgoing()->generate_addr_spec($self->req);
    return $self->SUPER::create($values, @_);
}

sub create_from_vevent {
    my($self, $vevent) = @_;
    return ($self->create_realm(_from_vevent($self, $vevent)))[0];
}

sub create_realm {
    my($self, $calendar_event, $realm_owner) = (shift, shift, shift);
    my(@res) = $self->create($calendar_event)->SUPER::create_realm({
        name => $self->id_to_realm_owner_name,
        %$realm_owner,
    }, @_);
    return @res;
}

sub id_to_realm_owner_name {
    my($self, $id) = @_;
    return $_REALM_OWNER_NAME_PREFIX
        . ($id || $self->get('calendar_event_id'));
}

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
        version => 1,
        table_name => 'calendar_event_t',

        columns => {
            calendar_event_id => ['RealmOwner.realm_id', 'PRIMARY_KEY'],
            realm_id => ['RealmOwner.realm_id', 'NOT_NULL'],
            modified_date_time => ['DateTime', 'NOT_NULL'],
            dtstart => ['DateTime', 'NOT_NULL'],
            dtend => ['DateTime', 'NOT_NULL'],
            time_zone => ['TimeZone', 'NONE'],
            uid => ['String', 'NONE'],
            location => ['Text', 'NONE'],
            description => ['LongText', 'NONE'],
            url => ['HTTPURI', 'NONE'],
        },
        auth_id => ['realm_id'],
        other => [
            [qw(calendar_event_id RealmOwner.realm_id)],
        ],
    });
}

sub update_from_ics {
    my($self, $ics) = @_;
    my($old) = {map(
        ($_->{uid} => $_),
        @{$self->new_other('CalendarEventList')->map_iterate},
    )};
    my($ce) = $self->new;
    foreach my $v (@{$_MC->vevents_from_ics($ics)}) {
        if (my $x = delete($old->{$v->{uid}})) {
            $ce->load({calendar_event_id => $x->{'CalendarEvent.calendar_event_id'}})
                ->update_from_vevent($v);
        }
        else {
            $ce->create_from_vevent($v);
        }
    }
    foreach my $x (values(%$old)) {
        $ce->load({calendar_event_id => $x->{'CalendarEvent.calendar_event_id'}})
            ->cascade_delete;
    }
    return;
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
        _map_field($self, $vevent,
            [qw(dtstart dtend location url description time_zone uid)]),
    }, {
        _map_field(
            $_RO ||= b_use('Model.RealmOwner')->get_instance,
            $vevent,
            [qw(summary:display_name)],
        ),
    });
}

sub _map_field {
    my($m, $vevent, $fields) = @_;
    return map({
        my($from, $to) = split(/:/, $_);
        $to ||= $from;
        ($to => _value_for_type($m, $to, $vevent, $from));
    } @$fields);
}

sub _value_for_type {
    my($m, $field, $vevent, $from) = @_;
    return $vevent->{$from}
        if ref($vevent->{$from});
    my($t) = $m->get_field_type($field);
    # Dates are converted "twice", but we that's ok, because date
    # internal format can be converted from literal
    my($v, $e) = $t->from_literal($vevent->{$from});
    if ($e) {
        if ($t->isa('Bivio::Type::String')) {
            # need to canonicalize before trimmming due to expansion
            ($v, $e) = $t->from_literal(
                substr(${$t->canonicalize_charset($vevent->{$from})},
                       0, $t->get_width));
        }
         b_die(
            $from, '=', $vevent->{$from}, ': ', $e, ' of ', $vevent
        ) if $e;
    }
    return $v;
}

1;
