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

L<Bivio::UI::HTML::Widget>

=cut

use Bivio::UI::HTML::Widget;
@Bivio::UI::HTML::Widget::DateTime::ISA = ('Bivio::UI::HTML::Widget');

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

=item value : array_ref (required)

Dereferenced and passed to C<$source-E<gt>get_widget_value>
to get date to use (see below).

=item undef_value : string ['&nbsp;']

What to display if I<value> is C<undef>.
Not used if I<value> is a constant.

=back

=cut

#=IMPORTS
use Bivio::Agent::Request;
use Bivio::Type::DateTime;
use Bivio::UI::DateTimeMode;
use Bivio::UI::HTML::Format::DateTime;
use Bivio::UI::HTML::Widget::JavaScript;

#=VARIABLES
my($_PACKAGE) = __PACKAGE__;
my($_UNIX_EPOCH) = Bivio::Type::DateTime->UNIX_EPOCH_IN_JULIAN_DAYS;
my($_SECONDS) = Bivio::Type::DateTime->SECONDS_IN_DAY;
my($_JSV) = Bivio::UI::HTML::Widget::JavaScript->VERSION_VAR;

# Write once, run nowhere...  Date.getFullYear was not introduced
# until JavaScript 1.2.  Date.getYear is totally broken.  Read
# O'Reilly JavaScript book under Date.getYear.  IE3 doesn't go
# before 1970.  NS3 does bizarre things with dates.  Anyway,
# this is the solution.  Study it carefully before changing it.
my($_FUNCS) = <<"EOF";
function dt(m,j,t,gmt){
var y=j-$_UNIX_EPOCH;
if(y<0
&&navigator.appName.indexOf('Microsoft')
&&navigator.appVersion<4.0){
document.write(gmt);
return;
}
var d=new Date((y*$_SECONDS+t)*1000);
document.write(
((m&1)?dt_n(d.getMonth()+1)+'/'+dt_n(d.getDate())+'/'+dt_n(dt_y(d)):'')
+(m==3?' ':'')
+((m&2)?dt_n(d.getHours())+':'+dt_n(d.getMinutes()):''));
}
function dt_n(n){
return n<10?'0'+n:n;
}
function dt_y(d){
if($_JSV>=1.2){return d.getFullYear();}
var y=d.getYear();
return y<1000?y+1900:y;
}
EOF

=head1 FACTORIES

=cut

=for html <a name="new"></a>

=head2 static new(hash_ref attributes) : Bivio::UI::HTML::Widget::DateTime

Creates a new DateTime widget.

=cut

sub new {
    my($self) = &Bivio::UI::HTML::Widget::new(@_);
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

    # Don't display anything if null
    $$buffer .= $fields->{undef_value}, return unless defined($value);
    my($req) = Bivio::Agent::Request->get_current;
    unless ($req->unsafe_get('javascript_dt')) {
	Bivio::UI::HTML::Widget::JavaScript->render($source, $buffer);
	# ASSUMES: Bivio::UI::DateTimeMode is DATE=1, TIME=2 & DATE_TIME=3
	$$buffer .= "<script language=\"JavaScript\">\n<!--\n";
	$$buffer .= $_FUNCS;
	$req->put(javascript_dt => 1);
    }
    else {
	$$buffer .= "<script language=\"JavaScript\">\n<!--\n";
    }
    my($gmt) = Bivio::UI::HTML::Format::DateTime->get_widget_value(
	    $value, $fields->{mode});
    my($mi) = $fields->{mode};
    $$buffer .= 'dt('.join(',', $mi, split(' ', $value), "'$gmt'").')'
	    ."\n// -->\n</script><noscript>";
    $$buffer .= $gmt;
    $$buffer .= '</noscript>';
    return;
}

#=PRIVATE METHODS

=head1 COPYRIGHT

Copyright (c) 1999 bivio, LLC.  All rights reserved.

=head1 VERSION

$Id$

=cut

1;
