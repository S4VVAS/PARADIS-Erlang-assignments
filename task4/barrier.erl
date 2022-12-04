%Assignment 4.1 by SAVVAS GIORTSIS (sagi2536)

-module(barrier).
-export([start/1, wait/2, inList/2]).

start(Refs) ->
    spawn_link(fun () -> loop(Refs, []) end).

loop(Expected, PidRefs) when length(PidRefs) =:= Expected ->
    [Pid ! {continue, Ref} || {Pid, Ref} <- PidRefs],
    loop(Expected, []);
loop(Expected, PidRefs) ->
    receive
	{arrive, {Pid, Ref}} ->
	case inList(Ref, PidRefs) of
		true ->
			loop(Expected, [{Pid, Ref}|PidRefs]);
		false->
			Pid ! {continue, Ref}
	end
	    
    end.
	
inList(Elm, List) ->
	lists:any(fun(X) -> X == Elm end, List).

wait(StartPid, Ref) ->

    StartPid ! {arrive, {self(), Ref}},
    receive
	{continue, Ref} ->
	    ok
    end.
