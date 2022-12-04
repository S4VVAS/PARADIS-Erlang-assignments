%Assignment 3.3 by SAVVAS GIORTSIS (sagi2536)

-module(ring).
-export([start/2]).

start(N, M) when N > 0 ->
	masterNode(M,N);
start(0, _) ->
	0.

createLinkNodes(Previous, N) when N > 1 ->
	CurrentPid = spawn(fun () -> myNode(Previous) end),
	createLinkNodes(CurrentPid, N-1);
createLinkNodes(Previous, 1) ->
	spawn(fun () -> myNode(Previous) end).
	
masterNode(Itterations, NumNodes) ->
	MPid = self(),
	LastNode = createLinkNodes(MPid, NumNodes),
	masterNode(LastNode, Itterations, 0).
	
masterNode(NextNode, Itterations, StartNum) ->
	if
	Itterations > 0 ->
		Ref = make_ref(),
		NextNode ! {StartNum, Ref},
		receive
			{Integer, Ref} ->
				masterNode(NextNode, Itterations-1, Integer)
		end;
	true ->
		NextNode ! {terminate},
		receive
			{terminate} ->
				StartNum
		end
	end.

myNode(NextNode) ->
	receive
		{Integer, Ref} ->
			NextNode ! {Integer + 1, Ref},
			myNode(NextNode);
		{terminate} ->
			NextNode ! {terminate}
	end.