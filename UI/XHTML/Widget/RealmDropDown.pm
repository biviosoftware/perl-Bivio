# Copyright (c) 2007-2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::XHTML::Widget::RealmDropDown;
use strict;
use Bivio::Base 'Widget.If';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_RT) = b_use('Auth.RealmType');

sub NEW_ARGS {
    return shift->can('DEFAULT_REALM_TYPES') ? [] : [qw(realm_types)];
}

sub initialize {
    my($self) = @_;
    b_die('pass realm_types instead of realm_type')
        if $self->unsafe_get('realm_type');
    my($rt) = _realm_types($self);
    my($first_rt) = $rt->[0];
    $self->put_unless_exists(
	control => [sub {@{$self->internal_choices(shift)} != 0}],
	control_on_value => If(
	    [sub {_one_choice($self, shift)}],
	    SPAN(_curr_realm(), {class => 'dd_link'}),
	    DIV_task_menu_wrapper(
		DropDown(
		    If([[qw(->req auth_realm type)], '->equals_by_name', @$rt],
		       _curr_realm(),
		       Prose(vs_text('RealmDropDown', $first_rt)),
		    ),
		    DIV_dd_menu(
			[sub {
			     my($source) = @_;
			     my($realms) = $self->internal_choices($source);
			     my($r) = $source->req('auth_realm');
			     $r = $r->get('type')->equals_by_name(@$rt)
				 ? $r->get('owner_name')
				 : '';
			     return Join([
				 map(
				     Link(String(_value($_, 'display_name')) => URI({
					 realm => _value($_, 'name'),
					 task_id => _value($_, 'task_id')
					     || $self->render_simple_attr(
						 task_id => $source,
					     ) || ($first_rt . '_HOME'),
					 query => undef,
					 path_info => undef,
				     })),
				     grep(_eq($_, $r), @$realms),
				     grep(!_eq($_, $r), @$realms),
				 ),
			     ]);
			}],
			{
			    id => lc($first_rt) . '_drop_down',
			},
		    ),
		),
	    ),
	),
    );
    return shift->SUPER::initialize(@_);
}

sub internal_choices {
    my($self, $source) = @_;
    return $source->req->map_user_realms(
	sub {shift->{'RealmOwner.name'}},
	{'RealmOwner.realm_type' => [
            map($_RT->from_any($_), @{_realm_types($self)}),
        ]},
    );
}

sub _curr_realm {
    return String([qw(->req auth_realm owner_name)]);
}

sub _eq {
    my($choice, $name) = @_;
    return (_value($choice, 'name') || '') eq $name;
}

sub _one_choice {
    my($self, $source) = @_;
    my($choices) = $self->internal_choices($source);
    my($ar) = $source->req('auth_realm');
    return @$choices == 1
        && $ar->has_owner
	&& _value($choices->[0], 'name') eq $ar->get('owner_name');
}

sub _realm_types {
    my($self) = @_;
    my($v) = $self->get_or_default(
        'realm_types', sub {$self->DEFAULT_REALM_TYPES});
    $v = [map($_RT->from_any($_)->get_name, ref($v) ? @$v : $v)];
    $self->put(realm_types => $v);
    return $v;
}

sub _value {
    my($choice, $which) = @_;
    return $choice->{$which}
	if ref($choice);
    return $choice
	if $which =~ /name/;
    return undef;
}

1;
