-module(ppool_worker).
-behaviour(gen_server).

-export([start_link/2]).
-export([init/1, handle_cast/2, handle_call/3, handle_continue/2]).

start_link(PoolName, WorkerName) ->
    gen_server:start_link({local, WorkerName}, ?MODULE, [PoolName], []).

init(Args) ->
    PoolName = lists:nth(1, Args),
    {ok, PoolName, {continue, notify_pool_manager}}.

handle_cast(Job, PoolName) ->
    Job(),
    {noreply, PoolName, {continue, notify_pool_manager}}.

handle_call(_Request, _From, PoolName) ->
    {reply, ok, PoolName}.

handle_continue(notify_pool_manager, PoolName) ->
    {registered_name, WorkerName} = erlang:process_info(self(), registered_name),
    erlang:send(PoolName, {put_worker, WorkerName}),
    {noreply, PoolName}.