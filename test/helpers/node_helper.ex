defmodule SimpleGraph.Helpers.NodeHelper do
  @moduledoc false
  alias SimpleGraph.Node

  def node_with_id(value) do
    %Node{value: value, id: UUID.uuid4()}
  end

  def node_with_params(params) when is_map(params) do
    params = Map.put_new_lazy(params, :id, &UUID.uuid4/0)
    struct(Node, params)
  end
end
