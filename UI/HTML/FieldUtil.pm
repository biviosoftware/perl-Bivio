# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::HTML::FieldUtil;
use strict;
$Bivio::UI::HTML::FieldUtil::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::HTML::FieldUtil - utility class for model field rendering

=head1 SYNOPSIS

    use Bivio::UI::HTML::FieldUtil;
    my($req) = Bivio::Agent::TestRequest->new('club');
    my($type) = Bivio::Biz::FieldDescriptor->lookup('NUMBER', 16)],
    Bivio::UI::HTML::FieldUtil->get_renderer($type)->render('123', $req);

=cut

use Bivio::UNIVERSAL;
@Bivio::UI::HTML::FieldUtil::ISA = qw(Bivio::UNIVERSAL);

=head1 DESCRIPTION

C<Bivio::UI::HTML::FieldUtil> contains utility methods for looking up
field renderers and form entry field rendering.

=cut

#=IMPORTS
use Bivio::Biz::FieldDescriptor;
use Bivio::IO::Trace;
use Bivio::UI::DateRenderer;
use Bivio::UI::StringRenderer;
use Bivio::UI::HTML::EmailRefRenderer;

#=VARIABLES
use vars qw($_TRACE);
Bivio::IO::Trace->register;
my($_PACKAGE) = __PACKAGE__;
my($_RENDERER_CACHE);
my($_DEFAULT_RENDERER) = Bivio::UI::StringRenderer->new();

=head1 METHODS

=cut

=for html <a name="entry_field"></a>

=head2 static entry_field(PropertyModel model, string field, Request req, boolean required)

=head2 static entry_field(PropertyModel model, string field, Request req)

Draws the specified input field onto the request in a two column row
of a table. The table should be rendered before calling this method.

=cut

sub entry_field {
    my(undef, $model, $field, $req, $required) = @_;
    my($reply) = $req->get_reply();

#TODO: Probably don't want to call reply->print for each of these.
#      instead build up the string and then call reply->print.
    $reply->print('<tr><td>');
    $reply->print('*&nbsp;') if $required;
    my($fd) = $model->get_field_descriptor($field);

    # Get the current value from the model
    my($value) = $model->get($field);

    if ($fd->get_type() == Bivio::Biz::FieldDescriptor::STRING
	    || $fd->get_type() == Bivio::Biz::FieldDescriptor::CURRENCY
	    || $fd->get_type() == Bivio::Biz::FieldDescriptor::NUMBER
	    || $fd->get_type() == Bivio::Biz::FieldDescriptor::DATE
	    || $fd->get_type() == Bivio::Biz::FieldDescriptor::EMAIL) {
#TODO: Need to put in label here
	$reply->print('<label for="'.$field.'">'
		.'NEED LABEL: '.$field.': </label></td><td>');
	$reply->print('<input type="text" name="'.$field
		.'" maxlength='.$fd->get_size());

	if (defined($value)) {
	    $reply->print(' value="'.$value.'"');
	}
	if ($fd->get_size() < 15) {
	    $reply->print(' size='.$fd->get_size());
	}
	elsif ($fd->get_size() > 40) {
	    # 40 is pretty big for an entry field
	    $reply->print(' size=40');
	}
	$reply->print('>');
    }
    elsif ($fd->get_type() == Bivio::Biz::FieldDescriptor::BOOLEAN) {
	$reply->print('<input type="checkbox" name="'.$field.'"');
#TODO: Is this correct or should there be a test for defined($value)?
	if ($value) {
	    $reply->print(' checked');
	}
	$reply->print('>');
    }
    elsif ($fd->get_type() == Bivio::Biz::FieldDescriptor::GENDER) {
	$reply->print('<input type="radio" name="'.$field
		.'" value="M"');
	if (defined($value) && $value eq "M") {
	    $reply->print(' checked');
	}
	$reply->print('> Male <br><input type="radio" name="'
		.$field.'" value="F"');
	if (defined($value) && $value eq "F") {
	    $reply->print(' checked');
	}
	$reply->print('> Female <br>');
    }
    elsif ($fd->get_type() == Bivio::Biz::FieldDescriptor::PASSWORD) {
	$reply->print('<label for="password">Password: </label></td><td>'
		.'<input type="password" name="password" maxlength=32');
	if (defined($value)) {
	    $reply->print(' value="'.$value.'"');
	}
	$reply->print('><br></td></tr><tr><td>');
	$reply->print('*&nbsp;') if $required;
	$reply->print('<label for="confirm_password">Confirm password: </label>'
		.'</td><td><input type="password" name="confirm_password"'
		.' maxlength=32');
	if ($value) {
	    $reply->print(' value="'.$value.'"');
	}
	$reply->print('><br></td></tr>');
    }
    elsif ($fd->get_type() == Bivio::Biz::FieldDescriptor::ROLE) {
	my($role);
#TODO: Encapsulate valid values so can validate input as well.
#      Must be clear definition of what a form allows and doesn't or
#      we'll have security problems.
	foreach $role (qw(ADMINISTRATOR MEMBER GUEST)) {
	    my($r) = Bivio::Auth::Role->$role();
	    my($i, $n) = ($r->as_int, ucfirst(lc($r->get_name)));
	    my($checked) = defined($value) && $value == $i ? ' checked' : '';
	    $reply->print(<<"EOF");
<input type="radio" name="$field" value=$i$checked>&nbsp;$n<br>
EOF
	}
    }
    $reply->print('</td></tr>');
    return;
}

=for html <a name="get_renderer"></a>

=head2 static get_renderer(FieldDescriptor descriptor) : Renderer

Looks up and returns an appropriate field renderer for the specified data
type.

=cut

sub get_renderer {
    my(undef, $descriptor) = @_;

    # lazy instantiation of renderer cache
    if (! $_RENDERER_CACHE) {
	$_RENDERER_CACHE = {
	    Bivio::Biz::FieldDescriptor::DATE(),
	        Bivio::UI::DateRenderer->new(),
	    Bivio::Biz::FieldDescriptor::EMAIL_REF(),
	        Bivio::UI::HTML::EmailRefRenderer->new()
	    };
    }
    return $_RENDERER_CACHE->{$descriptor->get_type()} || $_DEFAULT_RENDERER;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
