# Copyright (c) 2001-2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::HTML::Widget::TaskInfo;
use strict;
use Bivio::Base 'UI.Widget';
use Bivio::UI::ViewLanguageAUTOLOAD;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_SC);

sub render {
    my($self, $source, $buffer) = @_;
    my($req) = $source->get_request;
    my($task) = $req->get('task');
    $$buffer .= <<"EOF"
<pre>
<b>Control Logic for This Page</b>
(click on link to see the source code)
Name:         @{[$task->get('id')->get_name]}
Realm:        @{[$task->get('realm_type')->get_name]}
Permissions:  @{[join('&',
    map($_->get_name, @{Bivio::Auth::PermissionSet->to_array(
        $task->get('permission_set'))}))]}
EOF
        . join("\n",
	    map({
		my($object, $method, $args) = @$_;
		$object = ref($object)
		    if ref($object);
    #TODO: Does not handle inline subs
		my($b) = '';
		($_SC ||= SourceCode({})->package_name)->render_source_link(
		    $req,
		    $object->isa('Bivio::UI::View::LocalFile')
			? 'View.' . $args->[0]
			: $object,
		    $object . '->'
			. $method
			. (@$args ? '(' . join(', ', @$args) . ')' : ''),
		    \$b,
		);
		$b;
	    } @{$task->get('items')}),
	    "</pre>\n",
	 );
#TODO: render attributes
    return;
}

1;
