# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Club::MessageAttachment;
use strict;
$Bivio::UI::HTML::Club::MessageAttachment::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::HTML::Club::MessageAttachment - Displays a MIME encoded part of an email

=head1 SYNOPSIS

    use Bivio::UI::HTML::Club::MessageAttachment;
    Bivio::UI::HTML::Club::MessageAttachment->new();

=cut

=head1 EXTENDS

L<Bivio::UI::HTML::Widget>

=cut

use Bivio::UI::HTML::Widget;
@Bivio::UI::HTML::Club::MessageAttachment::ISA = ('Bivio::UI::HTML::Widget');

=head1 DESCRIPTION

C<Bivio::UI::HTML::Club::MessageAttachment> shows a window with a MIME part in it.
It also displays links to other, nested MIME parts.

=cut

#=IMPORTS
#=IMPORTS
use Bivio::Agent::TaskId;
use Bivio::Biz::Model::MailMessage;
use Bivio::DieCode;
use Bivio::UI::HTML::Widget::Join;
use Bivio::UI::HTML::Widget::Link;
use Bivio::UI::HTML::Widget::String;


#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

=head1 METHODS

=cut

=for html <a name="execute"></a>

=head2 execute() : 



=cut

sub execute {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
