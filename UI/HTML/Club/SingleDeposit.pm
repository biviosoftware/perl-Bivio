# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Club::SingleDeposit;
use strict;
$Bivio::UI::HTML::Club::SingleDeposit::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::HTML::Club::SingleDeposit - a single member deposit form

=head1 SYNOPSIS

    use Bivio::UI::HTML::Club::SingleDeposit;
    Bivio::UI::HTML::Club::SingleDeposit->new();

=cut

=head1 EXTENDS

L<Bivio::UI::HTML::Widget>

=cut

use Bivio::UI::HTML::Widget;
@Bivio::UI::HTML::Club::SingleDeposit::ISA = ('Bivio::UI::HTML::Widget');

=head1 DESCRIPTION

C<Bivio::UI::HTML::Club::SingleDeposit>

=cut

#=IMPORTS
use Bivio::Biz::Model::RealmUser;
use Bivio::Biz::Model::RealmAccountList;
use Bivio::Biz::Model::RealmValuationAccountList;
use Bivio::Type::DepositType;
use Bivio::UI::Font;
use Bivio::UI::HTML::Club::Page;
use Bivio::UI::HTML::Widget::Currency;
use Bivio::UI::HTML::Widget::Date;
use Bivio::UI::HTML::Widget::Director;
use Bivio::UI::HTML::Widget::Form;
use Bivio::UI::HTML::Widget::FormFieldLabel;
use Bivio::UI::HTML::Widget::Grid;
use Bivio::UI::HTML::Widget::Join;
use Bivio::UI::HTML::Widget::Select;
use Bivio::UI::HTML::Widget::Submit;
use Bivio::UI::HTML::Widget::Text;
use Bivio::UI::HTML::Widget::TextArea;
use Bivio::Util;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;
my($_FIELDS) = [];


=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::UI::HTML::Club::SingleDeposit

Creates and arranges a member single deposit dialog.

=cut

sub new {
    my($self) = &Bivio::UI::HTML::Widget::new(@_);
    my($fields) = $self->{$_PACKAGE} = {};
    my($blank_cell) = Bivio::UI::HTML::Widget::Join->new({
	values => ['&nbsp;']});
    my($empty_cell) = Bivio::UI::HTML::Widget::String->new({
	value => ''});
    $fields->{form} = Bivio::UI::HTML::Widget::Form->new({
	form_model => ['Bivio::Biz::Model::SingleDepositForm'],
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
				field => 'RealmTransaction.date_time',
			    })),
		],
		[
		    Bivio::UI::HTML::Widget::Director->new({
			control => ['show_valuation_date'],
			values => {
			    1 => Bivio::UI::HTML::Widget::FormFieldLabel->new({
				label => 'Valuation Date',
				field => 'valuation_date_time',
			    }),
			    0 => $empty_cell,
			},
		    }),
		    Bivio::UI::HTML::Widget::Director->new({
			control => ['show_valuation_date'],
			values => {
			    1 => Bivio::UI::HTML::Widget::Date->new({
				field => 'valuation_date_time',
			    }),
			    0 => $empty_cell,
			},
		    }),
#		    _field('Valuation Date',
#			    Bivio::UI::HTML::Widget::Date->new({
#				field => 'valuation_date_time',
#			    })),
		],
		[
		    _field('Account',
			    Bivio::UI::HTML::Widget::Select->new({
				field => 'RealmAccountEntry.realm_account_id',
				choices => ['account_list'],
				list_display_field => 'RealmAccount.name',
			      list_id_field => 'RealmAccount.realm_account_id',
			    })),
		],
		[
		    _field('Amount',
			    Bivio::UI::HTML::Widget::Currency->new({
				field => 'Entry.amount',
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
				cols => 25,
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
    push(@$_FIELDS, ['valuation_date_time', 'Valuation Date']);
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

    # get the selected user and load them
    my($owner) = $req->get('Bivio::Biz::Model::RealmUser')
	    ->get_model('RealmOwner_2');

    my($task_id) = $req->get('task_id');
    my($heading, $account_list, $show_valuation_date);
    if ($task_id
	    == Bivio::Agent::TaskId::CLUB_ACCOUNTING_MEMBER_PAYMENT()) {
	$heading = 'Payment: ';
	$account_list = Bivio::Biz::Model::RealmAccountList->new($req);
	$show_valuation_date = 1;
    }
    elsif ($task_id
	    == Bivio::Agent::TaskId::CLUB_ACCOUNTING_MEMBER_FEE()) {
	$heading = 'Fee: ';
	$account_list = Bivio::Biz::Model::RealmValuationAccountList
		->new($req);
	$show_valuation_date = 0;
    }
    else {
	die("unhandled task_id $task_id");
    }
    $req->put(show_valuation_date => $show_valuation_date);
    $account_list->load();

    $req->put(page_heading => $heading.$owner->get('display_name'),
	    page_subtopic => undef,
	    page_content => $fields->{form},
	    account_list => $account_list,
	   );
    my($form) = $req->get('form_model');

    # error rendering
#TODO: Replace with ErrorPage
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
