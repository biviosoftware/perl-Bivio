# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Club::SearchList;
use strict;
$Bivio::UI::HTML::Club::SearchList::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::HTML::Club::SearchList - view search results

=head1 SYNOPSIS

    use Bivio::UI::HTML::Club::SearchList;
    Bivio::UI::HTML::Club::SearchList->new();

=cut

=head1 EXTENDS

L<Bivio::UI::HTML::Widget>

=cut

use Bivio::UI::HTML::Widget;
@Bivio::UI::HTML::Club::SearchList::ISA = ('Bivio::UI::HTML::Widget');

=head1 DESCRIPTION

C<Bivio::UI::HTML::Club::SearchList> displays search results and
contains a form to make another query.

=cut


=head1 CONSTANTS

=cut

#=IMPORTS
use Bivio::UI::HTML::Widget::Table;
use Bivio::UI::HTML::Widget::Grid;
use Bivio::UI::HTML::Widget::Search;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;
use vars qw($_TRACE);
Bivio::IO::Trace->register;

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::UI::HTML::Club::SearchList

Creates a new widget.

=cut

sub new {
    my($self) = Bivio::UI::HTML::Widget::new(@_);
    my($fields) = $self->{$_PACKAGE} = {};

    my($empty_message) = $self->director(
            [[['list_model'], '->get_query'], '->has_keys', 'search'],
            {
                0 => $self->string('A'),
              #  1 => $self->string('B')
            },
            $self->string('Query found no documents.', 'page_text')
            );

    my($table) = Bivio::UI::HTML::Widget::Table->new({
        list_class => 'SearchList',
	expand => 1,
        columns => [
            ['score_percent', {
                column_align => 'RIGHT',
            }],
            ['description', {
                column_widget => $self->link(['description'], ['uri']),
                column_expand => 1,
                heading_align => 'SW',
                column_align => 'W',
            }],
            ['date_time', {
                column_widget => $self->date_time(['date_time'],
                        'DATE_TIME'),
                column_nowrap => 1,
            }],
            ['size', {
                column_widget => $self->string(['size',
                    'Bivio::UI::HTML::Format::Bytes']),
                column_align => 'RIGHT',
            }],
        ],
        empty_list_widget => $empty_message,
    });
    $fields->{action_bar} = Bivio::UI::HTML::Widget::ActionBar->new({
        values => [],
    });
    $fields->{action_bar}->initialize;

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

    my($list) = $req->get('Bivio::Biz::Model::SearchList');
    $req->put(
	    page_subtopic => Bivio::UI::Label->get_simple('SEARCH'),
	    page_title_value => 'Search',
	    page_action_bar => $fields->{action_bar},
	    page_content => $fields->{content},
	    page_type => Bivio::UI::PageType::LIST(),
	    list_model => $list,
	    list_uri => $req->format_stateless_uri($req->get('task_id')),
	   );
    return Bivio::UI::HTML::Page->execute($req);
}


#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
