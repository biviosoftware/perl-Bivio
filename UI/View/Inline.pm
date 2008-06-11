# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::View::Inline;
use strict;
use Bivio::Base 'UI.View';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub absolute_path {
    return shift->get('view_code') . '';
}

sub compile {
    my($self) = @_;
    my($c) = $self->get('view_code');
    return ref($c) eq 'CODE' ? $c->() : $c;
}

sub render_code_as_string {
    my($proto, $code_ref, $req, $class_map, $shortcuts) = @_;
    $class_map ||= 'Widget';
    $shortcuts ||= b_use('UI.ViewShortcuts');
    # View calls us back, because we're passing in a code_ref
    return ${$proto->call_main(
	sub {
	    view_class_map($class_map);
	    view_shortcuts($shortcuts);
	    return view_main(Simple([sub {$code_ref->(@_)}]));
	},
	$req,
    )};
}

sub unsafe_new {
    my($proto, $name, $facade) = @_;
    return ref($name) eq 'SCALAR' ? $proto->new({
	view_code => $name,
	view_name => substr($$name, 0, 100),
    }) : ref($name) eq 'CODE' ? $proto->new({
	view_code => $name,
	view_name => $name . '',
    }) : undef;
}

1;
