# Copyright (c) 2003-2009 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::Biz::Model::QuerySearchBaseForm;
use strict;
use Bivio::Base 'Biz.FormModel';

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
my($_CR) = b_use('Action.ClientRedirect');

sub OMIT_DEFAULT_VALUES_FROM_QUERY {
    # Returns true if the query values are to be omitted if they match
    # the default_value. Subclasses may override this to change the behavior.
    return 1;
}

sub execute_empty {
    my($self) = @_;
    foreach my $field (@{_get_visible_fields($self)}) {
	_load_query_value($self, $field);
    }
    return;
}

sub execute_ok {
    my($self) = @_;
    return _redirect($self, {
        map({
            my($v) = $self->unsafe_get($_);
            my($t) = $self->get_field_info($_, 'type');
            my($dv) = $self->get_field_info($_, 'default_value');
	    my($name) = $self->get_field_info($_, 'form_name');
            !$self->OMIT_DEFAULT_VALUES_FROM_QUERY || !$t->is_equal($dv, $v)
	        ? ($name => $t->to_literal($v)) : ();
        } @{_get_visible_fields($self)}),
    });
}

sub execute_other {
    my($self) = shift;
    return _redirect($self)
        if $self->unsafe_get('reset_button');
    return $self->SUPER::execute_other(@_);
}

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

sub _get_visible_fields {
    my($self) = @_;
    return [
        grep(! ($self->get_field_info($_, 'type')
            && $self->get_field_info($_, 'type')
                ->isa('Bivio::Type::FormButton')),
            @{$self->get_info('visible_field_names')}),
    ];
}

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

sub _redirect {
    # CLIENT_REDIRECT to avoid browser seeing redirect loop.
    my($self, $query) = @_;
    my($req) = $self->req;
    return {
	method => 'client_redirect',
	task_id => 'CLIENT_REDIRECT',
	query => {
	    $_CR->QUERY_TAG => $req->format_uri(
		$req->get('task_id'), $query || {}),
	},
    };
}

1;
