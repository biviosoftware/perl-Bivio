# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Club::InstrumentSell;
use strict;
$Bivio::UI::HTML::Club::InstrumentSell::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::HTML::Club::InstrumentSell - 

=head1 SYNOPSIS

    use Bivio::UI::HTML::Club::InstrumentSell;
    Bivio::UI::HTML::Club::InstrumentSell->new();

=cut

=head1 EXTENDS

L<Bivio::UI::HTML::Widget>

=cut

use Bivio::UI::HTML::Widget;
@Bivio::UI::HTML::Club::InstrumentSell::ISA = ('Bivio::UI::HTML::Widget');

=head1 DESCRIPTION

C<Bivio::UI::HTML::Club::InstrumentSell>

=cut

#=IMPORTS
use Bivio::Util;
use Bivio::Biz::Model::RealmInstrument;
use Bivio::UI::Font;
use Bivio::UI::HTML::Club::Page;
use Bivio::UI::HTML::Widget::Currency;
use Bivio::UI::HTML::Widget::Date;
use Bivio::UI::HTML::Widget::Director;
use Bivio::UI::HTML::Widget::Form;
use Bivio::UI::HTML::Widget::FormFieldLabel;
use Bivio::UI::HTML::Widget::Grid;
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
	form_model => ['Bivio::Biz::Model::InstrumentSellForm'],
	value => Bivio::UI::HTML::Widget::Grid->new({
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
		    _field('Date',
			    Bivio::UI::HTML::Widget::Date->new({
				field => 'RealmTransaction.dttm',
			    })),
		    Bivio::UI::HTML::Widget::String->new({
			value => '&nbsp;',
			escape_text => 0,
		    }),
		    _field('Account',
			    Bivio::UI::HTML::Widget::Select->new({
				field => 'RealmAccountEntry.realm_account_id',
			        choices =>
				'Bivio::Biz::Model::RealmValuationAccountList',
				list_display_field => 'RealmAccount.name',
			      list_id_field => 'RealmAccount.realm_account_id',
			    })),
		],
		[
		    Bivio::UI::HTML::Widget::String->new({
			value => '&nbsp;',
			escape_text => 0,
		    }),
		],
		[
		    _field('Price/Share',
			    Bivio::UI::HTML::Widget::Currency->new({
				field => 'Entry.amount',
				size => 10,
			    })),
		],
		[
		    _field('Commission',
			    Bivio::UI::HTML::Widget::Currency->new({
				field => 'commission',
				size => 10,
			    })),
		    Bivio::UI::HTML::Widget::String->new({
			value => '&nbsp;',
			escape_text => 0,
		    }),
		    _field('Service Fee',
			    Bivio::UI::HTML::Widget::Currency->new({
				field => 'admin_fee',
				size => 10,
			    })),
		],
		[
		    Bivio::UI::HTML::Widget::Join->new({
			cell_expand => 1,
			values => [
			    Bivio::UI::HTML::Widget::FormFieldLabel->new({
				label => 'Remark',
				field => 'RealmTransaction.remark',
			    }),
			    '<br>',
			    Bivio::UI::HTML::Widget::TextArea->new({
				cell_expand => 1,
				field => 'RealmTransaction.remark',
				rows => 3,
				cols => 40,
			    }),
			],
		    }),
		],
		[
		    Bivio::UI::HTML::Widget::Submit->new({
			cell_expand => 1,
			cell_align => 'center',
		    }),
		],
	    ],
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

    # make sure the member key is in the query
    if (defined($req->get('query')) && defined($req->get('query')->{pk})) {
	my($id) = $req->get('query')->{pk};

	my($realm_inst) = Bivio::Biz::Model::RealmInstrument->new($req);
	$realm_inst->load(realm_instrument_id => $id);

	$req->put(page_heading => 'Sell: '.$realm_inst
		->get_model('Instrument')->get('name'),
		page_subtopic => undef,
		page_content => $fields->{form});
	my($form) = $req->get('form_model');

	if ($form->in_error) {
	    my($errors) = $form->get_errors;

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
	Bivio::UI::HTML::Club::Page->execute($req);
	return;
    }
    $req->die(Bivio::DieCode::NOT_FOUND);
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
