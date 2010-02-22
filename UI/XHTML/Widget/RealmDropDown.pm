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
	control => [sub {$self->internal_control_value(@_)}],
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
			     my($realms) = _choices($self, $source);
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

sub internal_control_value {
    my($self, $source) = @_;
    return @{_choices($self, $source)} == 0 ? 0 : 1;
}

sub _choices {
    my($self, $source) = @_;
    return $source->req->cache_for_auth_user(
	[$self, @{_realm_types($self)}],
	sub {$self->internal_choices($source)},
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
    my($choices) = _choices($self, $source);
    my($ar) = $source->req('auth_realm');
    return @$choices == 1
        && $ar->has_owner
	&& _value($choices->[0], 'name') eq $ar->get('owner_name');
}

sub _realm_types {
    my($self) = @_;
    return $self->get_if_exists_else_put(_realm_types => sub {
	my($rt) = $self->unsafe_get('realm_types')
	    || $self->DEFAULT_REALM_TYPES;
        return [map(
	    $_RT->from_any($_)->get_name,
	    ref($rt) ? @$rt : $rt,
        )];
    });
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
