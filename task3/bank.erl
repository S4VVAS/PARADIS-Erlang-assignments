%Assignment 3.2 by SAVVAS GIORTSIS (sagi2536)

-module(bank).
-export([start/0, balance/2, deposit/3, withdraw/3, lend/4, handle_call/3, handle_cast/2, init/1, terminate/2, handle_continue/2, handle_info/2]).
-behaviour(gen_server).
	
handle_info(_AnyTerm, State) ->
	{noreply, State}.
	
handle_continue({get, _Name}, State) ->
    {noreply, State};
handle_continue({set, _Name, _Address}, State) ->
    {noreply, State}.


handle_call({get, Name}, _From, State) ->                  %%GET BALANCE
	Reply = case ets:lookup(accounts, Name) of
	[] ->
	    not_found;
	[{Name, Balance}] ->
	    {ok, Balance}
	end,
    {reply, Reply, State, {continue, {get, Name}}}.
	
handle_cast({set, {Who, NewBalance}}, State) ->             %%SET BALANCE
	ets:insert(accounts, {Who, NewBalance}),
    {noreply, State, {continue, {set, Who, NewBalance}}}.
	
init(_) ->
	ets:new(accounts, [set,private,named_table]),
	{ok, no_state}.

start() ->
	{ok, Pid} = gen_server:start(?MODULE, [], []),
	Pid.

terminate(_Reason, _State) ->
    ets:delete(accounts),
    ok.

%-----------------BALANCE--------------------------

balance(Pid, Who) -> 
	case is_process_alive(Pid) of
	true ->
		Response = gen_server:call(Pid, {get, Who}),
		if 
			Response == not_found ->
				no_account;
			true ->
				Response
		end;
	false -> 
		no_bank
	end.

%-----------------DEPOSIT--------------------------

deposit(Pid, Who, X) -> 
	case is_process_alive(Pid) of
		true ->
			Response = gen_server:call(Pid, {get, Who}),
			if 
				Response == not_found ->
					gen_server:cast(Pid, {set, {Who, X}}),
					gen_server:call(Pid, {get, Who});
				true ->
					{ok, Amt} = Response,
					gen_server:cast(Pid, {set, {Who, Amt + X}}),
					gen_server:call(Pid, {get, Who})
			end;
		false -> 
			no_bank
	end.


%-----------------WITHDRAW-------------------------

withdraw(Pid, Who, X) ->
	case is_process_alive(Pid) of
		true ->
			Response = gen_server:call(Pid, {get, Who}),
			if 
				Response == not_found ->
					no_account;
				true ->
					{ok, Amt} = Response,
					if 
						Amt - X >= 0 ->
							gen_server:cast(Pid, {set, {Who, Amt - X}}),
							gen_server:call(Pid, {get, Who});
						Amt - X < 0 ->
							insufficient_funds
					end
			end;
		false -> 
			no_bank
	end.
	
%-----------------LEND---------------------------

lend(Pid, From, To, X) ->
	ToBalance = balance(Pid, To), %Check if 'To' exists
	FromBalance = balance(Pid, From), %Check if 'From' exists
	if
		ToBalance =/= no_account ->
			AnwFrom = withdraw(Pid, From, X),
			case AnwFrom of	
				{ok,_} -> %%put money withdrawn in to 'To'
					deposit(Pid, To, X),
					ok;
				no_account ->
					{no_account, From};
				no_bank ->
					no_bank;
				_ ->
					AnwFrom
			end;
		true -> %To does not exist
			if	
			(no_account == FromBalance) ->
				{no_account, both};
			true ->
				{ToBalance, To}
			end
	end.
