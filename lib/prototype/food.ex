defmodule Prototype.Food do
  use GenServer, restart: :transient

  alias Prototype.{PetriDish, Food}

  defstruct [
    id: nil, # used to identify food
    type: :food, # defaults to food
    x: nil, # X coordinate for current location
    y: nil, # Y coordinate for current location
    time_to_spoil: 30_000, # in milliseconds.
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

  def consumed(%{id: id}) do
    with pid when is_pid(pid) <- :global.whereis_name(id) do
      GenServer.stop(pid)
    end
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
      x: Enum.random(5..(x - 5)),
      y: Enum.random(5..(y - 5)),
    }
  end

  defp set_timer(%{time_to_spoil: tts} = dna) do
    :timer.send_after(tts, :spoil)
    dna
  end

  defp draw(dna) do
    PetriDish.create(dna)
    dna
  end

  defp remove(dna), do: PetriDish.remove(dna)

end
