# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::HTML::View::Test;
use strict;
$Bivio::UI::HTML::View::Test::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::HTML::View::Test - 

=head1 SYNOPSIS

    use Bivio::UI::HTML::View::Test;
    Bivio::UI::HTML::View::Test->new();

=cut

=head1 EXTENDS

L<Bivio::UI::HTML::View>

=cut

use Bivio::UI::HTML::View;
@Bivio::UI::HTML::View::Test::ISA = qw(Bivio::UI::HTML::View);

=head1 DESCRIPTION

C<Bivio::UI::HTML::View::Test>

=cut

#=IMPORTS
use Bivio::Agent::HTTP::Request;
use Bivio::Agent::TaskId;
use Bivio::UI::HTML::ActionButtons;
use Bivio::UI::HTML::Format::DateTime;
use Bivio::UI::HTML::Format::Printf;
use Bivio::UI::HTML::Widget::ActionBar;
use Bivio::UI::HTML::Widget::Director;
use Bivio::UI::HTML::Widget::Grid;
use Bivio::UI::HTML::Widget::Image;
use Bivio::UI::HTML::Widget::Link;
use Bivio::UI::HTML::Widget::String;
use Bivio::UI::HTML::Widget::TextTabMenu;
use Bivio::UI::Icon;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

=head1 FACTORIES

=cut

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
    my($fields) = $self->{$_PACKAGE};
    my($buffer) = $fields->{prefix};
# Cache this?
    $self->get('child')->render($req, \$buffer);
    $buffer .= $fields->{suffix};
    $req->get('reply')->print($buffer);
    return;
}

=for html <a name="initialize"></a>

=head2 initialize()

=cut

sub initialize {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    $fields->{prefix} = <<'EOF';
<html><head><title>Test</title></head><body>
EOF
    $fields->{suffix} = <<'EOF';
</body></html>
EOF
    $self->put('child', Bivio::UI::HTML::Widget::Grid->new({
	parent => $self,
        values => [[
	    Bivio::UI::HTML::Widget::Grid->new({
	    values => [
		[
		    Bivio::UI::HTML::Widget::String->new({
			value => ['task_id', 'get_short_desc',
			       'Bivio::UI::HTML::Format::Printf',
			       'The Task is %s',],
			string_font => 'page_heading',
			cell_expand => 1,
			cell_align => 'center',
		    }),
		],
		[
		    Bivio::UI::HTML::Widget::String->new({
			value => 'south east',
			cell_align => 'SE',
		    }),
		    Bivio::UI::HTML::Widget::Director->new({
			control => ['auth_user'],
			undef_value => Bivio::UI::HTML::Widget::Image->new({
			    src => ['Bivio::UI::Icon', 'next_ia'],
			    alt => 'no auth_user',
			}),
			default_value => Bivio::UI::HTML::Widget::Image->new({
			    src => ['Bivio::UI::Icon', 'next'],
			    alt => ['auth_user', 'name',
				    'Bivio::UI::HTML::Format::Printf',
				    'The auth_user is %s'],
			}),
			values => {},
			cell_align => 'right',
		    }),
		    Bivio::UI::HTML::Widget::String->new({
			value => 'NW',
			cell_align => 'NW',
		    }),
		],
		[
		    Bivio::UI::HTML::Widget::String->new({
			value => ['start_time', 0,
			    'Bivio::UI::HTML::Format::DateTime'],
			string_font => 'table_heading',
		    }),
		    Bivio::UI::HTML::Widget::String->new({
			value => 'Elapsed time:',
		    }),
		    Bivio::UI::HTML::Widget::String->new({
			value => ['->elapsed_time'],
		    }),
		],
		[
		    Bivio::UI::HTML::Widget::Link->new({
			href => ['->format_uri',
				Bivio::Agent::TaskId::TEST_FORM(),
				undef,
				undef],
			value => Bivio::UI::HTML::Widget::String->new({
			    value => Bivio::Agent::HTTP::Request->format_uri(
				    Bivio::Agent::TaskId::TEST_FORM(),
				    undef,
				    undef),
			}),
		    }),
		],
		[
		    Bivio::UI::HTML::Widget::TextTabMenu->new({
			text_tab_height => 0,
			orient => 'up',
			values => [
			    Form => Bivio::Agent::TaskId::TEST_FORM(),
			    This => [Bivio::Agent::TaskId::TEST_VIEW()],
			],
		    }),
		],
	    ],
	   }),
	   Bivio::UI::HTML::Widget::ActionBar->new({
	      values => Bivio::UI::HTML::ActionButtons->get_list('test_view',
		     'test_view'),
	      bgcolor => 'icon_text_ia',
	      string_font => 'error',
	      cell_align => 'right',
	   }),
	]],
    }));
    $self->get('child')->initialize;
    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
