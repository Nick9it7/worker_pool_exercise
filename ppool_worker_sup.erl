-module(ppool_worker_sup).
-behaviour(supervisor).

-export([start_link/2]).
-export([init/1]).

start_link(PoolName, WorkersNumber) ->
   supervisor:start_link(ppool_worker_sup, [PoolName, WorkersNumber]).

init(Args) ->
   PoolName = lists:nth(1, Args),
   WorkersNumber = lists:nth(2, Args),

   ChildSpecifications =
      lists:map(fun(WorkerNumber) -> 
         WorkerPoolName = list_to_atom(string:concat("ppool_worker", integer_to_list(WorkerNumber))),
         gen_child_spec(PoolName, WorkerPoolName)
       end, lists:seq(1, WorkersNumber)),

   {ok, {#{}, ChildSpecifications}}.

gen_child_spec(PoolName, WorkerPoolName) ->
   #{id => WorkerPoolName,
   start => {ppool_worker, start_link, [PoolName, WorkerPoolName]},
   type => worker}.