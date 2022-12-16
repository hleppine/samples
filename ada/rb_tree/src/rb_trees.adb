

with RB_Trees.Core;


package body RB_Trees is

   package Tree_Core is new RB_Trees.Core;
   -- Core algorithms for a red-black tree.


   --
   -- Pool operations
   --

   procedure Initialize_Pool
     (Pool : in out Pool_T)
   is
   begin
   
      -- TODO

      pragma Unreferenced(Pool);

   end Initialize_Pool;


   --
   -- Node operations
   --

   procedure Allocate_Node
     (Pool : in     not null Pool_Ref_T;
      Node :    out Node_Ref_T)
   is
   begin

      -- TODO

      pragma Unreferenced(Pool);

      Node := null;

   end Allocate_Node;


   function Is_Null
     (Node : in Node_Ref_T)
     return Boolean
   is
   begin

      return Node = null or else Node = Node.Tree.Nil;
      -- Check if the reference is null,
      -- or it points to the Nil node of its tree.

   end Is_Null;


   function Is_Orphan
     (Node : in Node_Ref_T)
     return Boolean
   is
   begin

      return Node.Tree = null;
      -- Check if the tree of the reference is null.

   end Is_Orphan;


   procedure Free_Node
     (Node : in out Node_Ref_T)
   is
   begin

      pragma Unreferenced(Node);

   end Free_Node;





   procedure Make_Null
     (Node : in out Node_Ref_T)
   is
   begin

      Node := null;

   end Make_Null;


   function Get_Key
     (Node : in Node_Ref_T)
     return Key_T
   is
   begin

      return Node.Key;

   end Get_Key;


   function Get_Value
     (Node : in Node_Ref_T)
     return Value_T
   is
   begin

      return Node.Value;

   end Get_Value;


   function Predecessor
     (Node : in Node_Ref_T)
     return Node_Ref_T
   is
   begin

      return Tree_Core.Tree_Predecessor
          (T => Node.Tree.all,
           Z => Node);

   end Predecessor;


   function Successor
     (Node : in Node_Ref_T)
     return Node_Ref_T
   is
   begin

      return Tree_Core.Tree_Successor
          (T => Node.Tree.all,
           Z => Node);

   end Successor;


   procedure Set_Value
     (Node  : in Node_Ref_T;
      Value : in Value_T)
   is
   begin

      Node.Value := Value;

   end Set_Value;


-- Tree operations


   procedure Initialize
     (Tree : in not null Tree_Ref_T)
   is
   begin

      Tree.Nil := Tree.Nil_Node'Access;

      Tree.Nil.Tree := Tree;

      Tree.Nil.Color := Black;

      Tree.Root := Tree.Nil;

   end Initialize;


   function Minimum
     (Tree : in Tree_T)
     return Node_Ref_T
   is
   begin

      return Tree_Core.Tree_Minimum
          (T => Tree,
           X => Tree.Root);

   end Minimum;


   function Maximum
     (Tree : in Tree_T)
     return Node_Ref_T
   is
   begin

      return Tree_Core.Tree_Maximum
          (T => Tree,
           X => Tree.Root);

   end Maximum;


   procedure Search
     (Tree   : in Tree_T;
      Key    : in Key_T;
      Found  : out Boolean;
      Node   : out Node_Ref_T
     )
   is
   begin

      Node := Tree_Core.Tree_Search
        (T => Tree,
         K => Key);

      Found := Node.Key = Key;

   end Search;


   procedure Insert
     (Tree    : in not null Tree_Ref_T;
      Key     : in Key_T;
      Node    : in Node_Ref_T)
   is
   begin

      pragma Assume(Node.Tree = null);
      -- A node cannot be in two trees.

      Node.Key := Key;

      Node.Tree := Tree;

      Tree_Core.RB_Insert
           (T => Tree.all,
            Z => Node);

   end Insert;


   procedure Remove
     (Node : in Node_Ref_T)
   is
   begin

      pragma Assume(Node.Tree /= null);
      -- The node must be in a tree.

      Tree_Core.RB_Delete
        (T => Node.Tree.all,
         Z => Node);

      Node.Tree := null;

   end Remove;


end RB_Trees;
