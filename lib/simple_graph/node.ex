defmodule SimpleGraph.Node do
  @moduledoc """
  A Node in the graph. A node has directed edges to others nodes. These nodes are either in the `outgoing` or in the `incoming` list. All adjancy nodes are in the `adjacent` list.
  """

  alias SimpleGraph.Node

  @type graph_id :: String.t()

  @type t :: %__MODULE__{
          adjacent: [graph_id()],
          subgraphs: [graph_id()],
          value: any(),
          outgoing: [graph_id()],
          incoming: [graph_id()],
          id: graph_id(),
          parent: graph_id() | nil
        }

  @enforce_keys [:value, :id]
  defstruct adjacent: [],
            outgoing: [],
            incoming: [],
            subgraphs: [],
            value: "",
            id: "",
            parent: nil

  @spec create_node(any()) :: Node.t()
  def create_node(value) do
    %Node{value: value, id: UUID.uuid4(:default)}
  end

  @spec add_node(self: Node.t(), outgoing: Node.t(), incoming: Node.t(), subgraph: Node.t()) ::
          [self: Node.t(), outgoing: Node.t()]
          | [self: Node.t(), incoming: Node.t()]
          | [self: Node.t(), subgraph: Node.t()]
  def add_node(self: %Node{} = self, outgoing: %Node{} = outgoing) do
    new_outgoing = %Node{
      outgoing
      | adjacent: [self.id | outgoing.adjacent],
        incoming: [self.id | outgoing.incoming]
    }

    [
      self: %Node{
        self
        | adjacent: [new_outgoing.id | self.adjacent],
          outgoing: [new_outgoing.id | self.outgoing]
      },
      outgoing: new_outgoing
    ]
  end

  def add_node(self: %Node{} = self, incoming: %Node{} = incoming) do
    new_incoming = %Node{
      incoming
      | outgoing: [self.id | incoming.outgoing],
        adjacent: [self.id | incoming.adjacent]
    }

    [
      self: %Node{
        self
        | adjacent: [incoming.id | self.adjacent],
          incoming: [incoming.id | self.incoming]
      },
      incoming: new_incoming
    ]
  end

  def add_node(self: %Node{} = self, subgraph: %Node{} = sub) do
    new_sub = %Node{sub | parent: self.id}
    [self: %Node{self | subgraphs: [sub.id | self.subgraphs]}, subgraph: new_sub]
  end

  @spec remove_node(self: Node.t(), outgoing: Node.t(), incoming: Node.t(), subgraph: Node.t()) ::
          [self: Node.t(), outgoing: Node.t()]
          | [self: Node.t(), incoming: Node.t()]
          | [self: Node.t(), subgraph: Node.t()]
  def remove_node(self: %Node{} = self, outgoing: %Node{} = outgoing) do
    new_outgoing = %Node{
      outgoing
      | incoming: outgoing.incoming |> Enum.reject(fn x -> x == self.id end),
        adjacent: outgoing.adjacent |> Enum.reject(fn x -> x == self.id end)
    }

    [
      self: %Node{
        self
        | outgoing: self.outgoing |> Enum.reject(&(&1 == outgoing.id)),
          adjacent: self.adjacent |> Enum.reject(&(&1 == outgoing.id))
      },
      outgoing: new_outgoing
    ]
  end

  def remove_node(self: %Node{} = self, incoming: %Node{} = incoming) do
    new_incoming = %Node{
      incoming
      | outgoing: incoming.outgoing |> Enum.reject(&(&1 == self.id)),
        adjacent: incoming.adjacent |> Enum.reject(&(&1 == self.id))
    }

    [
      self: %Node{
        self
        | incoming: self.incoming |> Enum.reject(&(&1 == incoming.id)),
          adjacent: self.adjacent |> Enum.reject(&(&1 == incoming.id))
      },
      incoming: new_incoming
    ]
  end

  def remove_node(self: %Node{} = self, subgraph: subgraph) do
    new_sub = %Node{subgraph | parent: nil}

    [
      self: %Node{self | subgraphs: self.subgraphs |> Enum.reject(&(&1 == subgraph.id))},
      subgraph: new_sub
    ]
  end

  @doc """
  Defines if a node is empty.
  A node is empty, if it has no `outgoing`,`incoming` and `subgraphs`. So if non other `Node` is connected to it or connects to it.
  ## Examples
    iex> SimpleGraph.Node.empty?(SimpleGraph.Node.create_node("name"))
    true
    iex>SimpleGraph.Node.empty?(%SimpleGraph.Node{id: "testid",value: "test-value",adjacent: [%SimpleGraph.Node{id: "secondid",value: "second-test-value"}] })
    false
  """
  @spec empty?(Node.t()) :: true | false
  def empty?(%Node{adjacent: [], incoming: [], outgoing: [], subgraphs: []}),
    do: true

  def empty?(%Node{}) do
    false
  end
end
