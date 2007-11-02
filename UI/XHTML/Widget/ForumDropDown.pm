# Copyright (c) 2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::XHTML::Widget::ForumDropDown;
use strict;
use Bivio::Base 'Widget.If';
use Bivio::UI::ViewLanguageAUTOLOAD;
my($_RT) = __PACKAGE__->use('Auth.RealmType');

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub initialize {
    my($self) = @_;
    $self->put(
	control => [sub {@{_forums(shift)} != 0}],
	control_on_value => If(
	    [\&_one_forum],
	    SPAN(_curr_realm(), {class => 'dd_link'}),
	    DropDown(
		If([[qw(->req auth_realm type)], '->eq_forum'],
		   _curr_realm(),
		   'Forums',
	        ),
		DIV_dd_menu(
		    [sub {
			 my($source) = @_;
			 my($forums) = _forums($source);
			 my($r) = $source->req('auth_realm');
			 $r = $r->get('type')->eq_forum ? $r->get('owner_name')
			     : '';
			 return Join([
			     map(
				 Link(String($_) => URI({
				     realm => $_,
				     task_id => 'FORUM_HOME',
				     query => undef,
				 })),
				 grep($_ eq $r, @$forums),
				 grep($_ ne $r, @$forums),
			     ),
			 ]);
		    }],
		    {
			id => 'forum_drop_down',
		    },
		),
	    ),
	),
    );
    return shift->SUPER::initialize(@_);
}

sub internal_new_args {
    my(undef, $attributes) = @_;
    return {
	($attributes ? %$attributes : ()),
    };
}

sub _forums {
    return shift->req->map_user_realms(
	sub {shift->{'RealmOwner.name'}},
	{'RealmOwner.realm_type' => $_RT->FORUM},
    );
}

sub _one_forum {
    my($source) = @_;
    return $source->req(qw(auth_realm type))->eq_forum
	&& @{_forums($source)} == 1;
}

sub _curr_realm {
    return String([qw(->req auth_realm owner_name)]);
}

1;
