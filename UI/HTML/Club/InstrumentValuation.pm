# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Club::InstrumentValuation;
use strict;
$Bivio::UI::HTML::Club::InstrumentValuation::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::HTML::Club::InstrumentValuation - 

=head1 SYNOPSIS

    use Bivio::UI::HTML::Club::InstrumentValuation;
    Bivio::UI::HTML::Club::InstrumentValuation->new();

=cut

=head1 EXTENDS

L<Bivio::UI::HTML::Widget>

=cut

use Bivio::UI::HTML::Widget;
@Bivio::UI::HTML::Club::InstrumentValuation::ISA = ('Bivio::UI::HTML::Widget');

=head1 DESCRIPTION

C<Bivio::UI::HTML::Club::InstrumentValuation>

=cut

#=IMPORTS
use Bivio::Util;
use Bivio::Biz::Model::RealmInstrumentValuation;
use Bivio::UI::Font;
use Bivio::UI::HTML::Club::Page;
use Bivio::UI::HTML::Widget::Currency;
use Bivio::UI::HTML::Widget::Date;
use Bivio::UI::HTML::Widget::Director;
use Bivio::UI::HTML::Widget::Form;
use Bivio::UI::HTML::Widget::FormFieldLabel;
use Bivio::UI::HTML::Widget::Grid;
use Bivio::UI::HTML::Widget::Hidden;
use Bivio::UI::HTML::Widget::Join;
use Bivio::UI::HTML::Widget::Submit;
use Bivio::UI::HTML::Widget::TextArea;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;
my($_FIELDS) = [];

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::UI::HTML::Club::AccountTransaction

Creates and arranges an account transaction dialog.

=cut

sub new {
    my($self) = &Bivio::UI::HTML::Widget::new(@_);
    my($fields) = $self->{$_PACKAGE} = {};
    my($blank_cell) = Bivio::UI::HTML::Widget::Join->new({
	values => ['&nbsp;']});
    $fields->{form} = Bivio::UI::HTML::Widget::Form->new({
	form_model => ['Bivio::Biz::Model::InstrumentValuationForm'],
	value => Bivio::UI::HTML::Widget::Director->new({
	    cell_expand => 1,
	    cell_align => 'center',
	    control => ['page'],
	    values => {

		1 =>

	Bivio::UI::HTML::Widget::Grid->new({
	    pad => 5,
	    values => [
		[
		    Bivio::UI::HTML::Widget::Director->new({
			control => ['->unsafe_get', 'page_error'],
			values => {},
			cell_expand => 1,
			cell_align => 'center',
			undef_value => $blank_cell,
			default_value => Bivio::UI::HTML::Widget::Join->new({
			    values => [['page_error']],
			}),
		    }),
		],
		[
		    _field('Valuation Date',
			    Bivio::UI::HTML::Widget::Date->new({
				field => 'RealmInstrumentValuation.date_time',
			    })),
		],
		[
		    Bivio::UI::HTML::Widget::Submit->new({
			cell_expand => 1,
			cell_align => 'center',
			has_next => 1,
		    }),
		],
	    ],
	}),


		2 =>

	Bivio::UI::HTML::Widget::Grid->new({
	    pad => 5,
	    values => [
		[
		    Bivio::UI::HTML::Widget::Director->new({
			control => ['->unsafe_get', 'page_error'],
			values => {},
			cell_expand => 1,
			cell_align => 'center',
			undef_value => $blank_cell,
			default_value => Bivio::UI::HTML::Widget::Join->new({
			    values => [['page_error']],
			}),
		    }),
		],
		[
		    Bivio::UI::HTML::Widget::String->new({
			value => ['date', 'Bivio::UI::HTML::Format::Date'],
		    }),
		],
		[
		    _field('Valuation Date',
			    Bivio::UI::HTML::Widget::Date->new({
				field => 'RealmInstrumentValuation.date_time',
			    })),
		],
		[
		    Bivio::UI::HTML::Widget::Submit->new({
			cell_expand => 1,
			cell_align => 'center',
		    }),
		],
	    ],
	}),

	    },
	}),
    });

    $fields->{form}->initialize;
    return $self;
}

=head1 METHODS

=cut

=for html <a name="execute"></a>

=head2 execute(Bivio::Agent::Request req)

Loads the target member, processes any form errors and renders the page.

=cut

sub execute {
    my($self, $req) = @_;
    my($fields) = $self->{$_PACKAGE};

    my($form) = $req->get('form_model');
    my($page) = $form->get('page');
    if ($page == 2) {
	$req->put('date', $form->get('RealmInstrumentValuation.date_time'));
    }
    $req->put('page', $page);
    $req->put(page_heading => 'Investment Valuation ('.$page.'/2)',
	    page_subtopic => undef,
	    page_content => $fields->{form});

    if ($form->in_error) {
	my($errors) = $form->get_errors;

	if (! $errors->{page}) {
	    my(@errors);
	    foreach my $f (@$_FIELDS) {
		my($n) = $f->[0];
		next unless defined($errors->{$n});
		push(@errors, Bivio::Util::escape_html(
			$f->[1].': '.$errors->{$n}->get_long_desc));
	    }

	    my($p, $s) = Bivio::UI::Font->as_html('error');
	    $req->put(page_error =>
		    "<table border=0 cellpadding=5 cellspacing=0>\n<tr><td>"
		    .join("</td></tr>\n<tr><td><li>",
			    "${p}Please correct the following errors:$s",
			    @errors)
		    ."</td></tr></table>\n<hr>");
	}
    }
    Bivio::UI::HTML::Club::Page->execute($req);
    return;
}

#=PRIVATE METHODS

# _field(string caption, Widget widget) : (FormFieldLabel, Widget)
#
# Returns a (label, widget) pair for the specified caption and widget.
#
sub _field {
    my($caption, $widget) = @_;

    my($label) = Bivio::UI::HTML::Widget::FormFieldLabel->new({
	label => $caption,
	field => $widget->get('field'),
    });

    push(@$_FIELDS, [$label->get('field'), $caption]);
    return ($label, $widget);
}

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
