# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::TestView;
use strict;
$Bivio::UI::TestView::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::TestView - a simple testing view

=head1 SYNOPSIS

    use Bivio::UI::TestView;
    my($model) = Bivio::Biz::Model::Test->new('test2', {}, 'title', 'heading');
    my($view) = Bivio::UI::TestView->new('test', '<i>a test view</i>', $model);
    $view->activate()->render($model, $req);

=cut

=head1 EXTENDS

L<Bivio::UI::View>

=cut

use Bivio::UI::View;
@Bivio::UI::TestView::ISA = qw(Bivio::UI::View);

=head1 DESCRIPTION

C<Bivio::UI::TestView> ignores the model and prints a few things
when renderering. This is a good place-holder for work-in-progress.
See L<Bivio::Biz::Model::Test>.

=cut

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(string name, string output, Model default_model) : Bivio::UI::TestView

Creates a new TestView with the specified name, output, and default model.

=cut

sub new {
    my($proto, $name, $output, $default_model) = @_;
    my($self) = &Bivio::UI::View::new($proto, $name);

    $self->{$_PACKAGE} = {
	'output' => $output,
	'default_model' => $default_model
    };
    return $self;
}

=head1 METHODS

=cut

=for html <a name="get_default_model"></a>

=head2 get_default_model() : Model

Returns a default model.

=cut

sub get_default_model {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    return $fields->{default_model};
}

=for html <a name="render"></a>

=head2 render(Model model, Request req)

Prints the output string to the specified request.

=cut

sub render {
    my($self, $model, $req) = @_;
    my($fields) = $self->{$_PACKAGE};

    $req->get_reply()->print($fields->{output});
    return;
}


#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
