# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::Model::MessageList;
use strict;
$Bivio::Biz::Model::MessageList::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Biz::Model::MessageList - the message list view model.

=head1 SYNOPSIS

    use Bivio::Biz::Model::MessageList;
    Bivio::Biz::Model::MessageList->new();

=cut

=head1 EXTENDS

L<Bivio::Biz::ListModel>

=cut

use Bivio::Biz::ListModel;
@Bivio::Biz::Model::MessageList::ISA = ('Bivio::Biz::ListModel');

=head1 DESCRIPTION

C<Bivio::Biz::Model::MessageList> manages the list of messages for a club.

=cut

#=IMPORTS

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;
use vars qw($_TRACE);
Bivio::IO::Trace->register;



=head1 METHODS

=cut

=for html <a name="hacked_uri"></a>

=head2 hacked_uri() : 



=cut

sub hacked_uri {
    my($self) = @_;
    my($req) = Bivio::Agent::Request->get_current();
    return $req->format_uri(
	    Bivio::Agent::TaskId::CLUB_COMMUNICATIONS_MESSAGE_DETAIL(),
	    'pk='.$self->get('MailMessage.mail_message_id'));
}

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : 



=cut

sub internal_initialize {
    return {
       version => 1,
       order_by => [qw(
                      MailMessage.dttm
		      MailMessage.subject_sort
		      MailMessage.from_name_sort
                      )],
       other => [qw(
       	    	      MailMessage.subject
		      MailMessage.from_name
    	    	      )],
       primary_key => [
                      [qw(MailMessage.mail_message_id)],
                      ],
       auth_id => [qw(MailMessage.club_id)],
    };
}

=for html <a name="internal_load"></a>

=head2 internal_load() : 



=cut

sub internal_load {
    _trace('internal_load called.') if $_TRACE;
    my($self, $rows, $query) = @_;
    $self->SUPER::internal_load($rows, $query);
    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
