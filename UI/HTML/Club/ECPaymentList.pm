# Copyright (c) 2000 bivio Inc.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Club::ECPaymentList;
use strict;
$Bivio::UI::HTML::Club::ECPaymentList::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::UI::HTML::Club::ECPaymentList::VERSION;

=head1 NAME

Bivio::UI::HTML::Club::ECPaymentList - view payments

=head1 SYNOPSIS

    use Bivio::UI::HTML::Club::ECPaymentList;

=cut

=head1 EXTENDS

L<Bivio::UI::HTML::Widget>

=cut

use Bivio::UI::HTML::Widget;
@Bivio::UI::HTML::Club::ECPaymentList::ISA = ('Bivio::UI::HTML::Widget');

=head1 DESCRIPTION

C<Bivio::UI::HTML::Club::ECPaymentList> displays payments made.

=cut

#=IMPORTS

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;
use vars qw($_TRACE);
Bivio::IO::Trace->register;


=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::UI::HTML::Club::ECPaymentList

Creates a new widget.

=cut

sub new {
    my($self) = Bivio::UI::HTML::Widget::new(@_);
    my($fields) = $self->{$_PACKAGE} = {};

    $fields->{page_heading} = $self->heading(
	    Bivio::UI::Label->get_simple('EC_PAYMENT_PAGE_HEADING'))
	    ->put_and_initialize(parent => $self);
    $fields->{action_bar} = $self->action_bar;
    $fields->{action_bar}->initialize;

    my($empty_message) = $self->string('No payments.',
            'page_text');
    my($table) = Bivio::UI::HTML::Widget::Table->new({
        list_class => 'ECPaymentList',
	expand => 1,
        columns => [
            ['ECPayment.creation_date_time', {
                column_align => 'LEFT',
            }],
            ['RealmOwner.name', {
                column_heading => 'ECPayment.user',
                column_align => 'CENTER',
            }],
            ['ECPayment.payment_type', {
                column_align => 'CENTER',
                column_widget => $self->director([
                    sub {
                        my($list) = shift->get_list_model;
                        return defined($list->get('ECPayment.ec_subscription_id'));
                    }], {
#TODO: Want to display subscription name, eg. "AccountSync"
                        1 => $self->load_and_new('Enum', {
                            field => 'ECPayment.payment_type',
                        }),
                    }, $self->load_and_new('Enum', {
                        field => 'ECPayment.payment_type',
                    }),
                       ),
            }],
            ['ECPayment.status', {
                column_align => 'CENTER',
            }],
            ['ECPayment.amount', {
            }],
            ['ECPayment.method', {
                column_align => 'CENTER',
            }],
            ['ECPAYMENT_ACTION', {
                column_nowrap => 1,
                column_widget => $self->director([
                    sub {
                        my($list) = shift->get_list_model;
                        return 1;
                    }], {
                        0 => Bivio::UI::HTML::Widget::ListActions->new({
                            values => [
                                ['renew subscription',
                                         'CLUB_ADMIN_SUBSCRIPTION_PAYMENT',
                                         'THIS_DETAIL'],
                            ],
                        }),
                        1 => Bivio::UI::HTML::Widget::ListActions->new({
                            values => [
                                ['view detail',
                                         'CLUB_ADMIN_PAYMENT_DETAIL',
                                         'THIS_DETAIL'],
                            ],
                        }),
                    }),
            }],
        ],
        empty_list_widget => $empty_message,
    });
    $fields->{content} = $table;
    $fields->{content}->initialize;
    return $self;
}

=head1 METHODS

=cut

=for html <a name="execute"></a>

=head2 execute(Bivio::Agent::Request req) : boolean

Called before rendering, add dynamic information

=cut

sub execute {
    my($self, $req) = @_;
    my($fields) = $self->{$_PACKAGE};

    my($list) = $req->get('Bivio::Biz::Model::ECPaymentList');
    $req->put(
	    page_subtopic =>
                Bivio::UI::Label->get_simple('EC_PAYMENT_PAGE_HEADING'),
	    page_title_value => $fields->{page_heading},
	    page_content => $fields->{content},
	    page_action_bar => $fields->{action_bar},
	    page_type => Bivio::UI::PageType::LIST(),
	    list_model => $list,
	    list_uri => $req->format_stateless_uri($req->get('task_id')),
	    detail_uri => $req->format_stateless_uri(
		    Bivio::Agent::TaskId::CLUB_ADMIN_PAYMENT_DETAIL()),
	   );
    return Bivio::UI::HTML::Page->execute($req);
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2000 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
