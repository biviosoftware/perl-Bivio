# Copyright (c) 2000 bivio Inc.  All rights reserved.
# $Id$
package Bivio::Test::HTMLAnalyzer;
use strict;
$Bivio::Test::HTMLAnalyzer::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Test::HTMLAnalyzer::VERSION;

=head1 NAME

Bivio::Test::HTMLAnalyzer - semantically analyse Bivio pages

=head1 SYNOPSIS

    use Bivio::Test::HTMLAnalyzer;

=cut

=head1 EXTENDS

L<Bivio::UNIVERSAL>

=cut

use Bivio::UNIVERSAL;
@Bivio::HTMLAnalyzer::ISA = ('Bivio::UNIVERSAL');

=head1 DESCRIPTION

C<Bivio::Test::HTMLAnalyzer> applies heuristics to previously parsed
HTML pages and attempts to determine their semantic content.  It is
never concerned with the original HTML.

To do: remove $self->{'Bivio::Test::HTMLParser'} = $p in new().
Add 'escaping' to gen_form_get().

=cut

#=IMPORTS
use Bivio::IO::Trace;
use Bivio::Die;
use Bivio::Test::HTMLParser;
use Data::Dumper;

#=VARIABLES
use vars ('$_TRACE');
Bivio::IO::Trace->register;
my($_PACKAGE) = __PACKAGE__;


=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(string content) : Bivio::HTMLAnalyzer

Parse an HTML page and attempt to semantically analyze it.

=cut

sub new {
    my($proto,$content) = @_;
    my($self) = Bivio::UNIVERSAL::new($proto);
    my($fields) = $self->{$_PACKAGE} = {};

    my($p) = Bivio::Test::HTMLParser->new($content)->get_fields();

#   $fields->{title} = $p->get_title();
    $fields->{title} = $p->{title};

    # save parser's output, for reference when debugging.
    # for convenience when reading the output, we temporarily put
    # it under the top level of $self, not under $fields.
    $self->{'Bivio::Test::HTMLParser'} = $p;

    # problem domain question: does any table contain multiple forms?
    for (my($i) = 0; $i < int(@{$p->{tables}}); $i++) {
	if (defined($p->{tables}[$i]->{forms})) {
	    Bivio::Die->die("Table has multiple forms!\n")
		    unless (int(keys(%{$p->{tables}[$i]->{forms}})) < 2);
	}
    }

    $fields->{form_list} = [];
   
    _find_button_home_page($self, $p);
    _find_button_logout($self, $p);
    _find_button_my_site($self, $p);

    _find_imagemenu($self, $p);
    _find_login($self, $p);
    _find_preferences($self, $p);
    _find_realm_chooser($self, $p);
    _find_tos($self, $p);

    # any unidentified table must be the 'main' table.
    for (my($i) = 0; $i < int(@{$p->{tables}}); $i++) {
	unless (defined($p->{tables}[$i]->{identification})) {
	    Bivio::Die->die("ambiguous 'main' table\n")
			if (defined($fields->{main}));
	    $p->{tables}[$i]->{identification} = 'Main';
	    $fields->{main} = $p->{tables}[$i];
	    push(@{$fields->{form_list}}, 'main');
	}
    }
 
    if ($_TRACE) {
	my($dd) = Data::Dumper->new([$self]);
	$dd->Indent(1);
	$dd->Terse(1);
	$dd->Deepcopy(1);
	print STDERR $dd->Dumpxs();
    }

    return $self;
}

=head1 METHODS

=cut

=for html <a name="find_row_by_content"></a>

=head2 find_row_by_content(Bivio::HTML::HTMLAnalyzer self, string pattern)

Find the first row in the main table which contains the specified
pattern in either the 'links' or 'text' array.

=cut

sub find_row_by_content {
    my($self, $pattern) = @_;
    my($fields) = $self->{$_PACKAGE};

    return undef unless (defined($fields->{main})
	    && defined($fields->{main}->{rows}));

    my($q) = $fields->{main}->{rows};
    for (my($i) = 0; $i < int(@{$q}); $i++) {
	if (defined(@{$q}[$i]->{links})) {
	    my(@keys) = keys(%{@{$q}[$i]->{links}});
	    for (my($j) = 0; $j < int(@keys); $j++) {
		return @{$q}[$i] if ($keys[$j] =~ $pattern);
	    }
	}

	if (defined(@{$q}[$i]->{text})) {
	    for (my($j) = 0; $j < int(@{@{$q}[$i]->{text}}); $j++) {
		return @{$q}[$i] if (@{$q}[$i]->{text}->[$j] =~ $pattern);
	    }
	}
    }

    return undef;
}

=for html <a name="gen_form_data"></a>

=head2 gen_form_data(Bivio::Test::HTMLAnalyzer self, string name, hash_ref p) : hash_ref

Return a hash_ref that contains all information necessary to submit the
form to the HTTP object.  The hash_ref passed in should be a modified
version of the public fields returned by list_public_fields.

=cut

sub gen_form_data {
    my($self, $name, $p) = @_;
    my($fields) = $self->{$_PACKAGE};
    my($data) = [];
    my($key);
    my($_VALID_METHODS) = 'post|get';

    Bivio::Die->die ("specified form does not exist: $name!")
		unless defined($fields->{$name});

    my($form_name) = $fields->{$name}->{form_name};
    my($form) = $fields->{$name}->{forms}->{$form_name};
    my($method) = $form->{method};

    Bivio::Die->die ("unexpected form method: $method")
		unless ($method =~ /^(?:$_VALID_METHODS)$/io);
    $method = 'post' if ($method =~ /^post$/io);
    $method = 'get' if ($method =~ /^get$/io);

    if (defined($p)) {
	foreach $key (keys(%{$p})) {
	    if (defined($p->{$key}->{value})) {
		push(@{$data}, { name => $p->{$key}->{name},
		    value => $p->{$key}->{value} });
	    }
	    else {
		push(@{$data}, { name => $p->{$key}->{name} } );
	    }
	}
    }

    $p = $form->{hidden_fields};
    if (defined($p)) {
	foreach $key (keys(%{$p})) {
	    if (defined($p->{$key}->{value})) {
		push(@{$data}, { name => $p->{$key}->{name},
		    value => $p->{$key}->{value} });
	    }
	    else {
		push(@{$data}, { name => $p->{$key}->{name} } );
	    }
	}
    }

    return {
	action => $form->{action},
        method => $method,
        data => $data };
}

=for html <a name="gen_form_uri"></a>

=head2 gen_form_uri(Bivio::Test::HTMLAnalyzer self, string name, hash_ref fields) : array_ref

Generate the URI and passed data for the named form and values.  If the
field hash_ref is undefined, the default values are used.

=cut

sub gen_form_uri {
    my($self, $name, $form_fields) = @_;
    my($fields) = $self->{$_PACKAGE};
    my($_VALID_METHODS) = 'post|get';

    # dispatch the appropriate handler.
    my($form_name) = $fields->{$name}->{form_name};
    my($method) = $fields->{$name}->{forms}->{$form_name}->{method};
    $method = 'post' if ($method =~ /^post$/io);
    $method = 'get' if ($method =~ /^get$/io);
    Bivio::Die->die ("unexpected form method: $method")
		unless ($method =~ /^(?:$_VALID_METHODS)$/io);
    $method = '_gen_form_'.$method;

    $form_fields = $fields->{$name}->{forms}->{$form_name}->{fields}
	    unless defined($form_fields);
   
    return &{\&{$method}} ({ form => $fields->{$name}->{forms}->{$form_name},
	fields => $form_fields });
}

=for html <a name="get_form_action"></a>

=head2 get_form_action(Bivio::Test::HTMLAnalyzer self, string name) : string

Return a string containing the 'action' of the named form.

=cut

sub get_form_action {
    my($self, $name) = @_;
    my($fields) = $self->{$_PACKAGE};

    Bivio::Die->die ("No such form!") unless defined ($fields->{$name});

    my($form_name) = $fields->{$name}->{form_name};
    return ($fields->{$name}->{forms}->{$form_name}->{action});

    return;
}

=for html <a name="get_form_method"></a>

=head2 get_form_method(Bivio::Test::HTMLAnalyzer self, string name) : string

Return a string containing the 'method' of the named form.  This should
always be the string 'POST' or 'GET'.  (Use enumeration instead?)

=cut

sub get_form_method {
    my($self, $name) = @_;
    my($fields) = $self->{$_PACKAGE};

    Bivio::Die->die ("No such form!") unless defined ($fields->{$name});

    my($form_name) = $fields->{$name}->{form_name};
    return ($fields->{$name}->{forms}->{$form_name}->{method});
}

=for html <a name="get_title"></a>

=head2 get_title(Bivio::Test::HTMLAnalyzer self) : string

Return a string containing the "title" of the document.  If none
was defined, an 'undef' is returned.

=cut

sub get_title {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    return ($fields->{title});
}

=for html <a name="list_form_fields"></a>

=head2 list_all_public_fields(Bivio::Test::HTMLAnalyzer self, string name) : hash_ref

Return a hash_ref containing all public fields in all forms.


=cut

sub list_all_public_fields {
    my($self,$name) = @_;
    my($fields) = $self->{$_PACKAGE};
    my($results) = {};
    my($form);

    foreach $form (@{$fields->{form_list}}) {
	my($f) = $self->list_public_fields($form);
	@{$results->{$form}} = keys(%{$f});
    }

    return $results;
}

=for html <a name="list_forms_by_field"></a>

=head2 list_forms_by_field(HTMLAnalyzer self) : hash_ref 

Return a hash_ref mapping public fields to the forms that contain them.
The results are undefined if the same label appears in multiple forms.

=cut

sub list_forms_by_field {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    my($results) = {};
    my($form);

    foreach $form (@{$fields->{form_list}}) {
	my($f) = $self->list_public_fields($form);
	if (int($f) > 0) {
	    my($g);
	    foreach $g (keys(%{$f})) {
		$results->{$g} = $form;
	    }
	}
    }

    return $results;
}

=for html <a name="list_private_fields"></a>

=head2 list_private_fields(Bivio::Test::HTMLAnalyzer self, string name) : hash_ref

Return a hash_ref containing information about all private (hidden) input
fields for the named form.  If none exist, 'undef' is returned.

=cut

sub list_private_fields {
    my($self, $name) = @_;
    my($fields) = $self->{$_PACKAGE};

    Bivio::Die->die ("No such form!") unless defined ($fields->{$name});

    my($form_name) = $fields->{$name}->{form_name};
    return ($fields->{$name}->{forms}->{$form_name}->{hidden_fields});
}

=for html <a name="list_public_fields"></a>

=head2 list_public_fields(Bivio::Test::HTMLAnalyzer self, string name) : hash_ref

Return a hash_ref containing information about all public input fields
in the named form.  If no public input fields exist, this procedure will
return an 'undef'.

=cut

sub list_public_fields {
    my($self, $name) = @_;
    my($fields) = $self->{$_PACKAGE};

    Bivio::Die->die ("No such form!") unless defined ($fields->{$name});

    my($form_name) = $fields->{$name}->{form_name};
    return ($fields->{$name}->{forms}->{$form_name}->{fields});
}

=for html <a name="list_forms"></a>

=head2 list_forms(Bivio::Test::HTMLAnalyzer self) : array_ref;

List the nmenomic names for all forms present in the page as an
array of strings.

=cut

sub list_forms {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    return (\@{$fields->{form_list}});
}

#=PRIVATE METHODS

# _find_button_home_page(Bivio::Test::HTMLAnalyzer self, hash_ref p)
#
# Identify the home page button on the HTML page, if any.
# It is stored under fields->{buttons}->{homepage}.
#
sub _find_button_home_page {
    my($self, $p) = @_;
    my($fields) = $self->{$_PACKAGE};

    if (exists($p->{links}->{'Home Page'})) {
	$fields->{buttons} = {} unless defined($fields->{buttons});
	$fields->{buttons}->{homepage} = $p->{links}->{'Home Page'};
    }
    return;
}

# _find_button_logout(Bivio::Test::HTMLAnalyzer self, hash_ref p)
#
# Identify the logout button on the HTML page, if any.
# It is stored under fields->{buttons}->{logout}.
#
sub _find_button_logout {
    my($self, $p) = @_;
    my($fields) = $self->{$_PACKAGE};

    if (exists($p->{links}->{Logout})) {
	$fields->{buttons} = {} unless defined($fields->{buttons});
	$fields->{buttons}->{logout} = $p->{links}->{Logout};
    }
    return;
}

# _find_button_my_site(Bivio::Test::HTMLAnalyzer self, hash_ref p)
#
# Identify the 'My Site' button on the HTML page, if any.
# It is stored under fields->{buttons}->{mysite}.
#
sub _find_button_my_site {
    my($self, $p) = @_;
    my($fields) = $self->{$_PACKAGE};
 
    if (exists($p->{links}->{'My Site'})) {
	$fields->{buttons} = {} unless defined($fields->{buttons});
	$fields->{buttons}->{mysite} = $p->{links}->{'My Site'};
    }
    return;
}

# _find_imagemenu(Bivio::Test::HTMLAnalyzer self, hash_ref p)
#
# Identify the image menu on the HTML page, if any.
# It is stored under fields->{imagemenu}.
#
sub _find_imagemenu {
    my($self, $p) = @_;
    my($fields) = $self->{$_PACKAGE};

    for (my($i) = 0; $i < int(@{$p->{tables}}); $i++) {
	if (exists($p->{tables}[$i]->{links}->{Roster})) {
	    $fields->{imagemenu} = {} unless defined($fields->{imagemenu});
	    $fields->{imagemenu}->{administration} = $p->{tables}[$i];
	    $p->{tables}[$i]->{identification} = 'Image Menu';
	    push(@{$p->{form_list}}, 'imagemenu');
	}
	elsif (exists($p->{tables}[$i]->{links}->{Taxes})) {
	    $fields->{imagemenu} = {} unless defined($fields->{imagemenu});
	    $fields->{imagemenu}->{accounting} = $p->{tables}[$i];
	    $p->{tables}[$i]->{identification} = 'Image Menu';
	    push(@{$p->{form_list}}, 'imagemenu');
	}
	elsif (exists($p->{tables}[$i]->{links}->{Mail})) {
	    $fields->{imagemenu} = {} unless defined($fields->{imagemenu});
	    $fields->{imagemenu}->{accounting} = $p->{tables}[$i];
	    $p->{tables}[$i]->{identification} = 'Image Menu';
	    push(@{$p->{form_list}}, 'imagemenu');
	}
    }
 
    return;
}

# _find_login(Bivio::Test::HTMLAnalyzer self, hash_ref p)
#
# Identify the login menu on the HTML page, if any.
# It is stored under fields->{login}.
#
sub _find_login {
    my($self, $p) = @_;
    my($fields) = $self->{$_PACKAGE};

#    my(@f) = values(%{$p->{forms}});
#    for (my($i) = 0; $i < int(@f); $i++) {
#	if (exists($f[$i]->{submit}->{Login})) {
# 	    $fields->{login} = $f[$i];
#	}
#    }
    for (my($i) = 0; $i < int(@{$p->{tables}}); $i++) {
	if (exists($p->{tables}[$i]->{links}->{'Login'})) {
	    $p->{tables}[$i]->{identification} = 'Login';
	    push(@{$p->{form_list}}, 'login');
	    $fields->{login} = $p->{tables}[$i];
	}
    }
    return;
}

# _find_preferences(Bivio::Test::HTMLAnalyzer self, hash_ref p)
#
# Identify the preferences form on the HTML page, if any.
# It is stored under fields->{preferencemenu}.
#
sub _find_preferences {
    my($self, $p) = @_;
    my($fields) = $self->{$_PACKAGE};

#    my(@f) = values(%{$p->{forms}});
#    for (my($i) = 0; $i < int(@f); $i++) {
#	if (exists($f[$i]->{submit}->{'Change Preferences'})) {
# 	    $fields->{preferencemenu} = $f[$i];
#	}
#    }

    for (my($i) = 0; $i < int(@{$p->{tables}}); $i++) {
	if (exists($p->{tables}[$i]->{forms})) {
	    my(@f) = values(%{$p->{tables}[$i]->{forms}});
	    Bivio::Die->die('unexpected number of forms') unless ($#{@f} < 2);
	    if ($#{@f} && exists($f[0]->{submit}->{'Change Preferences'})) {
		$fields->{preferencemenu} = $p->{tables}[$i];
		push(@{$fields->{form_list}}, 'preferencemenu');
	    }
	}
    }
    return;
}

# _find_realm_chooser(Bivio::Test::HTMLAnalyzer self, hash_ref p)
#
# Identify the realm chooser form on the HTML page, if any.
# It is stored under fields->{realmchooser}.
#
sub _find_realm_chooser {
    my($self, $p) = @_;
    my($fields) = $self->{$_PACKAGE};

#    my(@f) = values(%{$p->{forms}});
#    for (my($i) = 0; $i < int(@f); $i++) {
#	if ($f[$i]->{action} eq '/goto') {
# 	    $fields->{realmchooser} = $f[$i];
#	}
#    }

    for (my($i) = 0; $i < int(@{$p->{tables}}); $i++) {
	if (exists($p->{tables}[$i]->{forms})) {
	    my(@f) = values(%{$p->{tables}[$i]->{forms}});
	    Bivio::Die->die('unexpected number of forms') unless ($#{@f} < 2);
	    if ($#{@f} && $f[0]->{action} eq '/goto') {
		$fields->{realmchooser} = $p->{tables}[$i];
		push(@{$fields->{form_list}}, 'realmchooser');
	    }
	}
    }
    return;
}

# _find_tos(Bivio::Test::HTMLAnalyzer self, hash_ref p)
#
# Identify the "terms of condition" form/table on the HTML page, if any.
# It is stored under fields->{tos}
#
sub _find_tos {
    my($self, $p) = @_;
    my($fields) = $self->{$_PACKAGE};

    for (my($i) = 0; $i < int(@{$p->{tables}}); $i++) {
	if (exists($p->{tables}[$i]->{links}->{'Terms of Service'})) {
	    $p->{tables}[$i]->{identification} = 'Terms of Service';
	    $fields->{tos} = $p->{tables}[$i];
	    push(@{$fields->{form_list}}, 'tos');
	}
    }
    return;
}

# _gen_form_get (hash_ref p) : array_ref
#
# Generate the URI and data for a "GET" form.
#
sub _gen_form_get {
    my($p) = @_;
    my($results) = $p->{form}->{action};
    my($key);

    $results .= '?';

    if (defined($p->{fields})) {
	foreach $key (keys(%{$p->{fields}})) {
	    $results .= $p->{fields}->{$key}->{name};
	    $results .= '='.$p->{fields}->{$key}->{value}
		    if (defined($p->{fields}->{$key}->{value}));
	    $results .= '&';
	}
    }
    if (defined($p->{form}->{hidden_fields})) {
	foreach $key (keys(%{$p->{form}->{hidden_fields}})) {
	    $results .= $p->{form}->{hidden_fields}->{$key}->{name};
	    $results .= '='.$p->{form}->{hidden_fields}->{$key}->{value}
		    if (defined($p->{form}->{hidden_fields}->{$key}->{value}));
	    $results .= '&';
	}
    }
    chomp ($results);

    return \@{[ $results ]};
}

# _gen_form_post(hash_ref p) : array_ref
#
# Generate the URI and data for a "POST" form.
#
sub _gen_form_post {
    my($p) = @_;
    my($data) = [];
    my($key);

    if (defined($p->{fields})) {
	foreach $key (keys(%{$p->{fields}})) {
	    my($line) = $p->{fields}->{$key}->{name};
	    $line .= '='.$p->{fields}->{$key}->{value}
		    if (defined($p->{fields}->{$key}->{value}));
	    push(@{$data}, $line);
	}
    }

    if (defined($p->{form}->{hidden_fields})) {
	foreach $key (keys(%{$p->{form}->{hidden_fields}})) {
	    my($line) = $p->{form}->{hidden_fields}->{$key}->{name};
	    $line .= '='.$p->{form}->{hidden_fields}->{$key}->{value}
		    if (defined($p->{form}->{hidden_fields}->{$key}->{value}));
	    push(@{$data}, $line);
	}
    }
    return \@{[ $p->{form}->{action}, $data ]};
}

	
#	my($dd) = Data::Dumper->new([$vv]);
#	$dd->Indent(1);
#	$dd->Terse(1);
#	$dd->Deepcopy(1);
#	print($dd->Dumpxs());

=head1 COPYRIGHT

Copyright (c) 2000 bivio Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
