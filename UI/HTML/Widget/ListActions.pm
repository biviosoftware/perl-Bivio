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

=item values : array_ref (required)

An array_ref of array_refs where the order is the order of the
actions to appear and the first element of sub-array_ref is the
name of the action and the second element is the task name.
The third optional element of sub-array_ref is the method name.
By default, this is C<format_uri_for_this>.

Links will be rendered in the ListAction font.

=back

=cut

#=IMPORTS

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
    my($p, $s) = Bivio::UI::Font->as_html('list_action');
    $fields->{values} = [];
    foreach my $v (@{$self->get('values')}) {
	push(@{$fields->{values}}, {
	    prefix => '<a href="',
	    task_id => Bivio::Agent::TaskId->from_name($v->[1]),
	    suffix => '">'.$p.Bivio::Util::escape_html($v->[0]).$s."</a>\n",
	    method => $v->[2] || 'format_uri_for_this',
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
		uri => $req->format_stateless_uri($v->{task_id})
	    });
	}

	# Only compute once
	$req->put($self => $info);
    }

    # Write executable actions
    foreach my $v (@$info) {
	my($v2) = $v->{value};
	my($m) = $v2->{method};
	$$buffer .= $v2->{prefix}.$source->$m($v->{uri}).$v2->{suffix};
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
