# Copyright (c) 2000 bivio Software, Inc.  All rights reserved.
# $Id$
package Bivio::Ext::HTMLParser;
use strict;
$Bivio::Ext::HTMLParser::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::Ext::HTMLParser::VERSION;

=head1 NAME

Bivio::Ext::HTMLParser - allows classes to parse without subclassing HTML::Parser

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    use Bivio::Ext::HTMLParser;

=cut

=head1 EXTENDS

L<HTML::Parser>

=cut

use HTML::Parser;
@Bivio::Ext::HTMLParser::ISA = ('HTML::Parser');

=head1 DESCRIPTION

C<Bivio::Ext::HTMLParser> defines an interface which allows non-subclasses to
parse html documents.  This method delegates the HTML::Parser calls to its
clients.  Clients define L<html_parser_start|"html_parser_start">, etc.
to receive the upcalls.

=head1 EXAMPLE

  sub parse_html {
      my($self, $content) = @_;
      my($fields) = $self->{$_PACKAGE};
      $fields->{html_parser} = Bivio::Ext::HTMLParser->new($self)
	      unless $fields->{html_parser};
      $fields->{html_parser}->parse($$content);
      return;
  }

=cut

#=IMPORTS

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;


=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(UNIVERSAL client) : Bivio::Ext::HTMLParser

I<client> is stored and must implement html_parser_* interface.

=cut

sub new {
    my(undef, $client) = @_;
    my($self) = shift->SUPER::new;
    $self->{$_PACKAGE} = {
	client => $client,
    };
    return $self;
}

=head1 METHODS

=cut

=for html <a name="comment"></a>

=head2 comment(string comment)

Calls L<html_parser_comment|"html_parser_comment">.

=cut

sub comment {
    return shift->{$_PACKAGE}->{client}->html_parser_comment(@_);
}

=for html <a name="end"></a>

=head2 end(string tag, string origtext)

Calls L<html_parser_end|"html_parser_end">.

=cut

sub end {
    return shift->{$_PACKAGE}->{client}->html_parser_end(@_);
}

=for html <a name="html_parser_comment"></a>

=head2 abstract html_parser_comment(string comment)

Clients must implement this method.  Called by L<comment|"comment">.

=cut

$_ = <<'}'; # emacs
sub html_parser_comment {
}

=for html <a name="html_parser_end"></a>

=head2 abstract html_parser_end(string tag, string origtext)

Clients must implement this method.  Called by L<end|"end">.

=cut

$_ = <<'}'; # emacs
sub html_parser_end {
}

=for html <a name="html_parser_start"></a>

=head2 abstract html_parser_start(string tag, hash_ref attr, array_ref attrseq, string origtext)

Clients must implement this method.  Called by L<start|"start">.

=cut

$_ = <<'}'; # emacs
sub html_parser_start {
}

=for html <a name="html_parser_text"></a>

=head2 abstract html_parser_text(string text)

Clients must implement this method.  Called by L<text|"text">.

=cut

$_ = <<'}'; # emacs
sub html_parser_text {
}

=for html <a name="start"></a>

=head2 start(string tag, hash_ref attr, array_ref attrseq, string origtext)

Calls L<html_parser_start|"html_parser_start">.

=cut

sub start {
    return shift->{$_PACKAGE}->{client}->html_parser_start(@_);
}

=for html <a name="text"></a>

=head2 text(string text)

Calls L<html_parser_text|"html_parser_text">.

=cut

sub text {
    return shift->{$_PACKAGE}->{client}->html_parser_text(@_);
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 2000 bivio Software, Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
