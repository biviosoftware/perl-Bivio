# Copyright (c) 2001 bivio Inc.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Widget::TaskInfo;
use strict;
$Bivio::UI::HTML::Widget::TaskInfo::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::UI::HTML::Widget::TaskInfo::VERSION;

=head1 NAME

Bivio::UI::HTML::Widget::TaskInfo - displays the current task information

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::UI::HTML::Widget::TaskInfo;

=cut

=head1 EXTENDS

L<Bivio::UI::Widget>

=cut

use Bivio::UI::Widget;
@Bivio::UI::HTML::Widget::TaskInfo::ISA = ('Bivio::UI::Widget');

=head1 DESCRIPTION

C<Bivio::UI::HTML::Widget::TaskInfo>

=cut

#=IMPORTS
use Bivio::Agent::TaskId;
use Bivio::Die;
use Bivio::UI::HTML::Widget::SourceCode;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(hash_ref attributes) : Bivio::UI::HTML::Widget::TaskInfo

Creates a new TaskInfo widget.

=cut

sub new {
    my($self) = Bivio::UI::Widget::new(@_);
    $self->{$_PACKAGE} = {};
    return $self;
}

=head1 METHODS

=cut

=for html <a name="initialize"></a>

=head2 initialize()

Initializes from configuration attributes.

=cut

sub initialize {
    my($self) = @_;
    return;
}

=for html <a name="render"></a>

=head2 render(any source, string_ref buffer)

Render the source code using perl2html, then adding links.

=cut

sub render {
    my($self, $source, $buffer) = @_;
    my($req) = $source->get_request;

    my($info) = _get_task_info($req->get('task_id')->get_name);
    my($name, $realm, $perm) = (@$info)[0, 2, 3];

    $$buffer .= <<"EOF";
<pre>
<b><font size="+1">Control Logic for This Page</font></b>
<font size="-1">(click on link to see the source code)</font>
Name:         $name
Realm:        $realm
Permissions:  $perm
EOF

    foreach my $item ((@$info)[4..int(@$info) - 1]) {
	my($name, $module, $method) = _get_item_parts($item);

	if (Bivio::UI::HTML::Widget::SourceCode->is_source_module($module)) {
	    Bivio::UI::HTML::Widget::SourceCode->render_source_link(
		    $req, $module, $name, $buffer);
	    $$buffer .= $method."\n";
	}
	elsif ($name =~ /^View\./) {
	    Bivio::UI::HTML::Widget::SourceCode->render_source_link(
		    $req, $name, $name, $buffer);
	    $$buffer .= "\n";
	}
	else {
	    $$buffer .= "$name\n";
	}
    }
    $$buffer .= "</pre>\n";
    return;
}

#=PRIVATE METHODS

# _get_item_parts(string item) : (string, string, string)
#
# Returns the (name, module, method) components of a task item.
# The module and method parts may be ''.
#
sub _get_item_parts {
    my($item) = @_;

    my($method) = '';
    if ($item !~ /^View\./ && $item =~ s/(-.*)$//) {
	$method = $1;
    }
    my($name) = $item;
    my($module) = $item;

    if ($module =~ s/^Model\.//) {
	$module = ref(Bivio::Biz::Model->get_instance($module));
    }
    return ($name, $module, $method);
}

# _get_task_info(string name) : array_ref
#
# Returns the raw array of task information.
#
sub _get_task_info {
    my($name) = @_;

    my($list) = Bivio::Agent::TaskId->get_cfg_list;
    foreach my $task (@$list) {
	return $task if $task->[0] eq $name;
    }
    Bivio::Die->die('task not found: ', $name);
}

=head1 COPYRIGHT

Copyright (c) 2001 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
