# Copyright (c) 2001 bivio Inc.  All rights reserved.
# $Id$
package Bivio::Biz::Action::ViewAsPlainText;
use strict;
$Bivio::Biz::Action::ViewAsPlainText::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Biz::Action::ViewAsPlainText::VERSION;

=head1 NAME

Bivio::Biz::Action::ViewAsPlainText - renders view source as plain text

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::Biz::Action::ViewAsPlainText;

=cut

=head1 EXTENDS

L<Bivio::Biz::Action>

=cut

use Bivio::Biz::Action;
@Bivio::Biz::Action::ViewAsPlainText::ISA = ('Bivio::Biz::Action');

=head1 DESCRIPTION

C<Bivio::Biz::Action::ViewAsPlainText> renders a view's source as plain
text.

=cut

#=IMPORTS
use Bivio::UI::View;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

=head1 METHODS

=cut

=for html <a name="execute"></a>

=head2 static execute(Bivio::Agent::Request req) : boolean

Renders a view's source as plain text.  I<Request.uri> must be
the name of the view.
L<Bivio::UI::View::SUFFIX|Bivio::UI::View/"SUFFIX">
will be appended.

Always returns false.

=cut

sub execute {
    my($proto, $req) = @_;
    return $proto->get_instance('LocalFilePlain')->execute(
	    $req,
	    $req->get('uri').Bivio::UI::View->SUFFIX, 'text/plain');
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2001 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
