# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::HTML::View::ClubTest;
use strict;
$Bivio::UI::HTML::View::ClubTest::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::HTML::View::ClubTest - 

=head1 SYNOPSIS

    use Bivio::UI::HTML::View::ClubTest;
    Bivio::UI::HTML::View::ClubTest->new();

=cut

=head1 EXTENDS

L<Bivio::UI::HTML::View>

=cut

use Bivio::UI::HTML::View;
@Bivio::UI::HTML::View::ClubTest::ISA = ('Bivio::UI::HTML::View');

=head1 DESCRIPTION

C<Bivio::UI::HTML::View::ClubTest>

=cut

#=IMPORTS
use Bivio::UI::HTML::Club::Page;
use Bivio::Biz::PropertyModel::Club;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

=for html <a name="new"></a>

=head2 static new() : Bivio::UI::HTML::View::Test



=cut

sub new {
    my($self) = &Bivio::UI::HTML::View::new(@_);
    $self->{$_PACKAGE} = {};
    $self->initialize;
    return $self;
}

=head1 METHODS

=cut

=for html <a name="execute"></a>

=head2 execute(Bivio::Agent::Request req)


=cut

sub execute {
    my($self, $req) = @_;
    $req->put(page_subtopic => undef, page_heading => 'Page Heading',
	   page_content => $self);
    Bivio::UI::HTML::Club::Page->execute($req);
    return;
}

=for html <a name="initialize"></a>

=head2 initialize()

=cut

sub initialize {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    return;
}

=for html <a name="render"></a>

=head2 render() : 

=cut

sub render {
    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
