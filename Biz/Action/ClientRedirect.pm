# Copyright (c) 1999-2001 bivio Inc.  All rights reserved.
# $Id$
package Bivio::Biz::Action::ClientRedirect;
use strict;
$Bivio::Biz::Action::ClientRedirect::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Biz::Action::ClientRedirect::VERSION;

=head1 NAME

Bivio::Biz::Action::ClientRedirect - client redirect to specific task or URI

=head1 SYNOPSIS

    use Bivio::Biz::Action::ClientRedirect;

=cut

=head1 EXTENDS

L<Bivio::Biz::Action>

=cut

use Bivio::Biz::Action;
@Bivio::Biz::Action::ClientRedirect::ISA = ('Bivio::Biz::Action');

=head1 DESCRIPTION

C<Bivio::Biz::Action::ClientRedirect> redirects to the cancel or
next task values.

You may also redirect to a specific task:

    Bivio::Biz::Action::ClientRedirect->SOME_TASK($req);

The subroutines are dynamically compiled from the lists of
tasks in L<Bivio::Agent::TaskId|Bivio::Agent::TaskId>.

See also L<new|"new"> for instance-based redirects.

=cut

=head1 CONSTANTS

=for html <a name="QUERY_TAG"></a>

=head2 QUERY_TAG : string

Returns tag to be used in query string

=cut

sub QUERY_TAG {
    return 'x';
}

#=IMPORTS
use Bivio::IO::Trace;
use Bivio::Agent::TaskId;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;
use vars ('$_TRACE');
Bivio::IO::Trace->register;
_compile();


=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(string uri) : Bivio::Biz::Action::ClientRedirect

If I<uri> is supplied, creates an instance which will redirect
to I<uri> every time L<execute|"execute"> is called.

If I<uri> is C<undef>, L<execute|"execute"> will throw an exception.

=cut

sub new {
    my($proto, $uri) = @_;
    my($self) = Bivio::UNIVERSAL::new($proto);
    if ($uri) {
	$self->{$_PACKAGE} = {
	    uri => $uri,
	};
    }
    return $self;
}

=head1 METHODS

=cut

=for html <a name="execute"></a>

=head2 execute(Bivio::Agent::Request req) : boolean

Redirects only if created with a I<uri>.

=cut

sub execute {
    my($self, $req) = @_;
    Bivio::Die->die('cannot be called statically or without uri')
		unless ref($self) && $self->{$_PACKAGE};
    $req->client_redirect($self->{$_PACKAGE}->{uri});
    # DOES NOT RETURN
}

=for html <a name="execute_cancel"></a>

=head2 execute_cancel(Bivio::Agent::Request req)

Redirect to I<cancel> task.

=cut

sub execute_cancel {
    my(undef, $req) = @_;
    $req->client_redirect($req->get('task')->get('cancel'));
    # DOES NOT RETURN
}

=for html <a name="execute_home_page_if_site_root"></a>

=head2 execute_home_page_if_site_root(Bivio::Agent::Request req) : boolean

Redirects to I<Text.home_page_uri> if the I<$req.uri> is '/' or the empty
string.  Otherwise,

=cut

sub execute_home_page_if_site_root {
    my(undef, $req) = @_;
    $req->client_redirect_contextless(
	    Bivio::UI::Text->get_value('home_page_uri', $req))
	    if $req->get('uri') =~ m!^/?$!;
    return 0;
}

=for html <a name="execute_next"></a>

=head2 execute_next(Bivio::Agent::Request req)

Redirect to I<next> task.

=cut

sub execute_next {
    my(undef, $req) = @_;
    $req->client_redirect($req->get('task')->get('next'));
    # DOES NOT RETURN
}

=for html <a name="execute_next_stateless"></a>

=head2 execute_next_stateless(Bivio::Agent::Request req)

Redirect to I<next> task without a query.

=cut

sub execute_next_stateless {
    my(undef, $req) = @_;
    $req->client_redirect($req->get('task')->get('next'), undef, undef);
    # DOES NOT RETURN
}

=for html <a name="execute_query"></a>

=head2 execute_query(Bivio::Agent::Request req)

Redirects to URI in query string or to I<next> task if no query string.

=cut

sub execute_query {
    my(undef, $req) = @_;

    # If there is a query, use that as the name of the realm
    my($query) = $req->unsafe_get('query');
    if ($query && defined($query->{QUERY_TAG()})) {
	my($uri) = $query->{QUERY_TAG()};
	# Insert absolute path if not already absolute
	$uri =~ s,^(?!\w+:|\/),\/,;
	_trace($uri) if $_TRACE;
	$req->client_redirect($uri);
	# DOES NOT RETURN
    }

    # Just redirect to the configured default
    $req->client_redirect($req->get('task')->get('next'));
    # DOES NOT RETURN
}

#=PRIVATE METHODS

# _compile()
#
# Create autoredirect functions for all the tasks in TaskId.
#
sub _compile {
    foreach my $t (Bivio::Agent::TaskId->get_list) {
#TODO: Would like to not define subs for for that don't have URIs,
#      but can't do this because Tasks is not fully initialized by
#      the time this module has been called.  It is called during
#      initialization and Location hasn't fully initialized either.
#      Probably want to do two passes in Location.  First setting
#      URIs and second initializing the tasks.
	my($n) = $t->get_name;
	eval(<<"EOF") || die($@);
	    sub $n {
                my(undef, \$req) = \@_;
                \$req->client_redirect(Bivio::Agent::TaskId::$n());
            }
            1;
EOF
    }
    return;
}

=head1 COPYRIGHT

Copyright (c) 1999-2001 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
