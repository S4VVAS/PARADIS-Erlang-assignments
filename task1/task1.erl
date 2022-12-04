%Assignment 1 by SAVVAS GIORTSIS (sagi2536)

-module(task1).

-export([eval/1, eval/2, map/2, filter/2, split/2, groupby/2]).

%----------HELPER-FUNCTIONS---------------

eval({Op,E1,E2}) ->
	Result = evaluate({Op,E1,E2}),
	{ok, Result}.
	
eval({Op,E1,E2}, Map) ->
	Result = (catch evaluateHash({Op,E1,E2}, Map)),
	if
	is_integer(Result) -> 
		{ok,Result};
	true ->
		{_,{H,_}} = Result,
		
		if
		H == badarith ->
			{error,variable_not_found};
		true ->
			{error, H}
		end
	end.
	
map(F,L) ->
	map(F,L,[]).
	
filter(P,L) ->
	filter(P,L,[]).

split(P,L) ->
	split(P,L,{[],[]}).
	
groupby(F, L) ->
	groupby(F, L, 1, #{}).
	
%----------------TASK1-------------------

evaluate({add,E1,E2}) ->
	evaluate(E1 + evaluate(E2));
	
evaluate({mul,E1,E2}) ->
	evaluate(E1 * evaluate(E2));
	
evaluate({'div',E1,E2}) ->
	evaluate(E1 div evaluate(E2));
	
evaluate({sub,E1,E2}) ->
	evaluate(E1 - evaluate(E2));
	
evaluate({_,_,_}) ->
	{error, invalid_operator};
	
evaluate(E) ->
	E.	
	
%-----------------TASK2------------------

evaluateHash({add,E1,E2}, Map) ->
	catch evaluateHash(E1, Map) + evaluateHash(E2, Map);
	
evaluateHash({mul,E1,E2}, Map) ->
	catch evaluateHash(E1, Map) * evaluateHash(E2, Map);
	
evaluateHash({'div',E1,E2}, Map) ->
	catch evaluateHash(E1, Map) div evaluateHash(E2, Map);
	
evaluateHash({sub,E1,E2}, Map) ->
	catch evaluateHash(E1, Map) - evaluateHash(E2, Map);
	
evaluateHash({_,_,_}, _) ->
	{error, invalid_operator};

evaluateHash(E, Map) ->
	Num = (catch maps:find(E,Map)),
	
	if 
	Num == error -> %Value of E was not found in hashmap
		catch E * 1; %if E is not numerical, E is a unvalid variable (i know this is not a beautiful solution)
	true ->
		{ok, Return} = Num,
		Return
	end.
	
%-----------------TASK3.1----------------

map(F,[H|T], UpdList) ->
	map(F,T,UpdList ++ [F(H)]);
	
map(_,[],UpdList) ->
	UpdList.

%-----------------TASK3.2----------------

filter(F,[H|T], UpdList) ->
	Anw = F(H),
	if 
	Anw ->	
		filter(F,T, UpdList ++ [H]);
	true -> 
		filter(F,T, UpdList)
	end;
	
filter(_,[],UpdList) ->
	UpdList.
	
%-----------------TASK3.3----------------
	
split(F,[H|T], {TrueL, FalseL}) ->
	Anw = F(H),
	if 
	Anw ->	
		split(F,T, {TrueL ++ [H], FalseL});
	true -> 
		split(F,T, {TrueL,FalseL ++ [H]})
	end;
	
split(_,[],{TrueL, FalseL}) ->
	{TrueL, FalseL}.

%-----------------TASK3.4----------------

	
groupby(F,[H|T], Counter, HMap) ->
	Key = F(H),
	Exists = maps:find(Key,HMap),
	if
	Exists == 'error' -> %No key in HMap exists
		groupby(F,T, Counter + 1, maps:put(Key, [Counter], HMap));
	true -> %Key exists
		{_,Arr} = maps:find(Key,HMap),
		groupby(F,T, Counter + 1, maps:put(Key, Arr ++ [Counter], HMap))
	end;
	
groupby(_,[],_, HMap) ->
	HMap.

%-----------END-OF-ASSIGNMENT------------




	