%Assignment 2.1.2 by SAVVAS GIORTSIS (sagi2536)

-module(monitor).
-export([start/0]).

start() ->
	double:start(),
	on_error_restart_double().
	
on_error_restart_double() ->
	spawn( fun() ->
		Pid = whereis(double),
		Ref = monitor(process, Pid),
		receive
			{'DOWN', Ref, process, Pid, _} ->
				demonitor(Ref),
				start()	
		end
	end).