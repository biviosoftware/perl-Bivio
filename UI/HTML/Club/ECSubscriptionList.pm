# Copyright (c) 2000 bivio Inc.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Club::ECSubscriptionList;
use strict;
$Bivio::UI::HTML::Club::ECSubscriptionList::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::UI::HTML::Club::ECSubscriptionList::VERSION;

=head1 NAME

Bivio::UI::HTML::Club::ECSubscriptionList - view subscriptions

=head1 SYNOPSIS

    use Bivio::UI::HTML::Club::ECSubscriptionList;

=cut

=head1 EXTENDS

L<Bivio::UI::HTML::Widget>

=cut

use Bivio::UI::HTML::Widget;
@Bivio::UI::HTML::Club::ECSubscriptionList::ISA = ('Bivio::UI::HTML::Widget');

=head1 DESCRIPTION

C<Bivio::UI::HTML::Club::ECSubscriptionList> displays subscriptions.

=cut

#=IMPORTS

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;
use vars qw($_TRACE);
Bivio::IO::Trace->register;


=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::UI::HTML::Club::ECSubscriptionList

Creates a new widget.

=cut

sub new {
    my($self) = Bivio::UI::HTML::Widget::new(@_);
    my($fields) = $self->{$_PACKAGE} = {};

    $fields->{page_heading} = $self->heading(
	    Bivio::UI::Label->get_simple('EC_SUBSCRIPTION_PAGE_HEADING'))
	    ->put_and_initialize(parent => $self);
    $fields->{action_bar} = $self->action_bar('club_post_message');
    $fields->{action_bar}->initialize;

#TODO: Just a temporary message!
    my($empty_message) = $self->join(<<'EOF');
No running subscriptions.
Subscribe to <A HREF="subscription/account-sync">AccountSync</A>
or <A HREF="subscription/account-keeper">AccountKeeper</A>!
EOF
    my($table) = Bivio::UI::HTML::Widget::Table->new({
        list_class => 'ECSubscriptionList',
	expand => 1,
        columns => [
            ['ECSubscription.subscription_type', {
                heading_align => 'LEFT',
            }],
            ['ECSubscription.start_date_time', {
                column_align => 'CENTER',
            }],
            ['ECSubscription.end_date', {
                column_align => 'CENTER',
            }],
            ['ECSubscription.renewal_method', {
                column_align => 'CENTER',
            }],
            ['ECSubscription.renewal_period', {
                column_align => 'CENTER',
            }],
        ],
        empty_list_widget => $empty_message,
    });
    my($table_admin) = Bivio::UI::HTML::Widget::Table->new({
        list_class => 'ECSubscriptionListForm',
        cellpadding => 2,
	expand => 1,
        columns => [
            {
                heading_align => 'LEFT',
                column_expand => 1,
                column_heading => 'ECSubscription.subscription_type',
                column_widget => $self->link([['->get_list_model'],
                    'ECSubscription.subscription_type', '->get_short_desc'],
                        [['->get_list_model'], '->format_uri', 'THIS_DETAIL']),
            },
            ['ECSubscription.start_date_time', {
                column_align => 'CENTER',
                column_widget => $self->date_time(
                        [['->get_list_model'], 'ECSubscription.start_date_time']),
            }],
            ['ECSubscription.end_date', {
                column_align => 'CENTER',
                column_widget => $self->date_time(
                        [['->get_list_model'], 'ECSubscription.end_date']),
            }],
            {
                column_align => 'CENTER',
                column_heading => 'ECSubscription.renewal_method',
                column_widget => $self->director([sub {
                    my($list) = shift->get_list_model;
                    return Bivio::Type::Date->compare(
                            $list->get('ECSubscription.end_date'),
                            Bivio::Type::Date->now) == 1 ? 1 : 0;
                }], {
                    0 => $self->string('EXPIRED'),
                    1 => Bivio::UI::HTML::Widget::Select->new({
                        field => 'ECSubscription.renewal_method',
                        choices => 'Bivio::Type::ECRenewalMethod',
                    }),
                }),
            },
            {
                column_align => 'CENTER',
                column_heading => 'ECSubscription.renewal_period',
                column_widget => $self->director([sub {
                    my($list) = shift->get_list_model;
                    return Bivio::Type::Date->compare(
                            $list->get('ECSubscription.end_date'),
                            Bivio::Type::Date->now) == 1 ? 1 : 0;
                }], {
                    0 => $self->string('EXPIRED'),
                    1 => Bivio::UI::HTML::Widget::Select->new({
                        field => 'ECSubscription.renewal_period',
                        choices => ['Bivio::Biz::Model::ECSubscriptionPriceList'],
                        list_id_field => 'period',
                        list_display_field => 'period_display',
                    }),
                }),
            },
            ['ECSUBSCRIPTION_ACTION', {
                column_nowrap => 1,
                column_widget => $self->director([
                    sub {
                        my($list) = shift->get_list_model;
                        return Bivio::Type::Date->compare(
                                $list->get('ECSubscription.end_date'),
                                Bivio::Type::Date->now) == 1 ? 1 : 0;
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
                                ['extend subscription',
                                         'CLUB_ADMIN_SUBSCRIPTION_PAYMENT',
                                         'THIS_DETAIL'],
                            ],
                        }),
                    }),
            }],
        ],
        empty_list_widget => $empty_message,
    });

    my($form) = $self->simple_form('ECSubscriptionListForm',
            $self->join($table_admin,
                    $self->indent($self->director(
                            ['Bivio::Biz::Model::ECSubscriptionList',
                                '->get_result_set_size'], {
                                    0 => $self->join(),
                                }, $self->form_button(
                                        'ECSubscriptionListForm.ok_button',
                                        'apply_changes_button')))
                   ));
    $fields->{content} = $self->director(
	    ['->has_keys', 'Bivio::Biz::Model::ECSubscriptionListForm'],
	    {
		0 => $table,
		1 => $form,
	    });
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

    my($list) = $req->get('Bivio::Biz::Model::ECSubscriptionList');
    $req->put(
	    page_subtopic =>
                Bivio::UI::Label->get_simple('EC_SUBSCRIPTION_PAGE_HEADING'),
	    page_title_value => $fields->{page_heading},
	    page_content => $fields->{content},
#	    page_action_bar => $fields->{action_bar},
	    page_type => Bivio::UI::PageType::LIST_ALL(),
	    list_model => $list,
	    list_uri => $req->format_stateless_uri($req->get('task_id')),
	    detail_uri => $req->format_stateless_uri(
		    Bivio::Agent::TaskId::CLUB_ADMIN_SUBSCRIPTION_DETAIL()),
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
