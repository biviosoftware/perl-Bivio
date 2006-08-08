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

=head1 CONSTANTS

=cut

=for html <a name="OMIT_DEFAULT_VALUES_FROM_QUERY"></a>

=head2 OMIT_DEFAULT_VALUES_FROM_QUERY : boolean

Returns true if the query values are to be omitted if they match
the default_value. Subclasses may override this to change the behavior.

=cut

sub OMIT_DEFAULT_VALUES_FROM_QUERY {
    return 1;
}

#=IMPORTS

#=VARIABLES

=head1 METHODS

=cut

=for html <a name="execute_empty"></a>

=head2 execute_empty()

Fills in the default values.

=cut

sub execute_empty {
    my($self) = @_;

    foreach my $field (@{_get_visible_fields($self)}) {
	_load_query_value($self, $field);
    }
    return;
}

=for html <a name="execute_ok"></a>

=head2 execute_ok()

Sets the query.

=cut

sub execute_ok {
    my($self) = @_;
    # Build query hash from form data.
    _redirect($self, {
        map({
            my($v) = $self->unsafe_get($_);
            my($t) = $self->get_field_info($_, 'type');
            my($dv) = $self->get_field_info($_, 'default_value');
	    my($name) = $self->get_field_info($_, 'form_name');
            $self->OMIT_DEFAULT_VALUES_FROM_QUERY
                ? ($t->is_equal($dv, $v) ? () : ($name => $t->to_literal($v)))
                : ($name => $t->to_literal($v));
        } @{_get_visible_fields($self)}),
    });
    return;
}

=for html <a name="execute_other"></a>

=head2 execute_other()

Reset all form fields to their default value if the reset button was clicked.

=cut

sub execute_other {
    my($self, $button_field) = @_;
    _redirect($self)
        if $button_field eq 'reset_button';
    return $self->SUPER::execute_other($button_field);
}

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : hash_ref

B<FOR INTERNAL USE ONLY>

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

=for html <a name="internal_pre_execute"></a>

=head2 internal_pre_execute()

Load the default value of any fields that were not present on the form.

=cut

sub internal_pre_execute {
    my($self) = @_;
    return unless $self->get_request->unsafe_get('form')
	&& $self->equals($self->get_request->get('form'));

    foreach my $field (@{_get_visible_fields($self)}) {
        next if defined($self->unsafe_get($field));
        next if $self->get_field_error($field);
        $self->internal_put_field($field =>
            $self->get_field_info($field, 'default_value'));
    }
    return;
}

#=PRIVATE SUBROUTINES

# _get_visible_fields(self) : array_ref
#
# Returns the visible non-button form field names.
#
sub _get_visible_fields {
    my($self) = @_;
    return [
        grep(! ($self->get_field_info($_, 'type')
            && $self->get_field_info($_, 'type')
                ->isa('Bivio::Type::FormButton')),
            @{$self->get_info('visible_field_names')}),
    ];
}

# _load_query_value(self, string field)
#
# Load query value into form model.  Load the default value if no value is
# present on the query.
#
sub _load_query_value {
    my($self, $field) = @_;
    my($query) = $self->get_request->get('query');
    my($v, $e);

    my($value) = $query->{$self->get_field_info($field, 'form_name')};
    if (defined($value)) {
	($v, $e) = $self->get_field_type($field)->from_literal($value);
	if ($e) {
	    $self->internal_put_error($field => $e);
	    return;
	}
    }
    else {
	$v = $self->get_field_info($field, 'default_value');
    }
    $self->internal_put_field($field => $v);
    return;
}

# _redirect(self)
#
# _redirect(self, hash_ref query)
#
# Redirect to this task with new query, but must got through
# CLIENT_REDIRECT to avoid browser seeing redirect loop.
#
sub _redirect {
    my($self, $query) = @_;
    my($req) = $self->get_request;
    $req->client_redirect(Bivio::Agent::TaskId->CLIENT_REDIRECT, undef, {
        Bivio::Biz::Action::ClientRedirect->QUERY_TAG =>
            $req->format_uri($req->get('task_id'), $query || {}),
    });
    return;
}

=head1 COPYRIGHT

Copyright (c) 2003 bivio Software Artisans, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
