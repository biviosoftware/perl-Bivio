# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::HTML::TestView;
use strict;
use Data::Dumper;
$Bivio::UI::HTML::TestView::VERSION = sprintf('%d.%02d', q$Revision$ =~ /+/g);

=head1 NAME

Bivio::UI::HTML::TestView - a simple testing view

=head1 SYNOPSIS

    use Bivio::UI::HTML::TestView;
    Bivio::UI::HTML::TestView->new();

=cut

=head1 EXTENDS

L<Bivio::UI::View>

=cut

@Bivio::UI::HTML::TestView::ISA = qw(Bivio::UI::View);

=head1 DESCRIPTION

C<Bivio::UI::HTML::TestView> ignores the model and prints a few things
when renderering.

=cut

=head1 CONSTANTS

=cut

#=VARIABLES

my($PACKAGE) = __PACKAGE__;

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(string title, string output) : Bivio::UI::HTML::TestView

Creates a new TestView with the specified title, and rendering output.

=cut

sub new {
    my($proto, $title, $output) = @_;
    my($self) = &Bivio::UI::View::new($proto);

#    print Dumper($self);

    $self->{$PACKAGE} = {
	title => $title,
	output => $output
    };
    return $self;
}

=head1 METHODS

=cut

=for html <a name="get_title"></a>

=head2 get_title() : string

Returns the title of the view.

=cut

sub get_title {
    my($self) = @_;
    my($fields) = $self->{$PACKAGE};
    return $fields->{title};
}

=for html <a name="render"></a>

=head2 render(UNIVERSAL target, Request req)

Prints the output string to the specified request.

=cut

sub render {
    my($self) = @_;
    my($fields) = $self->{$PACKAGE};

    print($fields->{output});
}


#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
