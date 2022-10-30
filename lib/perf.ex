defmodule Perf do
  @moduledoc """
  Documentation for `Perf`.
  """

  defmacro __using__(_opts) do
    quote do
      import unquote(__MODULE__)

      def perf_get_results() do
        Perf.Store.get(__MODULE__)
      end
    end
  end

  defmacro deftimer(call, do: block) do
    block_with_timer =
      quote do
        # This actually replaces the inside of the function by wrapping it in a timing call, and sending it to our Perf.Store GenServer.
        %{module: mod, function: {function, arity}, file: file, line: line} = __ENV__

        {time, return} = :timer.tc(fn -> unquote(block) end)
        Perf.Store.set(mod, function, time)

        return
      end

    quote do
      def unquote(call) do
        unquote(block_with_timer)
      end
    end
  end
end
