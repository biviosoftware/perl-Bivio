# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Club::Embargoed;
use strict;
$Bivio::UI::HTML::Club::Embargoed::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::HTML::Club::Embargoed - not yet supported

=head1 SYNOPSIS

    use Bivio::UI::HTML::Club::Embargoed;
    Bivio::UI::HTML::Club::Embargoed->new();

=cut

=head1 EXTENDS

L<Bivio::UI::HTML::Widget>

=cut

use Bivio::UI::HTML::Widget;
@Bivio::UI::HTML::Club::Embargoed::ISA = ('Bivio::UI::HTML::Widget');

=head1 DESCRIPTION

C<Bivio::UI::HTML::Club::Embargoed>

=cut

#=IMPORTS
use Bivio::UI::HTML::ActionButtons;
use Bivio::UI::HTML::Club::Page;
use Bivio::UI::HTML::Widget::ActionBar;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

=for html <a name="new"></a>

=head2 static new() : Bivio::UI::HTML::Club::Embargoed


=cut

sub new {
    my($self) = &Bivio::UI::HTML::Widget::new(@_);
    my($fields) = $self->{$_PACKAGE} = {};
    $fields->{message} = Bivio::UI::HTML::Widget::String->new({
	value => 'This function has been embargoed for the pilot.',
	string_font => 'error',
    });
    $fields->{message}->initialize;
    $fields->{action_bar} = Bivio::UI::HTML::Widget::ActionBar->new({
	values => Bivio::UI::HTML::ActionButtons->get_list(
		'club_compose_message'),
    });
    $fields->{action_bar}->initialize;
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
    $req->put(page_subtopic => undef, page_heading => 'Embargoed',
	   page_content => $fields->{message},
	   page_action_bar => $fields->{action_bar});
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
