# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Setup::User;
use strict;
$Bivio::UI::HTML::Setup::User::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::HTML::Setup::User - 

=head1 SYNOPSIS

    use Bivio::UI::HTML::Setup::User;
    Bivio::UI::HTML::Setup::User->new();

=cut

=head1 EXTENDS

L<Bivio::UI::HTML::Widget>

=cut

use Bivio::UI::HTML::Widget;
@Bivio::UI::HTML::Setup::User::ISA = ('Bivio::UI::HTML::Widget');

=head1 DESCRIPTION

C<Bivio::UI::HTML::Setup::User>

=cut

#=IMPORTS
use Bivio::UI::HTML::Setup::Page;
use Bivio::UI::HTML::Widget::Form;
use Bivio::UI::HTML::Widget::FormFieldLabel;
use Bivio::UI::HTML::Widget::Grid;
use Bivio::UI::HTML::Widget::Text;
use Bivio::UI::HTML::Widget::Submit;
use Bivio::UI::HTML::Widget::Select;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

=for html <a name="new"></a>

=head2 static new() : Bivio::UI::HTML::Setup::User


=cut

sub new {
    my($self) = &Bivio::UI::HTML::Widget::new(@_);
    my($fields) = $self->{$_PACKAGE} = {};
    $fields->{form} = Bivio::UI::HTML::Widget::Form->new({
	form_model => ['Bivio::Biz::FormModel::User'],
	value => Bivio::UI::HTML::Widget::Grid->new({
	    pad => 5,
	    values => [
		[
		    Bivio::UI::HTML::Widget::FormFieldLabel->new({
			label => 'Name',
			field => 'RealmOwner.name',
		    }),
		    Bivio::UI::HTML::Widget::Text->new({
			field => 'RealmOwner.name',
			size => 20,
		    }),
		],
		[
		    Bivio::UI::HTML::Widget::FormFieldLabel->new({
			label => 'Password',
			field => 'RealmOwner.password',
		    }),
		    Bivio::UI::HTML::Widget::Text->new({
			field => 'RealmOwner.password',
			size => 20,
		    }),
		],
		[
		    Bivio::UI::HTML::Widget::FormFieldLabel->new({
			label => 'Confirm Password',
			field => 'confirm_password',
		    }),
		    Bivio::UI::HTML::Widget::Text->new({
			field => 'confirm_password',
			size => 20,
		    }),
		],
		[
		    Bivio::UI::HTML::Widget::FormFieldLabel->new({
			label => 'email',
			field => 'UserEmail.email',
		    }),
		    Bivio::UI::HTML::Widget::Text->new({
			field => 'UserEmail.email',
			size => 20,
		    }),
		],
		[
		    Bivio::UI::HTML::Widget::FormFieldLabel->new({
			label => 'First Name',
			field => 'User.first_name',
		    }),
		    Bivio::UI::HTML::Widget::Text->new({
			field => 'User.first_name',
			size => 20,
		    }),
		],
		[
		    Bivio::UI::HTML::Widget::FormFieldLabel->new({
			label => 'Middle Name',
			field => 'User.middle_name',
		    }),
		    Bivio::UI::HTML::Widget::Text->new({
			field => 'User.middle_name',
			size => 20,
		    }),
		],
		[
		    Bivio::UI::HTML::Widget::FormFieldLabel->new({
			label => 'Last Name',
			field => 'User.last_name',
		    }),
		    Bivio::UI::HTML::Widget::Text->new({
			field => 'User.last_name',
			size => 20,
		    }),
		],
		[
		    Bivio::UI::HTML::Widget::FormFieldLabel->new({
			label => 'Gender',
			field => 'User.gender',
		    }),
		    Bivio::UI::HTML::Widget::Select->new({
			field => 'User.gender',
			choices => 'Bivio::Type::Gender',
		    }),
		],
		[
		    Bivio::UI::HTML::Widget::Submit->new({
			cell_expand => 1,
			cell_align => 'center',
		    }),
		]
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
    $req->put(page_heading => 'Setup User',
	   page_content => $fields->{form});
    my($form) = $req->get('form_model');
    $req->put(page_error =>
	    'Please correct the highlighted fields and resubmit')
	    if $form->in_error;
    Bivio::UI::HTML::Setup::Page->execute($req);
    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
