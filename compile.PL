$^W = 1;
use Carp qw(verbose);
use Bivio::Agent::Dispatcher;
Bivio::Agent::Dispatcher->initialize;
use Bivio::UI::HTML::Club::Page;
Bivio::UI::HTML::Club::Page->get_instance;
