$^W = 1;
use Carp qw(verbose);

BEGIN {
    # Force the debugger to stop
    $DB::single = 1;
    # Avoid warnings
    $_ = $DB::single;
}
use Bivio::Agent::HTTP::Dispatcher;
Bivio::Agent::HTTP::Dispatcher->initialize;
