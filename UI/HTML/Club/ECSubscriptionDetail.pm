# Copyright (c) 2000 bivio Inc.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Club::ECSubscriptionDetail;
use strict;
$Bivio::UI::HTML::Club::ECSubscriptionDetail::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::UI::HTML::Club::ECSubscriptionDetail::VERSION;

=head1 NAME

Bivio::UI::HTML::Club::ECSubscriptionDetail - subscription detail page

=head1 SYNOPSIS

    use Bivio::UI::HTML::Club::ECSubscriptionDetail;

=cut

=head1 EXTENDS

L<Bivio::UI::Widget>

=cut

use Bivio::UI::Widget;
@Bivio::UI::HTML::Club::ECSubscriptionDetail::ISA = ('Bivio::UI::Widget');

=head1 DESCRIPTION

C<Bivio::UI::HTML::Club::ECSubscriptionDetail> shows the details
of the subscription.

TODO: Should be used to configure/modify subscription configuration

=cut

#=IMPORTS
use Bivio::UI::HTML::ViewShortcuts;

#=VARIABLES
my($_VS) = 'Bivio::UI::HTML::ViewShortcuts';

my($_PACKAGE) = __PACKAGE__;
use vars qw($_TRACE);
Bivio::IO::Trace->register;

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::UI::HTML::Club::ECSubscriptionDetail



=cut

sub new {
    my($self) = Bivio::UI::Widget::new(@_);
    my($fields) = $self->{$_PACKAGE} = {};

    $fields->{content} = $_VS->vs_join([
#TODO:        'TODO: This should be the service setup page!',
        '<P>',
        Bivio::UI::HTML::Widget::Grid->new({
            values => [
                [
                    $_VS->vs_string('Subscription first started on: '),
                    $_VS->vs_date_time(['Bivio::Societas::Biz::Model::ECSubscription',
                        'start_date']),
                ], [
                    $_VS->vs_string('Subscription ends at: '),
                    $_VS->vs_date_time(['Bivio::Societas::Biz::Model::ECSubscription',
                        'end_date']),
                ],
            ]
        }),
    ]);
    $fields->{content}->initialize;
    return $self;
}

=head1 METHODS

=cut

=for html <a name="execute"></a>

=head2 execute(Bivio::Agent::Request req)



=cut

sub execute {
    my($self, $req) = @_;
    my($fields) = $self->{$_PACKAGE};

    $req->put(
	    page_subtopic => 'AccountSync Setup',
	    page_title_value => 'AccountSync Setup',
	    page_content => $fields->{content},
	  #  page_action_bar => $fields->{action_bar},
	    page_type => Bivio::UI::PageType::DETAIL(),
	    );
    return Bivio::UI::HTML::Club::Page->execute($req);
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2000 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
