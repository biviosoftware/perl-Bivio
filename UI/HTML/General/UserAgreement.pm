# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::HTML::General::UserAgreement;
use strict;
$Bivio::UI::HTML::General::UserAgreement::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::HTML::General::UserAgreement - renders the user agreement

=head1 SYNOPSIS

    use Bivio::UI::HTML::General::UserAgreement;
    Bivio::UI::HTML::General::UserAgreement->new($attrs);

=cut

=head1 EXTENDS

L<Bivio::UI::HTML::Widget::Template>

=cut

use Bivio::UI::HTML::Widget::Template;
@Bivio::UI::HTML::General::UserAgreement::ISA = ('Bivio::UI::HTML::Widget::Template');

=head1 DESCRIPTION

C<Bivio::UI::HTML::General::UserAgreement> renders the user agreement
with an included form.

=cut

#=IMPORTS
use Bivio::UI::HTML::Widget::StandardSubmit;
use Bivio::UI::HTML::Widget::Form;

#=VARIABLES


=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::UI::HTML::General::UserAgreement

Creates and initializes this widget

=cut

sub new {
    my($self) = Bivio::UI::HTML::Widget::Template::new(@_);
    $self->put(
	uri => ['->format_stateless_uri',
	    Bivio::Agent::TaskId::USER_AGREEMENT_TEXT()],
	map => {
	    FORM => Bivio::UI::HTML::Widget::Form->new({
		form_model => ['Bivio::Biz::Model::UserAgreementForm'],
		value => Bivio::UI::HTML::Widget::StandardSubmit->new({
		    align => 'center',
		    separation => 100,
		}),
	    }),
	},
    );
    # This is the top level widget
    $self->initialize;
    return $self;
}

=head1 METHODS

=cut

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
