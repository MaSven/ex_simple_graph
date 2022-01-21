defmodule SimpleGraph.NodeTest do
  use ExUnit.Case, async: true
  doctest SimpleGraph.Node

  alias SimpleGraph.Node
  import SimpleGraph.Helpers.NodeHelper

  describe "Test add node" do
    test "with empty graph" do
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

    test "one node to another outgoing" do
      existing_uuid = UUID.uuid4()
      self_node = node_with_params(%{adjacent: [existing_uuid], value: "selfnode"})
      next_node = node_with_params(%{adjacent: [], value: "nextvalue"})

      assert [self: root, outgoing: outgoing] =
               Node.add_node(self: self_node, outgoing: next_node)

      assert [next_node.id, existing_uuid] == root.adjacent
      assert [next_node.id] == root.outgoing
      assert [self_node.id] == outgoing.adjacent
      assert [self_node.id] == outgoing.incoming
    end

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

    test "one node to another incoming" do
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

    test "as subgraph" do
      first_node = node_with_id("parent-node")
      second_node = node_with_id("child-node")
      assert [self: first_node_edit,subgraph: second_node_edit] = Node.add_node(self: first_node,subgraph: second_node)
      assert first_node.id == second_node_edit.parent
      assert Enum.all?(first_node_edit.subgraphs,fn value -> value == second_node.id end)
      assert length(first_node_edit.subgraphs) == 1

    end

    test "multi subgraphs" do
      first_node = node_with_id("parent-node")
      second_node = node_with_id("second-node")
      third_node = node_with_id("third-node")
      assert [self: first_node_edit,subgraph: second_node_edit] = Node.add_node(self: first_node,subgraph: second_node)
      assert [self: first_node_edit,subgraph: third_node_edit] = Node.add_node(self: first_node_edit,subgraph: third_node)
      assert length(first_node_edit.subgraphs) == 2
      assert second_node_edit.parent == first_node.id
      assert third_node_edit.parent == first_node.id
      assert first_node_edit.subgraphs |> Enum.all?(&(&1 == second_node.id || &1 == third_node.id))
    end

  end

  describe "Remvoe nodes" do
    test "node not adjacent" do
      first_node = node_with_id("node_without_adjacents")
      second_node = node_with_id("second_node_without_adjacents")

      assert [self: %Node{} = first_node_edit, outgoing: %Node{} = second_node_edit] =
               Node.remove_node(self: first_node, outgoing: second_node)

      assert Node.empty?(first_node_edit)
      assert "node_without_adjacents" == first_node_edit.value
      assert Node.empty?(second_node_edit)

    end

    test "node which is outgoing" do
      first_node = node_with_id("first_value")
      second_node = node_with_id("second_value")

      [self: first_node_edit, outgoing: second_node_edit] =
        Node.add_node(self: first_node, outgoing: second_node)

      assert [self: first_node_removed, outgoing: second_node_removed] =
               Node.remove_node(self: first_node_edit, outgoing: second_node_edit)

      assert Node.empty?(first_node_removed)
      assert Node.empty?(second_node_removed)
    end

    test "multiple nodes which are outgoing" do
      first_node = node_with_id("first-value")
      second_node = node_with_id("second-value")
      third_node = node_with_id("third-value")

      [self: first_node_edit, outgoing: second_node_edit] =
        Node.add_node(self: first_node, outgoing: second_node)

      [self: first_node_edit, outgoing: third_node_edit] =
        Node.add_node(self: first_node_edit, outgoing: third_node)

      [self: first_node_removed, outgoing: second_node_removed] =
        Node.remove_node(self: first_node_edit, outgoing: second_node_edit)

      assert Node.empty?(second_node_removed)
      assert !Node.empty?(first_node_removed)
      assert Enum.all?(first_node_removed.outgoing, fn value -> value == third_node.id end)

      [self: first_node_removed, outgoing: third_node_removed] =
        Node.remove_node(self: first_node_removed, outgoing: third_node_edit)

      assert Node.empty?(first_node_removed)
      assert Node.empty?(third_node_removed)
    end

    test "node which is incoming" do
      first_node = node_with_id("first_value")
      second_node = node_with_id("second_value")

      [self: first_node_edit, incoming: second_node_edit] =
        Node.add_node(self: first_node, incoming: second_node)

      assert [self: first_node_removed, incoming: second_node_removed] =
               Node.remove_node(self: first_node_edit, incoming: second_node_edit)

      assert Node.empty?(first_node_removed)
      assert Node.empty?(second_node_removed)
    end

    test "multiple nodes which are incoming" do
      first_node = node_with_id("first-value")
      second_node = node_with_id("second-value")
      third_node = node_with_id("third-value")

      [self: first_node_edit, incoming: second_node_edit] =
        Node.add_node(self: first_node, incoming: second_node)

      [self: first_node_edit, incoming: third_node_edit] =
        Node.add_node(self: first_node_edit, incoming: third_node)

      [self: first_node_removed, incoming: second_node_removed] =
        Node.remove_node(self: first_node_edit, incoming: second_node_edit)

      assert Node.empty?(second_node_removed)
      assert !Node.empty?(first_node_removed)
      assert Enum.all?(first_node_removed.incoming, fn value -> value == third_node.id end)

      [self: first_node_removed, incoming: third_node_removed] =
        Node.remove_node(self: first_node_removed, incoming: third_node_edit)

      assert Node.empty?(first_node_removed)
      assert Node.empty?(third_node_removed)
    end
  end
end
