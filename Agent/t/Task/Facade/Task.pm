# Copyright (c) 2000 bivio Software Artisans, Inc.  All rights reserved.
# $Id$
package Bivio::Agent::t::Task::Facade::Task;
use strict;
$Bivio::Agent::t::Task::Facade::Task::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Agent::t::Task::Facade::Task::VERSION;

=head1 NAME

Bivio::Agent::t::Task::Facade::Task - facade for Task.t

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::Agent::t::Task::Facade::Task;

=cut

=head1 EXTENDS

L<Bivio::UI::Facade>

=cut

use Bivio::UI::Facade;
@Bivio::Agent::t::Task::Facade::Task::ISA = ('Bivio::UI::Facade');

=head1 DESCRIPTION

C<Bivio::Agent::t::Task::Facade::Task> is a facade for Task.t

=cut

#=IMPORTS
use Bivio::UI::HTML::ViewShortcuts;

#=VARIABLES
my($_SELF) = __PACKAGE__->new({
    clone => undef,
    is_production => 1,
    uri => 'task',
    # So local files are found
    local_file_prefix => 'petshop',
    Color => {
	initialize => sub {
	    my($fc) = @_;
	    return;
	},
    },
    Font => {
	initialize => sub {
	    my($fc) = @_;
	    $fc->group(default => [
		'family=verdana,arial,helvetica,sans-serif',
		'size=small',
	    ]);
	    return;
	}
    },
    Text => {
	initialize => sub {
            my($t) = @_;
            return;
        },
    },
    Task => {
	initialize => sub {
	    my($t) = @_;
	    $t->group(SITE_ROOT => ['/*']);
            foreach my $n (qw(
                CLUB_HOME
                MY_CLUB_SITE
                MY_SITE
                REDIRECT_TEST_1
                REDIRECT_TEST_2
                USER_HOME
                LOGIN
            )) {
		$t->group($n => undef);
	    }
	    return;
	},
    },
    HTML => {
	initialize => sub {
	    return;
	},
    },
});

=head1 METHODS

=cut

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2000 bivio Software Artisans, Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
