# Copyright (c) 2000 bivio Inc.  All rights reserved.
# $Id$
package Bivio::Test::HTMLParser;
use strict;
$Bivio::Test::HTMLParser::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Test::HTMLParser::VERSION;

=head1 NAME

Bivio::Test::HTMLParser - class that parses an HTML page

=head1 SYNOPSIS

    use Bivio::Test::HTMLParser;

=cut

=head1 EXTENDS

L<HTML::Parser>

=cut

use HTML::Parser;
@Bivio::Test::HTMLParser::ISA = ('HTML::Parser');

=head1 DESCRIPTION

C<Bivio::Test::HTMLParser>

Extend HTML::Parser to extract interesting bits from Bivio pages.
The following fields are defined:

   forms - all forms
   links - all links
   text - all text outside of tags and forms

TO DO: revisit text(), _parse_end_a(), _parse_start_form(),
_parse_start_select().

=cut

=head1 CONSTANTS

=cut

#=IMPORTS
use Bivio::IO::Trace;
use Bivio::Die;

#=VARIABLES
use vars ('$_TRACE');
Bivio::IO::Trace->register;
my($_PACKAGE) = __PACKAGE__;


=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(HTTP::Response response) : Bivio::Test::HTMLParser

Parse an HTTP::Response and return an instance

=cut

sub new {
    my($proto,$content) = @_;
    my($self) = HTML::Parser::new($proto);
    my($fields) = $self->{$_PACKAGE} = {
#	offset => 0,
#	length => length($$content),
	forms => {},
	links => {},
	text => {},

	# counter used to create unique form names.
	unnamed_count => 0
    };

    # call the HTML::Parser parser
    $self->parse($content);
    $self->eof();

    return $self;
}

=head1 METHODS

=cut

=for html <a name="end"></a>

=head2 end(string tag) :

HTML::Parser calls this routine for all end tags.  It will
return immediately unless the tag is "interesting;" in those
cases it will call the procedure named _parse_end_$tag.

=cut

sub end {
    my($self, $tag, $origtext) = @_;
    my($fields) = $self->{$_PACKAGE};
    my($_INTERESTING_TAGS) = 'a|form|select|tr';

    # return if we don't care about this tag
    return unless $tag =~ /^(?:$_INTERESTING_TAGS)$/io;

    # dispatch the appropriate end tag action.
    my($method) = '_parse_end_'.$tag;
    &{\&{'_parse_end_'.$tag}}($self);
    
    return;
}

=for html <a name="start"></a>

=head2 start(string text, hash_ref attr, arrayref attrseq, string origtext) : 

HTML::Parser calls this routine for all start tags.  It will
return immediately unless the tag is "interesting;" in those
cases it will call the procedure named _parse_start_$tag.

=cut

sub start {
    my($self, $tag, $attr, $attrseq, $origtext) = @_;
    my($fields) = $self->{$_PACKAGE};
    my($_INTERESTING_TAGS) = 'a|form|input|img|option|select|textarea';

    # return if we don't care about this tag
    return unless $tag =~ /^(?:$_INTERESTING_TAGS)$/io;
    
    unless (defined ($fields->{currenttext})) {
	_trace ("no text associated with $origtext") if $_TRACE;
    }
    
    # dispatch the appropriate start tag action.
    my($method) = '_parse_start_'.$tag;
    &{\&{'_parse_start_'.$tag}}($self, $attr, $origtext);

    return;
}

=for html <a name="text"></a>

=head2 text(string tag) :

Save all text outside of tags, with some awareness of forms.

N.B., it's possible that the parser will split a single text entity
into multiple pieces.  We don't worry about that yet.

=cut

sub text {
    my($self, $text) = @_;
    my($fields) = $self->{$_PACKAGE};

    # ignore blank lines
    return unless ($text =~ /\S+/ && $text ne '&nbsp;');

    # convert any "&nbsp;" to a single space
    $text =~ s/&nbsp;/ /g;
    
    # remove leading and trailing whitespace
    $text =~ s/^\s+|\s+$//g;

    # store onsreen text
    # options terminate with text
    if (defined ($fields->{option})) {
        if (defined ($fields->{currentform}
		&& defined ($fields->{currentselect}))) {
	    my($form) = $fields->{forms}->{$fields->{currentform}};
	    my($selection) = $form->{$fields->{currentselect}};
	    _trace ('\$selection->{$text} = $fields->{option}') if $_TRACE;
#	    push (@{$selection->{options}});
	    $selection->{options}->{$text} = $fields->{option};
	}
	delete ($fields->{option});
    }
	    

    # radio_or_checkbox inputs terminate with text
    elsif (defined ($fields->{radio_or_checkbox})) {
	if (! defined ($fields->{currentform})) {
	    _trace('Warning!  Skipping radio/checkbox input because of nameless form')
		    if $_TRACE;
	}
	elsif (! defined ($text)) {
	    _trace('Warning! radio/checkbox input had no associated text; ignoring')
		    if $_TRACE;
	}
	else {
	    my($form) = $fields->{forms}->{$fields->{currentform}};
	    _trace ('\$form->{$text} = $fields->{radio_or_checkbox}')
		    if $_TRACE;
	    $form->{$text} = $fields->{radio_or_checkbox};
	}
	delete $fields->{radio_or_checkbox};
    }
    
    # forms and hyperlinks just get cached for later processing
    elsif (defined ($fields->{currentform}) || defined ($fields->{a})) {
	if (defined ($fields->{text})) {
	    $fields->{currenttext} = $text;
	}
	else {
	    $fields->{currenttext} = $fields->{currenttext}.$text;
	}
    }

    # anything gets saved until later.
    else {
	_trace ("text '", $text, "': found") if $_TRACE;
	# following line doesn't seem to do what I intended...
#	push (@{$fields->{text}}, qw/$text/);
	$fields->{text}->{$text} = 1;
    }
	
    return;
}

#=PRIVATE METHODS

# _handle_hidden(Bivio::Test::HTMLParser self, hash_ref attr, string origtext) : 
#
# Save the "name=" and "value=" components of a form's hidden field.
# These values are stored in the permanent hash
# "fields->forms->{$form}->{hidden_fields}."
#
sub _handle_hidden {
    my($self, $attr, $origtext) = @_;
    my($fields) = $self->{$_PACKAGE};

    my($name) = $attr->{name};
    my($value) = $attr->{value};

    my($form) = $fields->{$fields->{currentform}};
    
    _trace('Form $form->{name} hidden field: $name') if $_TRACE;
    $form->{hidden_fields}->{$name} = $value;

    return;
}

# _handle_radio_checkbox(Bivio::Test::HTMLParser self, hash_ref attr, string origtext) : 
#
# Save the name and value of a "radio" or "checkbox" input field
# in the temporary field "radio_or_checkbox."
#
sub _handle_radio_checkbox {
    my($self, $attr, $origtext) = @_;
    my($fields) = $self->{$_PACKAGE};

    my($name) = $attr->{name};
    my($value) = $attr->{value};

    $fields->{radio_or_checkbox} = $name.'='.$value;
    
    return;
}

# _handle_submit(Bivio::Test::HTMLParser self, hash_ref attr, string origtext) : 
# Save the name and value of any form <submit> tag.  There may be
# multiple tags per form.
#
sub _handle_submit {
    my($self, $attr, $origtext) = @_;
    my($fields) = $self->{$_PACKAGE};

    my($name) = $attr->{name};
    my($value) = $attr->{value};

    my($form) = $fields->{form}->{$fields->{currentform}};
    
    if ($name) {
	_trace('push \@{$form->{name}}->{$value}, $name)')
		if $_TRACE;
	push (@{$form->{$value}}, $name);
    }
    
    return;
}

# _handle_text_password_file_textarea(Bivio::Test::HTMLParser self, hash_ref attr, string origtext) : 
#
# Save the name and value of most input fields.  There may be multiple
# <input> tags per form.
#
sub _handle_text_password_file_textarea {
    my($self, $attr, $origtext) = @_;
    my($fields) = $self->{$_PACKAGE};

    my($name) = $attr->{name};
    my($value) = $attr->{value};
    my($text) = $fields->{currenttext};
    my($out);

    my($form) = $fields->{form}->{$fields->{currentform}};
    
    Bivio::Die->die ("No text found associated with input field: $origtext")
		unless defined ($text);

    $out = $value ? $name.'='.$value : $name.'=';

    _trace('push \@{\$form->{$text}), $out') if $_TRACE;
    push (@{$form->{$text}}, $out);

    return;
}

# _parse_end_a(Bivio::Test::HTMLParser self) : 
#
# Store hyperlink information and then clear the image name,
# text and hyperlink temporary fields.
#
sub _parse_end_a {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};

    my($text);
    if (defined ($fields->{currenttext})) {
	$text = $fields->{currenttext};
	$text =~ s/&amp;/&/g
    }

    my($img_base);
    if (defined ($fields->{img_name})) {
	($img_base) = $fields->{img_name} =~ /(\w+)\.\w+/;
    }

    my($href);
    if (defined ($fields->{a})) {
	($href) = ($fields->{a} =~ /^(\/\S*)$/);
	if (! $href) {
	    ($href) = (('/'.$fields->{a}) =~ /^(\/\S+)$/);  # some miss first /
	}
    }

    if ($text) {
	_trace('\${links}->{$text} = $href') if $_TRACE;
	$fields->{links}->{$text} = $href;
    }

    if ($img_base) {
	_trace('\${links}->{$img_basde} = $href') if $_TRACE;
	$fields->{links}->{$text} = $href;

	# flip _on / _off in image name and apply, if applicable
	if ($img_base =~ /_off$/) {
	    $img_base =~ s/_off$/_on/;
	}
	else {
	    $img_base =~ s/_on$/_off/;
	}
        _trace('\${links}->{$img_base} = $href') if $_TRACE;
        $fields->{links}->{$img_base} = $href;
    }

    delete $fields->{image_name};
    delete $fields->{currenttext};
    delete $fields->{a};

    return;
}

# _parse_end_form(Bivio::Test::HTMLParser self) : 
#
# Delete the name of the current form and any unaccounted for text.
#
sub _parse_end_form {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    delete $fields->{currentform};
    delete $fields->{currenttext};
    delete $fields->{form};
    return;
}

# _parse_end_select(Bivio::Test::HTMLParser self) :
#
# Delete the temporary field "select"
#
sub _parse_end_select {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    delete $fields->{currentselect};
    return;
}

# _parse_end_tr(Bivio::Test::HTMLParser self) : 
#
# Delete the temporary fields "text" and "radio_or_checkbox".
#
sub _parse_end_tr {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    delete $fields->{currenttext};
    delete $fields->{radio_or_checkbox};
    return;
}

# _parse_input_checkbox(Bivio::Text::HTMLParser self, hash_ref attr, string origtext) : 
#
# Redirect to the method that handles <input type="checkbox"...>
#
sub _parse_input_checkbox {
    my($self, $attr, $origtext) = @_;
    $self->_handle_radio_checkbox($self, $attr, $origtext);
    return;
}

# _parse_input_file(Bivio::Test::HTMLParser self, hash_ref attr, string origtext) : 
#
# Redirect to the method that handles <input type="file"...>
#
sub _parse_input_file {
    my($self, $attr, $origtext) = @_;
    $self->_handle_text_password_file_textarea($self, $attr, $origtext);
    return;
}

# _parse_input_hidden(Bivio::Test::HTMLParser self, hash_ref attr, string origtext) : 
#
# Redirect to the method that handles <input type="hidden"...>
#
sub _parse_input_hidden {
    my($self, $attr, $origtext) = @_;
    $self->_handle_hidden($self, $attr, $origtext);
    return;
}

# _parse_input_password(Bivio::Test::HTMLParser self, hash_ref attr, string origtext) : 
#
# Redirect to the method that handles <input type="password"...>
#
sub _parse_input_password {
    my($self, $attr, $origtext) = @_;
    $self->_handle_text_password_file_textarea($self, $attr, $origtext);
    return;
}

# _parse_input_radio(Bivio::Test::HTMLParser self, hash_ref attr, string origtext) : 
#
# Redirect to the method that handles <input type="radio"...>
#
sub _parse_input_radio {
    my($self, $attr, $origtext) = @_;
    $self->_handle_radio_checkbox($self, $attr, $origtext);
    return;
}

# _parse_input_submit(Bivio::Test::HTMLParser self, hash_ref attr, string origtext) : 
#
# Redirect to the method that handles <input type="submit"...>
#
sub _parse_input_submit {
    my($self, $attr, $origtext) = @_;
    $self->_handle_submit($self, $attr, $origtext);
    return;
}

# _parse_input_text(Bivio::Text::HTMLParser self, hash_ref attr, string origtext) : 
#
# Redirect to the method that handles <input type="text"...>
#
sub _parse_input_text {
    my($self, $attr, $origtext) = @_;
    $self->_handle_text_password_file_textarea($self, $attr, $origtext);
    return;
}

# _parse_start_a(Bivio::Test::HTMLParser self, hash_ref attr, string origtext) : 
#
# Store hyperlink in temporary field.
#
sub _parse_start_a {
    my($self, $attr, $origtext) = @_;
    my($fields) = $self->{$_PACKAGE};
    $fields->{a} = $attr->{href};
    return;
}

# _parse_start_form(Bivio::Test::HTMLParser self, hash_ref attr, string origtext) :
#
# Store the form's name in the temporary field "formname".  If the form
# does not have an explicit name, generate a unique one.
#
# If the action and method are specified, store them in the permanent
# field forms->{$name}->{action} and forms->{$name}->{method}, respectively,
# where $name is the name of the form.
#
sub _parse_start_form {
    my($self, $attr, $origtext) = @_;
    my($fields) = $self->{$_PACKAGE};

    my($action) = $attr->{action};
    my($method) = $attr->{method};
    my($name)= $attr->{name};

    # create a unique name for nameless forms.
    # alternately, we could *require* all forms have names.
    unless ($name) {
	_trace('Warning! No name in form: $origtext')
		if $_TRACE;
	$name = 'unnamed-'.$fields->{unnamed_count};
	$fields->{unnamed_count}++;
    }

    my($form) = $fields->{forms}->{$name} = {};
    $form->{name} = $name;
    
    # if an action is specified, save it.
    if ($action) {
	_trace('Form $form->{name} action: $action') if $_TRACE;
	$form->{action} = $action;
    }

    # if a method is specified, save it.
    if ($method) {
	_trace('Form $form->{name} method: $method') if $_TRACE;
	$form->{method} = $method;
    }

    # cache name of current form.
    $fields->{currentform} = $name;

    return;
}

# _parse_start_img(hash_ref attr, string origtext) : 
#
# Store image's source in temporary field.
#
sub _parse_start_img {
    my($self, $attr, $origtext) = @_;
    my($fields) = $self->{$_PACKAGE};
    $fields->{image_name} = $attr->{src};
    return;
}

# _parse_start_input(hash_ref attr, string origtext) : 
#
# Dispatch method for all form <input...> tags.
#
sub _parse_start_input {
    my($self, $attr, $origtext) = @_;
    my($fields) = $self->{$_PACKAGE};
    if (defined ($fields->{currentform})) {
	my($method) = '_parse_start_input_'.$attr->{type};
	&{\&{'_parse_input_'.$attr->{type}}}($self, $attr, $origtext);
    }
    return;
}

# _parse_start_option(Bivio::Test::HTMLParser self, hash_ref attr, string origtext) : 
#
# Cache the <option value="xxx"> value.
#
sub _parse_start_option {
    my($self, $attr, $origtext) = @_;
    my($fields) = $self->{$_PACKAGE};
    if (defined ($fields->{currentform})
	    && defined ($fields->{currentselect})) {
	$fields->{option} = $attr->{value};
	my($form) = $fields->{forms}->{$fields->{currentform}};
	my($selection) = $form->{$fields->{currentselect}};
	$selection->{options} = {} unless (defined ($selection->{options}));
    }
    return;
}

# _parse_start_select(Bivio::Test::HTMLParser self, hash_ref attr, string origtext) : 
#
# Save the name, action, and method of a form <select...> tag
sub _parse_start_select {
    my($self, $attr, $origtext) = @_;
    my($fields) = $self->{$_PACKAGE};
    if (defined ($fields->{currentform})) {
	my($form) = $fields->{forms}->{$fields->{currentform}};

	if (defined ($form->{select})) {
	    $fields->{option} = $attr->{value};
	    return;
	}
	my($name) = $attr->{name};
	my($action) = $form->{action};
	my($method) = $form->{method};
	my($text) = $fields->{currenttext};

	$text = 'RealmChooser'
		if (!defined ($text) && $action && $action eq '/goto');

	my($selection) = $form->{$name} = {};
	
	$fields->{currentselect} = ${selection}->{name} = $name;
	${selection}->{text} = $text;

	if (defined ($action)) {
	    _trace ('Form $form->{name}, selection $name: action $action')
		    if $_TRACE;
	    ${selection}->{action} = $action;
	}

	if (defined ($method)) {
	    _trace ('Form $form->{name}, selection $name: method $method')
		    if $_TRACE;
	    ${selection}->{method} = $method;
	}
    }
    
    return;
}

# _parse_start_textarea(hash_ref attr, string origtext) : 
#
# Handle <textarea> start tags.
#
sub _parse_start_textarea {
    my($self, $attr, $origtext) = @_;
    my($fields) = $self->{$_PACKAGE};
    if (defined ($fields->{currentform})) {
	$self->_handle_text_password_file_textarea($self, $attr, $origtext);
    }
    return;
}

=head1 COPYRIGHT

Copyright (c) 2000 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
