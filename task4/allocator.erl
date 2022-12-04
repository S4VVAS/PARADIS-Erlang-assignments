%Assignment 4.2 by SAVVAS GIORTSIS (sagi2536)

-module(allocator).
-export([start/1, request/2, release/2]).

start(Resources) ->
    spawn_link(fun () ->
		       allocator(Resources)
	       end).

request(Pid, RequestedList) ->
    Ref = make_ref(),
    Pid ! {request, {self(), Ref, RequestedList}},
    receive
	{granted, Ref, Resources} ->
	    Resources;
	{wait,Ref,resource_not_found} ->
		request(Pid, RequestedList)
    end.

release(Pid, ResourcesList) ->
    Ref = make_ref(),
    Pid ! {release, {self(), Ref, ResourcesList}},
    receive
	{released, Ref} ->
	    ok
    end.

allocator(Resources) ->
    receive
	{request, {Pid, Ref, N}} when N =< length(Resources) ->
		R = getResources(Resources, N),
		case R of
		{ok, NotR, Req} ->
			Pid ! {granted, Ref, Req},
			allocator(NotR);
		{error,resource_not_found,_} ->
			Pid ! {wait,Ref,resource_not_found},
			allocator(Resources)
		end;
	{release, {Pid, Ref, Released}} ->
	    Pid ! {released, Ref},
	    allocator(Released ++ Resources)
    end.

getResources(AllResources, Requested) -> %Returns => {ok, NOT_REQUESTED, REQUESTED} , error if resource not found, specifying which
	getResources(AllResources, Requested, #{}).	
getResources(AllResources, [RName|T], Found) ->
	Resource = maps:find(RName, AllResources),
	case Resource of
	{ok, R} ->
		NFound = maps:put(RName, R, Found),
		NAll = maps:remove(RName, AllResources),
		getResources(NAll, T, NFound);
	error ->
		{error, resource_not_found, RName}
	end;
getResources(AllResources, [], Found) ->
	{ok, AllResources, Found}.