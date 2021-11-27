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


      assert [self: incoming_node,outgoing: outgoing_node]=
        Node.add_node(self: root_node, outgoing: self_node)

      assert %Node{value: "selfnode",id: root_id, adjacent: [outgoing_node.id],outgoing: [outgoing_node.id]}  ==incoming_node
      assert %Node{value: "testnode",id: self_id,adjacent: [incoming_node.id],incoming: [incoming_node.id]} == outgoing_node
    end

    test "Add node to graph" do
      test_uuid = UUID.uuid4()
      self_node = node_with_params(%{adjacent: [UUID.uuid4()], value: "selfnode"})
      next_node = node_with_params(%{adjacent: [], value: "nextvalue"})
      assert [self: new_self,outgoing: new_node] = Node.add_node(self: self_node, outgoing: next_node)

      assert %Node{id: self_node.id,value: "selfnode", adjacent}

    end
  end

  describe "Test add incoming" do
   test "Create empty graph" do
      self_node = node_with_id( "testnode")
      root_node = node_with_id("selfnode")

      assert %Node{value: "selfnode", adjacent: [root_node], incoming: [root_node], outgoing:  []} =
               Node.add_node(self: root_node, incoming:  self_node)
    end

    test "Add node to graph" do
      self_node = node_with_params(%{adjacent: [node_with_params(%{adjacent: [], value: "firstvalue"})], value: "selfnode"})
      next_node = node_with_params(%{adjacent: [], value: "nextvalue"})
      assert new_node = Node.add_node(self: self_node, incoming: next_node)

      assert [
               %Node{adjacent: [], value: "firstvalue", outgoing: [], incoming: [],id: self_node.id},
               next_node
             ],
             new_node.adjacent

      assert [next_node], new_node.incoming
    end

  end

end
