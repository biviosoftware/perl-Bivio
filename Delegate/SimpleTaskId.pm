# Copyright (c) 2001 bivio Inc.  All rights reserved.
# $Id$
package Bivio::Delegate::SimpleTaskId;
use strict;
$Bivio::Delegate::SimpleTaskId::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Delegate::SimpleTaskId::VERSION;

=head1 NAME

Bivio::Delegate::SimpleTaskId - default required tasks

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::Delegate::SimpleTaskId;

=cut

use Bivio::Delegate;
@Bivio::Delegate::SimpleTaskId::ISA = ('Bivio::Delegate');

=head1 DESCRIPTION

C<Bivio::Delegate::SimpleTaskId> defines the standard tasks typically used by a
site.  If you subclass this class, you need to define you tasks with numbers
500 and above.

If you want to replace a task here, use the same name and number, so that
L<merge_task_info|"merge_task_info"> doesn't tried to create two tasks with the
same name.

=cut

#=IMPORTS

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="get_delegate_info"></a>

=head2 static get_delegate_info() : array_ref

Returns the task declarations which are needed for the
simplest site.

=cut

sub get_delegate_info {
    return [
	# used by UI::Task
	[qw(
	    SHELL_UTIL
	    1
	    GENERAL
	    ANYBODY
	    Action.ClientRedirect->execute_next
	    next=SITE_ROOT
            cancel=SITE_ROOT
	)],
	[qw(
	    SITE_ROOT
	    2
	    GENERAL
	    ANYBODY
	    Action.ClientRedirect->execute_home_page_if_site_root
	    Bivio::UI::View->execute_uri
	)],
	[qw(
	    LOCAL_FILE_PLAIN
	    3
	    GENERAL
	    ANYBODY
	    Action.LocalFilePlain
	    want_query=0
	)],
	# used by UI::Task
	[qw(
	    MY_SITE
	    4
	    GENERAL
	    ANY_USER
	    Action.ClientRedirect->execute_next
	    next=SITE_ROOT
	)],
	# used by Model::RealmOwner
	[qw(
	    USER_HOME
	    5
	    USER
	    DATA_READ
	    Action.ClientRedirect->execute_next
	    next=SITE_ROOT
	)],
	# used by UI::Task
	[qw(
	    MY_CLUB_SITE
	    6
	    GENERAL
	    ANY_USER
	    Action.ClientRedirect->execute_next
	    next=SITE_ROOT
	)],
	# used by Model.RealmOwner
	[qw(
	    CLUB_HOME
	    7
	    CLUB
	    DATA_READ
	    Action.ClientRedirect->execute_next
	    next=SITE_ROOT
	)],
	# Redirects to a uri supplied in the query
	[qw(
	    CLIENT_REDIRECT
	    8
	    GENERAL
	    ANYBODY
	    Action.ClientRedirect->execute_query
	    next=SITE_ROOT
	)],
	# Help pages
	[qw(
	    HELP
	    9
	    GENERAL
	    ANYBODY
	    Action.LocalFilePlain
	)],
	# Handy for demos and such.  You need to provide a link in the
	# "plain" space to the view source, e.g.
	#    cd plain; ln -s ../view vs
	[qw(
	    VIEW_AS_PLAIN_TEXT
	    10
	    GENERAL
	    ANYBODY
	    Action.ViewAsPlainText
	)],
	[qw(
	    ADM_SUBSTITUTE_USER
	    11
	    GENERAL
	    ADMIN_READ&ADMIN_WRITE
	    Model.AdmSubstituteUserForm
            View.adm-substitute-user
	    next=MY_SITE
	)],
	# To make this visible, add this to Task section of your facade:
	#   $t->group(FAVICON_ICO => '/favicon.ico');
        # and in the Text section:
	#   $t->group(favicon_uri => '/i/favicon.ico');
	[qw(
            FAVICON_ICO
            12
            GENERAL
            ANYBODY
            Action.LocalFilePlain->execute_favicon
        )],
	[qw(
            DEFAULT_ERROR_REDIRECT_FORBIDDEN
            13
            GENERAL
            ANYBODY
            Model.ForbiddenForm
            next=FORBIDDEN
	    login_task=LOGIN
        )],
        [qw(
            FORBIDDEN
            14
            GENERAL
            ANYBODY
            Action.Forbidden
        )],
        # Add this to the Task section of your facade:
        #   $t->group(ROBOTS_TXT => 'robots.txt');
	[qw(
            ROBOTS_TXT
            15
            GENERAL
            ANYBODY
            Action.LocalFilePlain->execute_robots_txt
        )],
	[qw(
	    TEST_BACKDOOR
	    16
	    GENERAL
	    TEST_TRANSIENT
	    Action.TestBackdoor
	    Action.MailReceiveStatus
	)],
	# used by Model.RealmOwner
	[qw(
	    FORUM_HOME
	    17
	    FORUM
	    DATA_READ
	    Action.ClientRedirect->execute_next
	    next=SITE_ROOT
	)],
	[qw(
	    GENERAL_USER_PASSWORD_QUERY
	    18
	    GENERAL
	    ANYBODY
	    Model.UserPasswordQueryForm
	    View.user-password-query
	    reset_task=USER_PASSWORD_RESET
	    next=GENERAL_USER_PASSWORD_QUERY_MAIL
	    cancel=SITE_ROOT
	)],
	[qw(
	    GENERAL_USER_PASSWORD_QUERY_MAIL
	    19
	    GENERAL
	    ANYBODY
	    View.user-password-query-mail
	    Action.ServerRedirect->execute_next
	    next=GENERAL_USER_PASSWORD_QUERY_ACK
	)],
	[qw(
	    USER_PASSWORD_RESET
	    20
	    USER
	    ANYBODY
	    Action.UserPasswordQuery
	    password_task=USER_PASSWORD
	    NOT_FOUND=GENERAL_USER_PASSWORD_QUERY
	)],
        # forbidden errors are probably due to missing cookies.
        # for example, if user is resetting password from email link
        #   with cookies disabled
	[qw(
	    USER_PASSWORD
	    21
	    USER
	    ADMIN_READ&ADMIN_WRITE
	    Model.UserPasswordForm
	    View.user-password
	    next=MY_SITE
            FORBIDDEN=DEFAULT_ERROR_REDIRECT_MISSING_COOKIES
	)],
	[qw(
	    GENERAL_USER_PASSWORD_QUERY_ACK
	    22
	    GENERAL
	    ANYBODY
	    View.user-password-query-ack
	)],
	[qw(
            DEFAULT_ERROR_REDIRECT_MISSING_COOKIES
	    23
	    GENERAL
	    ANYBODY
	    View.missing-cookies
	)],
    ];
}

=for html <a name="merge_task_info"></a>

=head2 static merge_task_info(array_ref default, array_ref source) : array_ref

Merges the two task definitions into source, overwriting defaults with
source entries.

=cut

sub merge_task_info {
    my($proto, $default, $source) = @_;

    my($ids) = {};
    foreach my $task (@$source) {
	$ids->{$task->[1]} = 1;
    }
    foreach my $task (@$default) {
	next if $ids->{$task->[1]};
	push(@$source, $task);
    }
    return $source;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2001 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
