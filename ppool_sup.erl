-module(ppool_sup).
-behaviour(supervisor).

-export([start_link/2]).
-export([init/1]).

start_link(PoolName, WorkersNumber) ->
   supervisor:start_link(ppool_sup, [PoolName, WorkersNumber]).

init(Args) ->
   PoolName = lists:nth(1, Args),
   WorkersNumber = lists:nth(2, Args),

   SupervisorFlags = #{strategy => rest_for_one},

   ChildSpecifications =
        [#{id => ppool_manager,
        start => {ppool_manager, start_link, [PoolName]},
        type => worker},
        #{id => ppool_worker_sup,
        start => {ppool_worker_sup, start_link, [PoolName, WorkersNumber]},
        type => supervisor}],

   {ok, {SupervisorFlags, ChildSpecifications}}.