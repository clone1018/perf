defmodule Perf.Store do
  use GenServer

  @me __MODULE__

  @moduledoc """
  Simple GenServer for keep track of Perf history.
  """

  def start(default \\ []) do
    GenServer.start(__MODULE__, default, name: @me)
  end

  def set(module, function, value) do
    GenServer.cast(@me, {:set, module, function, value})
  end

  def get(module) do
    GenServer.call(@me, {:get, module})
  end

  def get(module, function) do
    GenServer.call(@me, {:get, module, function})
  end

  def keys do
    GenServer.call(@me, {:keys})
  end

  def delete(key) do
    GenServer.cast(@me, {:remove, key})
  end

  def stop do
    GenServer.stop(@me)
  end

  def init(args) do
    {:ok, Enum.into(args, %{})}
  end

  def handle_cast({:set, module, function, value}, state) do
    {:noreply, state |> Map.put_new(module, %{}) |> put_in([module, function], value)}
  end

  def handle_cast({:remove, key}, state) do
    {:noreply, Map.delete(state, key)}
  end

  def handle_call({:get, module}, _from, state) do
    {:reply, state[module], state}
  end

  def handle_call({:get, module, function}, _from, state) do
    {:reply, state[module][function], state}
  end

  def handle_call({:keys}, _from, state) do
    {:reply, Map.keys(state), state}
  end
end
