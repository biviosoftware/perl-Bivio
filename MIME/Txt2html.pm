# Copyright (c) 2000 bivio, Inc.  All rights reserved.
# $Id$
package Bivio::MIME::Txt2html;
use strict;
$Bivio::MIME::Txt2html::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Txt2html - convert raw text to something with a little HTML formatting

=head1 SYNOPSIS

    use Txt2html;
    my($tp) = Txt2html->new();

    $tp->set_short_line_length($char_count);
    $tp->set_preformat_whitespace_min($char_count);
    $tp->set_par_indent($char_count);
    $tp->set_preformat_trigger_lines($line_count);
    $tp->set_endpreformat_trigger_lines($line_count);
    $tp->set_hrule_min($char_count);
    $tp->set_min_caps_length($char_count);
    $tp->set_caps_tag($caps_tag);
    $tp->set_mailmode($do_mail_mode);
    $tp->set_unhyphenation($enable_unhyphenation);
    $tp->set_append_file($file_name);
    $tp->set_prepend_file($file_name);
    $tp->set_append_head($file_name);
    $tp->set_title($title);
    $tp->set_titlefirst($do_title_first);
    $tp->set_doctype($doctype);
    $tp->set_underline_length_tolerance($char_count);
    $tp->set_underline_offset_tolerance($char_count);
    $tp->set_tab_width($char_count);
    $tp->set_indent_width($char_count);
    $tp->set_extract($do_extract_mode);
    $tp->set_make_links($file_name);
    $tp->set_escape_HTML_chars($escape_html_chars);
    $tp->set_link_only($do_link_only);
    $tp->add_custom_heading_regexp($regexp);
    $tp->set_explicit_headings($do_explicit_headings_only);
    $tp->add_custom_tags($tag_and_regexp);	# Not implemented yet.
    $tp->set_dict_debug($flags);

    my($hp) = $tp->convert();

=head1 DESCRIPTION

C<Txt2html> converts plain ASCII text to HTML.

=cut

#=IMPORTS
use Bivio::UNIVERSAL;
@Bivio::MIME::Txt2html::ISA = qw(Bivio::UNIVERSAL);

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;

# These are just constants I use for making bit vectors to keep track
# of what modes I'm in and what actions I've taken on the current and
# previous lines.
*NONE       =   \0;
*LIST       =   \1;
*HRULE      =   \2;
*PAR        =   \4;
*PRE        =   \8;
*END        =  \16;
*BREAK      =  \32;
*HEADER     =  \64;
*MAILHEADER = \128;
*MAILQUOTE  = \256;
*CAPS       = \512;
*LINK       =\1024;

# Constants for Ordered Lists and Unordered Lists.
# I use this in the list stack to keep track of what's what.
*OL = \1;
*UL = \2;

# XXX is there a better way to make a constant hash?
# Character entity names
my(%char_entities) = (
     "\241", "&iexcl;",  "\242", "&cent;",   "\243", "&pound;",
     "\244", "&curren;", "\245", "&yen;",    "\246", "&brvbar;",
     "\247", "&sect;",   "\250", "&uml;",    "\251", "&copy;",
     "\252", "&ordf;",   "\253", "&laquo;",  "\254", "&not;",
     "\255", "&shy;",    "\256", "&reg;",    "\257", "&hibar;",
     "\260", "&deg;",    "\261", "&plusmn;", "\262", "&sup2;",
     "\263", "&sup3;",   "\264", "&acute;",  "\265", "&micro;",
     "\266", "&para;",   "\267", "&middot;", "\270", "&cedil;",
     "\271", "&sup1;",   "\272", "&ordm;",   "\273", "&raquo;",
     "\274", "&fraq14;", "\275", "&fraq12;", "\276", "&fraq34;",
     "\277", "&iquest;", "\300", "&Agrave;", "\301", "&Aacute;", 
     "\302", "&Acirc;",  "\303", "&Atilde;", "\304", "&Auml;",
     "\305", "&Aring;",  "\306", "&AElig;",  "\307", "&Ccedil;", 
     "\310", "&Egrave;", "\311", "&Eacute;", "\312", "&Ecirc;", 
     "\313", "&Euml;",   "\314", "&Igrave;", "\315", "&Iacute;", 
     "\316", "&Icirc;",  "\317", "&Iuml;",   "\320", "&ETH;", 
     "\321", "&Ntilde;", "\322", "&Ograve;", "\323", "&Oacute;",
     "\324", "&Ocirc;",  "\325", "&Otilde;", "\326", "&Ouml;", 
     "\327", "&times;",  "\330", "&Oslash;", "\331", "&Ugrave;",
     "\332", "&Uacute;", "\333", "&Ucirc;",  "\334", "&Uuml;", 
     "\335", "&Yacute;", "\336", "&THORN;",  "\337", "&szlig;", 
     "\340", "&agrave;", "\341", "&aacute;", "\342", "&acirc;", 
     "\343", "&atilde;", "\344", "&auml;",   "\345", "&aring;", 
     "\346", "&aelig;",  "\347", "&ccedil;", "\350", "&egrave;", 
     "\351", "&eacute;", "\352", "&ecirc;",  "\353", "&euml;", 
     "\354", "&igrave;", "\355", "&iacute;", "\356", "&icirc;",
     "\357", "&iuml;",   "\360", "&eth;",    "\361", "&ntilde;",
     "\362", "&ograve;", "\363", "&oacute;", "\364", "&ocirc;", 
     "\365", "&otilde;", "\366", "&ouml;",   "\367", "&divide;",
     "\370", "&oslash;", "\371", "&ugrave;", "\372", "&uacute;",
     "\373", "&ucirc;",  "\374", "&uuml;",   "\375", "&yacute;", 
     "\376", "&thorn;",  "\377", "&yuml;", 
);

my($inline_dict) = <<'EOF';
#
# Sample links dictionary file for Seth Golub's txt2html
# http://www.thehouse.org/~seth/txt2html/
#
# This dictionary contains some patterns for converting obvious URLs,
# ftp sites, hostnames, email addresses and the like to hrefs.
#
# Adapted shamelessly from the html.pl package by Oscar Nierstrasz in
# the Software Archive of the Software Composition Group
# http://iamwww.unibe.ch/~scg/Src/
#
# Email suggestions to seth@thehouse.org
# Please include "txt2html" in the subject of your message.
#

# Urls: <service>:<rest-of-url>

|snews:[\w\.]+|         -> $&
|http:[\w/\.:+\-~\%#?]+[\w/]|  -> $&
|shttp:[\w/\.:+\-~\%#?]+| -> $&
|https:[\w/\.:+\-~\%#?]+| -> $&
|file:[\w/\.:+\-]+|     -> $&
|ftp:[\w/\.:+\-]+|      -> $&
|wais:[\w/\.:+\-]+|     -> $&
|gopher:[\w/\.:+\-]+|   -> $&
|telnet:[\w/\@\.:+\-]+|   -> $&


# catch some newsgroups to avoid confusion with sites:
|([^\w\-/\.:\@>])(alt\.[\w\.+\-]+[\w+\-]+)|    -h-> $1<A HREF="news:$2">$2</A>
|([^\w\-/\.:\@>])(bionet\.[\w\.+\-]+[\w+\-]+)| -h-> $1<A HREF="news:$2">$2</A>
|([^\w\-/\.:\@>])(bit\.[\w\.+\-]+[\w+\-]+)|    -h-> $1<A HREF="news:$2">$2</A>
|([^\w\-/\.:\@>])(biz\.[\w\.+\-]+[\w+\-]+)|    -h-> $1<A HREF="news:$2">$2</A>
|([^\w\-/\.:\@>])(clari\.[\w\.+\-]+[\w+\-]+)|  -h-> $1<A HREF="news:$2">$2</A>
|([^\w\-/\.:\@>])(comp\.[\w\.+\-]+[\w+\-]+)|   -h-> $1<A HREF="news:$2">$2</A>
|([^\w\-/\.:\@>])(gnu\.[\w\.+\-]+[\w+\-]+)|    -h-> $1<A HREF="news:$2">$2</A>
|([^\w\-/\.:\@>])(humanities\.[\w\.+\-]+[\w+\-]+)| 
          -h-> $1<A HREF="news:$2">$2</A>
|([^\w\-/\.:\@>])(k12\.[\w\.+\-]+[\w+\-]+)|    -h-> $1<A HREF="news:$2">$2</A>
|([^\w\-/\.:\@>])(misc\.[\w\.+\-]+[\w+\-]+)|   -h-> $1<A HREF="news:$2">$2</A>
|([^\w\-/\.:\@>])(news\.[\w\.+\-]+[\w+\-]+)|   -h-> $1<A HREF="news:$2">$2</A>
|([^\w\-/\.:\@>])(rec\.[\w\.+\-]+[\w+\-]+)|    -h-> $1<A HREF="news:$2">$2</A>
|([^\w\-/\.:\@>])(soc\.[\w\.+\-]+[\w+\-]+)|    -h-> $1<A HREF="news:$2">$2</A>
|([^\w\-/\.:\@>])(talk\.[\w\.+\-]+[\w+\-]+)|   -h-> $1<A HREF="news:$2">$2</A>
|([^\w\-/\.:\@>])(us\.[\w\.+\-]+[\w+\-]+)|     -h-> $1<A HREF="news:$2">$2</A>
|([^\w\-/\.:\@>])(ch\.[\w\.+\-]+[\w+\-]+)|     -h-> $1<A HREF="news:$2">$2</A>
|([^\w\-/\.:\@>])(de\.[\w\.+\-]+[\w+\-]+)|     -h-> $1<A HREF="news:$2">$2</A>

# FTP locations (with directory):
# anonymous@<site>:<path>
|(anonymous\@)([a-zA-Z][\w\.+\-]+\.[a-zA-Z]{2,}):(\s*)([\w\d+\-/\.]+)|
  -h-> $1<A HREF="ftp://$2/$4">$2:$4</A>$3

# ftp@<site>:<path>
|(ftp\@)([a-zA-Z][\w\.+\-]+\.[a-zA-Z]{2,}):(\s*)([\w\d+\-/\.]+)|
  -h-> $1<A HREF="ftp://$2/$4">$2:$4</A>$3

# Email address
|[a-zA-Z0-9_\+\-\.]+\@([a-zA-Z0-9][\w\.+\-]+\.[a-zA-Z]{2,})|
  -> mailto:$&

# <site>:<path>
|([^\w\-/\.:\@>])([a-zA-Z][\w\.+\-]+\.[a-zA-Z]{2,}):(\s*)([\w\d+\-/\.]+)|
  -h-> $1<A HREF="ftp://$2/$4">$2:$4</A>$3

# NB: don't confuse an http server with a port number for
# an FTP location!
# internet number version: <internet-num>:<path>
|([^\w\-/\.:\@])(\d{2,}\.\d{2,}\.\d+\.\d+):([\w\d+\-/\.]+)|
  -h-> $1<A HREF="ftp://$2/$3">$2:$3</A>

# telnet <site> <port>
|telnet ([a-zA-Z][\w+\-]+(\.[\w\.+\-]+)+\.[a-zA-Z]{2,})\s+(\d{2,4})|
  -h-> telnet <A HREF="telnet://$1:$3/">$1 $3</A>

# ftp <site>
|ftp ([a-zA-Z][\w+\-]+(\.[\w\.+\-]+)+\.[a-zA-Z]{2,})|
  -h-> ftp <A HREF="ftp://$1/">$1</A>

# host with "ftp" in the machine name
|(^|[^\w\d\-/\.:!])(([a-zA-Z][\w+\-]*)?ftp[\w+\-]*\.[\w\.+\-]+\.[a-zA-Z]{2,})([^\w\d\-/\.:!])|
  -h-> $1ftp <A HREF="ftp://$2/">$2</A>$4

# host with "www" in the machine name
|(^|[^\w\d\-/\.:!])(([a-zA-Z][\w+\-]*)?www[\w+\-]*\.[\w\.+\-]+\.[a-zA-Z]{2,})([^\w\d\-/\.:!])|
  -h-> $1<A HREF="http://$2/">$2</A>$4

# <site> <port>
|([a-zA-Z][\w+\-]+\.[\w+\-]+\.[a-zA-Z]{2,})\s+(\d{2,4})|
  -h-> <A HREF="telnet://$1:$2/">$1 $2</A>

# just the site name: <site>
|([^\w\-/\.:\@>])([a-zA-Z][\w+\-]+(\.[\w+\-]+)+\.[a-zA-Z]{2,})|
  -h-> $1<A HREF="http://$2">$2</A>/

# just internet numbers with port:
|([^\w\-/\.:\@])(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})\s+(\d{1,4})|
  -h-> $1<A HREF="telnet://$2:$3">$2 $3</A>

# just internet numbers:
|([^\w\-/\.:\@])(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})|
  -h-> $1<A HREF="telnet://$2">$2</A>


# (see "relative path") as used by Tom Fine
# /\(see \"([^\"]+)\"\)/  -> $1.html

# RFCs
/RFC ?(\d+)/ -i-> http://www.cis.ohio-state.edu/rfc/rfc$1.txt

# This would turn "f^H_o^H_o^H_" into "<U>foo</U>".  Gross, isn't it?
# Thanks to Mark O'Dell <emark@cns.caltech.edu> for fixing this. 
#
# /(.\\010_)+/ -he-> $tmp = $&;$tmp =~ s@\010_@@g;"<U>$tmp</U>"
# /(_\\010.)+/ -he-> $tmp = $&;$tmp =~ s@_\010@@g;"<U>$tmp</U>"
# /(.\^H_)+/ -he-> $tmp = $&;$tmp =~ s@\^H_@@g;"<U>$tmp</U>"
# /(_\^H.)+/ -he-> $tmp = $&;$tmp =~ s@_\^H@@g;"<U>$tmp</U>"


# Mark _underline stuff_ as <U>underlined stuff</U>
/_([a-z][a-z ]*[a-z])_/ -hi-> <U>$1</U>
# Need special case for _x_
/_([a-z])_/ -hi-> <U>$1</U>

# Mark *underline stuff* as <EM>underlined stuff</EM>
/\*([a-z][a-z ]*[a-z])\*/ -hi-> <EM>$1</EM>
# Need special case for *x*
/\*([a-z])\*/ -hi-> <EM>$1</EM>



# Seth and his amazing conversion program    :-)

"Seth Golub"  -io-> http://www.thehouse.org/~seth/
"txt2html"    -io-> http://www.thehouse.org/txt2html/


# End of sample dictionary

EOF

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(string_ref input_text) : Txt2html

Stores the reference I<input_text> for Txt2html::convert() to use in accessing
the input.  Does not modify I<input_text>.  Returns a reference to a Txt2html
object.

=cut

sub new {
    my($self) = Bivio::UNIVERSAL::new(@_);
    my(undef, $source_ref) = @_;
    $self = {
            # The following just have to be initialized once.
            links_dictionaries_aref => [],
            links_table_href => {},
            links_switch_table_href => {},
            # The code depends on the links_table_order array having 0 as its's
            # first element.
            links_table_order_aref => [0],
            default_link_dict => "$ENV{'HOME'}/.txt2html-linkdict",
            heading_styles_href => {},
            listprefix_aref => [],
            list_aref => [],
            num_heading_styles => 0,
            # End of variables that just have to be initialized once.
            # The following have to be initialized for each conversion.
            source_aref => [split(/^/, $$source_ref)],
            result => "",
            line => "",
            line_action => $Txt2html::NONE,
            non_header_anchor => 0,
            mode => 0,
            listnum => 0,
            list_indent => "",
            line_action => $Txt2html::NONE,
            prev_action => $Txt2html::NONE,
            prev_line_length => 0,
            prev_indent => 0,
            prev => "",
            nextline => 0,
            heading_count_aref => [],
            # End of variables tha have to be initialized for each conversion.
            # The following can be initialized to different values by the user.
            short_line_length => 40,
            preformat_whitespace_min => 5,
            par_indent => 2,
            preformat_trigger_lines => 2,
            endpreformat_trigger_lines => 2,
            hrule_min => 4,
            min_caps_length => 3,
            caps_tag => "STRONG",
            mailmode => 0,
            unhyphenation => 1,
            append_file => 0,
            prepend_file => 0,
            append_head => 0,
            title => 0,
            titlefirst => 0,
            doctype => "-//W3C//DTD HTML 3.2 Final//EN",
            underline_length_tolerance => 1,
            underline_offset_tolerance => 1,
            tab_width => 8,
            indent_width => 2,
            extract => 0,
            make_links => 1,
            escape_HTML_chars => 1,
            link_only => 0,
            custom_heading_regexp_aref => [],
            explicit_headings => 0,
            custom_tags_aref => [],
            dict_debug => 0,
            system_link_dict => "/usr/local/lib/txt2html-linkdict"
    };
    bless($self);
    return $self;
}

=head1 METHODS

=for html <a name="add_custom_heading_regexp"></a>

=head2 add_custom_heading_regexp(string_ref regexp)

Add a regexp for headings.  Header levels are assigned by regexp
in order seen When a line matches a custom header regexp, it is tagged as
a header.  If it's the first time that particular regexp has matched,
the next available header level is associated with it and applied to
the line.  Any later matches of that regexp will use the same header level.
Therefore, if you want to match numbered header lines, you could use
something like this.

    -H '^ *\d+\. \w+' -H '^ *\d+\.\d+\. \w+' -H '^ *\d+\.\d+\.\d+\. \w+'

Then lines like

=over 4

=item

1. Examples

=item

1.1 Things

=item

4.2.5 Cold Fusion

=back

Would be marked as H1, H2, and H3
(assuming they were found in that
order, and that no other header
styles were encountered).
If you prefer that the first one
specified always be H1, the second
always be H2, the third H3, etc,
then use the -EH/--explicit-headings
option.

=cut

sub add_custom_heading_regexp {
    my($self, $regexp_ref) = @_;
	push(@{$self->{custom_heading_regexp_aref}}, $$regexp_ref);
    return;
}

=for html <a name="convert"></a>

=head2 convert()


=cut

sub convert {
    my($self) = shift;

    $* = 1;			# Turn on multiline searches

    # Re-initialize variables that need it for each conversion.
    $self->initialize();

# Don't lookup external dictionaries, using internal one (see top of file)
#    if ($self->{make_links} && (-f $self->{default_link_dict})) {
#        push(@{$self->{links_dictionaries_aref}}, ($self->{default_link_dict}));
#    }
    $self->deal_with_options();
    if ($self->{make_links}) {
#        if (-f $self->{system_link_dict}) {
#            push(@{$self->{links_dictionaries_aref}},
#                    ($self->{system_link_dict}));
#        }
        $self->load_dictionary_links($inline_dict);
    }

    # Moved this way up here so we can grab the first line and use it
    # as the title (if --titlefirst is set)
    $self->{line}     = $self->getline();
    $self->{nextline} = $self->getline() if $self->{line};

    # Skip leading blank lines
    while ($self->is_blank($self->{line}) && $self->{line}) {
        $self->{prev} = $self->{line};
        $self->{line} = $self->{nextline};
        $self->{nextline} = $self->getline() if $self->{nextline};
    }

    if (!$self->{extract}) {
        $self->emit('<!DOCTYPE HTML PUBLIC "' .
                $self->{doctype} . "\">\n") unless !$self->{doctype};
        $self->emit("<HTML>\n");
        $self->emit("<HEAD>\n");

        # if --titlefirst is set and --title isn't, use the first line
        # as the title.
        if ($self->{titlefirst} && !$self->{title}) {
            ($self->{title}) = $self->{line} =~ /^ *(.*)/; # grab first line
            $self->{title} =~ s/ *$//;	# strip trailing whitespace
        }
        $self->{title} = "" if !$self->{title};
        $self->emit("<TITLE>$self->{title}</TITLE>\n");

        if ($self->{append_head}) {
            open(APPEND, $self->{append_head}) ||
                    die "Failed to open $self->{append_head}\n";
            while (<APPEND>) {
                $self->emit($_);
            }
            close(APPEND);
        }

        $self->emit("</HEAD>\n");
        $self->emit("<BODY>\n");
    }

    if ($self->{prepend_file}) {
        if (-r $self->{prepend_file}) {
            open( PREPEND, $self->{prepend_file} );
            while (<PREPEND>) {
                $self->emit($_);
            }
            close( PREPEND );
        } else {
            print STDERR "Can't find or read file $self->{prepend_file} to prepend.\n";
        }
    }

    do {
        my(@chars);
        if ( !$self->{link_only} ) {
            $self->{line_length} =
                    length($self->{line}); # Do this before tags go in
            $self->{line_indent} =
                    $self->count_indent($self->{line}, $self->{prev_indent});

			$self->escape() if $self->{escape_HTML_chars};

            $self->endpreformat()
                    if (($self->{mode} & $Txt2html::PRE) &&
                            ($self->{preformat_trigger_lines} != 0));

            $self->hrule() if !($self->{mode} & $Txt2html::PRE);

            $self->custom_heading()
                    if (($#{$self->{custom_heading_regexp_aref}} > -1)
                            && !($self->{mode} & $Txt2html::PRE));

            $self->liststuff() if (!($self->{mode} & $Txt2html::PRE) &&
                    !$self->is_blank($self->{line}));

            $self->heading()   if (!$self->{explicit_headings} &&
                    !($self->{mode} & ($Txt2html::PRE | $Txt2html::HEADER)) &&
                    $self->{nextline} =~ /^\s*[=\-\*\.~\+]+\s*$/);

#	        &custom_tag if (($#{$self->{custom_tags_aref}} > -1)
#                        && !($self->{mode} & $Txt2html::PRE)
#                        && !($self->{line_action} & $Txt2html::HEADER));

            $self->mailstuff() if ($self->{mailmode} &&
                    !($self->{mode} & $Txt2html::PRE) &&
                    !($self->{line_action} & $Txt2html::HEADER));

            $self->preformat() if (!($self->{line_action} &
                    ($Txt2html::HEADER |
                            $Txt2html::LIST |
                            $Txt2html::MAILHEADER)) &&
                    !($self->{mode} & ($Txt2html::LIST | $Txt2html::PRE)) &&
                    ($self->{endpreformat_trigger_lines} != 0));

            $self->paragraph();
            $self->shortline();

            $self->unhyphenate() if ($self->{unhyphenation} &&
                    ($self->{line} =~ /[^\W\d_]\-$/) && # ends in hyphen
                    # next line starts w/letters
                    ($self->{nextline} =~ /^\s*[^\W\d_]/) && 
                    !($self->{mode} & ($Txt2html::PRE |
                            $Txt2html::HEADER |
                            $Txt2html::MAILHEADER |
                            $Txt2html::BREAK)));

            $self->caps() if  !($self->{mode} & $Txt2html::PRE);

        }

        $self->make_dictionary_links() if ($self->{make_links}
                && !$self->is_blank($self->{line})
                && $#{$self->{links_table_order}});

        # All the matching and formatting is done.  Now we can 
        # replace non-ASCII characters with character entities.
        @chars = split(//,$self->{line});
        foreach $_ (@chars) {
            $_ = $char_entities{$_} if defined( $char_entities{$_} );
        }
        $self->{line} = join( "", @chars );

        # Print it out and move on.

        $self->emit($self->{prev});

        if (!$self->is_blank($self->{nextline})) {
            $self->{prev_action} = $self->{line_action};
            $self->{line_action} = $Txt2html::NONE;
            $self->{prev_line_length} = $self->{line_length};
            $self->{prev_indent} = $self->{line_indent};
        }

        $self->{prev} = $self->{line};
        $self->{line} = $self->{nextline};
        $self->{nextline} = $self->getline() if $self->{nextline};
    } until (!$self->{nextline} && !$self->{line} && !$self->{prev});

    $self->{prev} = "";
    &endlist($self->{listnum})
            if ($self->{mode} & $Txt2html::LIST); # End all lists
    $self->emit($self->{prev});

    $self->emit("\n");

    $self->emit("</PRE>\n") if ($self->{mode} & $Txt2html::PRE);

    if ($self->{append_file}) {
        if (-r $self->{append_file}) {
            open(APPEND, $self->{append_file});
            while (<APPEND>) {
                $self->emit($_);
            }
            close( APPEND );
        } else {
            print STDERR "Can't find or read file $self->{append_file} to append.\n";
        }
    }

    if (!$self->{extract}) {
        $self->emit("</BODY>\n");
        $self->emit("</HTML>\n");
    }

    # Return the converted text.
    return \$self->{result};
}

=for html <a name="set_dict_debug"></a>

=head2 set_dict_debug(flag bits)

Set the dictionary debugging flag bits to the given value.  Each bit in the
given value controls a debugging action.  Check the source
code to see what various actions are.

=cut

sub set_dict_debug {
    my($self, $new_value) = @_;
	$self->{dict_debug} = $new_value;
    return;
}

=for html <a name="set_mail_mode"></a>

=head2 set_mail_mode(boolean)

Sets the mailmode option to the given value.  Setting it to true causes
mail headers and quoted text of the type seen in mail
replies, i.e.

	> blah blah
	> blah blah
	> ...

to be processed.

=cut

sub set_mail_mode {
    my($self, $new_value) = @_;
	$self->{mailmode} = $new_value;
    return;
}

=for html <a name="set_title_first"></a>

=head2 set_title_first(boolean)

Sets the title first option to the given value.  Setting it to true causes
the first blank line to be used aa a title.

=cut

sub set_title_first {
    my($self, $new_value) = @_;
	$self->{titlefirst} = $new_value;
    return;
}

#=PRIVATE METHODS

# XXX Re-initialize the variables that need it when we start to reuse a
# Txt2html object to convert multiple pieces of text.
sub initialize {
	my($self) = shift;

}

# Call with a string to be added to $self->{result}, in which we accumulate
# the html text.
sub emit {
    my($self) = shift;
    $self->{result} .= shift;
}

sub is_blank {
    my($self) = shift;
    return $_[0] =~ /^\s*$/;
}

sub escape {
    my($self) = shift;
    $self->{line} =~ s/&/&amp;/g;
    $self->{line} =~ s/>/&gt;/g;
    $self->{line} =~ s/</&lt;/g;
}

sub hrule {
    my($self) = shift;
    if ($self->{line} =~ /^\s*([-_~=\*]\s*){$self->{hrule_min},}$/) {
        $self->{line} = "<HR>\n";
        $self->{prev} =~ s/<P>//;
        $self->{line_action} |= $Txt2html::HRULE;
    } elsif ($self->{line} =~ /\014/) {
        $self->{line_action} |= $Txt2html::HRULE;
        $self->{line} =~ s/\014/\n<HR>\n/g; # Linefeeds become horizontal rules
    }
}

sub shortline {
    # Short lines should be broken even on list item lines iff the
    # following line is more text.  I haven't figured out how to do
    # that yet.  For now, I'll just not break on short lines in lists.
    # (sorry)
    my($self) = shift;

    if (!($self->{mode} & ($Txt2html::PRE | $Txt2html::LIST))
            && !$self->is_blank($self->{line})
            && !$self->is_blank($self->{prev})
            && ($self->{prev_line_length} < $self->{short_line_length})
            && !($self->{line_action} & ($Txt2html::END
                    | $Txt2html::HEADER
                    | $Txt2html::HRULE
                    | $Txt2html::LIST
                    | $Txt2html::PAR))
            && !($self->{prev_action} & ($Txt2html::HEADER
                    | $Txt2html::HRULE
                    | $Txt2html::BREAK))) {
        $self->{prev} .= "<BR>" . chop($self->{prev});
        $self->{prev_action} |= $Txt2html::BREAK;
    }
}

sub mailstuff {
    my($self) = shift;
    if ((($self->{line} =~ /^\w*&gt/)    # Handle "FF> Werewolves."
            || ($self->{line} =~ /^\w*\|/)) # Handle "Igor| There wolves."
            && !$self->is_blank($self->{nextline})) {
	$self->{line} =~ s/$/<BR>/;
	$self->{line_action} |= ($Txt2html::BREAK | $Txt2html::MAILQUOTE);
        if(!($self->{prev_action} & ($Txt2html::BREAK | $Txt2html::PAR))) {
            $self->{prev} .= "<P>\n";
            $self->{line_action} |= $Txt2html::PAR;
        }
    } elsif (($self->{line} =~ /^(From:?)|(Newsgroups:) /)
             && $self->is_blank($self->{prev})) {
	$self->anchor_mail if !($self->{prev_action} & $Txt2html::MAILHEADER);
        chop $self->{line};
	$self->{line} = "<!-- New Message -->\n<p>\n" . $self->{line} . "<BR>\n";
	$self->{line_action} |= ($Txt2html::BREAK
                | $Txt2html::MAILHEADER
                | $Txt2html::PAR);
    } elsif (($self->{line} =~ /^[\w\-]*:/)  # Handle "Some-Header: blah"
            && ($self->{prev_action} & $Txt2html::MAILHEADER)
            && !$self->is_blank($self->{nextline})) {
	$self->{line} =~ s/$/<BR>/;
	$self->{line_action} |= ($Txt2html::BREAK | $Txt2html::MAILHEADER);
    } elsif (($self->{line} =~ /^\s+\S/) &&   # Handle multi-line mail headers
            ($self->{prev_action} & $Txt2html::MAILHEADER) &&
            !$self->is_blank($self->{nextline})) {
	$self->{line} =~ s/$/<BR>/;
	$self->{line_action} |= ($Txt2html::BREAK | $Txt2html::MAILHEADER);
    }
}

# Subtracts modes listed in $mask from $vector.
sub subtract_modes {
    my($self) = shift;
    my($vector, $mask) = @_;
    return ($vector | $mask) - $mask;
}

sub paragraph
{
    my($self) = shift;
    if (!$self->is_blank($self->{line})
            && !($self->{mode} & $Txt2html::PRE)
            && !$self->subtract_modes($self->{line_action},
                    $Txt2html::END
                    | $Txt2html::MAILQUOTE
                    | $Txt2html::CAPS
                    | $Txt2html::BREAK)
            && ($self->is_blank($self->{prev})
                    || ($self->{line_action} & $Txt2html::END)
                    || ($self->{line_indent}
                            > $self->{prev_indent} + $self->{par_indent}))) {
        $self->{prev} .= "<P>\n";
        $self->{line_action} |= $Txt2html::PAR;
    }
}

# If the line is blank, return the second argument.  Otherwise,
# return the number of spaces before any nonspaces on the line.
sub count_indent {
    my($self) = shift;
    my($line, $prev_length) = @_;
    my($ws);
    if($self->is_blank($line)) {
        return $prev_length;
    }
    $ws = $line =~ /^( *)[^ ]/;
    return length($ws);
}

sub listprefix {
    my($self) = shift;
    my($line) = @_;
    my($prefix, $number, $rawprefix);

    return (0,0,0) if (!($line =~ /^\s*[-=\*o]+\s+\S/ ) &&
            !($line =~ /^\s*(\d+|[^\W\d_])[\.\)\]:]\s+\S/ ));

    ($number) = $line =~ /^\s*(\d+|[^\W\d_])/;
    $number = 0 unless defined($number);

    # That slippery exception of "o" as a bullet
    # (This ought to be determined using the context of what lists
    #  we have in progress, but this will probably work well enough.)
    if ($line =~ /^\s*o\s/) {
        $number = 0;
    }

    if ($number) {
        ($rawprefix) = $line =~ /^(\s*(\d+|[^\W\d_]).)/; # XXX why ($rawprefix)?
        $prefix = $rawprefix;
        $prefix =~ s/(\d+|[^\W\d_])//; # Take the number out
    } else {
        ($rawprefix) = $line =~ /^(\s*[-=o\*]+.)/;	# XXX why ($rawprefix)?
        $prefix = $rawprefix;
    }
    return ($prefix, $number, $rawprefix);
}

sub startlist {
    my($self) = shift;
    my($prefix, $number, $rawprefix) = @_;

    ${$self->{listprefix_aref}}[$self->{listnum}] = $prefix;
    if ($number) {
        # It doesn't start with 1,a,A.  Let's not screw with it.
        if (($number ne "1") && ($number ne "a") && ($number ne "A")) {
            return 0;
        }
        $self->{prev} .= "$self->{list_indent}<OL>\n";
        ${$self->{list_aref}}[$self->{listnum}] = $Txt2html::OL;
    } else {
        $self->{prev} .= "$self->{list_indent}<UL>\n";
        ${$self->{list_aref}}[$self->{listnum}] = $Txt2html::UL;
    }

    $self->{listnum}++;
    $self->{list_indent} = " " x $self->{listnum} x $self->{indent_width};
    $self->{line_action} |= $Txt2html::LIST;
    $self->{mode} |= $Txt2html::LIST;
    return 1;
}

sub endlist	{		# End N lists
    my($self) = shift;
    my($n) = @_;
    for (; $n > 0; $n--, $self->{listnum}--) {
        $self->{list_indent} =
                " " x ($self->{listnum}-1) x $self->{indent_width};
        if (${$self->{list_aref}}[$self->{listnum}-1] == $Txt2html::UL) {
            $self->{prev} .= "$self->{list_indent}</UL>\n";
        } elsif (${$self->{list_aref}}[$self->{listnum}-1] ==
                $Txt2html::OL) {
            $self->{prev} .= "$self->{list_indent}</OL>\n";
        } else {
            print STDERR "Encountered list of unknown type\n";
        }
    }
    $self->{line_action} |= $Txt2html::END;
    $self->{mode} ^= $Txt2html::LIST if (!$self->{listnum});
}

sub continuelist {
    my($self) = shift;
    $self->{line} =~ s/^\s*[-=o\*]+\s*/$self->{list_indent}<LI> /
            if ${$self->{list_aref}}[$self->{listnum}-1] == $Txt2html::UL;
    $self->{line} =~ s/^\s*(\d+|[^\W\d_]).\s*/$self->{list_indent}<LI> /
            if ${$self->{list_aref}}[$self->{listnum}-1] == $Txt2html::OL;
    $self->{line_action} |= $Txt2html::LIST;
}

sub liststuff {
    my($self) = shift;
    my($i);
    my($prefix, $number, $rawprefix) = $self->listprefix($self->{line});
    my($prefix_alternate);
    my($islist);

    if (!$prefix) {
        return if !$self->is_blank($self->{prev}); # inside a list item
        # This ain't no list.  We'll want to end all of them.
        $self->endlist($self->{listnum}) if $self->{listnum};
        return;
    }

    # If numbers with more than one digit grow to the left instead of
    # to the right, the prefix will shrink and we'll fail to match the
    # right list.  We need to account for this.
    if (length("" . $number) > 1) {
        $prefix_alternate = (" " x (length( "" . $number) - 1)) . $prefix;
    }

    # Maybe we're going back up to a previous list
    for($i = $self->{listnum} - 1;
            ($i >= 0) && ($prefix ne ${$self->{listprefix_aref}}[$i]);
            $i--) {
        if (length( "" . $number ) > 1) {
            last if $prefix_alternate eq ${$self->{listprefix_aref}}[$i];
        }
    }

    # Measure the indent from where the text starts, not where the
    # prefix starts.  This won't screw anything up, and if we don't do
    # it, the next line might appear to be indented relative to this
    # line, and get tagged as a new paragraph.
    my($total_prefix) = $self->{line} =~ /^(\s*[\w-=o\*]+.\s*)/;
    # Of course, we only use it if it really turns out to be a list.

    $islist = 1;
    $i++;
    if (($i > 0) && ($i != $self->{listnum})) {
        $self->endlist($self->{listnum} - $i);
        $islist = 0;
    } elsif (!$self->{listnum} || ($i != $self->{listnum})) {
        if (($self->{line_indent} > 0)
                || $self->is_blank($self->{prev}) 
                || ($self->{prev_action} & ($Txt2html::BREAK
                        | $Txt2html::HEADER))) {
            $islist = $self->startlist($prefix, $number, $rawprefix);
        } else {
            # We have something like this: "- foo" which usually
            # turns out not to be a list.
            return;
        }
    }

    $self->continuelist($prefix, $number, $rawprefix)
            if ($self->{mode} & $Txt2html::LIST);
    $self->{line_indent} = length($total_prefix) if $islist;
}

# Returns true if the passed string is considered to be preformatted
sub is_preformatted {
    my($self) = shift;
    (($_[0] =~ /\s{$self->{preformat_whitespace_min},}\S+/o) # whitespaces
     || ($_[0] =~ /\.{$self->{preformat_whitespace_min},}\S+/o)); # dots
}

sub endpreformat {
    my($self) = shift;
    if(!$self->is_preformatted($self->{line}) 
            && ($self->{endpreformat_trigger_lines} == 1 
                    || !$self->is_preformatted($self->{nextline})))
    {
	$self->{prev} .= "</PRE>\n";
	$self->{mode} ^= ($Txt2html::PRE & $self->{mode});
	$self->{line_action} |= $Txt2html::END;
    }
}

sub preformat {
    my($self) = shift;
    if($self->{preformat_trigger_lines} == 0 ||
            ($self->is_preformatted($self->{line}) &&
                    ($self->{preformat_trigger_lines} == 1 ||
                            $self->is_preformatted($self->{nextline})))) {
        $self->{line} =~ s/^/<PRE>\n/;
        $self->{prev} =~ s/<P>//;
        $self->{mode} |= $Txt2html::PRE;
        $self->{line_action} |= $Txt2html::PRE;
    }
}

sub make_new_anchor {
    my($self) = shift;
    my($heading_level) = @_;
    my($anchor, $i);

    return sprintf("%d", $self->{non_header_anchor}++) if (!$heading_level);

    $anchor = "section-";
    ${$self->{heading_count_aref}}[$heading_level-1]++;

    # Reset lower order counters
    for ($i = $#{$self->{heading_count}} + 1; $i > $heading_level; $i--) {
        ${$self->{heading_count}}[$i - 1] = 0;
    }

    for($i = 0; $i < $heading_level; $i++) {
        ${$self->{heading_count}}[$i] = 1
                if !${$self->{heading_count}}[$i]; # In case they skip any
        $anchor .= sprintf("%d.", ${$self->{heading_count}}[$i]);
    }
    chop($anchor);
    return $anchor;
}

sub anchor_mail {
    my($self) = shift;
    my($anchor) = $self->make_new_anchor(0);
    $self->{line} =~ s/([^ ]*)/<A NAME="$anchor">$1<\/A>/;
}

sub anchor_heading {
    my($self) = shift;
    my($level) = @_;
    my($anchor) = $self->make_new_anchor($level);
    $self->{line} =~ s/(<H.>)(.*)(<\/H.>)/$1<A NAME="$anchor">$2<\/A>$3/;
}

sub heading_level {
    my($self) = shift;
    my($style) = @_;
    ${$self->{heading_styles_href}}{$style} = ++$self->{num_heading_styles}
        if !${$self->{heading_styles_href}}{$style};
    return ${$self->{heading_styles_href}}{$style};
}

sub heading
{
    my($self) = shift;
    my($hoffset, $heading) = $self->{line} =~ /^(\s*)(.+)$/;

    $hoffset = "" unless defined($hoffset);
    $heading = "" unless defined($heading);
    my($uoffset, $underline) = $self->{nextline} =~ /^(\s*)(\S+)\s*$/;
    $uoffset = "" unless defined($uoffset);
    $underline = "" unless defined($underline);
    my($lendiff, $offsetdiff);
    $lendiff = length($heading) - length($underline);
    $lendiff *= -1 if $lendiff < 0;

    $offsetdiff = length($hoffset) - length($uoffset);
    $offsetdiff *= -1 if $offsetdiff < 0;

    if ($self->is_blank($self->{line})
            ||($lendiff > $self->{underline_length_tolerance})
            ||($offsetdiff > $self->{underline_offset_tolerance})) {
        return;
    }

    $underline = substr($underline, 0, 1);

    $underline .= "C"
            if $self->iscaps($self->{line}); # Call it a different style if the
    # heading is in all caps.
    $self->{nextline} = $self->getline();		# Eat the underline
    my($heading_level) = $self->heading_level($underline);
    $self->tagline("H" . $heading_level);
    $self->anchor_heading($heading_level);
    $self->{line_action} |= $Txt2html::HEADER;
}

sub custom_heading {
    my($self) = shift;
    my($i, $level);
    for($i=0; $i <= $#{$self->{custom_heading_regexp_aref}}; $i++) {
        if ($self->{line} =~ /${$self->{custom_heading_regexp_aref}}[$i]/) {
            if ($self->{explicit_headings}) {
                $level = $i + 1;
            } else {
                $level = $self->heading_level("Cust" . $i);
            }
            $self->tagline("H" . $level);
            $self->anchor_heading($level);
            $self->{line_action} |= $Txt2html::HEADER;
            last;
        }
    }
}

sub unhyphenate {
    my($self) = shift;
    my($second);

    # This looks hairy because of all the quoted characters.
    # All I'm doing is pulling out the word that begins the next line.
    # Along with it, I pull out any punctuation that follows.
    # Preceding whitespace is preserved.  We don't want to screw up
    # our own guessing systems that rely on indentation.
    ($second) =	$self->{nextline} =~ /^\s*([^\W\d_]+[\)\}\]\.,:;\'\"\>]*\s*)/; # "
    $self->{nextline} =~ s/^(\s*)[^\W\d_]+[\)\}\]\.,:;\'\"\>]*\s*/$1/; # "
    # (The silly comments are for my less-than-perfect code hilighter)

    $self->{nextline} = $self->getline() if $self->{nextline} eq "";
    $self->{line} =~ s/\-\s*$/$second/;
    $self->{line} .= "\n";
}

sub untabify {
    my($self) = shift;
    my($line) = @_;
    while ($line =~ /\011/) {
        $line =~ s/\011/" " x ($self->{tab_width} - (length($`) % $self->{tab_width}))/e;
    }
    return $line;
}

sub tagline {
    my($self) = shift;
    my($tag) = @_;
    chop $self->{line};                 # Drop newline
    $self->{line} =~ s/^\s*(.*)$/<$tag>$1<\/$tag>\n/;
}

sub iscaps {
    my($self) = shift;
    local($_) = @_;
    # This is ugly, but I don't know a better way to do it.
    # (And, yes, I could use the literal characters instead of the 
    # numeric codes, but this keeps the script 8-bit clean, which will
    # save someone a big headache when they transfer via ASCII ftp.
    return (/^[^a-z\341\343\344\352\353\354\363\370\337\373\375\342\345\347\350\355\357\364\365\376\371\377\340\346\351\360\356\361\362\366\372\374<]*[A-Z\300\301\302\303\304\305\306\307\310\311\312\313\314\315\316\317\320\321\322\323\324\325\326\330\331\332\333\334\335\336]{$self->{min_caps_length},}[^a-z\341\343\344\352\353\354\363\370\337\373\375\342\345\347\350\355\357\364\365\376\371\377\340\346\351\360\356\361\362\366\372\374<]*$/);
}

sub caps {
    my($self) = shift;
    if ($self->iscaps($self->{line})) {
        $self->tagline($self->{caps_tag});
        $self->{line_action} |= $Txt2html::CAPS;
    }
}

# Convert very simple globs to regexps
sub glob2regexp {
    my($self) = shift;
    my($glob) = @_;

    # Escape funky chars
    $glob =~ s/[^\w\[\]\*\?\|\\]/\\$&/g;
    my($regexp, $i, $len, $escaped) = ("", 0, length($glob), 0);

    for (; $i < $len; $i++) {
        my($char) = substr($glob, $i, 1);
        if ($escaped) {
            $escaped = 0;
            $regexp .= $char;
            next;
        }
        if ($char eq "\\") {
            $escaped = 1; next;
            $regexp .= $char;
        }
        if ($char eq "?") {
            $regexp .= "."; next;
        }
        if ($char eq "*") {
            $regexp .= ".*"; next;
        }
        $regexp .= $char;		# Normal character
    }
    return ("\\b" . $regexp . "\\b");
}

sub add_regexp_to_links_table {
    my($self) = shift;
    my($key,$URL, $switches) = @_;

    # No sense adding a second one if it's already in there.
    # It would never get used.
	if (!${$self->{links_table_href}}{$key}) {
	    # Keep track of the order they were added so we can
	    # look for matches in the same order
		push(@{$self->{links_table_order_aref}}, ($key));

	    ${$self->{links_table_href}}{$key} = $URL;	# Put it in The Table
	    ${$self->{links_switch_table_href}}{$key} = $switches;
		if ($self->{dict_debug} & 1) {
			print STDERR
					" ($#{$self->{links_table_order}})\tKEY: $key\n",
					"\tVALUE: $URL\n\tSWITCHES: $switches\n\n";
		}
	} else {
	    if($self->{dict_debug} & 1) {
		print STDERR " Skipping entry.  Key already in table.\n";
		print STDERR "\tKEY: $key\n\tVALUE: $URL\n\n";
	    }
	}
}

sub add_literal_to_links_table {
    my($self) = shift;
    my($key, $URL, $switches) = @_;

    $key =~ s/(\W)/\\$1/g; # Escape non-alphanumeric chars
    $key = "\\b$key\\b"; # Make a regexp out of it
    $self->add_regexp_to_links_table($key, $URL, $switches);
}

sub add_glob_to_links_table {
    my($self) = shift;
    my($key, $URL, $switches) = @_;
    $self->add_regexp_to_links_table($self->glob2regexp($key), $URL, $switches);
}

# This is the only function you should need to change if you want to
# use a different dictionary file format.
sub parse_dict {
    my($self) = shift;
    my($dictfile, $dict) = @_;
    my($message, $near);

    print STDERR "Parsing dictionary file $dictfile\n"
            if ($self->{dict_debug} & 1);

    $dict =~ s/^\#.*$//g;	 # Strip lines that start with '#'
    $dict =~ s/^.*[^\\]:\s*$//g; # Strip lines that end with unescaped ':'

    if($dict =~ /->\s*->/) {
        $message = "Two consecutive '->'s found in $dictfile\n";

        # Print out any useful context so they can find it.
        ($near) = $dict =~ /([\S ]*\s*->\s*->\s*\S*)/;
        $message .= "\n$near\n" if $near =~ /\S/; 
        die $message;
    }

    while ($dict =~ /\s*(.+)\s+\-+([ieho]+\-+)?\>\s*(.*\S+)\s*\n/ig) {
        my($key, $URL, $switches, $options);
        $key = $1;
        $options = $2;
        $options = "" unless defined($options);
        $URL = $3;
        $switches = 0;
        $switches += 1 if $options =~ /i/i; # Case insensitivity
        $switches += 2 if $options =~ /e/i; # Evaluate as Perl code
        $switches += 4 if $options =~ /h/i; # provides HTML, not just URL
        $switches += 8 if $options =~ /o/i; # Only do this link once

        $key =~ s/\s*$//;		# Chop trailing whitespace

		if ($key =~ m|^/|) {	# Regexp
			$key = substr($key,1);
			$key =~ s|/$||;		# Allow them to forget the closing /
			$self->add_regexp_to_links_table($key, $URL, $switches);
		} elsif ($key =~ /^\|/) { # alternate regexp format
			$key = substr($key,1);
			$key =~ s/\|$//;	# Allow them to forget the closing |
			$key =~ s|/|\\/|g;	# Escape all slashes
			$self->add_regexp_to_links_table($key, $URL, $switches);
		} elsif ($key =~ /\"/) {
			$key = substr($key,1);
			$key =~ s/\"$//;	# Allow them to forget the closing "
			$self->add_literal_to_links_table($key, $URL, $switches);
		} else {
			$self->add_glob_to_links_table($key, $URL, $switches);
		}
    }
}

sub in_link_context {
    my($self) = shift;
    my($match, $before) = @_;
    return 1 if $match =~ m@</?A>@i; # No links allowed inside match

    my($final_open, $final_close);
    $final_open = rindex($before, "<A ") - $[;
    $final_close = rindex($before, "</A>") - $[;

    return 1 if ($final_open >= 0) # Link opened
            && (($final_close < 0) # and not closed    or
                    || ($final_open > $final_close)); # one opened after last close

    # Now check to see if we're inside a tag, matching a tag name,
    # or attribute name or value
    $final_open  = rindex($before, "<") - $[;
    $final_close = rindex($before, ">") - $[;
    ($final_open >= 0)          # Tag opened 
            && (($final_close < 0) # and not closed    or
                    || ($final_open > $final_close)); # one opened after last close
}

# This subroutine looks a little odd.  Rather than build up some code
# and keep "eval"ing later, I'm building a new subroutine.  This way I
# can declare local vars and not worry about the namespace in the
# calling context.  I don't know how much it really gains me, but I
# don't know of any real costs and it seems like it could be
# friendlier to optimization.  (And it's fun to define new
# subroutines at runtime.  :-)

# I once thought that storing the finished dynamic_make_dictionary_links
# in a file and using it for subsequent invokations (when the
# dictionaries were the same) would save time.  I tried it, and the
# speed gain is insignificant.  (Using the standard links dictionary,
# it speeds up by 0.1 seconds per invokation on a 386/33 with a slow
# old hard drive.  I couldn't measure a difference on my fast machine.)
sub make_dictionary_links_code {
    my($self) = shift;
    my($i, $pattern, $switches, $options, $code, $href, $key, $s_sw, $r_sw);

    $code = <<EOCode;
sub dynamic_make_dictionary_links {
	my(\$self) = shift;
    my(\$line_link) = (\$self->{line_action} | \$Txt2html::LINK);
    my(\$before, \$linkme, \$line_with_links, \$link_line, \@done_with_link);

EOCode

	for ($i=1; $i <= $#{$self->{links_table_order_aref}}; $i++) {
		$pattern = ${$self->{links_table_order_aref}}[$i];
		$key = $pattern;
		$switches = ${$self->{links_switch_table_href}}{$key};

		$s_sw = "";				# Options for searching
		$s_sw .= "i" if($switches & 1);

		$r_sw = "";				# Options for replacing
		$r_sw .= "i" if($switches & 1);
		$r_sw .= "e" if($switches & 2);

		$href = ${$self->{links_table_href}}{$key};

		$href =~ s@/@\\/@g;
		$href = '<A HREF="' . $href . '">$&<\\/A>'
				if !($switches & 4);

		$code .= "    \$line_with_links = \"\";";
		if ($switches & 8)		# Do link only once
				{
					$code .= "
    while(!\$done_with_link[$i] && \$self->{line} =~ /$pattern/$s_sw) {
        \$done_with_link[$i] = 1;
";
				} else {
					$code .= "\n\twhile(\$self->{line} =~ /$pattern/$s_sw) {\n";
				}
		$code .= <<EOCode;
		\$link_line = \$Txt2html::LINK if(!\$link_line);
		\$before = \$\`;
		\$linkme = \$&;

		\$self->{line} = substr(\$self->{line},
			length(\$before) + length(\$linkme));
		\$linkme =~ s/$pattern/$href/$r_sw
	    	if(!\$self->in_link_context(\$linkme,\$line_with_links . \$before));
		\$line_with_links .= \$before . \$linkme;
    }
    \$self->{line} = \$line_with_links . \$self->{line};
EOCode
	}
$code .= <<EOCode;

    \$self->{line_action} |= \$line_link; # Cheaper only to do bitwise OR once.
}
EOCode
	if ($self->{dict_debug} & 2) {
		# XXX print STDERR "$code" if ($self->{dict_debug} & 2);
		open CODE, ">code.pl" || die "Error opening code.pl\n";
		print CODE $code;
		close CODE;
	}
    eval "$code";
    if($@) {
        print STDERR "Problem making dictionary eval code\n";
        die $@;
    }

    return $code;
}

sub load_dictionary_links {
    my($self, $inline_dict) = @_;
    my($dict, $contents);

    $inline_dict && $self->parse_dict('inline', $inline_dict);
    foreach $dict (@{$self->{links_dictionaries_aref}}) {
        next unless $dict;
        open(DICT, "$dict") || die "Can't open Dictionary file $dict\n";

        $contents = "";
        $contents .= $_ while(<DICT>);
        close(DICT);
        $self->parse_dict($dict, $contents);
    }
    $self->make_dictionary_links_code();
}

sub make_dictionary_links {
    my($self) = shift;
#    eval "$self->dynamic_make_dictionary_links();";
#    warn $@ if $@;
    $self->dynamic_make_dictionary_links();
}

sub getline {
    my($self) = shift;
    my($line);
#    $line = <>;
    $line = shift(@{$self->{source_aref}});
    $line = "" unless defined ($line);
    $line =~ s/[ \011]*\015$//;	# Chop trailing whitespace and DOS CRs
    $line = $self->untabify($line);   # Change all tabs to spaces
    return $line;
}

# XXX need to deal with all the options.
sub deal_with_options {
    my($self) = shift;

    if ($self->{preformat_trigger_lines} < 0) {
        $self->{preformat_trigger_lines} = 0;
    } elsif ($self->{preformat_trigger_lines} > 2) {
        $self->{preformat_trigger_lines} = 2;
    }

    if ($self->{preformat_trigger_lines} == 0) {
        $self->{endpreformat_trigger_lines} = 1;
    }
    if ($self->{endpreformat_trigger_lines} < 0) {
        $self->{endpreformat_trigger_lines} = 0;
    } elsif ($self->{endpreformat_trigger_lines} > 2) {
        $self->{endpreformat_trigger_lines} = 2;
    }
}

=head1 COPYRIGHT

Copyright (c) 1998 Seth Golub <seth@thehouse.org>
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions
are met:

=over 4

=item 1

Redistributions of source code must retain the above copyright
notice, this list of conditions and the following disclaimer.

=item 2

Redistributions in binary form must reproduce the above copyright
notice, this list of conditions and the following disclaimer in the
documentation and/or other materials provided with the distribution.

=item 3

The name of the author may not be used to endorse or promote products
derived from this software without specific prior written permission.

=back

THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

Converted to a perl module by John Yates, bivio, Inc.

=head1 COPYRIGHT

Copyright (c) 2000 bivio, Inc.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
