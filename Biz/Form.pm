# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::Biz::Form;
use strict;
$Bivio::Biz::Form::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::Biz::Form - validates values and contains values, types, and errors

=head1 SYNOPSIS

    use Bivio::Biz::Form;
    Bivio::Biz::Form->new();
    Bivio::Biz::Form->execute($req);

=cut

=head1 EXTENDS

L<Bivio::Collection::Attributes>

=cut

use Bivio::Collection::Attributes;
@Bivio::Biz::Form::ISA = qw(Bivio::Collection::Attributes);

=head1 DESCRIPTION

C<Bivio::Biz::Form> is a container for form values, types, and
errors.  A C<Form> performs validation via its L<execute|"execute">
method.  A Form acts like an L<Bivio::Biz::Action|Bivio::Biz::Action>,
but does not use the database.  All validation is performed locally.

A Form's values come from a L<Bivio::Agent::Request|Bivio::Agent::Request>.

NOTES:

forms are rendered as hidden fields.  Need to be able to
enumerate all old values if the form is a "continuation".
Probably don't need to go through the form, just render
request->get('form') as hidden fields (password is plain text, ugh).

=cut

=head1 CONSTANTS

=cut

#=IMPORTS
use Bivio::IO::Config;
use Bivio::IO::Trace;

#=VARIABLES
use vars qw($_TRACE);
Bivio::IO::Trace->register;
my($_PACKAGE) = __PACKAGE__;
#Bivio::IO::Config->register;

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::Biz::Form



=cut

sub new {
    my($self) = &Bivio::Collection::Attributes::new(@_);
    $self->{$_PACKAGE} = {};
    return $self;
}

=head1 METHODS

=cut

=for html <a name="execute"></a>

=head2 execute() : 



=cut

sub execute {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    inserts forms into request with name ...Form::CreateUser.1
	    if the name is "CreateUser.1"
    Form searchs for all form values with /Name(.\d+)./;
    Special fields are marked with _, e.g. _taskid.
    Some of this can be handled by super class?
    Certainly checking each field.
    Form has to say whether field is required or not.
    get_field_is_required
    get_field_type
    get
    unsafe_get (foo._error) ??  Then errors are not
    special for View and widget renders errors.
	    get('CreateUser.1.foo._error') this tag is created
$req->put_instance($form or whatever, $num)
How do you know the forms are in the correct
order?  Well, can know the 
Form gets a value, then builds out request.
Form can fill itself in if there are no values
by going to database.  This may be necessary
in some cases.  execute for this type of form
must check request.
	    get('User.foo

e		    by widget
    For example, we might have a FormLabel which turns
	red if foo._error is non-null.
    Might have FormError which gets the error
	which is an enum and renders it appropriately.
    We probably need to strip off CreateUser.1. off even though
	it doesn't exist.
    Ok, so a form can be added.
    return;
}

#
#=for html <a name="handle_config"></a>
#
#=head2 static handle_config(hash cfg)
#
#=over 4
#
#=item name : type [default]
#
#=back
#
#=cut
#
#sub handle_config {
#    my(undef, $cfg) = @_;
#    return;
#}
#
#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
