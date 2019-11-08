defmodule Prototype.Food do
  use GenServer, restart: :transient

  require Logger

  alias Prototype.{PetriDish, Food}

  defstruct [
    id: nil, # used to identify food
    type: :food, # defaults to food
    x: nil, # X coordinate for current location
    y: nil, # Y coordinate for current location
    time_to_spoil: 30_000, # in milliseconds.
    width: 5,
    height: 5,
    radius: 5,
    calories: 3 # How much food will increase stamina 1-5
  ]

  def start_link(%{bounds: %{x: _x, y: _y} = bounds}) do
    id = UUID.uuid4()

    GenServer.start_link(
      __MODULE__,
      %{id: id, bounds: bounds},
      name: {:via, :global, id})
  end

  def init(state) do
    {:ok, state, {:continue, :sprout}}
  end

  def consumed(%{id: _id} = dna) do
    remove(dna)
  end

  def handle_continue(:sprout, state) do
    dna =
      state
      |> new()
      |> set_timer()
      |> draw()

    {:noreply, dna}
  end

  def handle_info(:spoil, dna) do
    remove(dna)

    {:stop, :normal, dna}
  end

  defp new(%{id: id, bounds: %{x: x, y: y}}) do
    %Food{
      id: id,
      x: Enum.random(50..(x - 50)),
      y: Enum.random(50..(y - 50)),
    }
  end

  defp set_timer(%{time_to_spoil: tts} = dna) do
    :timer.send_after(tts, :spoil)
    dna
  end

  defp draw(dna) do
    PetriDish.draw(dna)
    dna
  end

  defp remove(dna), do: PetriDish.remove(dna)

end
