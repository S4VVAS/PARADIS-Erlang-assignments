%Assignment 2.2 by SAVVAS GIORTSIS (sagi2536)

-module(bank).
-export([start/0, balance/2, deposit/3, withdraw/3, lend/4]).

%-----------------START--------------------------

start() -> 
	{Pid,Ref} = spawn_monitor(fun () -> server_loop(#{}) end),
	
	spawn(fun () ->
			receive
			{'DOWN', Ref, process, _, _} ->
				demonitor(Ref),
				start()	
		end
	end),
	Pid.
	
server_loop(Accounts) ->
	receive
		{Key, MPid, Ref} -> %get balance from key
			case (catch maps:get(Key, Accounts)) of
				{'EXIT',{{Reason,_},_}} ->
					MPid ! {error, Reason};
				Amt -> 
					MPid ! {ok, Amt, Ref}
			end,
			server_loop(Accounts);
		{Key, NewBalance, MPid, Ref} -> %make changes to key
			NewAccounts = maps:put(Key, NewBalance, Accounts),
			MPid ! {ok, maps:get(Key, NewAccounts), Ref},
			server_loop(NewAccounts)
	end.
	
%-----------------BALANCE--------------------------
	
balance(Pid, Who) -> 
	case is_process_alive(Pid) of
	false ->
		no_bank;
	true ->
		Ref = make_ref(),
		Pid ! {Who, self(), Ref},
		receive
			{ok, Amt, Ref} ->
				{ok, Amt};
			{error, badkey} ->
				no_account;
			{error, Reason} ->
				{error, Reason}
		after 1000 ->
			time_out
		end
	end.
	
%-----------------DEPOSIT--------------------------
	
deposit(Pid, Who, X) -> 
	case is_process_alive(Pid) of
	false ->
		no_bank;
	true ->
		Ref = make_ref(),
		Pid ! {Who, self(), Ref},
		receive
			{ok, Amt, Ref} ->
				update_money_in_account(Pid, Amt + X, Who);
			{error, badkey} ->
				update_money_in_account(Pid, X, Who);
			{error, Reason} ->
				{error, Reason}
		after 1000 ->
			time_out
		end
	end.
	
%-----------------WITHDRAW-------------------------
	
withdraw(Pid, Who, X) ->
	case is_process_alive(Pid) of
	false ->
		no_bank;
	true ->
		Ref = make_ref(),
		Pid ! {Who, self(), Ref},
		receive
			{ok, Amt, Ref} ->
				if 
				Amt - X < 0 ->
					insufficient_funds;
				true ->
					update_money_in_account(Pid, Amt - X, Who)
				end;
			{error, badkey} ->
				no_account;
			{error, Reason} ->
				{error, Reason}
		after 1000 ->
			time_out
		end
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
					{AnwFrom}
			end;
		true -> %To does not exist
			if	
			(no_account == FromBalance) ->
				{no_account, both};
			true ->
				{ToBalance, To}
			end
	end.

%-----------------HELPER---------------------------
	
update_money_in_account(Pid, NewBalance, Who) ->
	Ref = make_ref(),
	Pid ! {Who, NewBalance, self(), Ref},
	receive
		{ok, Amt, Ref} ->
			{ok, Amt};
		_ ->
			{error, could_not_complete_operation}
	end.
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	