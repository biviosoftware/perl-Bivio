$^W = 1;
# This is here to avoid a bunch of error messages when societas
# is started in stack_trace_warn.
use MIME::Parser;
use Carp qw(verbose);
use Bivio::Agent::HTTP::Dispatcher;
Bivio::Agent::HTTP::Dispatcher->initialize;
