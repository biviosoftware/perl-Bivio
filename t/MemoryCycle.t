#!perl -w
# Copyright (c) 2026 bivio Software, Inc.  All rights reserved.
use strict;
use Bivio::Test;

# Optional dep; skip the suite rather than fail when it is absent.
BEGIN {
    unless (eval {require Devel::Cycle; 1}) {
        print "1..0 # SKIP Devel::Cycle not installed\n";
        exit(0);
    }
}

package Bivio::t::MemoryCycle::Testee;
use Bivio::UNIVERSAL;
use Bivio::UI::Widget::Join;
use Scalar::Util ();
@Bivio::t::MemoryCycle::Testee::ISA = ('Bivio::UNIVERSAL');

# find_cycle ignores weak refs, so a weakened back-pointer is intentionally uncounted.
sub count_cycles {
    my(undef, $root) = @_;
    my($n) = 0;
    Devel::Cycle::find_cycle($root, sub {$n++});
    return $n;
}

# Full task path (auth, model, render) that request_freed_after_teardown omits.
sub execute_login_once {
    my($proto) = @_;
    my($req) = Bivio::Test::Request->initialize_fully('LOGIN');
    Bivio::Agent::Task->get_by_id($req->get('task_id'))->execute($req);
    Bivio::Agent::Request->clear_current;
    return;
}

# Diff across renders so cached widgets cancel out, leaving only per-render leakers.
sub leaked_widget_sites {
    my($proto) = @_;
    return 'no Devel::Gladiator'
        unless eval {require Devel::Gladiator; 1};
    my($n) = 40;
    $proto->execute_login_once
        for 1 .. 10;
    my($before) = _widget_sites();
    $proto->execute_login_once
        for 1 .. $n;
    my($after) = _widget_sites();
    my(@grew) = sort {$after->{$b} - ($before->{$b} || 0)
        <=> $after->{$a} - ($before->{$a} || 0)} keys(%$after);
    print "# per-render LEAKING widget sites (growth over $n renders):\n";
    foreach my $s (@grew[0 .. 12]) {
        my($g) = $after->{$s} - ($before->{$s} || 0);
        last
            unless $g > 0;
        printf("#   +%-5d %.1f/render  %s\n", $g, $g / $n, $s);
    }
    return scalar(@grew);
}

# Measure after warmup so one-time arena/cache fill is excluded from the growth.
sub login_loop_rss_kb_growth {
    my($proto) = @_;
    my($warmup, $iters) = (30, 200);
    $proto->execute_login_once
        for 1 .. $warmup;
    my($base) = _rss_kb();
    for my $i (1 .. $iters) {
        $proto->execute_login_once;
        print('# login loop iter ', $i, ' rss=', _rss_kb(),
            ' KB delta=', _rss_kb() - $base, " KB\n")
            if $i % 50 == 0;
    }
    return _rss_kb() - $base;
}

# clear_current breaks the request's cycles; without it the global registry pins it.
sub request_freed_after_teardown {
    my($proto) = @_;
    my($weak);
    {
        my($req) = Bivio::Test::Request->initialize_fully;
        Scalar::Util::weaken($weak = $req);
        Bivio::Agent::Request->clear_current;
    }
    return defined($weak) ? 0 : 1;
}

# Identify the leaking class by diffing the live-object arena across renders.
sub view_render_arena_growth_per_render {
    my($proto) = @_;
    return _arena_growth_per_iter($proto, sub {shift->execute_login_once});
}

sub view_render_rss_kb_growth {
    my($proto) = @_;
    return _loop_rss_kb_growth(
        $proto, sub {_render_login_view_once(shift)}, 'view render');
}

# Guards that the weakened parent back-pointer leaves no cycle.
sub widget_tree_after_teardown {
    my($proto) = @_;
    my($parent, $child) = _tree($proto);
    $child->delete('parent');
    return $proto->count_cycles($parent);
}

# Weak parent back-ref lets the tree be reclaimed when its root is dropped.
sub widget_tree_freed_when_root_dropped {
    my($proto) = @_;
    my($weak_child);
    {
        my($parent, $child) = _tree($proto);
        Scalar::Util::weaken($weak_child = $child);
    }
    return defined($weak_child) ? 0 : 1;
}

sub _arena_growth_per_iter {
    my($proto, $op) = @_;
    return -1
        unless eval {require Devel::Gladiator; 1};
    my($iters) = 100;
    $op->($proto)
        for 1 .. 30;
    my($before) = Devel::Gladiator::arena_ref_counts();
    $op->($proto)
        for 1 .. $iters;
    my($after) = Devel::Gladiator::arena_ref_counts();
    my(@growth) = sort {$b->[1] <=> $a->[1]}
        map([$_, ($after->{$_} || 0) - ($before->{$_} || 0)],
            keys(%$after));
    print "# top live-object growth over $iters renders (class: +count,"
        . " +per-render):\n";
    foreach my $g (@growth[0 .. 14]) {
        next
            unless $g && $g->[1] > 0;
        printf("#   %-45s +%-8d %.1f/render\n",
            $g->[0], $g->[1], $g->[1] / $iters);
    }
    return sprintf('%.1f', ($growth[0][1] || 0) / $iters);
}

# Measure post-warmup so one-time fill is excluded.
sub _loop_rss_kb_growth {
    my($proto, $op, $tag) = @_;
    my($warmup, $iters) = (30, 200);
    $op->($proto)
        for 1 .. $warmup;
    my($base) = _rss_kb();
    for my $i (1 .. $iters) {
        $op->($proto);
        print('# ', $tag, ' iter ', $i, ' rss=', _rss_kb(),
            ' KB delta=', _rss_kb() - $base, " KB\n")
            if $i % 50 == 0;
    }
    return _rss_kb() - $base;
}

# Render-only (no Action/Model) to bisect whether the leak is in rendering.
sub _render_login_view_once {
    my($proto) = @_;
    my($req) = Bivio::Test::Request->initialize_fully('LOGIN');
    Bivio::Die->catch(sub {
        Bivio::UI::View->execute('PetShop->login', $req);
    });
    Bivio::Agent::Request->clear_current;
    return;
}

sub _rss_kb {
    my(@l) = `ps -o rss= -p $$`;
    (my $kb = $l[0]) =~ s/\D//g;
    return $kb;
}

# Child holds a hard 'parent' back-pointer (initialize_with_parent) — the cycle under test.
sub _tree {
    my($parent) = Bivio::UI::Widget::Join->new({values => []});
    my($child) = Bivio::UI::Widget::Join->new({values => []});
    $parent->put(values => [$child]);
    $child->initialize_with_parent($parent);
    return ($parent, $child);
}

# Tally live widgets by construction site; leakers recur per render, cached don't.
sub _widget_sites {
    my(%site);
    foreach my $o (@{Devel::Gladiator::walk_arena()}) {
        next
            unless Scalar::Util::blessed($o)
            && $o->isa('Bivio::UI::Widget');
        my($cc) = $o->unsafe_get('b_widget_calling_context');
        $site{($cc ? $cc->as_string : '(no calling context)')
            . '  [' . ref($o) . ']'}++;
    }
    return \%site;
}

package main;

# Request cases below are gated on a DB/facade; skip them rather than fail if absent.
my(@cases) = (
    widget_tree_freed_when_root_dropped => 1,
    widget_tree_after_teardown => 0,
);
if (
    eval {
        require Bivio::IO::Config;
        # Production caches views; must be set before any facade is set up below.
        Bivio::IO::Config->introduce_values({
            'Bivio::UI::Facade' => {want_local_file_cache => 1},
        });
        require Bivio::Test::Request;
        require Bivio::Agent::Request;
        require Bivio::Agent::Task;
        require Bivio::UI::View;
        require Bivio::Die;
        Bivio::Agent::Request->clear_current(
            Bivio::Test::Request->initialize_fully);
        1;
    }
) {
    push(@cases, request_freed_after_teardown => 1);
    # Skip the loop cases if the login task can't run in this environment.
    if (eval {Bivio::t::MemoryCycle::Testee->execute_login_once; 1}) {
        my($report) = sub {
            my($label) = @_;
            return sub {
                my($case, $actual) = @_;
                my($kb) = $actual->[0];
                my($per) = sprintf('%.1f', $kb / 200);
                print "# $label RSS growth after warmup: $kb KB"
                    . " over 200 iters ($per KB/request)\n";
                # RSS isn't pure leak (CSS arena high-water), so this bound only
                # catches gross regressions; leaked_widget_sites is authoritative.
                return $kb < 12000 ? $actual : ["LEAK: $per KB/request"];
            };
        };
        # Bisection: render-only vs. full task localizes the leak.
        push(@cases, view_render_rss_kb_growth => $report->('view render'));
        push(@cases, login_loop_rss_kb_growth => $report->('full login task'));
        push(@cases, view_render_arena_growth_per_render => sub {
            my($case, $actual) = @_;
            print "# dominant per-render object growth: $actual->[0]/render\n";
            return $actual;
        });
        push(@cases, leaked_widget_sites => sub {shift; $_[0]});
    }
    else {
        print "# SKIP login loop: $@\n";
    }
}
else {
    print "# SKIP request_freed_after_teardown: no DB/facade ($@)\n";
}

Bivio::Test->new('Bivio::t::MemoryCycle::Testee')->unit([
    'Bivio::t::MemoryCycle::Testee' => \@cases,
]);
