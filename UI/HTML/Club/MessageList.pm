# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Club::MessageList;
use strict;
$Bivio::UI::HTML::Club::MessageList::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::HTML::Club::MessageList - the view of messages for a club.

=head1 SYNOPSIS

    use Bivio::UI::HTML::Club::MessageList;
    Bivio::UI::HTML::Club::MessageList->new();

=cut

=head1 EXTENDS

L<Bivio::UI::HTML::Widget>

=cut

use Bivio::UI::HTML::Widget;
@Bivio::UI::HTML::Club::MessageList::ISA = ('Bivio::UI::HTML::Widget');

=head1 DESCRIPTION

C<Bivio::UI::HTML::Club::MessageList> is an HTML widget that displays
a message list.

=cut

#=IMPORTS

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;


=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::UI::HTML::Club::MessageList

=cut

sub new {
    my($self) = &Bivio::UI::HTML::Widget::new(@_);
    my($fields) = $self->{$_PACKAGE} = {};
    $fields->{content} = Bivio::UI::HTML::Widget::Table->new({
	source => ['Bivio::Biz::Model::MessageList'],
	headings => [
		'Subject',
		'Author',
		'Date',
	],
	cells => [
		Bivio::UI::HTML::Widget::Link->new({
        #    	    href => ['->format_uri_for_this'],
		    href => ['->hacked_uri'],
		    value => Bivio::UI::HTML::Widget::String->new({
			value => ['MailMessage.subject'],
	        }),
	    }),
    	    ['MailMessage.from_name'],
            ['MailMessage.dttm',
		   'Bivio::UI::HTML::Format::Date', 2],
	],
	});
    $fields->{content}->initialize;
    return $self;
}

=head1 METHODS

=cut

=for html <a name="execute"></a>

=head2 execute() : 



=cut

sub execute {
    my($self, $req) = @_;
    my($fields) = $self->{$_PACKAGE};

    $req->put(page_subtopic => undef, page_heading => 'Messages',
	   page_content => $fields->{content});
    Bivio::UI::HTML::Club::Page->execute($req);
    return;

}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
