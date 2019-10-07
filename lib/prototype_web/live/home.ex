defmodule PrototypeWeb.Live.Home do
  use Phoenix.LiveView

  def mount(_, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~L"""
    <div>
      <h2>Hello World!</h2>
    </div>
    """
  end
end
