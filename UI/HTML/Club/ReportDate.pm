# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Club::ReportDate;
use strict;
$Bivio::UI::HTML::Club::ReportDate::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::HTML::Club::ReportDate - a report date form

=head1 SYNOPSIS

    use Bivio::UI::HTML::Club::ReportDate;
    Bivio::UI::HTML::Club::ReportDate->new();

=cut

=head1 EXTENDS

L<Bivio::UI::HTML::Widget>

=cut

use Bivio::UI::HTML::Widget;
@Bivio::UI::HTML::Club::ReportDate::ISA = ('Bivio::UI::HTML::Widget');

=head1 DESCRIPTION

C<Bivio::UI::HTML::Club::ReportDate> provides a single date field for
selecting a report date. It works with Bivio::Biz::Model::ReportDateForm.

=cut

#=IMPORTS

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;
my($_FIELDS) = [];

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::UI::HTML::Club::ReportDate

Creates the report date form UI.

=cut

sub new {
    my($self) = &Bivio::UI::HTML::Widget::new(@_);
    my($fields) = $self->{$_PACKAGE} = {};
    my($blank_cell) = Bivio::UI::HTML::Widget::Join->new({
	values => ['&nbsp;']});
    $fields->{form} = Bivio::UI::HTML::Widget::Form->new({
	form_model => ['Bivio::Biz::Model::ReportDateForm'],
# note: needed a join, or the errors widen the form too much
	value => Bivio::UI::HTML::Widget::Join->new({
	    values => [
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
		Bivio::UI::HTML::Widget::Grid->new({
		    pad => 5,
		    values => [
		    [
		        _field('Report Date',
			    Bivio::UI::HTML::Widget::DateField->new({
				field => 'report_date',
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

    my($task_id) = $req->get('task_id');
    my($heading);
    $heading = 'Valuation Statement Parameters' if $task_id
  == Bivio::Agent::TaskId::CLUB_ACCOUNTING_REPORT_VALUATION_STATEMENT_PARAMS();
    $heading = 'Investment Summary Parameters' if $task_id
   == Bivio::Agent::TaskId::CLUB_ACCOUNTING_REPORT_INVESTMENT_SUMMARY_PARAMS();
    $heading = 'Member Summary Parameters' if $task_id
       == Bivio::Agent::TaskId::CLUB_ACCOUNTING_REPORT_MEMBER_SUMMARY_PARAMS();
    $heading = 'Cash Account Summary Parameters' if $task_id
 == Bivio::Agent::TaskId::CLUB_ACCOUNTING_REPORT_CASH_ACCOUNT_SUMMARY_PARAMS();
    die("unhandled task_id $task_id") unless defined($heading);

    $req->put(page_heading => $heading,
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
