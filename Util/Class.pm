# Copyright (c) 2006 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Util::Class;
use strict;
use base 'Bivio::ShellUtil';
use Bivio::UI::Facade;
use Bivio::Agent::TaskId;

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_IDI) = __PACKAGE__->instance_data_index;

sub USAGE {
    return <<'EOF';
usage: b-class [options] command [args..]
commands
  qualified_name class -- return fully qualified name for class
  super package -- return the list of superclasses for given package
  tasks_for_label text -- find TaskIds from text in Facade.Text map
  tasks_for_view view -- find TaskIds from view name (View.<view name>)
EOF
}

sub internal_initialize_index {
    my($self) = @_;
    #TODO: BAD PROGRAMMER!  TaskId docs say only Tasks can call get_cfg_list
    my @tasks = @{Bivio::Agent::TaskId->get_cfg_list};
    my($fields) = $self->[$_IDI] ||= {
	view => {},
	task => {},
    };
    foreach my $task (@tasks) {
	$fields->{task}->{$task->[0]} = $task;
	my($view) = grep(/^View\./, @$task)
	    or next;
	$view =~ s/^View\.//;
	push(@{($fields->{view}->{$view} ||= [])}, $task);
    }
    return;
}

sub qualified_name {
    my($self, $name) = @_;
    return $self->use($name);
}

sub super {
    my($self, $package) = @_;
    return $self->use($package)->inheritance_ancestors;
}

sub tasks_for_label {
    my($self, $text) = @_;
    my($req) = $self->get_request;
    $req->initialize_fully;
    $self->internal_initialize_index;
    my($fields) = $self->[$_IDI];
    #TODO: BAD PROGRAMMER!  No hacking the internal data structures!
    #  does this use case justify exposing a reverse lookup on Facade?
    my($task_text) = $req->get_nested(qw(Bivio::UI::Facade Text))
	->[1]->{map};
    return [map($fields->{task}->{$_},
		map(@{$task_text->{$_}->{names}},
		grep({
		    defined($task_text->{$_})
			&& lc($task_text->{$_}->{value}) eq lc($text)
		} keys(%$task_text))))];
}

sub tasks_for_view {
    my($self, $view) = @_;
    $self->internal_initialize_index;
    my($fields) = $self->[$_IDI];
#    return [keys(%{$fields->{view}})];
    return $fields->{view}->{$view};
}

1;
