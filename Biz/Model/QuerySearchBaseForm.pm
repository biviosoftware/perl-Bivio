# Copyright (c) 2003 bivio Software Artisans, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::QuerySearchBaseForm;
use strict;
$Bivio::Biz::Model::QuerySearchBaseForm::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Biz::Model::QuerySearchBaseForm::VERSION;

=head1 NAME

Bivio::Biz::Model::QuerySearchBaseForm - manages query and form values for searching.

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::Biz::Model::QuerySearchBaseForm;

=cut

=head1 EXTENDS

L<Bivio::Biz::FormModel>

=cut

use Bivio::Biz::FormModel;
@Bivio::Biz::Model::QuerySearchBaseForm::ISA = ('Bivio::Biz::FormModel');

=head1 DESCRIPTION

C<Bivio::Biz::Model::QuerySearchBaseForm>

=cut

#=IMPORTS

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="emit_query_values"></a>

=head2 emit_query_values() : 

Build query hash from form data.

=cut

sub emit_query_values {
    my($self) = @_;
    return
	{
	    map({
		my($v) = $self->unsafe_get($_);
		my($dv) = $self->get_field_info($_, 'default_value');
		my($t) = $self->get_field_info($_, 'type');
		if (defined($v)) {
		    $v = undef if $t->is_equal($dv, $v);
		}
		else {
		    $v = $dv;
		}
		defined($v) ? ($_ => $t->to_literal($v)) : ();
		# might want to check for type=FormButton instead
	    } grep({$_ ne 'ok_button'}
		@{$self->get_info('visible_field_names')})),
	};
}

=for html <a name="execute_empty"></a>

=head2 execute_empty()

Fills in the default values.

=cut

sub execute_empty {
    my($self) = @_;
    my($q) = $self->get_request->get('query');
    foreach my $x (@{$self->get_info('visible_field_names')}) {
	$self->load_query_value($q, $x);
    }
    return;
}

=for html <a name="execute_ok"></a>

=head2 execute_ok()

Sets the query.

=cut

sub execute_ok {
    my($self) = @_;
    my($req) = $self->get_request;
    # Redirect to this task with new query, but must got through
    # CLIENT_REDIRECT to avoid browser seeing redirect loop
    $req->client_redirect(
	Bivio::Agent::TaskId->CLIENT_REDIRECT,
	undef,
	{
	    Bivio::Biz::Action::ClientRedirect->QUERY_TAG =>
	        $req->format_uri($req->get('task_id'),
		    $self->emit_query_values(),
		),
	},
    );
    return;
}

=for html <a name="execute_other"></a>

=head2 execute_other() : 

Reset all form fields to their default value if the reset button was clicked.

=cut

sub execute_other {
    my($self, $button_field) = @_;
    my($req) = $self->get_request;

    if ($button_field eq 'reset_button') {
	$req->client_redirect(Bivio::Agent::TaskId->CLIENT_REDIRECT,
	    undef,
	    {
		Bivio::Biz::Action::ClientRedirect->QUERY_TAG =>
	            $req->format_uri($req->get('task_id'), {}),
	    },
	),
    }
    return $self->SUPER::execute_other($button_field);
}

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : 



=cut

sub internal_initialize {
    my($self) = @_;
    return $self->merge_initialize_info($self->SUPER::internal_initialize, {
	visible => [
	    {
		name => 'reset_button',
		type => 'FormButton',
		constraint => 'NONE',
	    },
	],
    });
}

=for html <a name="load_query_value"></a>

=head2 load_query_value() : 

Load query value into form model. Load the default value if no value is
present on the query. Can optionally specify a query alias for the field.

=cut

sub load_query_value {
    my($self, $query, $field, $alias) = @_;

    if (exists($query->{$alias||$field})) {
	my($v, $e) = $self->get_field_type($field)
	    ->from_literal($query->{$alias||$field});
	if ($e) {
	    $self->internal_put_error($field => $e);
	}
	else {
	    $self->internal_put_field($field => $v);
	}
    }
    elsif (!$alias) {
	$self->internal_put_field($field =>
	    $self->get_field_info($field, 'default_value'));
    }
    return;
}

#=PRIVATE SUBROUTINES

=head1 COPYRIGHT

Copyright (c) 2003 bivio Software Artisans, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
