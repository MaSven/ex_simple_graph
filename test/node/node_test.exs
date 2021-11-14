defmodule SimpleGraphTest.NodeTest do
  use ExUnit.Case
  doctest SimpleGraph.Node

  alias SimpleGraph.Node

  describe "Test add outgoing" do
    test "Create empty graph" do
      self_node = %Node{value: "testnode"}
      root_node = %Node{value: "selfnode"}

      assert %Node{value: "selfnode", adjacent: [root_node], outgoing: [root_node], incoming: []} =
               Node.add_outgoing(self: root_node, outgoing: self_node)
    end

    test "Add node to graph" do
      self_node = %Node{adjacent: [%Node{adjacent: [], value: "firstvalue"}], value: "selfnode"}
      next_node = %Node{adjacent: [], value: "nextvalue"}
      assert new_node = Node.add_outgoing(self: self_node, outgoing: next_node)

      assert [
               %Node{adjacent: [], value: "firstvalue", outgoing: [], incoming: []},
               next_node
             ],
             new_node.adjacent

      assert [next_node], new_node.outgoing
    end
  end

  describe "Test add incoming" do
   test "Create empty graph" do
      self_node = %Node{value: "testnode"}
      root_node = %Node{value: "selfnode"}

      assert %Node{value: "selfnode", adjacent: [root_node], incoming: [root_node], outgoing:  []} =
               Node.add_incoming(self: root_node, incoming:  self_node)
    end

    test "Add node to graph" do
      self_node = %Node{adjacent: [%Node{adjacent: [], value: "firstvalue"}], value: "selfnode"}
      next_node = %Node{adjacent: [], value: "nextvalue"}
      assert new_node = Node.add_incoming(self: self_node, incoming: next_node)

      assert [
               %Node{adjacent: [], value: "firstvalue", outgoing: [], incoming: []},
               next_node
             ],
             new_node.adjacent

      assert [next_node], new_node.incoming
    end

  end
end
