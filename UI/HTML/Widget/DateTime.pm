# Copyright (c) 1999 bivio, LLC.  All rights reserved.
# $Id$
package Bivio::UI::HTML::Widget::DateTime;
use strict;
$Bivio::UI::HTML::Widget::DateTime::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);

=head1 NAME

Bivio::UI::HTML::Widget::DateTime - prints dates/times in html

=head1 SYNOPSIS

    use Bivio::UI::HTML::Widget::DateTime;
    Bivio::UI::HTML::Widget::DateTime->new($attrs);

=cut

=head1 EXTENDS

L<Bivio::UI::Widget>

=cut

use Bivio::UI::Widget;
@Bivio::UI::HTML::Widget::DateTime::ISA = ('Bivio::UI::Widget');

=head1 DESCRIPTION

C<Bivio::UI::HTML::Widget::DateTime> produces dates which are interpreted
locally by browsers which support javascript.  If the browser doesn't
support javascript, the strings are printed in gmt.

=head1 ATTRIBUTES

=over 4

=item mode : Bivio::UI::DateTimeMode [DATE]

What to display.
Passed to
L<Bivio::UI::DateTimeMode::from_any|Bivio::UI::DateTimeMode/"from_any">
so can be just the string name.

=item show_timezone : boolean [1]

If GMT is displayed (no JavaScript), show the time zone.

=item value : array_ref (required)

Dereferenced and passed to C<$source-E<gt>get_widget_value>
to get date to use (see below).

=item undef_value : string ['&nbsp;']

What to display if I<value> is C<undef>.
Not used if I<value> is a constant.

=back

=cut


=head1 CONSTANTS

=cut

=for html <a name="JAVASCRIPT_FUNCTIONS"></a>

=head2 JAVASCRIPT_FUNCTIONS : string

Returns the functions loaded when javascript is loaded.

=cut

my($_FUNCS);
sub JAVASCRIPT_FUNCTIONS {
    return $_FUNCS;
}

=for html <a name="JAVASCRIPT_FUNCTION_NAME"></a>

=head2 JAVASCRIPT_FUNCTION_NAME : string

Return the tag used by this class to prefix javascript functions.

=cut

sub JAVASCRIPT_FUNCTION_NAME {
    return 'dt';
}

#=IMPORTS
use Bivio::Agent::Request;
use Bivio::Type::DateTime;
use Bivio::UI::DateTimeMode;
use Bivio::UI::Font;
use Bivio::UI::HTML::Widget::JavaScript;
use Bivio::UI::HTML::ViewShortcuts;

#=VARIABLES
my($_VS) = 'Bivio::UI::HTML::ViewShortcuts';

my($_PACKAGE) = __PACKAGE__;
my($_UNIX_EPOCH) = Bivio::Type::DateTime->UNIX_EPOCH_IN_JULIAN_DAYS;
my($_SECONDS) = Bivio::Type::DateTime->SECONDS_IN_DAY;
my($_JSV) = Bivio::UI::HTML::Widget::JavaScript->VERSION_VAR;
my($_FN) = JAVASCRIPT_FUNCTION_NAME();

# Write once, run nowhere...  Date.getFullYear was not introduced
# until JavaScript 1.2.  Date.getYear is totally broken.  Read
# O'Reilly JavaScript book under Date.getYear.
$_FUNCS = Bivio::UI::HTML::Widget::JavaScript->strip(<<"EOF");
function dt(m,j,t,gmt){
    // Subtract off the Julian year
    var y=j-$_UNIX_EPOCH;

    // If we have a negative year, IE3.0 won't render it at all; use GMT
    if(y<0
            &&navigator.appName.indexOf('Microsoft')>=0
            &&parseFloat(navigator.appVersion)<4.0){
        document.write(gmt);
        return;
    }
    // Convert the time to milliseconds adding in the seconds component
    var d=new Date((y*$_SECONDS+t)*1000);

    // ASSUMES: Bivio::UI::DateTimeMode is DATE=1, TIME=2, DATE_TIME=3
    //          and MONTH_NAME_AND_DAY_NUMBER=4, DAY_AND_NUMBER=5
    // This renders more compact javascript and is possibly slower on client.
    document.write(
        m<=3?
            ((m&1)?dt_n(d.getMonth()+1)+'/'+dt_n(d.getDate())+'/'+dt_n(dt_y(d))
                  :'')
            +(m==3?' ':'')
            +((m&2)?dt_n(d.getHours())+':'+dt_n(d.getMinutes()):'')
        :m==4?dt_mn(d)+' '+d.getDate()
        :m==5?dt_n(d.getMonth()+1)+'/'+dt_n(d.getDate())
        :'');
}

// Returns a zero-padded number
function dt_n(n){
    // Why doesn't javascript have a sprintf?  Insert leading 0s
    return n<10?'0'+n:n;
}

// Returns the year
function dt_y(d){
    // NS3 does bizarre things with dates.  Anyway,
    // this is the solution.  Study it carefully before changing it.
    if($_JSV>=1.2){
        return d.getFullYear();
    }
    var y=d.getYear();
    return y<1000?y+1900:y;
}

// Returns the long month name
function dt_mn(d){
    switch(d.getMonth()){
    case 0: return 'January';
    case 1: return 'February';
    case 2: return 'March';
    case 3: return 'April';
    case 4: return 'May';
    case 5: return 'June';
    case 6: return 'July';
    case 7: return 'August';
    case 8: return 'September';
    case 9: return 'October';
    case 10: return 'November';
    case 11: return 'December';
    }
    return 'N/A';
}
EOF

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(hash_ref attributes) : Bivio::UI::HTML::Widget::DateTime

Creates a new DateTime widget.

=cut

sub new {
    my($self) = Bivio::UI::Widget::new(@_);
    $self->{$_PACKAGE} = {};
    return $self;
}

=head1 METHODS

=cut

=for html <a name="initialize"></a>

=head2 initialize()

Initializes static information.  In this case, prefix and suffix
field values.

=cut

sub initialize {
    my($self) = @_;
    my($fields) = $self->{$_PACKAGE};
    return if exists($fields->{value});
    $fields->{value} = $self->get('value');
    $fields->{mode} = Bivio::UI::DateTimeMode->from_any(
	    $self->get_or_default('mode', 'DATE'))->as_int;
    $fields->{undef_value} = $self->get_or_default('undef_value', '&nbsp;');
    $fields->{font} = $self->ancestral_get('string_font', undef);
    $fields->{no_timezone} = !$self->get_or_default('show_timezone', 1);
    warn("initialized without parent") unless $self->get('parent');
    return;
}

=for html <a name="render"></a>

=head2 render(any source, string_ref buffer)

Render the object.

=cut

sub render {
    my($self, $source, $buffer) = @_;
    my($fields) = $self->{$_PACKAGE};
    die('not initialized') unless exists($fields->{value});
    my($value) = $source->get_widget_value(@{$fields->{value}});

    my($p, $s) = $fields->{font} ? Bivio::UI::Font->format_html(
	    $fields->{font}, $source->get_request) : ('', '');
    $$buffer .= $p;
    # Don't display anything if null
    unless (defined($value)) {
	$$buffer .= $fields->{undef_value};
	$$buffer .= $s;
	return;
    }
    my($gmt) = Bivio::UI::HTML::Format::DateTime->get_widget_value(
	    $value, $fields->{mode}, $fields->{no_timezone});
    my($mi) = $fields->{mode};

    # Let Javascript do the work
    Bivio::UI::HTML::Widget::JavaScript->render($source, $buffer,
	    $_FN,
	    $_FUNCS,
	    # Must not begin dates with 0 (netscape barfs, so have to
	    # print as decimals
	    "$_FN(".sprintf('%d,%d,%d,%s', $mi, split(' ', $value),
		    "'$gmt'").');',
	    $gmt);
    $$buffer .= $s;
    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
