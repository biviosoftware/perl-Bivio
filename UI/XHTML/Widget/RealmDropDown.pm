# Copyright (c) 2007-2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::XHTML::Widget::RealmDropDown;
use strict;
use Bivio::Base 'Widget.If';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_RT) = b_use('Auth.RealmType');

sub NEW_ARGS {
    return [qw(realm_type)];
}

sub initialize {
    my($self) = @_;
    $self->put(
	realm_type => my $rt = $_RT->from_any($self->get('realm_type')));
    $self->put_unless_exists(
	control => [sub {@{$self->internal_choices(shift)} != 0}],
	control_on_value => If(
	    [sub {_one_choice($self, shift)}],
	    SPAN(_curr_realm(), {class => 'dd_link'}),
	    DropDown(
		If([[qw(->req auth_realm type)], '->equals', $rt],
		   _curr_realm(),
		   String(vs_text('RealmDropDown', $rt->get_name)),
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
				 Link(String($_) => URI({
				     realm => $_,
				     task_id => $self->render_simple_attr(
					 task_id => $source,
				     ) || ($rt->get_name . '_HOME'),
				     query => undef,
				     path_info => undef,
				 })),
				 grep($_ eq $r, @$realms),
				 grep($_ ne $r, @$realms),
			     ),
			 ]);
		    }],
		    {
			id => lc($rt->get_name) . '_drop_down',
		    },
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

sub _one_choice {
    my($self, $source) = @_;
    return $source->req(qw(auth_realm type))->equals($self->get('realm_type'))
	&& @{$self->internal_choices($source)} == 1;
}

1;
