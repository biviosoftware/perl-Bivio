# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::MessageBoard::MessageListView;
use strict;
$Bivio::UI::MessageBoard::MessageListView::VERSION = sprintf('%d.%02d', q$Revision$ =~ /+/g);

=head1 NAME

Bivio::UI::MessageBoard::MessageListView - a list of messages

=head1 SYNOPSIS

    use Bivio::UI::MessageBoard::MessageListView;
    Bivio::UI::MessageBoard::MessageListView->new();

=cut

=head1 EXTENDS

L<Bivio::UI::HTML::ListView>

=cut

use Bivio::UI::HTML::ListView;
@Bivio::UI::MessageBoard::MessageListView::ISA = qw(Bivio::UI::HTML::ListView);

=head1 DESCRIPTION

C<Bivio::UI::MessageBoard::MessageListView>

=cut

=head1 CONSTANTS

=cut

#=IMPORTS
use Bivio::Biz::Mail::MessageList;
use Bivio::IO::Trace;

#=VARIABLES
use vars qw($_TRACE);
Bivio::IO::Trace->register;
my($_PACKAGE) = __PACKAGE__;

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::UI::MessageBoard::MessageListView

Creates a MessageListView.

=cut

sub new {
    my($proto) = @_;
    my($self) = &Bivio::UI::HTML::ListView::new($proto, 'messages');
    $self->{$_PACKAGE} = {};
    return $self;
}

=head1 METHODS

=cut

=for html <a name="get_default_model"></a>

=head2 get_default_model() : Model

Returns the default model ready for rendering.

=cut

sub get_default_model {
    #NOTE: could cache this
    return Bivio::Biz::Mail::MessageList->new();
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
