#
# schelle@bivio.com
#
# BivioParser.pm
#
# Description: Class extending HTML::Parser used to parse an HTML page
#

package Bivio::Test::BivioParser;
use strict;

use base qw(HTML::Parser);

use URI::URL;

use PrintUtils;

#
# Global variables
#
my($_DEFS);           # definitions (read from defs.PL)
my($_DEBUG);          # verbose output
my($_DEBUG_LONG);     # very verbose output (prints $_CONTENT assignments)
my($_IGNORED_TAGS);   # HTML tags that we ignore
my($_CONTENT);        # parsed content of the page (see parse_http_response())

#
# Read config, definition, etc files
#
local($/);  # This lets you read a file in one go
open(IN, "defs.PL") || die("Failed to open defs.PL\n");
$_DEFS = eval(<IN>) || die("defs.PL: $@");
die("defs.PL: did not return hash") unless ref($_DEFS) eq 'HASH';
close(IN);

#
# Initialize global variables
#
$_DEBUG = $_DEFS->{DEBUG};
$_DEBUG_LONG = $_DEFS->{DEBUG_LONG};
$_IGNORED_TAGS = 'html|head|body|title|meta|style|big|table|td|script|font|b|br|small|i|p|noscript|div|ul|li|ol|hr|blockquote|h1';

################################################################################
##                                                                            ##
##                          Subroutines                                       ##
##                                                                            ##
################################################################################

#
# Parse an HTTP::Response and return the content we want
#
# $_CONTENT-> will refer to the following structure upon completion:
#
# Where: fn stands for "form name"
#        taw stands for "text associated with or adjacent to"
#         and
#        items in parenthesis would be replaced by actual values
#
# {HTTP_RESPONSE} =>                                   HTTP::Response
# {URI} =>                                             URI
# {TITLE} =>                                           Title
#
# {TEXT}->{(onscreen text)} =>                         1
#
# {FORMS}->{(fn)}->{action} =>                         (action)
# {FORMS}->{(fn)}->{method} =>                         (method)
#
# {FORMS}->{(fn)}->{HIDDEN_FIELDS}->{(name)} =>        (value)
#
# {FORMS}->{(fn)}->{(taw select)}->{name} =>           (select name)
# {FORMS}->{(fn)}->{(taw select)}->{(taw option)} =>   (option name)
#
# {FORMS}->{(fn)}->{(taw submit)} =>                   ARRAY of (submit names)
#
# {FORMS}->{(fn)}->{(taw text input)} =>               ARRAY of (name)=(value)
# {FORMS}->{(fn)}->{(taw password input)} =>           ARRAY of (name)=(value)
# {FORMS}->{(fn)}->{(taw file input)} =>               ARRAY of (name)=(value)
# {FORMS}->{(fn)}->{(taw textarea)} =>                 ARRAY of (name)=
#
# {FORMS}->{(fn)}->{(taw radio input} =>               (name)=(value)
# {FORMS}->{(fn)}->{(taw checkbox input} =>            (name)=(value)
#
# {LINKS}->{(underlined text)} =>                      (href)
#
# {LINKS}->{(image name w/o extension)} =>             (href)
#
sub parse_http_response {
	undef $_CONTENT;

	my($class) = shift;
	my($self) = $class->SUPER::new;
	my($response) = shift;

	$self->parse($response->content);
	$self->eof();

	$_CONTENT->{HTTP_RESPONSE} = $response; # should eventually get rid of this
	$_CONTENT->{URI} = $response->request->uri;
	$_CONTENT->{TITLE} = $response->title;

	return $_CONTENT;
}

sub start {
	my($self) = shift;
	my($tag, $attr, $attrseq, $origtext) = @_;

	# return if we don't care about this tag
	if ($tag =~ /^($_IGNORED_TAGS)$/i) {
		return;
	}

	if (! defined $self->{text}) {
		#if ($_DEBUG) { print "Warning! No text associated with tag $origtext (using TEXTLESS)\n"; }
		$self->{text} = 'TEXTLESS';
	}

	# only care about this in end()
	if ($tag eq 'tr') {
		return;
	}

	if ($tag eq 'form') {
		$self->_handle_form($attr, $origtext);
		return;
	}

	# if we are in a form now
	if (defined $self->{form}) {

		if ($tag eq 'select') {
			$self->_handle_select($attr, $origtext);
			return;
		}

		# if we are in a select now
		if (defined $self->{select}) {

			if ($tag eq 'option') {
				$self->_handle_option($attr, $origtext);
				return;
			}
		}

		if ($tag eq 'input') {
			my($type) = $attr->{type};

			if (! $type) {
				return;
			}
			elsif ($type eq 'submit') {
				$self->_handle_submit($attr, $origtext);
				return;
			}
			elsif ($type eq 'hidden') {
				$self->_handle_hidden($attr, $origtext);
				return;
			}
			elsif ($type eq 'radio' | $type eq 'checkbox') {
				$self->_handle_radio_checkbox($attr, $origtext);
				return;
			}
			elsif ($type eq 'text' || $type eq 'password' || $type eq 'file') {
				$self->_handle_text_password_file_textarea($attr, $origtext);
				return;
			}
			else {
				print "Found unknown input type in $origtext with state of:\n";
				my($key);
				foreach $key (keys %{$self}) {
					print "$key = $self->{$key}\n";
				}
				die;
			}
		}

		if ($tag eq 'textarea') {
			$self->_handle_text_password_file_textarea($attr, $origtext);
			return;
		}
	}

	if ($tag eq 'a') {
		$self->_handle_a($attr, $origtext);
		return;
	}

	if ($tag eq 'img') {
		$self->_handle_img($attr, $origtext);
		return;
	}

	print "Found unknown tag $tag with state of:\n";
	my($key);
	foreach $key (keys %{$self}) {
		print "$key = $self->{$key}\n";
	}
	die;
}

sub text {
  my($self) = shift;
  my($text) = @_;

	if ($text !~ /\S+/ || $text eq '&nbsp;') { # ignore
		return;
	}

	$text =~ s/\n$//g; # remove new line
	$text =~ s/^ //g;  # remove space at beginning
	$text =~ s/ $//g;  # remove space at end

	# store onscreen text for use in page verification
	if (! ($self->{a} || $self->{radio_or_checkbox} ||
					$self->{select} || $self->{option}) ) {
		if ($_DEBUG_LONG) { print "\$_CONTENT->{TEXT}->{$text} = 1\n"; }
		$_CONTENT->{TEXT}->{$text} = 1;
	}

	# options terminate with text
	if (defined $self->{option}) {
		$self->_store_option($text);
	}
	# radio_or_checkbox inputs terminate with text
	elsif (defined $self->{radio_or_checkbox}) {
		$self->_store_radio_checkbox($text);
	}
	elsif (defined $self->{form} || defined $self->{a}) {
  	$self->{text} = $text;
	}
}

sub end {
	my($self) = shift;
	my($tag, $origtext) = @_;

	# return if we don't care about this tag
	if ($tag =~ /^($_IGNORED_TAGS)$/i) {
		return;
	}

	if ($tag eq 'tr') {
		delete $self->{text};
		delete $self->{radio_or_checkbox};
		return;
	}

	if ($tag eq 'form') {
		delete $self->{form};
		delete $self->{text};
		return;
	}

	if ($tag eq 'select') {
		delete $self->{select};
		return;
	}

	if ($tag eq 'a') {
		$self->_store_href;

		delete $self->{img_name};
		delete $self->{text};
		delete $self->{a};
		return;
	}

	if ($tag eq 'textarea') {
		return;
	}

	print "Found unknown tag $tag with state of:\n";
	my($key);
	foreach $key (keys %{$self}) {
		print "$key = $self->{$key}\n";
	}
	die;
}

#
# Handle <form
#
sub _handle_form {

	my($self) = shift;
	my($attr) = shift;
	my($origtext) = shift;

	my($action) = $attr->{action};
	my($method) = $attr->{method};
	my($name) = $attr->{name};

	if (! $name) {
		if ($_DEBUG) { print "Warning! No name in form: $origtext (using NAMELESS)\n"; }
		$name = 'NAMELESS';
	}

	if ($action) {
		if ($_DEBUG_LONG) { print "\$_CONTENT->{FORMS}->{$name}->{action} = $action\n"; }

		$_CONTENT->{FORMS}->{$name}->{action} = $action;
	}

	if ($method) {
		if ($_DEBUG_LONG) { print "\$_CONTENT->{FORMS}->{$name}->{method} = $method\n"; }

		$_CONTENT->{FORMS}->{$name}->{method} = $method;
	}

	$self->{form} = $name;
}

#
# Handle <select ...>
#
sub _handle_select {
	my($self) = shift;
	my($attr) = shift;
	my($origtext) = shift;

	my($name) = $attr->{name};

	my($action) = $_CONTENT->{FORMS}->{$self->{form}}->{action};
	my($method) = $_CONTENT->{FORMS}->{$self->{form}}->{method};

	my($text) = $self->{text};

	if ($text eq 'TEXTLESS' && $action && $action eq '/goto') {
		$text = 'RealmChooser'; # so far this seems true
	}

	$self->{select} = $text;

	if ($_DEBUG_LONG) { print "\$_CONTENT->{FORMS}->{$self->{form}}->{$self->{select}}->{name} = $name\n"; }

	$_CONTENT->{FORMS}->{$self->{form}}->{$self->{select}}->{name} = $name;

	if ($_DEBUG_LONG) { print "\$_CONTENT->{FORMS}->{$self->{form}}->{$self->{select}}->{action} = $action\n"; }

	$_CONTENT->{FORMS}->{$self->{form}}->{$self->{select}}->{action} = $action;

	if ($_DEBUG_LONG) { print "\$_CONTENT->{FORMS}->{$self->{form}}->{$self->{select}}->{method} = $method\n"; }

	$_CONTENT->{FORMS}->{$self->{form}}->{$self->{select}}->{method} = $method;
}

#
# Handle <option ...>
#
sub _handle_option {
	my($self) = shift;
	my($attr) = shift;
	my($origtext) = shift;

	$self->{option} = $attr->{value};
}

#
# Handle <input type=submit ...>
#
sub _handle_submit {
	my($self) = shift;
	my($attr) = shift;
	my($origtext) = shift;

	my($name) = $attr->{name};
	my($value) = $attr->{value}; # text on the screen

	if ($name) { # only need info for submit inputs with a name
		if ($_DEBUG_LONG) { print "push \@{\$_CONTENT->{FORMS}->{$self->{form}}->{$value}}, $name\n"; }

		push @{$_CONTENT->{FORMS}->{$self->{form}}->{$value}}, $name;
	}
}

#
# Handle <input type=hidden ...>
#
sub _handle_hidden {
	my($self) = shift;
	my($attr) = shift;
	my($origtext) = shift;

	my($name) = $attr->{name};
	my($value) = $attr->{value};

	if ($_DEBUG_LONG) { print "\$_CONTENT->{FORMS}->{$self->{form}}->{HIDDEN_FIELDS}->{$name} = $value\n"; }

	$_CONTENT->{FORMS}->{$self->{form}}->{HIDDEN_FIELDS}->{$name} = $value;
}

#
# Handle <input type=radio|checkbox ...>
#
sub _handle_radio_checkbox {
	my($self) = shift;
	my($attr) = shift;
	my($origtext) = shift;

	my($name) = $attr->{name};
	my($value) = $attr->{value};

	$self->{radio_or_checkbox} = $name.'='.$value;
}

#
# Handle <input type=text|password|file ...> or <textarea ...>
#
sub _handle_text_password_file_textarea {
	my($self) = shift;
	my($attr) = shift;
	my($origtext) = shift;

	my($name) = $attr->{name};
	my($value) = $attr->{value};

	my($text) = $self->{text};

	my($out);
	if ($value) {
		$out = $name.'='.$value; # name=value
	}
	else {
		$out = $name.'='; # name=
	}

	if ($text) {
		if ($_DEBUG_LONG) { print "push \@{\$_CONTENT->{FORMS}->{$self->{form}}->{$text}}, $out\n"; }

		push @{$_CONTENT->{FORMS}->{$self->{form}}->{$text}}, $out;
	}
	else {
		die("No text found associated with text/password/file/textarea input: $origtext");
	}
}

#
# Handle <a ...>
#
sub _handle_a {
	my($self) = shift;
	my($attr) = shift;
	my($origtext) = shift;

	$self->{a} = $attr->{href};
}

#
# Handle <img ...>
#
sub _handle_img {
	my($self) = shift;
	my($attr) = shift;
	my($origtext) = shift;

	$self->{img_name} = $attr->{src}; # image name
}

#
# Store the option info
#
sub _store_option {
	my($self) = shift;
	my($text) = shift;

	if (! defined $self->{form}) {
		if ($_DEBUG) { print "Warning! Skipping <option ...> because of nameless form\n"; }

		delete $self->{option};

		return;
	}

	if ($_DEBUG_LONG) { print "\$_CONTENT->{FORMS}->{$self->{form}}->{$self->{select}}->{$text} = $self->{option}\n"; }
	$_CONTENT->{FORMS}->{$self->{form}}->{$self->{select}}->{$text} = $self->{option};

	delete $self->{option};
}

#
# Store the radio or checkbox info
#
sub _store_radio_checkbox {
	my($self) = shift;
	my($text) = shift;

	if (! defined $self->{form}) {
		if ($_DEBUG) { print "Warning! Skipping radio_or_checkbox input because of nameless form\n"; }

		delete $self->{radio_or_checkbox};

		return;
	}

	if (defined $text) {
		if ($_DEBUG_LONG) { print "\$_CONTENT->{FORMS}->{$self->{form}}->{$text} = $self->{radio_or_checkbox}\n"; }
		$_CONTENT->{FORMS}->{$self->{form}}->{$text} = $self->{radio_or_checkbox};
	}
	else {
		if ($_DEBUG) { print "Warning! radio_or_checkbox input had no associated text (ignoring)\n"; }
	}

	delete $self->{radio_or_checkbox};
}

#
# Store the href link
#
sub _store_href {
	my($self) = shift;

	my($text);
	if ($self->{text}) {
		$text = $self->{text};
		$text =~ s/&amp;/&/g;
	}

	my($img_base);
	if (defined $self->{img_name}) {
		($img_base) = ($self->{img_name} =~ /(\w+)\.\w+/);
	}

	my($href);
	if (defined $self->{a}) {
		($href) = ($self->{a} =~ /^(\/\S*)$/);
		if (! $href) {
			($href) = (('/'.$self->{a}) =~ /^(\/\S+)$/); # some are missing first /
		}
	}

	if ($text) {
		if ($_DEBUG_LONG) { print "\$_CONTENT->{LINKS}->{$text} = $href\n"; }
		$_CONTENT->{LINKS}->{$text} = $href;
	}

	if ($img_base) {
		if ($_DEBUG_LONG) { print "\$_CONTENT->{LINKS}->{$img_base} = $href\n"; }
		$_CONTENT->{LINKS}->{$img_base} = $href;

		# flip _on / _off in image name and apply, if applicable
		if ($img_base =~ /_off$/) {
			$img_base =~ s/_off$/_on/;
			if ($_DEBUG_LONG) { print "\$_CONTENT->{LINKS}->{$img_base} = $href\n"; }
			$_CONTENT->{LINKS}->{$img_base} = $href;
		}
		else {
			$img_base =~ s/_on$/_off/;
			if ($_DEBUG_LONG) { print "\$_CONTENT->{LINKS}->{$img_base} = $href\n"; }
			$_CONTENT->{LINKS}->{$img_base} = $href;
		}
	}

	return;
}

1;

