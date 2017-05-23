defmodule ED do
  @moduledoc """
  Documentation for ED.
  """

  @doc """
  Hello world.

  ## Examples

      iex> ED.hello
      :world

  """
  def hello do
    :world
  end
  
  def state, do: Process.get :state
  
  def handle_event({:message_create, payload}, state) do
    IO.puts "Received Message Create Event"
    IO.inspect payload
    Process.put :state, state
    {:ok, state}
  end
  
  def handle_event({event, _payload}, state) do
    IO.puts "Received Event: #{event}"
    {:ok, state}
  end

end
