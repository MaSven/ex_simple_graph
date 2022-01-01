defmodule SimpleGraph do
  @moduledoc """
  A complete graph
  """
  alias SimpleGraph.Node
  use Agent
  require Logger

  @type t :: %__MODULE__{nodes: %{binary() => Node.t()}, id: String.t(), name: String.t()}

  @enforce_keys [:id, :name]
  defstruct nodes: %{}, id: "", name: ""

  def start_link(graph_name: name) when is_atom(name) do
    Agent.start_link(fn -> %SimpleGraph{id: UUID.uuid4(), name: name} end, name: name)
  end

  @spec graph(atom()) :: SimpleGraph.t()
  def graph(graph_name) when is_atom(graph_name) do
    Agent.get(graph_name, fn %SimpleGraph{} = state -> state end)
  end

  @spec add_node(graph: SimpleGraph.t(), name: atom(), node: binary(), outgoing: binary()) ::
          SimpleGraph.t()
  def add_node(name: name, node: node) when is_atom(name) do
    Agent.update(name, fn %SimpleGraph{} = graph ->
      %{graph | nodes: Map.put(graph.nodes, node.id, node)}
    end)
  end

  def add_node(name: name, node: node_id, outgoing: outgoing_id)
      when is_atom(name) and is_binary(node_id) and is_binary(outgoing_id) do
    Logger.debug("Adding node #{name}, with first node #{node_id} and outgoging #{outgoing_id}")

    Agent.update(name, fn %SimpleGraph{} = graph ->
      add_node(graph: graph, node: node_id, outgoing: outgoing_id)
    end)
  end

  def add_node(graph: %SimpleGraph{} = graph, node: node_id, outgoing: outgoing_id)
      when is_binary(node_id) and is_binary(outgoing_id) do
    with {:ok, node} <- get_node(graph, node_id),
         {:ok, outgoing} <- get_node(graph, outgoing_id) do
      [self: new_node, outgoing: new_outgoing] = Node.add_node(self: node, outgoing: outgoing)

      put_node(graph, new_node)
      |> put_node(new_outgoing)
    else
      {:error, reason} ->
        Logger.warning(reason, graph_id: graph.id)
        graph
    end
  end

  @spec get_node(SimpleGraph.t(), String.t()) :: {:ok, Node.t()} | {:error, String.t()}
  def get_node(%SimpleGraph{} = graph, node_id) do
    case Map.fetch(graph.nodes, node_id) do
      {:ok, %Node{} = node} -> {:ok, node}
      :error -> {:error, "Node #{node_id} not found"}
    end
  end

  @spec put_node(SimpleGraph.t(), Node.t()) :: SimpleGraph.t()
  def put_node(%SimpleGraph{} = graph, %Node{} = node) do
    %{graph | nodes: Map.put(graph.nodes, node.id, node)}
  end
end
