# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::PDF::Dictionary;
use strict;
$Bivio::UI::PDF::Dictionary::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::PDF::Dictionary - encapsulates a PDF dictionary direct object.

=head1 SYNOPSIS

    use Bivio::UI::PDF::Dictionary;
    Bivio::UI::PDF::Dictionary->new();

=cut

=head1 EXTENDS

L<Bivio::UI::PDF::DirectObj>

=cut

use Bivio::UI::PDF::DirectObj;
@Bivio::UI::PDF::Dictionary::ISA = ('Bivio::UI::PDF::DirectObj');

=head1 DESCRIPTION

C<Bivio::UI::PDF::Dictionary>

=cut


#=IMPORTS
use Bivio::IO::Trace;
use Bivio::UI::PDF::ArrayIterator;
use Bivio::UI::PDF::Regex;

#=VARIABLES
use vars ('$_TRACE');
Bivio::IO::Trace->register;
my($_PACKAGE) = __PACKAGE__;

my($_DIC_END_REGEX) = Bivio::UI::PDF::Regex::DIC_END_REGEX();
my($_IGNORE_REGEX) = Bivio::UI::PDF::Regex::IGNORE_REGEX();
my($_NAME_REGEX) = Bivio::UI::PDF::Regex::NAME_REGEX();

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new() : Bivio::UI::PDF::Dictionary



=cut

sub new {
    my($self) = Bivio::UI::PDF::DirectObj::new(@_);
    $self->{$_PACKAGE} = {
	'values' => {},
	'order' => []	# Keep the key names in the order read in.
    };
    return $self;
}

=head1 METHODS

=cut

=for html <a name="clone"></a>

=head2 clone() : 



=cut

sub clone {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    my($clone) = Bivio::UI::PDF::Dictionary->new();
    my($clone_fields) = $clone->{$_PACKAGE};
    local($_);

    map {
	${$clone_fields->{'values'}}{$_} = ${$fields->{'values'}}{$_}->clone();
	push(@{$clone_fields->{'order'}}, $_);
    } @{$fields->{'order'}};

    return($clone);
}

=for html <a name="emit"></a>

=head2 emit() : 



=cut

sub emit {
    my($self, $emit_ref) = @_;
    my($fields) = $self->{$_PACKAGE};
    local($_);

    # Find out how many characters this object will emit to decide whether or
    # not to render it on one line.
    my($separator);
    if ($self->get_max_line() < $self->emit_length()) {
	$separator = "\n";
    }
    else {
	$separator = ' ';
    }

    # Emit the items in the order in which we read them in.
    $emit_ref->append_no_new_lines('<<');
    $emit_ref->append($separator);
    my($direct_obj_ref);
    map {
	$direct_obj_ref = ${$fields->{'values'}}{$_};
	$emit_ref->append_no_new_lines('/');
	$emit_ref->append($_ . ' ');
	$direct_obj_ref->emit($emit_ref);
	$emit_ref->append($separator);
    } @{$fields->{'order'}};
    $emit_ref->append_no_new_lines('>>');
    return;
}

=for html <a name="emit_length"></a>

=head2 emit_length() : 



=cut

sub emit_length {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    my($length) = 6;	# For the initial '<< ' and final ' >>';
    my($name, $direct_obj_ref);
    while (($name, $direct_obj_ref) = each(%{$fields->{'values'}})) {
	$length += length($name) + 2;	# 2 for the '/' and a space.
	$length += $direct_obj_ref->emit_length();
    }
    return($length);
}

=for html <a name="extract"></a>

=head2 extract() : 



=cut

sub extract {
    my($self, $line_iter_ref) = @_;
    my($fields) = $self->{$_PACKAGE};

    # The current line has the '<<' on it.  It may or may not have data
    # dictionary items as well.  Get the text of the line, remove the '<<",
    # remove the current line from the iterator, and push the altered text back
    # on the iterator so it gets read again (the version without the '<<').
    my($text) = ${$line_iter_ref->current_ref()};
    $text =~ s/\<\<//;
    $line_iter_ref->replace_first($text);

    #_trace("Extracting dictionary starting\n\t\"",
	#    ${$line_iter_ref->current_ref()}, "\"") if $_TRACE;

    while (1) {
	if (${$line_iter_ref->current_ref()}
		=~ /$_NAME_REGEX|$_IGNORE_REGEX|$_DIC_END_REGEX/) {
	    if (defined($1)) {
		# We found a name.
		my($name) = $1;

		# Remove the text up to and including that which we matched.
		$line_iter_ref->replace_first($'); #'

		# _trace("Dictionary key \"$name\"") if $_TRACE;

		# Extract the value that goes with the name.
		my($direct_obj_ref) = $self->extract_direct_obj($line_iter_ref);

	        # Add the name and direct object reference to the dictionary.
		${$fields->{'values'}}{$name} = $direct_obj_ref;

		# Add the name to the array of names we keep to keep track of
		# the order of the items.
		push(@{$fields->{'order'}}, $name);
	    } elsif (defined($2)) {
		# We found a blank line.
		$line_iter_ref->increment();
	    } elsif (defined($3)) {
		# We found the end of the dictionary text.  Remove the '>>".
		$line_iter_ref->replace_first($'); #'
		last;
	    } else {
		die(__FILE__, ", ", __LINE__, ": no matched text returned\n");
	    }
	} else {
	    die(__FILE__, ", ", __LINE__, ": No match\n");
	}
    }
    return;
}

=for html <a name="get_value"></a>

=head2 get_value() : 



=cut

sub get_value {
    my($self, $key) = @_;
    my($fields) = $self->{$_PACKAGE};
    return(${$fields->{'values'}}{$key});
}

=for html <a name="insert_field_value"></a>

=head2 insert_field_value() : 



=cut

sub insert_field_value {
    my($self, $new_value, $form_ref, $field_type) = @_;
    my($fields) = $self->{$_PACKAGE};
    my($return_value) = undef;

    unless (defined($field_type)) {
	my($field_type_ref) = $self->get_value('FT');
	$field_type = $field_type_ref->get_value();
    }

    # It seems to be the case that we need to add /V or /AS values to the
    # object dictionary that contains the /Type /Annot pair.
    my($type) = $self->get_value('Type');
    if (defined($type) && ('Annot' eq $type->get_value())) {
	# Add teh value here.
	if ('Tx' eq $field_type) {
	    $self->set_value('V', Bivio::UI::PDF::StringParen->new($new_value));
	    $self->set_value('NeedAppearances',
		    Bivio::UI::PDF::Boolean->new('true'));
	}
	elsif ('Btn' eq $field_type) {
	    $self->set_value('AS',
		    Bivio::UI::PDF::Name->new($new_value));
	}
    }
    else {
	# See if there is a kid.
	my($kids_array_ref) = $self->get_value('Kids');
	if (defined($kids_array_ref)) {
	    my($ref_obj) = ${$kids_array_ref->get_array_ref()}[0];
	    my($obj_number) = $ref_obj->get_obj_number();
	    my($obj_ref) = $form_ref->get_obj_ref($obj_number);
	    my($direct_obj_ref) = $obj_ref->get_direct_obj_ref();
	    $direct_obj_ref->insert_field_value($new_value, $form_ref,
		    $field_type);
	    $return_value = $obj_ref;
#TODO: Handle multiple kids.
	}
	else {
	    die(__FILE__, ", ", __LINE__, ": no place for new value\n");
	}
    }

    return($return_value);
}




#     my($field_type_ref);
#     if ($field_type_ref = $self->get_value('FT')) {
# 	my($field_type) = $field_type_ref->get_value();
# 	if ('Tx' eq $field_type) {
# 	    $self->set_value('V', Bivio::UI::PDF::StringParen->new($new_value));
# 	    $self->set_value('NeedAppearances',
# 		    Bivio::UI::PDF::Boolean->new('true'));
# 	}
# 	elsif ('Btn' eq $field_type) {
# 	    # The IRS forms seem to all have /AS set in the Btn fields, which
# 	    # can be set in a kid.  Setting a value with /v doesn't seem to
# 	    # work in this case, so we need to change the value of /AS from
# 	    # /Off to /Yes.
# 	    my($as);
# 	    if ($as = $self->get_value('AS')) {
# 		$self->set_value('AS',
# 			Bivio::UI::PDF::StringParen->new($new_value));
# 	    } else {
# 		# See if there is a kid.
# 		my($kids_array_ref) = $self->get_value('Kids');
# 		if (defined($kids_array_ref)) {
# 		    my($ref_obj) = ${$kids_array_ref->get_array_ref()}[0];
# 		    my($obj_number) = $ref_obj->get_obj_number();
# 		    my($obj_ref) = $form_ref->get_obj_ref($obj_number);
# 		    my($direct_obj_ref) = $obj_ref->get_direct_obj_ref();
# 		    $direct_obj_ref->insert_field_value($new_value, $form_ref);
# 		    $return_value = $obj_ref;
# #TODO: Handle multiple kids.
# 		}
# 		else {
# 		    die(__FILE__, ", ", __LINE__, ": no place for new value\n");
# 		}
# 	    }
# 	}
# 	else {
# 	    die(__FILE__, ", ", __LINE__, ": unknown field type \"",
# 		    $field_type, "\"\n");
# 	}
#     }
#     elsif ($field_type_ref = $self->get_value('AS')) {
# 	$self->set_value('AS', Bivio::UI::PDF::Name->new($new_value));
#     }
#     else {
# 	die(__FILE__, ", ", __LINE__, ": no field type\n");
#     }

#     return($return_value);
# }

=for html <a name="is_dictionary"></a>

=head2 is_dictionary() : 



=cut

sub is_dictionary {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    return(1);
}

=for html <a name="set_value"></a>

=head2 set_value() : 



=cut

sub set_value {
    my($self, $key, $new_value) = @_;
    my($fields) = $self->{$_PACKAGE};
    ${$fields->{'values'}}{$key} = $new_value;
    push(@{$fields->{'order'}}, $key);
    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
