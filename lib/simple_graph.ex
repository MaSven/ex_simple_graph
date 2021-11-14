defmodule SimpleGraph do
  alias SimpleGraph.Node
  use Agent
  require Logger

  @type t :: %__MODULE__{nodes: %{binary() => Node.t()}, id: String.t(), name: String.t()}

  @enforce_keys [:id, :name]
  defstruct nodes: %{}, id: "", name: ""

  def start_link(graph_name: name) when is_binary(name) do
    Agent.start_link(fn -> %SimpleGraph{id: UUID.uuid4(), name: name} end, name: name)
  end

  def add_node(name: name, node: node, outgoing: outgoing)
      when is_binary(name) and is_binary(node) and is_binary(outgoing) do
    Agent.get(name, fn graph -> add_node(graph: graph, node: node, outgoing: outgoing) end)
  end

  def add_node(gaph: %SimpleGraph{} = graph, node: node_id, outgoing: outgoing_id)
      when is_binary(node_id) and is_binary(outgoing_id) do
    with {:ok, node} <- get_node(graph, node_id),
         {:ok, outgoing} <- get_node(graph, node_id) do
      new_root = Node.add_outgoing(self: node, outgoing: outgoing)
      Map.put(graph.nodes, node_id, new_root)
    else
      {:error, reason} ->
        Logger.warning(reason, graph_id: graph.id)
        graph
    end
  end

  @spec get_node(SimpleGraph.t(), String.t()) :: {:ok, Node.t()} | {:error, String.t()}
  def get_node(%SimpleGraph{} = graph, node_id) do
    case Map.get(graph.nodes, node_id) do
      %Node{} = node -> {:ok, node}
      nil -> {:error, "Node with id #{node_id |> inspect()} not found"}
    end
  end
end
