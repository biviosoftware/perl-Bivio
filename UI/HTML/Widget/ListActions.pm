# Copyright (c) 1999-2001 bivio Inc.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Widget::ListActions;
use strict;
$Bivio::UI::HTML::Widget::ListActions::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::UI::HTML::Widget::ListActions::VERSION;

=head1 NAME

Bivio::UI::HTML::Widget::ListActions - actions which appear in a list

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::UI::HTML::Widget::ListActions;
    Bivio::UI::HTML::Widget::ListActions->new();

=cut

=head1 EXTENDS

L<Bivio::UI::Widget>

=cut

use Bivio::UI::Widget;
@Bivio::UI::HTML::Widget::ListActions::ISA = ('Bivio::UI::Widget');

=head1 DESCRIPTION

C<Bivio::UI::HTML::Widget::ListActions>

=head1 ATTRIBUTES

=over 4

=item link_target : string [] (inherited)

The value to be passed to the C<TARGET> attribute of C<A> tag.

=item link_font : string [list_action]

Font to use for rendering links in the list.

=item values : array_ref (required)

An array_ref of array_refs where the order is the order of the
actions to appear.

The first element of sub-array_ref is the name of the action.
It may also be a widget.

The second element is the task name.

The third optional element of sub-array_ref is
either a
L<Bivio::Biz::QueryType|Bivio::Biz::QueryType>
(default value is C<THIS_DETAIL>)
or a widget value which produces a URI.

The fourth optional element is a control.  If the control returns
true, the action is rendered.

=back

=cut

#=IMPORTS
use Bivio::HTML;
use Bivio::Biz::QueryType;
use Bivio::UI::HTML::ViewShortcuts;

#=VARIABLES
my($_VS) = 'Bivio::UI::HTML::ViewShortcuts';

my($_IDI) = __PACKAGE__->instance_data_index;


=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(array_ref values, hash_ref attributes) : Bivio::UI::HTML::Widget::ListActions

=head2 static new() : Bivio::UI::HTML::Widget::ListActions

Creates a new ListActions widget.

=cut

sub new {
    my($self) = shift->SUPER::new(@_);
    $self->[$_IDI] = {};
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
    my($fields) = $self->[$_IDI];
    return if exists($fields->{values});
    $fields->{values} = [];
    my($target) = $_VS->vs_link_target_as_html($self);
    $fields->{font} = $self->get_or_default('link_font', 'list_action');
    foreach my $v (@{$self->get('values')}) {
	push(@{$fields->{values}}, {
	    prefix => '<a'.$target.' href="',
	    task_id => Bivio::Agent::TaskId->from_name($v->[1]),
	    label => _init_label($self, $v->[0], $fields->{font}),
	    ref($v->[2]) eq 'ARRAY' ? (format_uri => $v->[2])
	    : (method => Bivio::Biz::QueryType->from_any(
		    $v->[2] || 'THIS_DETAIL')),
	    control => $v->[3],
	});
    }
    return;
}

=for html <a name="internal_new_args"></a>

=head2 static internal_new_args() : 

Implements positional argument parsing for L<new|"new">.

=cut

sub internal_new_args {
    my(undef, $values, $attributes) = @_;
    return '"values" must be defined' unless defined($values);
    return {
	values => $values,
	($attributes ? %$attributes : ()),
    };
}

=for html <a name="render"></a>

=head2 render(any source, string_ref buffer)

Renders the list, skipping those tasks that are invalid.

=cut

sub render {
    my($self, $source, $buffer) = @_;
    my($fields) = $self->[$_IDI];
    my($values) = $fields->{values};
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
    my($p, $s) = Bivio::UI::Font->format_html($fields->{font}, $req);
    foreach my $v (@$info) {
	my($v2) = $v->{value};
	next if $v2->{control}
		&& !$source->get_widget_value(@{$v2->{control}});
	$$buffer .= $sep.$v2->{prefix}.
		($v2->{format_uri}
			? $source->get_widget_value(@{$v2->{format_uri}})
			: $source->format_uri($v2->{method}, $v->{uri}))
		.'">'.$p;
	ref($v2->{label}) ? $v2->{label}->render($source, $buffer)
		: ($$buffer .= $v2->{label});
	$$buffer .= $s."</a>";
	$sep = ",\n";
    }
    return;
}

#=PRIVATE METHODS

# _init_label(self, any label, any font) : any
#
# Returns the label value.  Initializing appropriately.
#
sub _init_label {
    my($self, $label, $font) = @_;
    $label = $_VS->vs_new('String', $label, $font, {hard_spaces => 1})
	unless UNIVERSAL::isa($label, 'Bivio::UI::Widget');
    return $label->put_and_initialize(parent => $self);
}

=head1 COPYRIGHT

Copyright (c) 1999-2001 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
