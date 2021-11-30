defmodule SimpleGraph.NodeTest do
  use ExUnit.Case
  doctest SimpleGraph.Node

  alias SimpleGraph.Node
  import SimpleGraph.Helpers.NodeHelper

  describe "Test add outgoing" do
    test "Create empty graph" do
      self_node = node_with_id("testnode")
      root_node = node_with_id("selfnode")
      self_id = self_node.id
      root_id = root_node.id

      assert [self: incoming_node, outgoing: outgoing_node] =
               Node.add_node(self: root_node, outgoing: self_node)

      assert %Node{
               value: "selfnode",
               id: root_id,
               adjacent: [outgoing_node.id],
               outgoing: [outgoing_node.id]
             } == incoming_node

      assert %Node{
               value: "testnode",
               id: self_id,
               adjacent: [incoming_node.id],
               incoming: [incoming_node.id]
             } == outgoing_node
    end

    test "Add node to graph" do
      test_uuid = UUID.uuid4()
      self_node = node_with_params(%{adjacent: [UUID.uuid4()], value: "selfnode"})
      next_node = node_with_params(%{adjacent: [], value: "nextvalue"})

      assert [self: new_self, outgoing: new_node] =
               Node.add_node(self: self_node, outgoing: next_node)
    end
  end

  describe "Test add incoming" do
    test "Create empty graph" do
      self_node = node_with_id("testnode")
      root_node = node_with_id("selfnode")

      assert [
               self: %Node{
                 value: "selfnode",
                 adjacent: [self_node.id],
                 incoming: [self_node.id],
                 outgoing: [],
                 id: root_node.id
               },
               incoming: %Node{
                 id: self_node.id,
                 value: "testnode",
                 adjacent: [root_node.id],
                 outgoing: [root_node.id]
               }
             ] ==
               Node.add_node(self: root_node, incoming: self_node)
    end

    test "Add node to graph" do
      self_node =
        node_with_params(%{
          adjacent: [node_with_params(%{adjacent: [], value: "firstvalue"})],
          value: "selfnode"
        })

      next_node = node_with_params(%{adjacent: [], value: "nextvalue"})

      assert [self: new_self, incoming: new_incoming] =
               Node.add_node(self: self_node, incoming: next_node)

      assert [
               %Node{
                 adjacent: [],
                 value: "firstvalue",
                 outgoing: [],
                 incoming: [],
                 id: self_node.id
               },
               new_self
             ],
             new_incoming.adjacent

      assert [], new_incoming.incoming
      assert [new_self], new_incoming.outgoing
    end
  end
end
