# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::TestView;
use strict;
use Data::Dumper;
$Bivio::UI::TestView::VERSION = sprintf('%d.%02d', q$Revision$ =~ /+/g);

=head1 NAME

Bivio::UI::TestView - a simple testing view

=head1 SYNOPSIS

    use Bivio::UI::TestView;
    Bivio::UI::TestView->new();

=cut

=head1 EXTENDS

L<Bivio::UI::View>

=cut

@Bivio::UI::TestView::ISA = qw(Bivio::UI::View);

=head1 DESCRIPTION

C<Bivio::UI::TestView> ignores the model and prints a few things
when renderering.

=cut

=head1 CONSTANTS

=cut

#=VARIABLES

my($_PACKAGE) = __PACKAGE__;

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(string name, string output) : Bivio::UI::TestView

Creates a new TestView with the specified title, and rendering output.

=cut

sub new {
    my($proto, $name, $output, $default_model) = @_;
    my($self) = &Bivio::UI::View::new($proto, $name);

#    print Dumper($self);

    $self->{$_PACKAGE} = {
	output => $output,
	default_model => $default_model
    };
    return $self;
}

=head1 METHODS

=cut

=for html <a name="get_default_model"></a>

=head2 get_default_model() : Model

Returns a default model, ready for rendering.

=cut

sub get_default_model {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    return $fields->{default_model};
}

=for html <a name="render"></a>

=head2 render(UNIVERSAL target, Request req)

Prints the output string to the specified request.

=cut

sub render {
    my($self, $target, $req) = @_;
    my($fields) = $self->{$_PACKAGE};

    $req->print($fields->{output});
}


#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
