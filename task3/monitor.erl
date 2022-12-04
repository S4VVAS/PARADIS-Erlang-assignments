%Assignment 3.1 by SAVVAS GIORTSIS (sagi2536)

-module(monitor).
-export([start/0, init/1, start_double/0, double/1, double/0]).

-behaviour(supervisor).

start() ->
	supervisor:start_link(?MODULE, []).
	
init(_) ->
	SupFlags = #{
		strategy => one_for_one, 
		intensity => 10, 
		period => 5},
    ChildSpec = [#{
		id => double_id,
		start => {monitor, start_double, []}}],
    
	{ok,{SupFlags, ChildSpec}}.
	
start_double() ->
	Pid = spawn_link(monitor, double, []),
	register(double, Pid),
	{ok, Pid}.

double() ->
	receive
	{Pid, Ref, N} ->
		Pid ! {Ref, N * 2},
		double()
	end.
	
	
double(X) ->
	Ref = make_ref(),
	double ! {self(), Ref, X},
	receive
	{Ref, Doubled} ->
		Doubled
	after 1000 -> 
		timed_out
	end.