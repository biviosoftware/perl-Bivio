# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::Model::ReportDateForm;
use strict;
$Bivio::Biz::Model::ReportDateForm::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Biz::Model::ReportDateForm - a single date field form

=head1 SYNOPSIS

    use Bivio::Biz::Model::ReportDateForm;
    Bivio::Biz::Model::ReportDateForm->new();

=cut

=head1 EXTENDS

L<Bivio::Biz::FormModel>

=cut

use Bivio::Biz::FormModel;
@Bivio::Biz::Model::ReportDateForm::ISA = ('Bivio::Biz::FormModel');

=head1 DESCRIPTION

C<Bivio::Biz::Model::ReportDateForm> is a form with a single date field
for selecting a report date.

=cut

#=IMPORTS
use Bivio::Util;
use Bivio::Type::Date;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;
my($_DATE_KEY) = 'date';

=for html <a name="new"></a>

=head2 static new(Bivio::Agent::Request req) : Bivio::Biz::Model::ReportDateForm

Creates a report date form.

=cut

sub new {
    my($self) = &Bivio::Biz::FormModel::new(@_);
    $self->{$_PACKAGE} = {};

    # default dttm to now
    $self->internal_get->{'report_date'} =
	    Bivio::UI::HTML::Format::Date->get_widget_value(
		    Bivio::Type::Date->now());

    return $self;
}

=head1 METHODS

=cut

=for html <a name="execute_input"></a>

=head2 execute_input()

Puts the valid date onto the request query.

=cut

sub execute_input {
    my($self) = @_;

    my($req) = $self->get_request();
    $req->put('query_string', $_DATE_KEY.'='
	    .Bivio::Util::escape_uri($self->get('report_date')));

    return;
}

=for html <a name="get_date"></a>

=head2 static get_date(Bivio::Agent::Request req) : string

Returns the date encoded on the request, or the current date if not
present.

=cut

sub get_date {
    my(undef, $req) = @_;
    my($date);
    my($query) = $req->get('query');
    $date = $query->{$_DATE_KEY} if defined($query);
    return $date || Bivio::Type::Date->now;
}

=for html <a name="internal_initialize"></a>

=head2 internal_initialize() : hash_ref;

B<FOR INTERNAL USE ONLY>

=cut

sub internal_initialize {
    return {
	version => 1,
	visible => [
	    {
		name => 'report_date',
		type => 'Bivio::Type::Date',
		constraint => Bivio::SQL::Constraint::NOT_NULL(),
	    },
	],
    };
}

=for html <a name="validate"></a>

=head2 validate()

Does nothing.

=cut

sub validate {
    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
