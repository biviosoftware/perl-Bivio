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

#    $fields->{'Bivio::Test::HTMLParser'} = $p->{'Bivio::Test::HTMLParser'};

    _find_button_home_page($self, $p);
    _find_button_logout($self, $p);
    _find_button_my_site($self, $p);

    _find_imagemenu($self, $p);
    _find_loginmenu($self, $p);
    _find_preferences($self, $p);
    _find_realm_chooser($self, $p);

    
    return $self;
}

=head1 METHODS

=cut

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
	if (exists (@{$p->{tables}}[$i]->{links}->{Roster})) {
	    $fields->{imagemenu} = {} unless defined ($fields->{imagemenu});
	    $fields->{imagemenu}->{administration} = @{$p->{tables}}[$i];
	}
	elsif (exists (@{$p->{tables}}[$i]->{links}->{Taxes})) {
	    $fields->{imagemenu} = {} unless defined ($fields->{imagemenu});
	    $fields->{imagemenu}->{accounting} = @{$p->{tables}}[$i];
	}
	elsif (exists (@{$p->{tables}}[$i]->{links}->{Mail})) {
	    $fields->{imagemenu} = {} unless defined ($fields->{imagemenu});
	    $fields->{imagemenu}->{accounting} = @{$p->{tables}}[$i];
	}
    }
    
    return;
}

# _find_loginmenu(Bivio::HTML::Analyzer self, Bivio::HTML::Parser p) : 
#
# Identify the login menu on the HTML page, if any.
# It is stored under fields->{loginmenu}.
#
sub _find_loginmenu {
    my($self, $p) = @_;
    my($fields) = $self->{$_PACKAGE};

    my(@f) = values(%{$p->{forms}});
    for (my($i) = 0; $i < scalar(@f); $i++) {
	if (exists($f[$i]->{submit}->{Login})) {
 	    $fields->{loginmenu} = $f[$i];
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
