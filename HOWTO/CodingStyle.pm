# Copyright (c) 2002-2007 bivio Software, Inc.  All Rights Reserved.
# $Id$
package Bivio::HOWTO::CodingStyle;
use strict;
$Bivio::HOWTO::CodingStyle::VERSION = sprintf('%d.%02d', q$Revision$ =~ /\d+/g);
$_ = $Bivio::HOWTO::CodingStyle::VERSION;

=head1 NAME

Bivio::HOWTO::CodingStyle - documents bOP coding style

=head1 RELEASE SCOPE

bOP

=head1 SYNOPSIS

    perldoc Bivio::HOWTO::CodingStyle;

=cut

use Bivio::UNIVERSAL;
@Bivio::HOWTO::CodingStyle::ISA = ('Bivio::UNIVERSAL');

=head1 DESCRIPTION

C<Bivio::HOWTO::CodingStyle> describes the bOP coding style.

=head2 Format

=over 4

=item *

Indent by four.

=item *

Keyword statements are formatted with the keyword (if, elsif, while,
continue) beginning the line:

    if ($a eq $b) {
       some op;
    }
    elsif ($a eq $c) {
       some op;
    }
    else {
       some op;
    }


=item *

All lines should be less than 80 characters, including pod.  Any perl line
that exceeds 80 char should break on logic, '(', or '->', e.g.,

    long_line_call(
        arg1, arg2);

    really_long_args(
        arg1,
	arg2,
	...
    );

    $some_object->long_method(
        arg1,
	arg2,
    );

    $some_long_object
        ->method;

=item *

Operators should have spaces around them:



    $a = $b + $c;
    $a = $b . $c;

=item *

For clarity, the list of imports should be sorted (ctrl-x ctrl-l on the
region).

=item *

Don't line things up vertically. It gets messed up as the program is maintained
and variables are renamed.

    my($name) = 'Paul';
    my($favorite_color) = 'green';
    ### not
    #
    # my($name)           = 'Paul';
    # my($favorite_color) = 'green';


=back

=head2 Emacs

=head3 General Tips

=over 4

=item *

Let emacs do the work for you. We rely on C<cperl-mode> to do the
formatting for us. Sometimes it screws up, but most of the time it does
a great job. Hit I<tab> on lines that don't make sense.

=item *

If a file does not end in .pl or .pm, include the line:
C<'#mode:cperl'>
at the bottom before
C<'#End:'>. to make it fontify correctly

=item *

Use the bivio's builtin functions in emacs mode. bivio functions begin
with C<b-perl-> when C<cperl-mode> is loaded.

=back

=head3 Special method names:

=over 4

=item _trace

C<_trace> does an Trace::IO::Trace-E<gt>register and creates the variable
C<$_TRACE>.

=item handle_config

C<handle_config> does an Bivio::IO::Config-E<gt>register

=back

=head2 Naming

Name things absolutely uniquely with non-redundant, names if possible
esp. if you think the name might change. This is a difficult task. The
importance of good names for large system components cannot be overemphasized.
For example, we use the term honorific for the title of the user. This
originally was title. We changed the name with some difficulty when its
fundemental semantics changed.

=head3 Files:

=over 4

=item *

Modules should end in .pm

=item *

Programs should not end in .pl (see the Emacs section
for how to get them to fontify)

=item *

Programs should start with 'b-' eg, b-realm-admin and b-petshop.

=item *

Use dashes '-' instead of underscores '_' in URI components or names that might
become URI components, e.g. foo-bar.bview.  It's easier to read when
underlined. For example, we have file-delete and not file_delete.

=back

=head3 Variables:

=over 4

=item *

Multiword variables names should use the form:

    my($long_name) = ...;

=back

=head3 Methods:

=over 4

=item *

Constant subs should be uppercase and use '_' to separate words.
Declare constants before methods.

     e.g.
     sub SOME_CONSTANT {
         return 10;
     }

Use C-c c in emacs to create constants.

=item *

Protected methods begin with an C<internal_> prefix,
as in:

     =head2 internal_this_class_family()

     Called to do something from subclasses to superclasses or vice-versa.

     =cut

     sub internal_this_class_family {
	 my(self) = @_;
	 die('protected method') unless
	     caller(0)->isa(__PACKAGE__);
     }

Normally, we don't "protect" a protected method with an assertion like this.

=back

=head2 Documentation

=over 4

=item *

Write the code so that it doesn't need to be 

=item *

Don't use method prototypes. Perl doesn't use this when dynamically dispatching
an object method anyway.

=back

=head3 Comments:

=over 4

=item *

Comments should always be on their own line, with a space after the '#'.


     Eg:
     sub _foo() {
     my($num) = @_;
     # This is a fine comment
     while ($num E<lt> 10) {
     #this one has bad spacing
     ...
     } # and don't put one here
     }



=item *

Code which is unfinished or a "hack" which should be fixed is marked as
below. This comment is left justified, so it is easily recognizable.


     #TODO: Description of problem here.

=item *

Factories should be documented in the FACTORIES section. In cperl-mode,
if you define new it will be put in the FACTORIES section with the appropriate
super call.

=item *

Bivio::IO::Alert-E<gt>warn should
be used instead of perl's warn. We catch perl's warn and output a stack
trace, because it indicates a program error of some sort. Explicit warnings
should not need a stack trace. Note that
C<Bivio::IO::Alert-E<gt>warn>
inserts the location of the message and the newline, so you don't have
to. Warning messages should contain dynamic data, but use commas to separate
the variables.
C<Bivio::IO::Alert-E<gt>warn> automatically truncates
long values and unwraps hash_refs and array_refs.

=item *

C<Bivio::IO::Trace> for debugging output.
Don't check in libraries that use C<print STDERR> for debugging
statements.  You'll never find the print statements again.

If you define the subroutine _trace in cperl-mode, it will automatically
insert the following statements:

     use Bivio::IO::Trace;
     use vars qw($_TRACE);
     Bivio::IO::Trace->register;

register creates private routine _trace and defines the variable
C<$_TRACE>.
Both of these are local to the module in which register is called. The
value of C<$_TRACE> and the implementation of _trace are dynamically
modified with the value of the trace parameters. See the module documentation
for more details.

Usage:

     _trace($bla) if $_TRACE;

=item *

Configuration is handled by registering with
C<Bivio::IO::Config>.
If you define the method
C<handle_config> in cperl-mode, it automatically
inserts the following code:


     use Bivio::IO::Config;
     Bivio::IO::Config->register;

and the method handle_config which takes specific parameters. Look around
for modules that use configuration, e.g. C<Bivio::IO::Trace>
and C< Bivio::Ext::DBI>. Read the perldoc of C<Bivio::IO::Config>
for how to configuration your system.

=item *

Exceptions are managed by C<Bivio::Die>. Modules which would like
to catch exceptions "along the way" should define a handle_die method.
This method will be called if a method "up the stack" calls
C<Bivio::Die-E<gt>catch>.
See C<Bivio::Agent::Dispatcher>, it calls catch. See C<Bivio::Agent::Task>,
it defines a
C<handle_die>. For the brave, check out the implementation
of
C<Bivio::Die>.

=item *

Primary Ids are strings, not numbers. Use "eq" and "ne" for comparison.
Do not depend on the value of the contents.

=item *

Use C<Bivio::ShellUtil> as the base class for program function classes.
The programs themselves should simply call:

   Bivio::Some::Program::Package->main(@ARGV);

=item *

Avoid the use of C<Bivio::Agent::Request-E<gt>get_current> or
C<get_current_or_new>.
Instead in Widgets, use
C<$source-E<gt>get_request>, which should always
return the request being rendered.

You'll need to use:

   $source->get_request->get_widget_value

on widget values set from inherited attributes, e.g. form_model.

=item *

ListModel queries are sometimes tricky to get right, because Oracle tends
towards the "constants" in the query. The first constant evaluated should
be the auth_id, since this will narrow the query to just the realm's data.
If there is another constant, e.g. entry_type, make sure the auth_id qualifies
this table.

=item *

Magic variables are conveniences. Here is a list:

     $_M is 'Bivio::Type::Amount'.
     $_W is 'Bivio::UI::HTML::Widget'.
     $_IDI is the instance data index, see Bivio::UNIVERSALx

=item *

CONNECT BY should be programmed as follows:


     SELECT expense_category_id, name, deductible,
     parent_category_id, level
     FROM expense_category_t
     START WITH realm_id=? AND parent_category_id IS NULL
     CONNECT BY realm_id=?
     AND parent_category_id = PRIOR expense_category_id
     ORDER BY LEVEL;

The realm_id and any other constant qualifying parameters (e.g. volume)
should be specified in the "START WITH" and the "CONNECT BY".

=back

=head2 Syntax

=head3 Perl/General:

=over 4

=item *

    #!/usr/bin/perl -w
    use strict;

=item *

To force the debugger to stop at a particular piece of code, use:

     $DB::single = 1;

It is harmless if the debugger isn't running. compile.PL has this otherwise
you never get a chance to "break" the debugger.

=item *

Watch out for this one:


     my($value) = '0.00';
     #--- case one ------
     $value ||= 'blah';
     #--- case two ------
     $value = 'blah' if $value == 0;

The two cases aren't equivalent, the first case isn't using numeric comparison
so it won't be applied. The second is the correct form. Very embarrassing.

=item *

Avoid variable interpolation in trace and die statements. If the
variables are undef, this may cause problems. Also avoid string concatenation
(which defeats string checking).

	   _trace('Name = ', $name) if $_TRACE;

Incorrect usage:

	   _trace("Name = $name") if $_TRACE; # WRONG
	   _trace('Name ='.$name) if $_TRACE; # WRONG

_trace statements never need a '\n' at the end.

=item *

Perl commands that are methods should be followed by a parenthesis (no
space) like all methods.

	   if (defined($foo)) {...
      not  if (defined $foo)  {...

=back

=head3 Imports:

=over 4

=item *

To avoid namespace pollution created by the @EXPORT=... statement in third
party modules, packages should be imported as

     use Third::Party::Package ();

Unfortunately, this doesn't always work. perl's autoload feature is abused
by many third party packages, e.g. GDBM, and you must pollute your namespace.
In general, wrap third party modules

when possible to avoid general name space pollution and tight coupling.
This allows us to maintain stable interfaces in the face of third party
API changes.

=back

=head3 Method Dispatch:

=over 4

=item *

Always call public static methods using the dynamic dispatch (->) form.


     ex.
     Foo->bar(); # not Foo::bar(), or bar().

In other words, the first parameter to all public methods is either $proto
or $self. There is no such restriction on private methods, since the _method()
form is used--see below.


=item *

Constants should be called with dynamic dispatch (->), because they may
be overriden,


     e.g. Bivio::Biz::FormModel->SUBMIT_OK.

Invoke private methods using the form E<lt>method-name>(...). This avoids
dynamic lookup and will always use the method from the current package.
Prepend a '_' to private methods and variables.

     ex.
     my($_GLOBAL_PRIVATE) = ...;
     sub _foo {
     my($self) = @_;
     ...
     }
     _foo($self);

C<cperl-mode> automatically inserts methods which begin with an underscore
(_) in the C<#=PRIVATE SUBROUTINE> section of the module.

=back

=head3 HTML:

=over 4

=item *

If you have a series of td's, and you want one of them to expand into
filling a browser of any size, with the other ones fixed, you can't use
a colspan anwhere in the table. The solution is to use two tables, and
not have any whitespace between table ... /table E<gt>E<lt>table E<gt> ...
E<lt>/table E<gt>.


BTW, E<lt>td width=xxx> is sometimes required for IE to behave properly.  So
E<lt>td>E<lt>table width=xxx> is not the same as E<lt>td width=xxx>E<lt>table
width=xxx> for instance. This is an IE, not a NS bug.

=back

=head2 Style

=head3 General:

=over 4

=item *

Keep instance state in its own namespace
within the field hash. This avoids having to know the field names of all
super/sub classes when adding a new field to a class.


     ex.
     my($fields) = {};
     $self->{$_PACKAGE} = $fields;
     $fields->{'foo'} = ...;

When calling overridden method in superclass, try to use the following
form:

     sub some_method {
     my($self) = shift;
     .... my stuff here...
     return $self->SUPER::my_method(@_);
     }

This allows the superclass to change its parameters and return types without
changing all subclasses.


Any class which has subclasses should define the factory method
new(). This allows the generated code for new() in the subclasses to
work correctly.


The new() method should always create a $self->{$_PACKAGE} (fields)
reference. 


$self->{$_PACKAGE} (fields) should never be reassigned or created in
any other method.



=item *

Avoid global variables in modules except at initialization. This avoids
subtle bugs in supposedly stateless servers. It's ok to cache certain things
from the database, e.g. see
C<Bivio::Auth::Realm>. State should be
held in objects. There is global state here, but more easily managed. In
the servers,
C<Bivio::Agent::Request> holds the state which is cleared
after each request. Put it on the request if you need global state (context)
during a operation.




=item *

Avoid putting logic in perl programs. It is likely it will be reused, so
create a module that contains the logic and call it from the program. For
an example, see the perl/Bivio/Biz/Util directory.




=item *

Don't use temporary variables in a method if it can be avoided. Never use
the word 'temp' in a variable name. Avoiding temporary variables makes
it easier to analyze long methods. This rule can be relaxed in certain
cases (like format statements).


     ex.
     sub add_error {
	 my($self, $error) = @_;

	 ### like this
	 push(@{$self->[$_IDI]->{'errors'}}, $error);

	 ### not this
	 #my($temp_ref) = $self->[$_IDI]->{'errors'};
	 # push(@$temp_ref, $error);
     }



=item *

In general, pass and return references to arrays and hashes. For example,
Bivio::Collection::Attributes-E<GT>new takes a hash_ref, which it assumes ownership
of.

There are exceptions, e.g. multi-variable method results, e.g.
C<Bivio::Type::from_literal> and variable argument methods, e.g.
C<Bivio::Biz::PropertyModel::load>.

=item *

Import "minimally", i.e. don't use packages unless you have to. This goes
against the standard of declaring before use, but this standard is only
useful for unqualified imports. We always import qualified (full package
name), so you know where the object is coming from.

=item *

Little languages pop up everywhere. perl is an interpreted language,
so you don't need to invent your own languages. For examples, see
C<Bivio::IO::Config, Bivio::Biz::Model::Preferences,> and
C<Bivio::IO::Trace>. If the language is part of a critical
run-time path or there are security concerns, make up your own. There
is a performance penalty, of course.  For example,
C<Bivio::Agent::HTTP::Cookie> doesn't use eval, but uses split
and stuffs the attributes in a hash.

The advantages of using one language for everything outweighs
almost any disadvantage.

=item *

Methods that return a value should use the 'return' keyword.

     sub foo {
         return 1;
     }

=item *

Encapsulate anything that can be. Don't expose unnecessary variables,
methods, etc.

=item *

Avoid modifying global data structures, even if they aren't used again.

=back


=head2 Die

=over 4

=item *

We use a fail fast policy within the application. If the code cannot recover
from a state problem, call die. However, exceptions should be thrown or
returned when data is invalid, e.g. no rows match a user query.

=item *

C<Bivio::Die-E<gt>die> or C<die> should be used to indicate a program
error. Use C<Bivio::Die> when in doubt. In general, die is
just a short hand which doesn't check its arguments carefully. You can
also use:


     Bivio::Die->throw('DIE', {entity => $bla, ....});

This is more cumbersome, but allows you to set an arbitrary list of attributes
associated with the error. Typically, you just want to print a message
with some arguments, so the above form is rarely used.

=item *

If you can continue, but would like to log the error use

   Bivio::IO::Alert->warn

=back

=head2 Arguments

=over 4

=item *

Always unwrap arguments as the first statement.


     sub foo {
	 my($self, $count, $file_name) = @_;
	 ...
     }

There are a few exceptions. In constructors, you may pass the arguments
on as follows:

     sub new {
         my($self) = shift->SUPER::new(@_);
     }

If the function is overloaded or takes unlimited arguments, i.e. it checks
the number and type of its parameters, it may make sense to check @_ explicitly.

If you have no need for $self or $proto, you may say

     sub my_static_func {
         my(undef, $other_arg) = @_;
     }

Another special case is the use of $fields (see discussion of instance
state</a>). If you don't need $self, you may use:

     sub my_func {
         my($fields) = shift->[$_IDI]
     }


=back

=cut

=head1 COPYRIGHT

Copyright (c) 2002-2007 bivio Software, Inc.  All Rights Reserved.

=head1 VERSION

$Id$

=cut

1;
