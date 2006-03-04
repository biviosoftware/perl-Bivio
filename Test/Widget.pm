# Copyright (c) 2003-2005 bivio Software, Inc.  All Rights Reserved.
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

=head1 EXTENDS

L<Bivio::Collection::Attributes>

=cut

use Bivio::Collection::Attributes;
@Bivio::Test::Widget::ISA = ('Bivio::Collection::Attributes');

=head1 DESCRIPTION

C<Bivio::Test::Widget> helps you test L<Bivio::UI::Widget|Bivio::UI::Widget>.

=cut

#=IMPORTS
use Bivio::UI::Widget::Join;
use Bivio::Test::Request;

#=VARIABLES
our($AUTOLOAD);

=head1 FACTORIES

=cut

=for html <a name="new_unit"></a>

=head2 new_unit(string class_name, hash_ref attrs) : self

Accepts I<setup_render> and I<compute_return> attributes.  Also allows
override of I<class_name> via I<attrs>.

=cut

sub new_unit {
    my($proto, $class_name, $attrs) = @_;
    ($attrs ||= {})->{class_name} ||= $class_name;
    Bivio::Agent::Task->initialize;
    Bivio::Test::Request->setup_facade;
    return $proto->new($attrs);
}

=head1 METHODS

=cut

# =for html <a name="AUTOLOAD"></a>

# =head2 AUTOLOAD(...) : any

# The widget and shortcut methods are dynamically loaded.

# =cut

# sub AUTOLOAD {
# #TODO: This doesn't work
#     return Bivio::IO::ClassLoader->simple_require(
# 	'Bivio::UI::ViewLanguage',
#     )->call_method(
# 	$AUTOLOAD, 'Bivio::UI::ViewLanguage', @_,
#     );
# }

=for html <a name="run_unit"></a>

=head2 run_unit(array_ref cases)

Calls L<unit|"unit"> with appropriate args.

=cut

sub run_unit {
    my($self, $cases) = @_;
    return $self->unit(
	$self->unsafe_get(qw(class_name setup_render compute_return)),
	$cases,
    );
}

=for html <a name="setup_render"></a>

=head2 callback setup_render(Bivio::Agent::Request req, Bivio::Test::Case case, array_ref params, any method, any object)

Used to setup the parameters for render.

=cut

$_ = <<'}'; # emacs
sub setup_render {
}

=for html <a name="unit"></a>

=head2 static unit(string class_name, array_ref cases)

=head2 static unit(string class_name, code_ref setup_render, array_ref cases)

=head2 static unit(string class_name, code_ref setup_render, code_ref compute_return, array_ref cases)

Calls L<Bivio::Test::new|Bivio::Test/"new"> and
L<Bivio::Test::unit|Bivio::Test/"unit"> with I<cases>.  Calls
L<setup_render|"setup_render"> (if defined) with Bivio::Test::Request instance
for call to render.  Adds an explicit C<compute_return> for render which
returns the rendered buffer.  After fixup I<compute_return> is called,
if defined.  create_object calls C<new> and then puts parent and initializes.

If the case is of the form:

    ['new args', ...] => 'string',

It will be transformed to:

    ['new args', ...] => [
        render => [
            [] => 'string',
        ],
    ],

=cut

sub unit {
    my($self) = shift;
    Bivio::Agent::Task->initialize;
    my($req) = Bivio::Test::Request->setup_facade;
    my($i) = 0;
    my($class_name) = shift;
    my($cases) = pop;
    my($setup_render, $compute_return) = @_;
    my($res);
    $req->put('Bivio::Test::Widget' => sub {
	$res = Bivio::Test->new({
	    create_object => sub {
		my($case, $params) = @_;
		return $case->get('class_name')->new(@$params)
		    ->put_and_initialize(parent => undef);
	    },
	    class_name => $class_name,
	    compute_params => sub {
		my($case, $params) = @_;
		return $params
		    unless _is_render($case);
		$setup_render->($req, @_)
		    if $setup_render;
		my($x) = '';
		return [$req, \$x];
	    },
	    compute_return => sub {
		my($case, $actual) = splice(@_, 0, 2);
		return $actual
		    unless _is_render($case);
		$actual = [${$case->get('params')->[1]}];
		return $compute_return ? $compute_return->($case, $actual, @_)
		    : $actual;
	    },
	})->unit([map(
	    $i++ % 2 && ref($_) ne 'ARRAY' ? [render => [[] => $_]] : $_,
	    @$cases,
	)]);
    });
#TODO: Shouldn't be hardwired, can setup above.
    Bivio::UI::View->execute(\(<<'EOF'), $req);
view_class_map('HTMLWidget');
view_shortcuts('Bivio::UI::HTML::ViewShortcuts');
view_main(SimplePage([
    sub {
	shift->get_request->get('Bivio::Test::Widget')->();
	return '';
    },
]));
EOF
    return $res;
}

=for html <a name="vs_new"></a>

=head2 vs_new(....)

#TODO: Remove this after AUTOLOAD works
Calls Bivio::UI::ViewShortcuts::vs_call.

=cut

sub vs_new {
    shift;
    return Bivio::IO::ClassLoader->simple_require(
	'Bivio::UI::HTML::ViewShortcuts',
    )->vs_new(@_);
}

#=PRIVATE SUBROUTINES

# _is_render(Bivio::Test::Case case) : boolean
#
# Returns true if render.
#
sub _is_render {
    return shift->get('method') eq 'render' ? 1 : 0;
}

=head1 COPYRIGHT

Copyright (c) 2003-2005 bivio Software, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
