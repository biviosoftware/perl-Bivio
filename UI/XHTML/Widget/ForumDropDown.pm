# Copyright (c) 2007-2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::XHTML::Widget::ForumDropDown;
use strict;
use Bivio::Base 'Widget.If';
use Bivio::UI::ViewLanguageAUTOLOAD;
my($_FORUM) = __PACKAGE__->use('Auth.RealmType')->FORUM;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub initialize {
    my($self) = @_;
    $self->put_unless_exists(
	control => [sub {@{$self->internal_choices(shift)} != 0}],
	control_on_value => If(
	    [sub {_one_choice($self, shift)}],
	    SPAN(_curr_realm(), {class => 'dd_link'}),
	    DropDown(
		If([[qw(->req auth_realm type)], '->eq_forum'],
		   _curr_realm(),
		   'Forums',
	        ),
		DIV_dd_menu(
		    [sub {
			 my($source) = @_;
			 my($forums) = $self->internal_choices($source);
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

sub internal_choices {
    my(undef, $source) = @_;
    return $source->req->map_user_realms(
	sub {shift->{'RealmOwner.name'}},
	{'RealmOwner.realm_type' => $_FORUM},
    );
}

sub internal_new_args {
    my(undef, $attributes) = @_;
    return {
	($attributes ? %$attributes : ()),
    };
}

sub _curr_realm {
    return String([qw(->req auth_realm owner_name)]);
}

sub _one_choice {
    my($self, $source) = @_;
    return $source->req(qw(auth_realm type))->eq_forum
	&& @{$self->internal_choices($source)} == 1;
}

1;
