

with Interfaces;

use Interfaces;


generic

   type Key_T is private;
   -- Key type for the tree.

   type Value_T is private;
   -- Value type for the tree.

   with function "<"
     (Left  : in Key_T;
      -- Left side of the comparison.
      Right : in Key_T
      -- Right side of the comparison.
     )
      return Boolean is <>;
   -- Returns True if Left < Right.
   -- Uses default for Key_T if available.

   -- Generic package for red-black trees. Red-black trees are self-balancing
   -- binary search trees.
   --
   -- Red-black trees support insertions, deletions, and searches in
   -- O(log n) time. In-order predecessors and successors of nodes can also
   -- be found in O(log n) time.
   --
package RB_Trees is


   subtype Count_T is Unsigned_32;
   -- A count of nodes.


   subtype Index_T is Count_T range 1 .. Count_T'Last;
   -- An index of a node, or a non-zero count of nodes.


   type Pool_T
     (Nb_Nodes : Index_T)
   is limited private;


   type Pool_Ref_T is access all Pool_T;


   type Tree_T is private;
   -- A red-black tree.


   type Tree_Ref_T is access all Tree_T;
   -- Reference to a red-black tree.


   type Node_Ref_T is private;
   -- Reference to a tree node.


   --
   -- Pool operations
   --

   procedure Initialize_Pool
     (Pool : in out Pool_T);



   --
   -- Node operations
   --

   procedure Allocate_Node
     (Pool : in     not null Pool_Ref_T;
      Node :    out Node_Ref_T);


   function Is_Null
     (Node : in Node_Ref_T
      -- The node to be accessed.
     )
      return Boolean;
   -- Returns True if the given Node is null.


   function Is_Orphan
     (Node : in Node_Ref_T
      -- The node to be accessed.
     )
      return Boolean
     with Pre => not Is_Null (Node);
   -- Returns True if the given Node is orphan, i.e. not in a tree.


   procedure Free_Node
     (Node : in out Node_Ref_T)
     with Pre => not Is_Null (Node) and Is_Orphan (Node);


   procedure Make_Null
     (Node : in out Node_Ref_T
      -- The node reference to be made null.
     );
   -- Makes the given node reference null.


   function Get_Key
     (Node : in Node_Ref_T
      -- The selected node.
     )
      return Key_T with
     Pre => not Is_Null (Node);
   -- Returns the key of the given Node.


   function Get_Value
     (Node : in Node_Ref_T
      -- The selected node.
     )
      return Value_T with
     Pre => not Is_Null (Node);
   -- Returns the value of the given Node.


   procedure Set_Value
     (Node  : in Node_Ref_T;
      -- The node to access.
      Value : in Value_T
      -- The value to set.
     ) with
       Pre  => not Is_Null (Node);
   -- Set the specified value to the given node.


   --
   -- Tree operations
   --


   procedure Initialize
     (Tree : in not null Tree_Ref_T);


   function Minimum
     (Tree : in Tree_T
      -- The tree to be accessed.
     )
      return Node_Ref_T;
   -- Return the leftmost node of the tree.


   function Maximum
     (Tree : in Tree_T
      -- The tree to be accessed.
     )
      return Node_Ref_T;
   -- Return the rightmost node of the tree.


   function Predecessor
     (Node : in Node_Ref_T
      -- The specified node.
     )
      return Node_Ref_T with
     Pre => not Is_Null (Node);
   -- Return the predecessor of the specified node.


   function Successor
     (Node : in Node_Ref_T
      -- The specified node.
     )
      return Node_Ref_T with
     Pre => not Is_Null (Node);
   -- Return the successor of the specified node.


   procedure Search
     (Tree   : in Tree_T;
      -- The tree to be accessed.
      Key    : in Key_T;
      -- The key to be searched.
      Found  : out Boolean;
      -- True if an exact match was found.
      Node   : out Node_Ref_T
      -- Exactly matching node if Found = True; otherwise, the closest match.
     );
   -- Search for the given key in the indicated tree.


   procedure Insert
     (Tree    : in not null Tree_Ref_T;
      -- The tree to be accessed.
      Key     : in Key_T;
      -- The key to be used for the node.
      Node    : in Node_Ref_T
      -- The node to insert.
     )
   with Pre => not Is_Null(Node) and Is_Orphan(Node);
   -- Insert the given node to the specified tree.


   procedure Remove
     (Node : in Node_Ref_T)
   with Pre => not Is_Null(Node) and not Is_Orphan(Node);
   -- Remove a node from the tree.


private

   type Color_T is
     (Red,
      -- Red node.

      Black
      -- Black node.
     );
   -- Color of a node.

   type Node_T is record

      Pool : Pool_Ref_T;
      -- Pool of the node.

      Index : Count_T;
      -- Index of the node.

      Tree : Tree_Ref_T;
      -- Tree of the node.

      P    : Node_Ref_T;
      -- Parent node.

      Left : Node_Ref_T;
      -- Left child node.

      Right : Node_Ref_T;
      -- Right child node.

      Color : Color_T;
      -- Color of the node.

      Key  : Key_T;
      -- Key of the node.

      Value : Value_T;
      -- Value of the node.

   end record;
   -- A node in the tree.


   type Node_Ref_T is access all Node_T;


   type Node_Array_T is array (Index_T range <>) of aliased Node_T;


   type Tree_T is record

      Nil_Node : aliased Node_T;
      -- A special sentinel node for the tree.

      Nil      : Node_Ref_T;
      -- Reference to the special sentinel node.

      Root     : Node_Ref_T;
      -- Reference to the root node of the tree.

   end record;
   -- A red-black tree.


   type Pool_T
     (Nb_Nodes : Index_T)
   is record

      Foo : Natural;

   end record;


end RB_Trees;
