defmodule SimpleGraph.Node do

  alias SimpleGraph.Node
  @type t :: %__MODULE__{adjacent: [Node.t()], value: any()}

  @enforce_keys [:adjacent,:value]
  defstruct adjacent: [] , value: ""

  @spec add_outgoing(self: Node.t(),outgoing: Node.t()) :: Node.t()
  def add_outgoing(self: %Node{}=self,outgoing: %Node{}=outgoing) do
    %Node{self | adjacent: self.adjacent++outgoing}
  end

  def add_incoming(self: %Node{}=self,incoming: %Node{}=incoming) do

  end

end
