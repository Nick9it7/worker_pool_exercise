-module(ppool).
-export([run_async_job/2]).

run_async_job(PoolName, Job) ->
    ppool_manager:run_job(PoolName, Job).