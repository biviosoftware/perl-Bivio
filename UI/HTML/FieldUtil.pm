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

    $req->print('<tr><td>');
    $req->print('*&nbsp;') if $required;
    my($fd) = $model->get_field_descriptor($field);

    # get the current value from the request or the model
    my($value) = $req->get_arg($field) || $model->get($field);

    if ($fd->get_type() == Bivio::Biz::FieldDescriptor::STRING
	    || $fd->get_type() == Bivio::Biz::FieldDescriptor::CURRENCY
	    || $fd->get_type() == Bivio::Biz::FieldDescriptor::NUMBER
	    || $fd->get_type() == Bivio::Biz::FieldDescriptor::DATE
	    || $fd->get_type() == Bivio::Biz::FieldDescriptor::EMAIL) {
	$req->print('<label for="'.$field.'">'
		.$model->get_field_caption($field).': </label></td><td>');
	$req->print('<input type="text" name="'.$field
		.'" maxlength='.$fd->get_size());

	if ($value) {
	    $req->print(' value="'.$value.'"');
	}
	if ($fd->get_size() < 15) {
	    $req->print(' size='.$fd->get_size());
	}
	elsif ($fd->get_size() > 40) {
	    # 40 is pretty big for an entry field
	    $req->print(' size=40');
	}
	$req->print('>');
    }
    elsif ($fd->get_type() == Bivio::Biz::FieldDescriptor::BOOLEAN) {
	$req->print('<input type="checkbox" name="'.$field.'"');
	if ($value) {
	    $req->print(' checked');
	}
	$req->print('>');
    }
    elsif ($fd->get_type() == Bivio::Biz::FieldDescriptor::GENDER) {
	$req->print('<input type="radio" name="'.$field
		.'" value="M"');
	if ($value && $value eq "M") {
	    $req->print(' checked');
	}
	$req->print('> Male <br><input type="radio" name="'
		.$field.'" value="F"');
	if ($value && $value eq "F") {
	    $req->print(' checked');
	}
	$req->print('> Female <br>');
    }
    elsif ($fd->get_type() == Bivio::Biz::FieldDescriptor::PASSWORD) {
	$req->print('<label for="password">Password: </label></td><td>'
		.'<input type="password" name="password" maxlength=32');
	if ($value) {
	    $req->print(' value="'.$value.'"');
	}
	$req->print('><br></td></tr><tr><td>');
	$req->print('*&nbsp;') if $required;
	$req->print('<label for="confirm_password">Confirm password: </label>'
		.'</td><td><input type="password" name="confirm_password"'
		.' maxlength=32');
	if ($value) {
	    $req->print(' value="'.$value.'"');
	}
	$req->print('><br></td></tr>');
    }
    elsif ($fd->get_type() == Bivio::Biz::FieldDescriptor::ROLE) {
	$req->print('<input type="radio" name="'.$field
		.'" value="0"');
	if ($value && $value == 0) {
	    $req->print(' checked');
	}
	$req->print('> Administrator<br><input type="radio" name="'
		.$field.'" value="1"');
	if ($value && $value == 1) {
	    $req->print(' checked');
	}
	$req->print('> Member<br><input type="radio" name="'
	       .$field.'" value="2"');
	if ($value && $value == 2) {
	    $req->print(' checked');
	}
	$req->print('> Guest<br>');
    }
    $req->print('</td></tr>');
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
