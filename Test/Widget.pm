# Copyright (c) 2003 bivio Software Artisans, Inc.  All Rights Reserved.
# $Id$
package Bivio::Test::Widget;
use strict;
$Bivio::Test::Widget::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Test::Widget::VERSION;

=head1 NAME

Bivio::Test::Widget - supports testing widgets

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::Test::Widget;

=cut

use Bivio::UNIVERSAL;
@Bivio::Test::Widget::ISA = ('Bivio::UNIVERSAL');

=head1 DESCRIPTION

C<Bivio::Test::Widget> helps you test L<Bivio::UI::Widget|Bivio::UI::Widget>.

=cut

#=IMPORTS
use Bivio::UI::Widget::Join;
use Bivio::Test::Request;

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="setup_render"></a>

=head2 callback setup_render(Bivio::Agent::Request req, Bivio::Test::Case case, array_ref params, any method, any object)

Used to setup the parameters for render.

=cut

$_ = <<'}'; # emacs
sub setup_render {
}

=for html <a name="unit"></a>

=head2 static unit(string class_name, code_ref setup_render, array_ref cases)

Calls L<Bivio::Test::new|Bivio::Test/"new"> and
L<Bivio::Test::unit|Bivio::Test/"unit"> with I<cases>.  Calls
L<setup_render|"setup_render"> with Bivio::Test::Request instance for call to
render.  Adds an explicit check_return for render which returns the rendered
buffer.

=cut

sub unit {
    my($proto, $class_name, $setup_render, $cases) = @_;
    Bivio::Test->new({
	class_name => $class_name,
	compute_params => sub {
	    my($case, $params, $method) = @_;
	    return $params
		unless $method eq 'render';
	    my($req) = Bivio::Test::Request->get_instance;
	    $setup_render->($req, @_);
	    my($x) = '';
	    return $method eq 'render' ? [$req, \$x] : $params;
	},
	check_return => sub {
	    my($case, $actual, $expected) = @_;
	    return $expected
		unless $case->get('method') eq 'render';
	    $case->actual_return([${$case->get('params')->[1]}]);
	    return $expected;
	}
    })->unit($cases);
}

#=PRIVATE SUBROUTINES

=head1 COPYRIGHT

Copyright (c) 2003 bivio Software Artisans, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
