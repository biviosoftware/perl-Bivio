# Copyright (c) 2000 bivio Inc.  All rights reserved.
# $Id$
package Bivio::Test::HTMLAnalyzer;
use strict;
$Bivio::Test::HTMLAnalyzer::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Test::HTMLAnalyzer::VERSION;

=head1 NAME

Bivio::Test::HTMLAnalyzer - analyse Bivio page to identify logical components
of a Bivio page.

=head1 SYNOPSIS

    use Bivio::Test::HTMLAnalyzer;

=cut

=head1 EXTENDS

L<Bivio::UNIVERSAL>

=cut

use Bivio::UNIVERSAL;
@Bivio::HTMLAnalyzer::ISA = ('Bivio::UNIVERSAL');
#@Bivio::HTMLAnalyzer::HASA = ('Bivio::Test::HTMLParser');

=head1 DESCRIPTION

C<Bivio::Test::HTMLAnalyzer>

=cut

#=IMPORTS
use Bivio::IO::Trace;
use Bivio::Die;
use Bivio::Test::HTMLParser;
use Data::Dumper;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;


=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(string content) : Bivio::HTMLAnalyzer

Parse an HTML page, analyze it, and t

=cut

sub new {
    my($proto,$content) = @_;
    my($self) = Bivio::UNIVERSAL::new($proto);
    my($fields) = $self->{$_PACKAGE} = {};
    
    my($p) = Bivio::Test::HTMLParser->new($content);
    $p = $p->{'Bivio::Test::HTMLParser'};

    # save parser's output, for reference.
    $self->{'Bivio::Test::HTMLParser'} = $p;

    # problem domain question: does any table contain multiple forms?
    for (my($i) = 0; $i < scalar(@{$p->{tables}}); $i++) {
	if (defined ($p->{tables}[$i]->{forms})) {
	    Bivio::Die->die ("Table has multiple forms!\n")
		    unless (scalar(keys(%{$p->{tables}[$i]->{forms}})) < 2);
	}
    }

    _find_button_home_page($self, $p);
    _find_button_logout($self, $p);
    _find_button_my_site($self, $p);

    _find_imagemenu($self, $p);
    _find_login($self, $p);
    _find_preferences($self, $p);
    _find_realm_chooser($self, $p);
    _find_tos($self, $p);

    # any unidentified table must be the 'main' table.
    for (my($i) = 0; $i < scalar(@{$p->{tables}}); $i++) {
	unless (defined ($p->{tables}[$i]->{identification})) {
	    Bivio::Die->die ("ambiguous 'main' table\n")
			if (defined ($fields->{main}));
	    $p->{tables}[$i]->{identification} = 'Main';
	    $fields->{main} = $p->{tables}[$i];
	}
    }
    
    return $self;
}

=head1 METHODS

=cut

=for html <a name="find_row_by_content"></a>

=head2 find_row_by_content(Bivio::HTML::HTMLAnalyzer self, string pattern) :

Find the first row in the main table which contains the specified
pattern in either the 'links' or 'text' array.

=cut

sub find_row_by_content {
    my($self, $pattern) = @_;
    my($fields) = $self->{$_PACKAGE};

    return undef unless (defined ($fields->{main})
	    && defined ($fields->{main}->{rows}));

    my($q) = $fields->{main}->{rows};
    for (my($i) = 0; $i < scalar(@{$q}); $i++) {
	if (defined (@{$q}[$i]->{links})) {
	    my(@keys) = keys(%{@{$q}[$i]->{links}});
	    for (my($j) = 0; $j < scalar(@keys); $j++) {
		return @{$q}[$i] if (@keys[$j] =~ $pattern);
	    }
	}

	if (defined (@{$q}[$i]->{text})) {
	    for (my($j) = 0; $j < scalar(@{@{$q}[$i]->{text}}); $j++) {
		return @{$q}[$i] if (@{$q}[$i]->{text}->[$j] =~ $pattern);
	    }
	}
    }
    
    return undef;
}

#=PRIVATE METHODS

# _find_button_home_page(Bivio::HTML::Analyzer self, Bivio::HTML::Parser p) : 
#
# Identify the home page button on the HTML page, if any.
# It is stored under fields->{buttons}->{homepage}.
#
sub _find_button_home_page {
    my($self, $p) = @_;
    my($fields) = $self->{$_PACKAGE};

    if (exists ($p->{links}->{'Home Page'})) {
	$fields->{buttons} = {} unless (defined ($fields->{buttons}));
	$fields->{buttons}->{homepage} = $p->{links}->{'Home Page'};
    }
    return;
}

# _find_button_logout(Bivio::HTML::Analyzer self, Bivio::HTML::Parser p) : 
#
# Identify the logout button on the HTML page, if any.
# It is stored under fields->{buttons}->{logout}.
#
sub _find_button_logout {
    my($self, $p) = @_;
    my($fields) = $self->{$_PACKAGE};

    if (exists ($p->{links}->{Logout})) {
	$fields->{buttons} = {} unless (defined ($fields->{buttons}));
	$fields->{buttons}->{logout} = $p->{links}->{Logout};
    }
    return;
}

# _find_button_my_site(Bivio::HTML::Analyzer self, Bivio::HTML::Parser p) : 
#
# Identify the 'My Site' button on the HTML page, if any.
# It is stored under fields->{buttons}->{mysite}.
#
sub _find_button_my_site {
    my($self, $p) = @_;
    my($fields) = $self->{$_PACKAGE};
    
    if (exists ($p->{links}->{'My Site'})) {
	$fields->{buttons} = {} unless (defined ($fields->{buttons}));
	$fields->{buttons}->{mysite} = $p->{links}->{'My Site'};
    }
    return;
}

# _find_imagemenu(Bivio::HTML::Analyzer self, Bivio::HTML::Parser p) : 
#
# Identify the image menu on the HTML page, if any.
# It is stored under fields->{imagemenu}.
#
sub _find_imagemenu {
    my($self, $p) = @_;
    my($fields) = $self->{$_PACKAGE};

    for (my($i) = 0; $i < scalar(@{$p->{tables}}); $i++) {
	if (exists ($p->{tables}[$i]->{links}->{Roster})) {
	    $fields->{imagemenu} = {} unless defined ($fields->{imagemenu});
	    $fields->{imagemenu}->{administration} = $p->{tables}[$i];
	    $p->{tables}[$i]->{identification} = 'Image Menu';
	}
	elsif (exists ($p->{tables}[$i]->{links}->{Taxes})) {
	    $fields->{imagemenu} = {} unless defined ($fields->{imagemenu});
	    $fields->{imagemenu}->{accounting} = $p->{tables}[$i];
	    $p->{tables}[$i]->{identification} = 'Image Menu';
	}
	elsif (exists ($p->{tables}[$i]->{links}->{Mail})) {
	    $fields->{imagemenu} = {} unless defined ($fields->{imagemenu});
	    $fields->{imagemenu}->{accounting} = $p->{tables}[$i];
	    $p->{tables}[$i]->{identification} = 'Image Menu';
	}
    }
    
    return;
}

# _find_login(Bivio::HTML::Analyzer self, Bivio::HTML::Parser p) : 
#
# Identify the login menu on the HTML page, if any.
# It is stored under fields->{login}.
#
sub _find_login {
    my($self, $p) = @_;
    my($fields) = $self->{$_PACKAGE};

#    my(@f) = values(%{$p->{forms}});
#    for (my($i) = 0; $i < scalar(@f); $i++) {
#	if (exists($f[$i]->{submit}->{Login})) {
# 	    $fields->{loginmenu} = $f[$i];
#	}
#    }
    for (my($i) = 0; $i < scalar(@{$p->{tables}}); $i++) {
	if (exists ($p->{tables}[$i]->{links}->{'Login'})) {
	    $p->{tables}[$i]->{identification} = 'Login';
	    $fields->{login} = $p->{tables}[$i];
	}
    }
    return;
}

# _find_preferences(Bivio::HTML::Analyzer self, Bivio::HTML::Parser p) : 
#
# Identify the preferences form on the HTML page, if any.
# It is stored under fields->{preferencemenu}.
#
sub _find_preferences {
    my($self, $p) = @_;
    my($fields) = $self->{$_PACKAGE};

    my(@f) = values(%{$p->{forms}});
    for (my($i) = 0; $i < scalar(@f); $i++) {
	if (exists($f[$i]->{submit}->{'Change Preferences'})) {
 	    $fields->{preferencemenu} = $f[$i];
	}
    }

    return;
}

# _find_realm_chooser(Bivio::Test::HTMLAnalyzer self, Bivio::Test::HTMLParser p) : 
#
# Identify the realm chooser form on the HTML page, if any.
# It is stored under fields->{realmchooser}.
#
sub _find_realm_chooser {
    my($self, $p) = @_;
    my($fields) = $self->{$_PACKAGE};

    my(@f) = values(%{$p->{forms}});
    for (my($i) = 0; $i < scalar(@f); $i++) {
	if ($f[$i]->{action} eq '/goto') {
 	    $fields->{realmchooser} = $f[$i];
	}
    }

    return;
}

# _find_tos(Bivio::Test::HTMLAnalyzer self, Bivio::Test::HTMLParser p) : 
#
# Identify the "terms of condition" form/table on the HTML page, if any.
# It is stored under fields->{tos}
#
sub _find_tos {
    my($self, $p) = @_;
    my($fields) = $self->{$_PACKAGE};

    for (my($i) = 0; $i < scalar(@{$p->{tables}}); $i++) {
	if (exists ($p->{tables}[$i]->{links}->{'Terms of Service'})) {
	    $p->{tables}[$i]->{identification} = 'Terms of Service';
	    $fields->{tos} = $p->{tables}[$i];
	}
    }
    return;
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
