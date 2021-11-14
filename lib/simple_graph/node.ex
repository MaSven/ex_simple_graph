defmodule SimpleGraph.Node do
  alias SimpleGraph.Node

  @type t :: %__MODULE__{
          adjacent: [Node.t()],
          subgraphs: [Node.t()],
          value: any(),
          outgoing: [Node.t()],
          incoming: [Node.t()],
          id: binary(),
          parent: Node.t() | nil
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
      | adjacent: [self | outgoing.adjacent],
        incoming: [self | outgoing.incoming]
    }

    [
      self: %Node{
        self
        | adjacent: [new_outgoing | self.adjacent],
          outgoing: [new_outgoing | self.adjacent]
      },
      outgoing: new_outgoing
    ]
  end

  def add_node(self: %Node{} = self, incoming: %Node{} = incoming) do
    new_incoming = %Node{
      incoming
      | outgoing: [self | incoming.outgoing],
        adjacent: [self | incoming.adjacent]
    }

    [
      self: %Node{
        self
        | adjacent: [incoming | self.adjacent],
          incoming: [incoming | self.incoming]
      },
      incoming: new_incoming
    ]
  end

  def add_node(self: %Node{} = self, subgraph: %Node{} = sub) do
    new_sub = %Node{sub | parent: self}
    [self: %Node{self | subgraphs: [sub | self.subgraphs]}, subgraph: new_sub]
  end

  @spec remove_node(self: Node.t(), outgoing: Node.t(), incoming: Node.t(), subgraph: Nodet.t()) ::
          [self: Node.t(), outgoing: Node.t()]
          | [self: Node.t(), incoming: Node.t()]
          | [self: Node.t(), subgraph: Node.t()]
  def remove_node(self: %Node{} = self, outgoing: %Node{} = outgoing) do
    new_outgoing = %Node{
      outgoing
      | incoming: outgoing.incoming |> Enum.reject(fn x -> x.id == self.id end),
        adjacent: outgoing.adjacent |> Enum.reject(fn x -> x.id == self.id end)
    }

    [
      self: %Node{
        self
        | outgoing: self.outgoing |> Enum.filter(&(&1.id == outgoing.id)),
          adjacent: self.adjacent |> Enum.filter(&(&1.id == outgoing.id))
      },
      outgoing: new_outgoing
    ]
  end

  def remove_node(self: %Node{} = self, incoming: %Node{} = incoming) do
    new_incoming = %Node{
      incoming
      | outgoing: incoming.outgoing |> Enum.reject(&(&1.id == self.id)),
        adjacent: incoming.adjacent |> Enum.reject(&(&1.id == self.id))
    }

    [
      self: %Node{
        self
        | incoming: self.incoming |> Enum.reject(&(&1.id == incoming.id)),
          adjacent: self.adjacent |> Enum.reject(&(&1.id == incoming.id))
      },
      incoming: new_incoming
    ]
  end

  def remove_node(self: %Node{} = self, subgraph: subgraph) do
    new_sub = %Node{subgraph | parent: nil}

    [
      self: %Node{self | subgraphs: self.subgraphs |> Enum.reject(&(&1.id == subgraph.id))},
      subgraph: new_sub
    ]
  end
end
