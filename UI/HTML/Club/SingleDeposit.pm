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
use Bivio::Type::DepositType;
use Bivio::UI::Font;
use Bivio::UI::HTML::Club::Page;
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
			cols => 25,
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
	my($user_id) = $req->get('query')->{pk};

	my($realm_user) = Bivio::Biz::Model::RealmUser->new($req);
	$realm_user->load(user_id => $user_id);
#TODO: why User_2?
	my($user) = $realm_user->get_model('User_2');

	$req->put(page_heading => 'Member Deposit: '
		.$user->get('display_name'),
		page_subtopic => undef,
		page_content => $fields->{form});
	my($form) = $req->get('form_model');

	if ($form->in_error) {
	    my($errors) = $form->get_errors;

	    my(@errors);
#	    foreach my $f (@{$fields->{fields}}) {
#		my($n) = $f->[0];
#		next unless defined($errors->{$n});
#		push(@errors, Bivio::Util::escape_html(
#			$f->[1].': '.$errors->{$n}->get_long_desc));
#	    }
	    foreach my $k (keys(%$errors)) {
		push(@errors, Bivio::Util::escape_html(
			$errors->{$k}->get_long_desc));
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
    $req->die(Bivio::DieCode::NOT_FOUND);
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
