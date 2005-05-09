# Copyright (c) 2002 bivio Software Artisans, Inc.  All rights reserved.
# $Id$
package Bivio::Agent::t::Task::TaskId;
use strict;
$Bivio::Agent::t::Task::TaskId::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Agent::t::Task::TaskId::VERSION;

=head1 NAME

Bivio::Agent::t::Task::TaskId - test tasks

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::Agent::t::Task::TaskId;

=cut

use Bivio::Delegate::SimpleTaskId;
@Bivio::Agent::t::Task::TaskId::ISA = ('Bivio::Delegate::SimpleTaskId');

=head1 DESCRIPTION

C<Bivio::Agent::t::Task::TaskId> test tasks

=cut

#=IMPORTS

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="get_delegate_info"></a>

=head2 static get_delegate_info() : array_ref

Returns the task declarations.

=cut

sub get_delegate_info {
    my($proto) = @_;
    return $proto->merge_task_info($proto->SUPER::get_delegate_info, [
	[qw(
	    LOGIN
	    500
	    GENERAL
	    ANYBODY
            Action.ClientRedirect->execute_next
            next=SITE_ROOT
	)],
	[qw(
	    REDIRECT_TEST_1
	    501
	    GENERAL
	    ANYBODY
            Action.ClientRedirect->execute_next
            next=REDIRECT_TEST_2
	)],
	[qw(
	    REDIRECT_TEST_2
	    502
	    GENERAL
	    ANY_USER
            FORBIDDEN=SITE_ROOT
	)],
	[qw(
	    REDIRECT_TEST_3
	    503
	    GENERAL
	    ANYBODY
            t1_task=REDIRECT_TEST_1
            t2_task=REDIRECT_TEST_2
	),
	    sub {
		my($req) = @_;
		my($i) = $req->unsafe_get('redirect_test_3') || 0;
		$req->put_durable(redirect_test_3 => ++$i);
		return "t${i}_task";
	    },
	],
	[qw(
	    DEVIANCE_1
	    504
	    GENERAL
	    ANYBODY
	),
	    sub {
		return "no_such_task";
	    },
	],
	[qw(
	    TEST_TRANSIENT
	    505
	    GENERAL
	    TEST_TRANSIENT
            Action.ClientRedirect->execute_next
            next=SITE_ROOT
	)],
    ]);
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2002 bivio Software Artisans, Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
