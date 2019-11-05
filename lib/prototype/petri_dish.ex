defmodule Prototype.PetriDish do
  @moduledoc """

  This process holds the objects in the petri dish

  """
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    {:ok, %{}}
  end

  @doc """
  Retrieve all objects in the dish
  """
  def all do
    GenServer.call(__MODULE__, :all)
  end

  @doc """
  Get a single object from the dish.
  Objects must have an id to be retreived from the dish
  """
  def get(%{id: _} = object) do
    GenServer.call(__MODULE__, {:get, object})
  end

  def get(_) do
    {:error, :missing_id}
  end

  @doc """
  Create a new object in the dish.
  Objects must have an id and x/y coordinates to be added to the dish
  """
  def create(%{id: _, x: x, y: y} = object) when is_integer(x) and is_integer(y) do
    GenServer.cast(__MODULE__, {:create, object})
  end

  def create(_) do
    {:error, :invalid_object}
  end

  @doc """
  Update an object in the dish.
  Objects must have an id and x/y coordinates to be updated in the dish
  """
  def update(%{id: _, x: x, y: y} = object) when is_integer(x) and is_integer(y) do
    GenServer.cast(__MODULE__, {:update, object})
  end

  def update(_) do
    {:error, :invalid_object}
  end

  @doc """
  Remove an object from the dish.
  Objects must have an id to be removed from the dish
  """
  def remove(%{id: _} = object) do
    GenServer.cast(__MODULE__, {:remove, object})
  end

  def remove(_) do
    {:error, :missing_id}
  end

  @doc """
  Call to clear all objects from the petri dish.
  """
  def clear do
    GenServer.cast(__MODULE__, :clear)
  end

  def handle_call(:all, _from, state) do
    {:reply, Map.values(state), state}
  end

  def handle_call({:get, %{id: id}}, _from, state) do
    {:reply, Map.get(state, :"#{id}"), state}
  end

  def handle_cast({:create, %{id: id} = organism}, state) do
    {:noreply, Map.put(state, :"#{id}", organism)}
  end

  def handle_cast({:update, %{id: id} = organism}, state) do
    {:noreply, Map.replace!(state, :"#{id}", organism)}
  end

  def handle_cast({:remove, %{id: id}}, state) do
    {:noreply, Map.delete(state, :"#{id}")}
  end

  def handle_cast(:clear, _state) do
    {:noreply, %{}}
  end

end
