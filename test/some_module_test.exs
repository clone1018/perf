defmodule Perf.SomeModule do
  use Perf

  deftimer fast_function do
    "I'm fast!"
  end

  deftimer slow_function(arg) do
    IO.inspect(Enum.map(0..10, fn i -> fib(i) end))
    "I'm slow! w/ arg=" <> arg
  end

  def fib(0), do: 0
  def fib(1), do: 1
  def fib(n), do: fib(0, 1, n - 2)

  def fib(_, prv, -1), do: prv

  def fib(prvprv, prv, n) do
    next = prv + prvprv
    fib(prv, next, n - 1)
  end
end

defmodule Perf.SomeModuleTest do
  use ExUnit.Case

  setup_all do
    Perf.Store.start()

    :ok
  end

  test "calls the function" do
    assert Perf.SomeModule.slow_function("derp") == "I'm slow! w/ arg=derp"

    assert %{slow_function: time} = Perf.Store.get(Elixir.Perf.SomeModule)
    assert is_integer(time)

    assert Perf.SomeModule.fast_function() == "I'm fast!"

    assert %{slow_function: slow_time, fast_function: time} = Perf.SomeModule.perf_get_results()

    assert is_integer(time)
  end
end
