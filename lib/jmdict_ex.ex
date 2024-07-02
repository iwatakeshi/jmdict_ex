defmodule JMDictEx do
  use Application
  @impl true
  def start(_type, _args) do
    JMDictEx.Supervisor.start_link(name: JMDictEx.Supervisor)
  end
end
