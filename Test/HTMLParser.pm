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
The following fields are defined

   forms - all forms
   tables - all top-level tables
   links - all links
   text - all text outside of tags and forms

Tables and forms may contain nested "links" and "text" elements
which contain the subset of values found with the scope of the
table and form, respectively.

This module is only concerned with the HTML representation of the
information, not its semantics.

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

=head2 static new(string content) : Bivio::Test::HTMLParser

Parse an HTML page and return an instance

=cut

sub new {
    my($proto,$content) = @_;
    my($self) = HTML::Parser::new($proto);
    my($fields) = $self->{$_PACKAGE} = {
#	offset => 0,
#	length => length($$content),
	forms => {},
	links => {},
	tables => [],

	line_no => 1,
	table_count => 0,
	table_depth => 0,
	form_count => 0,
	
	# counter used to create unique form names.
	unnamed_count => 0,
	in_title => 0
    };

    # call the HTML::Parser parser
    $self->parse($content);
    $self->eof();

    return $self;
}

=head1 METHODS

=cut

=for html <a name="end"></a>

=head2 end(string tag)

HTML::Parser calls this routine for all end tags.  It will
return immediately unless the tag is "interesting;" in those
cases it will call the procedure named _parse_end_$tag.

=cut

sub end {
    my($self, $tag, $origtext) = @_;
    my($fields) = $self->{$_PACKAGE};
    my($_INTERESTING_TAGS) = 'a|form|select|table|tr|title';

    # return if we don't care about this tag
    return unless $tag =~ /^(?:$_INTERESTING_TAGS)$/io;

    # dispatch the appropriate end tag action.
    my($method) = '_parse_end_'.$tag;
    &{\&{'_parse_end_'.$tag}}($self);
  
    return;
}

=for html <a name="get_fields"></a>

=head2 get_content(Bivio::Test::HTMLParser self)

Access routine that returns the hashed contents of the HTML page.

=cut

sub get_fields {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    return($fields);
}

=for html <a name="get_title"></a>

=head2 get_title(Bivio::Test::HTMLParser self) : string

Access routine that returns the title of the HTML page.

=cut

sub get_title {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    return ($fields->{title});
}

=for html <a name="start"></a>

=head2 start(string text, hash_ref attr, arrayref attrseq, string origtext)

HTML::Parser calls this routine for all start tags.  It will
return immediately unless the tag is "interesting;" in those
cases it will call the procedure named _parse_start_$tag.

=cut

sub start {
    my($self, $tag, $attr, $attrseq, $origtext) = @_;
    my($fields) = $self->{$_PACKAGE};
    my($_INTERESTING_TAGS)
	    = 'a|form|input|img|option|select|table|textarea|tr|title';

    # return if we don't care about this tag
    return unless $tag =~ /^(?:$_INTERESTING_TAGS)$/io;
  
#    commented out momentarily - sometimes an error, most often not.
#    unless (defined($fields->{currenttext})) {
#	_trace("no text associated with $origtext") if $_TRACE;
#    }
  
    # dispatch the appropriate start tag action.
    my($method) = '_parse_start_'.$tag;
    &{\&{'_parse_start_'.$tag}}($self, $attr, $origtext);

    return;
}

=for html <a name="text"></a>

=head2 text(string tag)

Save all text outside of tags, with some awareness of forms.

N.B., it's possible that the parser will split a single text entity
into multiple pieces.  We don't worry about that yet.

=cut

sub text {
    my($self, $text) = @_;
    my($fields) = $self->{$_PACKAGE};

    $fields->{line_no}++ if ($text =~ /\n/);

    # ignore blank lines
    return unless ($text =~ /\S+/ && $text ne '&nbsp;');

    # convert any "&nbsp;" to a single space
    $text =~ s/&nbsp;/ /g;
  
    # remove leading and trailing whitespace
    $text =~ s/^\s+|\s+$//g;

    # store onsreen text
    # options terminate with text
    if (defined($fields->{option})) {
        if (defined($fields->{currentselect})) {
	    _trace('\selection->{$text} = $fields->{option}') if $_TRACE;
#	    push(@{$fields->{currentselect}->{options}});
	    $fields->{currentselect}->{options}->{$text} = $fields->{option};
	}
	delete($fields->{option});
    }
	  

    # radio_or_checkbox inputs terminate with text
    elsif (defined($fields->{radio_or_checkbox})) {
	if (! defined($fields->{currentform})) {
	    _trace('Warning!  Skipping radio/checkbox input outside of form')
		    if $_TRACE;
	}
	elsif (! defined($text)) {
	    _trace('Warning! radio/checkbox input had no associated text; ignoring')
		    if $_TRACE;
	}
	else {
	    $fields->{currentform}->{fields} = {}
		unless defined($fields->{currentform}->{fields});

	    Bivio::Die->die("duplicate field name: $text")
			if defined($fields->{currentform}->{fields}->{$text});

	    $fields->{currentform}->{fields}->{$text} = {};
	    $fields->{currentform}->{fields}->{$text}->{type}
		= $fields->{radio_or_checkbox}->{type};
	    $fields->{currentform}->{fields}->{$text}->{name}
		= $fields->{radio_or_checkbox}->{name};
	    $fields->{currentform}->{fields}->{$text}->{value}
		= $fields->{radio_or_checkbox}->{value};
	    $fields->{currentform}->{fields}->{$text}->{text} = $text;
	}
	delete $fields->{radio_or_checkbox};
    }

    # forms and hyperlinks just get cached for later processing
    elsif (defined($fields->{currentform}) || defined($fields->{a})) {
	if (defined($fields->{text})) {
	    $fields->{currenttext} = $text;
	}
	else {
	    $fields->{currenttext} .= $text;
	}
    }

    # cache document title
    elsif ($fields->{in_title}) {
	$fields->{title} = defined($fields->{title})
		? $fields->{title}.$text : $text;
    }

    # anything gets saved until later.
    else {
	_trace("text '", $text, "': found") if $_TRACE;
	# following line doesn't seem to do what I intended...

	$fields->{text} = [] unless defined($fields->{text});
	push(@{$fields->{text}}, $text);

#	$fields->{text}->{$text} = 1;
	if (defined($fields->{currentform})) {
	    $fields->{currentform}->{text} = []
		    unless defined($fields->{currentform}->{text});
	    push(@{$fields->{currentform}->{text}}, $text);
	}
	if (defined($fields->{currenttable})) {
	    $fields->{currenttable}->{text} = []
		    unless defined($fields->{currenttable}->{text});
	    push(@{$fields->{currenttable}->{text}}, $text);
	}
	if (defined($fields->{currentrow})) {
	    $fields->{currentrow}->{text} = []
		    unless defined($fields->{currentrow}->{text});
	    push(@{$fields->{currentrow}->{text}}, $text);
	}
    }
	
    return;
}

#=PRIVATE METHODS

# _handle_hidden(Bivio::Test::HTMLParser self, hash_ref attr, string origtext)
#
# Save the "name=" and "value=" components of a form's hidden field.
# These values are stored in the permanent hash
# "fields->forms->{$form}->{hidden_fields}."
#
sub _handle_hidden {
    my($self, $attr, $origtext) = @_;
    my($fields) = $self->{$_PACKAGE};

    my($name) = $attr->{name};

    Bivio::Die->die ("input outside of form!")
		unless defined($fields->{currentform});

    $fields->{currentform}->{hidden_fields} = {}
	    unless defined($fields->{currentform}->{hidden_fields});

    Bivio::Die->die("Duplicate hidden input field: $origtext")
		if defined($fields->{currentform}->{hidden_fields}->{$name});

    $fields->{currentform}->{hidden_fields}->{$name} = {};
    $fields->{currentform}->{hidden_fields}->{$name}->{type} = $attr->{type};
    $fields->{currentform}->{hidden_fields}->{$name}->{name} = $attr->{name};
    $fields->{currentform}->{hidden_fields}->{$name}->{value} = $attr->{value};

    return;
}

# _handle_radio_checkbox(Bivio::Test::HTMLParser self, hash_ref attr, string origtext)
#
# Save the name and value of a "radio" or "checkbox" input field
# in the temporary field "radio_or_checkbox."
#
sub _handle_radio_checkbox {
    my($self, $attr, $origtext) = @_;
    my($fields) = $self->{$_PACKAGE};

    Bivio::Die->die ("input outside of form!")
		unless defined($fields->{currentform});
    
    $fields->{radio_checkbox} = {}
	    unless defined($fields->{radio_checkbox});

    $fields->{radio_or_checkbox}->{type} = $attr->{type};
    $fields->{radio_or_checkbox}->{name} = $attr->{name};
    $fields->{radio_or_checkbox}->{value} = $attr->{value};

    return;
}

# _handle_submit(Bivio::Test::HTMLParser self, hash_ref attr, string origtext)
# Save the name and value of any form <submit> tag.  There may be
# multiple tags per form.
#
sub _handle_submit {
    my($self, $attr, $origtext) = @_;
    my($fields) = $self->{$_PACKAGE};

    my($name) = $attr->{value};

    Bivio::Die->die ("input outside of form!")
		unless defined($fields->{currentform});

    unless (defined($name)) {
	$name = "unnamed-".$fields->{unnamed_count};
	$fields->{unnamed_count}++;
    }

#    if (defined($fields->{currentform})) {
#	_trace('push \@{$fields->{currentform}->{name}}->{$value}, $name)')
#		if $_TRACE;
##	push(@{$fields->{currentform}->{$value}}, $name);
#	$fields->{currentform}->{submit} = {}
#		unless defined($fields->{currentform}->{submit});
#	$fields->{currentform}->{submit}->{$value} = $name;
#    }
  
    # technically, I believe it's legal to have multiple "submit"
    # input types in a single form.  However, no Bivio form should
    # have it.
    Bivio::Die->die("Duplicate submit fields: $origtext")
		if defined($fields->{currentform}->{hidden_fields}->{$name});

    $fields->{currentform}->{hidden_fields}->{$name} = {};
    $fields->{currentform}->{hidden_fields}->{$name}->{type} = $attr->{type};
    $fields->{currentform}->{hidden_fields}->{$name}->{name} = $attr->{name};
#   $fields->{currentform}->{hidden_fields}->{$name}->{value} = $attr->{value};

    return;
}

# _handle_text(Bivio::Test::HTMLParser self, hash_ref attr, string origtext)
#
# Save the name and value of most input fields.
#
sub _handle_text {
    my($self, $attr, $origtext) = @_;
    my($fields) = $self->{$_PACKAGE};

    my($text) = $fields->{currenttext};

    $text = 'search' if (!defined($text) && $attr->{name} eq 's');

    
    Bivio::Die->die("No text found associated with input field near line $fields->{line_no}: $origtext")
		unless defined($text);

    $fields->{currentform}->{fields} = {}
	    unless defined($fields->{currentform}->{fields});
    
    Bivio::Die->die("Duplicate input field: $origtext")
		if defined($fields->{currentform}->{fields}->{$text});

    $fields->{currentform}->{fields}->{$text} = {};
    $fields->{currentform}->{fields}->{$text}->{type} = $attr->{type};
    $fields->{currentform}->{fields}->{$text}->{name} = $attr->{name};
    $fields->{currentform}->{fields}->{$text}->{value} = $attr->{value};
    $fields->{currentform}->{fields}->{$text}->{text} = $text;
    
    return;
}

# _parse_end_a(Bivio::Test::HTMLParser self)
#
# Store hyperlink information and then clear the image name,
# text and hyperlink temporary fields.
#
sub _parse_end_a {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};

    if (defined($fields->{currenttable})) {
	$fields->{currenttable}->{links} = {}
		unless defined($fields->{currenttable}->{links});
    }
    if (defined($fields->{currentform})) {
	$fields->{currentform}->{links} = {}
		unless defined($fields->{currentform}->{links});
    }
    if (defined($fields->{currentrow})) {
	$fields->{currentrow}->{links} = {}
		unless defined($fields->{currentrow}->{links});
    }
  
    my($text);
    if (defined($fields->{currenttext})) {
	$text = $fields->{currenttext};
	$text =~ s/&amp;/&/g
    }

    my($img_base);
    if (defined($fields->{img_name})) {
	($img_base) = $fields->{img_name} =~ /(\w+)\.\w+/;
    }

    my($href);
    if (defined($fields->{a})) {
	($href) = ($fields->{a} =~ /^(\/\S*)$/);
	if (! $href) {
	    ($href) = (('/'.$fields->{a}) =~ /^(\/\S+)$/);  # some miss first /
	}
    }

    if ($text) {
	_trace('\${links}->{$text} = $href') if $_TRACE;
	$fields->{links}->{$text} = $href;
	if (defined($fields->{currentform})) {
	    $fields->{currentform}->{links}->{$text} = $href;
	}
	if (defined($fields->{currenttable})) {
	    $fields->{currenttable}->{links}->{$text} = $href;
	    $fields->{currenttable}->{link_count}++;
	}
	if (defined($fields->{currentrow})) {
	    $fields->{currentrow}->{links}->{$text} = $href;
	}
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
	if (defined($fields->{currentform})) {
	   $fields->{currentform}->{links}->{$img_base} = $href;
	}
	if (defined($fields->{currenttable})) {
	   $fields->{currenttable}->{links}->{$img_base} = $href;
	   $fields->{currenttable}->{link_count}++;
       }
	if (defined($fields->{currentrow})) {
	    $fields->{currentrow}->{links}->{$img_base} = $href;
	}
    }

    delete $fields->{image_name};
    delete $fields->{currenttext};
    delete $fields->{a};

    return;
}

# _parse_end_form(Bivio::Test::HTMLParser self)
#
# Delete the name of the current form and any unaccounted for text.
#
sub _parse_end_form {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    delete $fields->{currentform};
    delete $fields->{currenttext};
    return;
}

# _parse_end_select(Bivio::Test::HTMLParser self)
#
# Delete the temporary field "select"
#
sub _parse_end_select {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    delete $fields->{currentselect};
    return;
}

# _parse_end_table(Bivio::Test::HTMLParser self)
#
# Decrement the table counters.
#
sub _parse_end_table {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    $fields->{table_depth}--;
    if ($fields->{table_depth} == 0) {
	if ($fields->{currenttable}->{link_count} == 0) {
	    pop(@{$fields->{tables}});
	}
	delete $fields->{currenttable};
    }
    delete $fields->{currenttext};
    return;
}

# _parse_end_title(Bivio::Test::HTMLParser self)
#
# Stop collecting information about document title.
#
sub _parse_end_title {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    $fields->{in_title} = 0;
    return;
}

# _parse_end_tr(Bivio::Test::HTMLParser self)
#
# If this was an "interesting" table row, save it.
# Delete the temporary fields "text" and "radio_or_checkbox".
#
sub _parse_end_tr {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    if (defined($fields->{currentrow})
	    && int(keys(%{$fields->{currentrow}})) > 0) {
	if (defined($fields->{currenttable})) {
	    $fields->{currenttable}->{rows} = []
		    unless defined($fields->{currenttable}->{rows});
	    push(@{$fields->{currenttable}->{rows}}, $fields->{currentrow});
	    $fields->{unnamed_count}++;
	}
	delete($fields->{currentrow});
    }
    delete $fields->{radio_or_checkbox};
    return;
}

# _parse_input_checkbox(Bivio::Text::HTMLParser self, hash_ref attr, string origtext)
#
# Redirect to the method that handles <input type="checkbox"...>
#
sub _parse_input_checkbox {
    my($self, $attr, $origtext) = @_;
    $self->_handle_radio_checkbox($attr, $origtext);
    return;
}

# _parse_input_file(Bivio::Test::HTMLParser self, hash_ref attr, string origtext)
#
# Redirect to the method that handles <input type="file"...>
#
sub _parse_input_file {
    my($self, $attr, $origtext) = @_;
    $self->_handle_text($attr, $origtext);
    return;
}

# _parse_input_hidden(Bivio::Test::HTMLParser self, hash_ref attr, string origtext)
#
# Redirect to the method that handles <input type="hidden"...>
#
sub _parse_input_hidden {
    my($self, $attr, $origtext) = @_;
    $self->_handle_hidden($attr, $origtext);
    return;
}

# _parse_input_image(Bivio::Test::HTMLParser self, hash_ref attr, string origtext)
#
# Null handler for <input type="image"...>
#
sub _parse_input_image {
    my($self, $attr, $origtext) = @_;
    return;
}

# _parse_input_password(Bivio::Test::HTMLParser self, hash_ref attr, string origtext)
#
# Redirect to the method that handles <input type="password"...>
#
sub _parse_input_password {
    my($self, $attr, $origtext) = @_;
    $self->_handle_text($attr, $origtext);
    return;
}

# _parse_input_radio(Bivio::Test::HTMLParser self, hash_ref attr, string origtext)
#
# Redirect to the method that handles <input type="radio"...>
#
sub _parse_input_radio {
    my($self, $attr, $origtext) = @_;
    $self->_handle_radio_checkbox($attr, $origtext);
    return;
}

# _parse_input_reset(Bivio::Test::HTMLParser self, hash_ref attr, string origtext)
#
# Ignore <input type="reset"> tags.
#
sub _parse_input_reset {
    my($self, $attr, $origtext) = @_;
    return;
}

# _parse_input_submit(Bivio::Test::HTMLParser self, hash_ref attr, string origtext)
#
# Redirect to the method that handles <input type="submit"...>
#
sub _parse_input_submit {
    my($self, $attr, $origtext) = @_;
    $self->_handle_submit($attr, $origtext);
    return;
}

# _parse_input_text(Bivio::Text::HTMLParser self, hash_ref attr, string origtext)
#
# Redirect to the method that handles <input type="text"...>
#
sub _parse_input_text {
    my($self, $attr, $origtext) = @_;
    $self->_handle_text($attr, $origtext);
    return;
}

# _parse_start_a(Bivio::Test::HTMLParser self, hash_ref attr, string origtext)
#
# Store hyperlink in temporary field.
#
sub _parse_start_a {
    my($self, $attr, $origtext) = @_;
    my($fields) = $self->{$_PACKAGE};
    $fields->{a} = $attr->{href};
    return;
}

# _parse_start_form(Bivio::Test::HTMLParser self, hash_ref attr, string origtext)
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

    # we believe that forms are always within a table, and some of the
    # other modules explicitly assume that.  We check that here - if there
    # are any exceptions, we need to know that ASAP.
    Bivio::Die->die('Eeek! Form not within table! $origtext')
		if $fields->{table_depth} == 0;
  
    # alternately, we could *require* all forms have names.
    unless ($name) {
	_trace('Warning! No name in form: $origtext')
		if $_TRACE;
	$name = 'unnamed-'.$fields->{unnamed_count};
	$fields->{unnamed_count}++;
    }

    $fields->{currenttable}->{form_name} = $name;
    
    $fields->{currentform} = $fields->{forms}->{$name} = {};
    $fields->{currentform}->{attr} = $attr;
    $fields->{currentform}->{line_no} = $fields->{line_no};
    $fields->{currentform}->{name} = $name;
    $fields->{currentform}->{position} = $fields->{form_count}++;

    if (defined($fields->{currenttable})) {
	$fields->{currenttable}->{forms} = {}
		unless defined($fields->{currenttable}->{forms});
	$fields->{currenttable}->{forms}->{$name} = $fields->{forms}->{$name};
    }
  
    # if an action is specified, save it.
    if ($action) {
	_trace('Form $fields->{currentform}->{name} action: $action')
		if $_TRACE;
	$fields->{currentform}->{action} = $action;
    }

    # if a method is specified, save it.
    if ($method) {
	_trace('Form $fields->{currentform}->{name} method: $method')
		if $_TRACE;
	$fields->{currentform}->{method} = $method;
    }

    return;
}

# _parse_start_img(Bivio::Test::HTMLParser self, hash_ref attr, string origtext)
#
# Store image's source in temporary field.
#
sub _parse_start_img {
    my($self, $attr, $origtext) = @_;
    my($fields) = $self->{$_PACKAGE};
    $fields->{image_name} = $attr->{src};

return;
    $fields->{images} = [] unless defined($fields->{images});
    push(@{$fields->{images}}, $attr);
  
    if (defined($fields->{currenttable})) {
	$fields->{currenttable}->{images} = []
		unless defined($fields->{currenttable}->{images});
	push(@{$fields->{currenttable}->{images}}, $attr);
    }
    if (defined($fields->{currentrow})) {
	$fields->{currentrow}->{images} = []
		unless defined($fields->{currentrow}->{images});
	push(@{$fields->{currentrow}->{images}}, $attr);
    }

    return;
}

# _parse_start_input(Bivio::Test::HTMLParser self, hash_ref attr, string origtext)
#
# Dispatch method for all form <input...> tags.
#
sub _parse_start_input {
    my($self, $attr, $origtext) = @_;
    my($fields) = $self->{$_PACKAGE};
    if (defined($fields->{currentform})) {
	my($method) = '_parse_start_input_'.$attr->{type};
	&{\&{'_parse_input_'.$attr->{type}}}($self, $attr, $origtext);
    }
    return;
}

# _parse_start_option(Bivio::Test::HTMLParser self, hash_ref attr, string origtext)
#
# Cache the <option value="xxx"> value.
#
sub _parse_start_option {
    my($self, $attr, $origtext) = @_;
    my($fields) = $self->{$_PACKAGE};
    if (defined($fields->{currentselect})) {
	$fields->{option} = $attr->{value};
	$fields->{currentselect}->{options} = {}
		unless defined($fields->{currentselect}->{options});
    }
    return;
}

# _parse_start_select(Bivio::Test::HTMLParser self, hash_ref attr, string origtext)
#
# Save the name, action, and method of a form <select...> tag
sub _parse_start_select {
    my($self, $attr, $origtext) = @_;
    my($fields) = $self->{$_PACKAGE};

    Bivio::Die->die("outside of form: $origtext\n")
		unless defined($fields->{currentform});

    if (defined($fields->{currentform}->{select})) {
	$fields->{option} = $attr->{value};
	return;
    }
    my($text) = $fields->{currenttext};
    my($action) = $fields->{currentform}->{action};

    $text = 'RealmChooser'
	    if (!defined($text) && $action && $action eq '/goto');

    $fields->{currentselect} = $fields->{currentform}->{fields}->{$text} = {};
    $fields->{currentselect}->{type} = $attr->{type};
    $fields->{currentselect}->{name} = $attr->{name};
    $fields->{currentselect}->{text} = $text;
    $fields->{currentselect}->{value} = '';

#    if (defined($action)) {
#	_trace('Form, selection $name: action $action')
#		if $_TRACE;
#	$fields->{currentselect}->{action} = $action;
#    }
#
#    my($method) = $fields->{currentform}->{method};
#    if (defined($method)) {
#	_trace('Form, selection $name: method $method')
#		if $_TRACE;
#	$fields->{currentselect}->{method} = $method;
#    }
  
    return;
}

# _parse_start_table(Bivio::Test::HTMLParser self, hash_ref attr, string origtext)
#
# Increment the table counters.
#
sub _parse_start_table {
    my($self, $attr, $origtext) = @_;
    my($fields) = $self->{$_PACKAGE};

    if ($fields->{table_depth} == 0) {
	push(@{$fields->{tables}}, ($fields->{currenttable} = {}));
	$fields->{currenttable}->{line_no} = $fields->{line_no};
	$fields->{currenttable}->{link_count} = 0;

	# cache attributes, if any
	if (defined($attr)) {
	    $fields->{currenttable}->{attr} = $attr;
	}
    }
  
    # nested tables blow out the current row.
    delete ($fields->{currentrow}) if (defined($fields->{currentrow}));

    $fields->{table_depth}++;
    $fields->{table_count}++;
    return;
}

# _parse_start_textarea(Bivio::Test::HTMLParser self, hash_ref attr, string origtext)
#
# Handle <textarea> start tags.
#
sub _parse_start_textarea {
    my($self, $attr, $origtext) = @_;
    my($fields) = $self->{$_PACKAGE};
    if (defined($fields->{currentform})) {
	$self->_handle_text($self, $attr, $origtext);
    }
    return;
}

# _parse_start_title(Bivio::Test::HTMLParser self, hash_ref attr, string origtext)
#
# Start recording information about the document's title.
#
sub _parse_start_title {
    my($self, $attr, $origtext) = @_;
    my($fields) = $self->{$_PACKAGE};
    $fields->{in_title} = 1;
    return;
}

# _parse_start_tr(Bivio::Test::HTMLParser self, hash_ref attr, string origtext)
#
# Start recording information about a new row.
#
sub _parse_start_tr {
    my($self, $attr, $origtext) = @_;
    my($fields) = $self->{$_PACKAGE};
    $fields->{currentrow} = {};

    # cache row attributes, if any
#   if (defined($attr)) {
#	$fields->{currentrow}->{attr} = $attr;
#   }
    return;
}

=head1 COPYRIGHT

Copyright (c) 2000 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
