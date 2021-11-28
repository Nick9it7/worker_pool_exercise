-module(ppool_manager).
-behaviour(gen_server).

-export([start_link/1]).
-export([init/1, handle_cast/2, handle_call/3, handle_info/2, handle_continue/2]).
-export([run_job/2]).

-record(state, {workers=[], queue=queue:new()}).

start_link(PoolName) ->
    gen_server:start_link({local, PoolName}, ?MODULE, [], []).

init(_Args) ->
    {ok, #state{}}.

run_job(PoolName, Job) ->
    gen_server:cast(PoolName, Job).

handle_info({put_worker, WorkerName}, State = #state{workers=Workers}) ->
    {noreply, State#state{workers = [WorkerName | Workers]}, {continue, allocate_worker}}.

handle_cast(Job, State = #state{queue=Queue}) ->
    {noreply, State#state{queue = queue:in(Job, Queue)}, {continue, allocate_worker}}.

handle_call(_Job, _From, State) ->
    {reply, ok, State}.

handle_continue(allocate_worker, State = #state{workers=[Worker | AvailableWorkers], queue=Queue}) ->
    NewState =
        case queue:peek(Queue) of
            {value, Job} ->
                gen_server:cast(Worker, Job),
                State#state{workers = AvailableWorkers, queue=queue:drop(Queue)};
                
            empty ->
                State
        end,

    {noreply, NewState};

handle_continue(allocate_worker, State) ->
    {noreply, State}.