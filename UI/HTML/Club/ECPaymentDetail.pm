# Copyright (c) 2000 bivio Inc.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Club::ECPaymentDetail;
use strict;
$Bivio::UI::HTML::Club::ECPaymentDetail::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::UI::HTML::Club::ECPaymentDetail::VERSION;

=head1 NAME

Bivio::UI::HTML::Club::ECPaymentDetail - show payment details

=head1 SYNOPSIS

    use Bivio::UI::HTML::Club::ECPaymentDetail;

=cut

=head1 EXTENDS

L<Bivio::UI::HTML::Widget>

=cut

use Bivio::UI::HTML::Widget;
@Bivio::UI::HTML::Club::ECPaymentDetail::ISA = ('Bivio::UI::HTML::Widget');

=head1 DESCRIPTION

C<Bivio::UI::HTML::Club::ECPaymentDetail> shows payment details.

TODO: Want to allow modification of credit card info iff state
      is FAILED.

=cut

#=IMPORTS

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;
use vars qw($_TRACE);
Bivio::IO::Trace->register;

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::UI::HTML::Club::ECPaymentDetail



=cut

sub new {
    my($self) = Bivio::UI::HTML::Widget::new(@_);
    my($fields) = $self->{$_PACKAGE} = {};

    $fields->{content} = $self->join([
        Bivio::UI::HTML::Widget::Grid->new({
            values => [
                [
                    $self->string('Payment entered on: '),
                    $self->date_time(['Bivio::Biz::Model::ECPayment',
                        'creation_date_time']),
                ], [
                    $self->string('Payment status: '),
                    $self->string(['Bivio::Biz::Model::ECPayment',
                        'status', '->get_short_desc']),
                ], [
                    $self->string('Payment remark: '),
                    $self->string(['Bivio::Biz::Model::ECPayment',
                        'remark']),
                ],
            ]
        }),
    ]);
    $fields->{content}->initialize;
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

    $req->put(
	    page_subtopic => 'Payment Details',
	    page_title_value => 'Payment Details',
	    page_content => $fields->{content},
	  #  page_action_bar => $fields->{action_bar},
	    page_type => Bivio::UI::PageType::DETAIL(),
	    );
    return Bivio::UI::HTML::Club::Page->execute($req);
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2000 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
