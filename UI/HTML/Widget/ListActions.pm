# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Widget::ListActions;
use strict;
$Bivio::UI::HTML::Widget::ListActions::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::HTML::Widget::ListActions - actions which appear in a list

=head1 SYNOPSIS

    use Bivio::UI::HTML::Widget::ListActions;
    Bivio::UI::HTML::Widget::ListActions->new();

=cut

=head1 EXTENDS

L<Bivio::UI::HTML::Widget>

=cut

use Bivio::UI::HTML::Widget;
@Bivio::UI::HTML::Widget::ListActions::ISA = ('Bivio::UI::HTML::Widget');

=head1 DESCRIPTION

C<Bivio::UI::HTML::Widget::ListActions>

=head1 ATTRIBUTES

=over 4

=item link_target : string [] (inherited)

The value to be passed to the C<TARGET> attribute of C<A> tag.

=item values : array_ref (required)

An array_ref of array_refs where the order is the order of the
actions to appear.

The first element of sub-array_ref is the name of the action.

The second element is the task name.

The third optional element of sub-array_ref is
either a
L<Bivio::Biz::QueryType|Bivio::Biz::QueryType>
(default value is C<THIS_DETAIL>)
or a widget value which produces a URI.

The fourth optional element is a control.  If the control returns
true, the action is rendered.

Links will be rendered in the C<list_action> font.

=back

=cut

#=IMPORTS
use Bivio::HTML;
use Bivio::Biz::QueryType;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;


=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::UI::HTML::Widget::ListActions

Creates a new ListActions widget.

=cut

sub new {
    my($self) = Bivio::UI::HTML::Widget::new(@_);
    $self->{$_PACKAGE} = {};
    return $self;
}

=head1 METHODS

=cut

=for html <a name="initialize"></a>

=head2 initialize()

Initializes "values" in field.

=cut

sub initialize {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    return if exists($fields->{values});
    $fields->{values} = [];
    my($target) = $self->link_target_as_html;
    foreach my $v (@{$self->get('values')}) {
	push(@{$fields->{values}}, {
	    prefix => '<a'.$target.' href="',
	    task_id => Bivio::Agent::TaskId->from_name($v->[1]),
	    label => Bivio::HTML->escape($v->[0]),
	    ref($v->[2]) eq 'ARRAY' ? (format_uri => $v->[2])
	    : (method => Bivio::Biz::QueryType->from_any(
		    $v->[2] || 'THIS_DETAIL')),
	    control => $v->[3],
	});
    }
    return;
}

=for html <a name="render"></a>

=head2 render(any source, string_ref buffer)

Renders the list, skipping those tasks that are invalid.

=cut

sub render {
    my($self, $source, $buffer) = @_;
    my($values) = $self->{$_PACKAGE}->{values};
    my($req) = $source->get_request;

    # Have we already cached information?
    my($info) = $req->unsafe_get($self);
    unless ($info) {
	$info = [];
	# Check each of the actions for execute privs and if so push on $info
	foreach my $v (@$values) {
	    next unless $req->task_ok($v->{task_id});
	    push (@$info, {
		value => $v,
		$v->{method}
		? (uri => $req->format_stateless_uri($v->{task_id}))
		: (),
	    });
	}

	# Only compute once
	$req->put($self => $info);
    }

    # Write executable actions
    my($sep) = '';
    my($p, $s) = Bivio::UI::Font->format_html('list_action', $req);
    foreach my $v (@$info) {
	my($v2) = $v->{value};
	next if $v2->{control}
		&& !$source->get_widget_value(@{$v2->{control}});
	$$buffer .= $sep.$v2->{prefix}.
		Bivio::HTML->escape($v2->{format_uri}
			? $source->get_widget_value(@{$v2->{format_uri}})
			: $source->format_uri($v2->{method}, $v->{uri}))
		.'">'.$p.$v2->{label}.$s."</a>";
	$sep = ",\n";
    }
    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
