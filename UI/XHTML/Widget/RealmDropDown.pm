# Copyright (c) 2007-2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::XHTML::Widget::RealmDropDown;
use strict;
use Bivio::Base 'Widget.If';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_RT) = b_use('Auth.RealmType');

sub NEW_ARGS {
    return shift->can('DEFAULT_REALM_TYPE') ? [] : [qw(realm_type)];
}

sub initialize {
    my($self) = @_;
    $self->put(
	realm_type => my $rt = $_RT->from_any(
	    $self->get_or_default(
		'realm_type', sub {$self->DEFAULT_REALM_TYPE}),
	),
    );
    $self->put_unless_exists(
	control => [sub {@{$self->internal_choices(shift)} != 0}],
	control_on_value => If(
	    [sub {_one_choice($self, shift)}],
	    SPAN(_curr_realm(), {class => 'dd_link'}),
	    DIV_task_menu_wrapper(
		DropDown(
		    If([[qw(->req auth_realm type)], '->equals', $rt],
		       _curr_realm(),
		       Prose(vs_text('RealmDropDown', $rt->get_name)),
		    ),
		    DIV_dd_menu(
			[sub {
			     my($source) = @_;
			     my($realms) = $self->internal_choices($source);
			     my($r) = $source->req('auth_realm');
			     $r = $r->get('type')->equals($rt)
				 ? $r->get('owner_name')
				 : '';
			     return Join([
				 map(
				     Link(String(_value($_, 'display_name')) => URI({
					 realm => _value($_, 'name'),
					 task_id => _value($_, 'task_id')
					     || $self->render_simple_attr(
						 task_id => $source,
					     ) || ($rt->get_name . '_HOME'),
					 query => undef,
					 path_info => undef,
				     })),
				     grep(_eq($_, $r), @$realms),
				     grep(!_eq($_, $r), @$realms),
				 ),
			     ]);
			}],
			{
			    id => lc($rt->get_name) . '_drop_down',
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
	{'RealmOwner.realm_type' => $self->get('realm_type')},
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
    return $source->req(qw(auth_realm type))->equals($self->get('realm_type'))
	&& @$choices == 1
	&& $choices->[0] eq $source->req(qw(auth_realm owner_name));
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
