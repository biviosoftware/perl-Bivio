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
use Bivio::Type::DepositType;
use Bivio::UI::Font;
use Bivio::UI::HTML::Setup::Page;
use Bivio::UI::HTML::Widget::Form;
use Bivio::UI::HTML::Widget::FormFieldLabel;
use Bivio::UI::HTML::Widget::Grid;
use Bivio::UI::HTML::Widget::Select;
use Bivio::UI::HTML::Widget::Submit;
use Bivio::UI::HTML::Widget::Text;
use Bivio::UI::HTML::Widget::TextArea;
use Bivio::Util;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;


=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::UI::HTML::Club::SingleDeposit



=cut

sub new {
    my($self) = &Bivio::UI::HTML::Widget::new(@_);
    my($fields) = $self->{$_PACKAGE} = {};
    $fields->{form} = Bivio::UI::HTML::Widget::Form->new({
	form_model => ['Bivio::Biz::Model::SingleDepositForm'],
	value => Bivio::UI::HTML::Widget::Grid->new({
	    pad => 5,
	    values => [
		[
		    Bivio::UI::HTML::Widget::FormFieldLabel->new({
			label => 'Date',
			field => 'RealmTransaction.dttm',
		    }),
		    Bivio::UI::HTML::Widget::Text->new({
			field => 'RealmTransaction.dttm',
			size => 10,
		    }),
		],
		[
		    Bivio::UI::HTML::Widget::FormFieldLabel->new({
			label => 'Type',
			field => 'Entry.entry_type',
		    }),
		    Bivio::UI::HTML::Widget::Select->new({
			field => 'Entry.entry_type',
			choices => 'Bivio::Type::DepositType',
		    }),
		],
		[
		    Bivio::UI::HTML::Widget::FormFieldLabel->new({
			label => 'Amount',
			field => 'Entry.amount',
		    }),
		    Bivio::UI::HTML::Widget::Text->new({
			field => 'Entry.amount',
			size => 10,
		    }),
		],
		[
		    Bivio::UI::HTML::Widget::FormFieldLabel->new({
			label => 'Remark',
			field => 'RealmTransaction.remark',
		    }),
		],
		[
		    Bivio::UI::HTML::Widget::TextArea->new({
			cell_expand => 1,
			field => 'RealmTransaction.remark',
			rows => 3,
			cols => 20,
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



=cut

sub execute {
    my($self, $req) = @_;
    my($fields) = $self->{$_PACKAGE};
    $req->put(page_heading => 'Member Deposit',
	    page_subtopic => undef,
	   page_content => $fields->{form});
    my($form) = $req->get('form_model');
    if ($form->in_error) {
	my($errors) = $form->get_errors;
	my(@errors);
	foreach my $f (@{$fields->{fields}}) {
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
		."</td></tr></table>\n");
    }
    Bivio::UI::HTML::Club::Page->execute($req);
    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
