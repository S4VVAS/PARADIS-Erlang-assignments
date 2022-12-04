%Assignment 2.3 by SAVVAS GIORTSIS (sagi2536)

-module(pmap).
-export([unordered/2,unordered/3, ordered/3]).

unordered(Fun, L) ->
	Pids = [spawn_work([I], Fun) || I <- L],
	gather(Pids).
unordered(Fun, L, MaxWorkers) -> % ;)
	ordered(Fun,L,MaxWorkers).
ordered(Fun, L, MaxWorkers) ->
	Pids = [spawn_batch_worker(SubList, Fun) || SubList <- split_list(L, MaxWorkers)],
	gather(Pids).

gather([]) ->
	[];
gather([Pid|Pids]) ->
	receive
		{Pid, {ok, Result}} ->
			Result ++ gather(Pids)
	end.
	
%-----------------WORKERS-----------------------
	
worker() ->
	receive
		{Master, {Fun, Work}} ->
			Master ! {self(), {ok, [Fun(I) || I <- Work]}}
	end.
	

%-----------------UNORDERED/2-----------------------

spawn_work(Elm, Fun) ->
	Pid = spawn(fun () -> worker() end),
	Pid ! {self(), {Fun, Elm}},
	Pid.

%-----------------UNORDERED/3-----------------------
	
spawn_batch_worker(SubList, Fun) ->
	Pid = spawn(fun () -> worker() end), %MONITOR THIS ONE TO RECIEVE ONE MESSAGE AT A TIME
	Pid ! {self(), {Fun, SubList}},
	Pid.
	
%-----------------HELPER-FUNCTIONS------------------

split_list(L, N) when N > 0->
	if 
	length(L) >= N ->
		Len = round((length(L) / N));
	true -> 
		Len = 1
	end,
	split(L, Len, 1, N).
	
split(L, Len, Curr, N) ->
	if 
	(length(L) >= Len+Curr) and (N > 1)->
		[lists:sublist(L, Curr, Len)] ++ split(L, Len, Curr+Len, N-1);
	N == 1 ->
		[lists:sublist(L, Curr, length(L))];
	true ->
		[lists:sublist(L, Curr, Len)]
	end.