# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Agent::Tasks;
use strict;
$Bivio::Agent::Tasks::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Agent::Tasks - initializes all tasks

=head1 SYNOPSIS

    use Bivio::Agent::Tasks;
    Bivio::Agent::Tasks->initialize();

=cut

use Bivio::UNIVERSAL;
@Bivio::Agent::Tasks::ISA = qw(Bivio::UNIVERSAL);

=head1 DESCRIPTION

C<Bivio::Agent::Tasks> all initializes tasks.

This is a separate module from L<Bivio::Agent::TaskId|Bivio::Agent::TaskId> to
allow TaskId not to depend on other classes, i.e. can be standalone
enumeration.  Configuration resides in TaskId to avoid duplication.

=cut

#=IMPORTS
use Bivio::Agent::Task;
use Bivio::Agent::TaskId;
use Bivio::Agent::Views;
use Bivio::Util;

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="initialize"></a>

=head2 initialize()

Initializes task list from the configuration in
L<Bivio::Agent::TaskId|Bivio::Agent::TaskId>.

=cut

sub initialize {
    my($cfg) = Bivio::Agent::TaskId->get_cfg_list;
    map {
	my($id_name, $action_class, $view_class) = @{$_}[0,5,6];
	if ($action_class) {
	    $action_class = 'Bivio::Biz::Action::' . $action_class;
	    Bivio::Util::my_require($action_class);
	}
	Bivio::Agent::Task->new(
		Bivio::Agent::TaskId->$id_name(),
		$action_class,
		$view_class
		   && Bivio::Agent::Views->get('Bivio::UI::' . $view_class));
    } @$cfg;
    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
