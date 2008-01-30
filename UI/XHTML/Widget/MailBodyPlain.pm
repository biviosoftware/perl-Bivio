# Copyright (c) 2008 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::UI::XHTML::Widget::MailBodyPlain;
use strict;
use Bivio::Base 'XHTMLWidget.Tag';
use Text::Tabs ();

our($VERSION) = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

sub initialize {
    my($self) = @_;
    $self->put_unless_exists(tag => 'div');
    $self->put_unless_exists(class => 'text_plain');
    return shift->SUPER::initialize(@_);
}

sub internal_new_args {
    return shift->SUPER::internal_new_args(div => @_);
}

sub render_tag_value {
    my($self, $source, $buffer) = @_;
    $$buffer .= join(
	"<br />\n",
	map({
	    $_ = Text::Tabs::expand($_);
	    $_ =~ s{
                ((?:ftp|http)s?:\/\/[^\s"]*)(?=[\s>\)\],\.\!"']|$)
                | ([\w\-\+\.]+@(?:[[\w\-]{2,}\.?){2,})
                | (?:^|(?<=\W))(www(?:\.[\w\-]{2,}){2,})(?=\W|$)
		| ([\&<>])
            }{
		$1 ? _a($1, $1)
		    : $2 ? _a("mailto:$2", $2)
		    : $3 ? _a("http://$3", $3)
		    : Bivio::HTML->escape($4)
            }exsg;
	    $_;
	} split(/\n/, $self->render_simple_attr('value', $source))),
    );
    return;
}

sub _a {
    my($href, $value) = @_;
    return qq{<a href="$href">$value</a>};
}

1;
