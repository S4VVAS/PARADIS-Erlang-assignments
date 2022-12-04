%Assignment 2.1.1 by SAVVAS GIORTSIS (sagi2536)

-module(double).
-export([start/0, double/1]).

start() ->
	register(double, spawn(fun double/0)).

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
	end.