# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Setup::User;
use strict;
$Bivio::UI::HTML::Setup::User::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::HTML::Setup::User - create a user

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

C<Bivio::UI::HTML::Setup::User> creates a User.

=cut

#=IMPORTS
use Bivio::UI::Font;
use Bivio::UI::HTML::Setup::Page;
use Bivio::UI::HTML::Widget::Form;
use Bivio::UI::HTML::Widget::FormFieldLabel;
use Bivio::UI::HTML::Widget::Grid;
use Bivio::UI::HTML::Widget::Select;
use Bivio::UI::HTML::Widget::Submit;
use Bivio::UI::HTML::Widget::Text;
use Bivio::Util;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

=for html <a name="new"></a>

=head2 static new() : Bivio::UI::HTML::Setup::User


=cut

sub new {
    my($self) = &Bivio::UI::HTML::Widget::new(@_);
    my($fields) = $self->{$_PACKAGE} = {};
    $fields->{fields} = [];
    my(@fields) = (
	    [
		_field($fields, 'RealmOwner.name', 'Login Name', 10),
		_field($fields, 'RealmOwner.password', 'Password', 10),
		_field($fields, 'confirm_password', 'Confirm', 10),
	    ],
	    [
		_field($fields, 'User.first_name', 'First Name', 10),
		_field($fields, 'User.middle_name', 'Middle', 8),
		_field($fields, 'User.last_name', 'Last', 15),
	    ],
	    [
		_field($fields, 'UserEmail.email', 'email', 40),
	    ],
	    [
		_field($fields, 'User.street1', 'Street1', 40),
	    ],
	    [
		_field($fields, 'User.street2', 'Street2', 40),
	    ],
	    [
		_field($fields, 'User.city', 'City', 15),
		_field($fields, 'User.state', 'State', 2),
		_field($fields, 'User.zip', 'Zip', 10),
		_field($fields, 'User.country', 'Country', 2),
	    ],
	    [
		_field($fields, 'User.phone', 'Phone', 15),
		_field($fields, 'User.fax', 'Fax', 15),
	    ],
	    [
		_field($fields, 'User.gender', 'Gender',
			Bivio::UI::HTML::Widget::Select->new({
			    field => 'User.gender',
			    choices => 'Bivio::Type::Gender',
			    cell_expand => 1,
			})),
		_field($fields, 'User.birth_date', 'Birth Date', 15),
	    ],
    );
    foreach my $f (@fields) {
	# Only one field, don't join.
	next if int(@$f) <= 2;
	# Put all but the label in the first field
	my(@rest) = splice(@$f, 1);
	my($values) = [];
	while (1) {
	    push(@$values, shift(@rest));
	    last unless @rest;
	    push(@$values, '&nbsp;' x 2, shift(@rest), '&nbsp;');
	}
	$f->[1] = Bivio::UI::HTML::Widget::Join->new({
	    cell_expand => 1,
	    cell_nowrap => 1,
	    values => $values,
	});
    };
    $fields->{form} = Bivio::UI::HTML::Widget::Form->new({
	form_model => ['Bivio::Biz::Model::UserForm'],
	value => Bivio::UI::HTML::Widget::Grid->new({
	    pad => 5,
	    values => [
		@fields,
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
    if ($form->in_error) {
	my($errors) = $form->get_errors;
	my(@errors);
	foreach my $f (@{$fields->{fields}}) {
	    my($n) = $f->[0];
	    next unless defined($errors->{$n});
	    push(@errors, Bivio::Util::escape_html(
		    $f->[1].': '.$errors->{$n}->get_long_desc));
	}
#TODO: Cache this
	my($p, $s) = Bivio::UI::Font->as_html('error');
	$req->put(page_error =>
		"<table border=0 cellpadding=5 cellspacing=0>\n<tr><td>"
		.join("</td></tr>\n<tr><td><li>",
			"${p}Please correct the following errors:$s",
			@errors)
		."</td></tr></table>\n");
    }
    Bivio::UI::HTML::Setup::Page->execute($req);
    return;
}

#=PRIVATE METHODS

# _field(hash_ref fields, string field, string label, any size_or_widget) : array
#
# Returns two widgets
#
sub _field {
    my($fields, $field, $label, $size_or_widget) = @_;
    unless (ref($size_or_widget)) {
	$size_or_widget = Bivio::UI::HTML::Widget::Text->new({
	    field => $field,
	    size => $size_or_widget,
	});
    }
    push(@{$fields->{fields}}, [$field, $label]);
    return (Bivio::UI::HTML::Widget::FormFieldLabel->new({
		label => $label,
		field => $field,
	    }),
	    $size_or_widget,
	   );
}

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
