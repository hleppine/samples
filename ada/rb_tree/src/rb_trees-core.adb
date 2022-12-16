

package body RB_Trees.Core is

   -- References:
   -- [Cormen] Cormen et al. Introduction to Algorithms, Third Edition, 2009.

   function Tree_Minimum
     (T : in Tree_T;
      X : in Node_Ref_T)
     return Node_Ref_T
      --
      -- Search for the leftmost node of the tree.
      -- [Cormen] p. 291: TREE-MINIMUM(x)
      --
   is
      Z : Node_Ref_T := X;
   begin
      while Z.Left /= T.Nil
      loop
         Z := Z.Left;
      end loop;
      return Z;
   end Tree_Minimum;


   function Tree_Maximum
     (T : in Tree_T;
      X : in Node_Ref_T)
     return Node_Ref_T
   --
   -- Search for the rightmost node of the tree.
   -- [Cormen] p. 291: TREE-MAXIMUM(x)
   --
   is
      Z : Node_Ref_T := X;
   begin
      while Z.Right /= T.Nil
      loop
         Z := Z.Right;
      end loop;
      return Z;
   end Tree_Maximum;


   function Tree_Predecessor
     (T : in Tree_T;
      Z : in Node_Ref_T)
     return Node_Ref_T
   --
   -- Search for the predecessor of a given node.
   -- [Cormen] p. 292; analogous to TREE-SUCCESSOR
   --
   is
      X : Node_Ref_T := Z;
      Y : Node_Ref_T;
   begin
      if X.Left /= T.Nil
      then
         return Tree_Maximum
             (T => T,
              X => X.Left);
      end if;
      Y := X.P;
      while Y /= T.Nil and then X = Y.Left
      loop
         X := Y;
         Y := Y.P;
      end loop;
      return Y;
   end Tree_Predecessor;


   function Tree_Successor
     (T : in Tree_T;
      Z : in Node_Ref_T)
     return Node_Ref_T
   --
   -- Search for the successor of a given node.
   -- [Cormen] p. 292: TREE-SUCCESSOR(x)
   --
   is
      X : Node_Ref_T := Z;
      Y : Node_Ref_T;
   begin
      if X.Right /= T.Nil
      then
         return Tree_Minimum
             (T => T,
              X => X.Right);
      end if;
      Y := X.P;
      while Y /= T.Nil and then X = Y.Right
      loop
         X := Y;
         Y := Y.P;
      end loop;
      return Y;
   end Tree_Successor;


   function Tree_Search
     (T : in Tree_T;
      K : in Key_T)
     return Node_Ref_T
      --
      -- Search for the given key in the tree.
      -- [Cormen] p. 291: ITERATIVE-TREE-SEARCH(x, k)
      --
   is
      X : Node_Ref_T := T.Root;
   begin
      while X /= T.Nil
      loop
         if K < X.Key
         then
            X := X.Left;
         elsif X.Key < K
         then
            X := X.Right;
         else
            exit;
         end if;
      end loop;
      return X;
   end Tree_Search;


   procedure Left_Rotate
     (T : in out Tree_T;
      X : in     Node_Ref_T)
      --
      -- [Cormen] p. 313: LEFT-ROTATE(T,x)
      --
   is
      Y : Node_Ref_T;
   begin
      Y            := X.Right;
      X.Right := Y.Left;
      if Y.Left /= T.Nil
      then
         Y.Left.P := X;
      end if;
      Y.P := X.P;
      if X.P = T.Nil
      then
         T.Root := Y;
      elsif X = X.P.Left
      then
         X.P.Left := Y;
      else
         X.P.Right := Y;
      end if;
      Y.Left := X;
      X.P    := Y;
   end Left_Rotate;


   procedure Right_Rotate
     (T : in out Tree_T;
      X : in     Node_Ref_T)
      --
      -- [Cormen] p. 313: RIGHT-ROTATE(T,x), symmetric to LEFT-ROTATE
      --
   is
      Y : Node_Ref_T;
   begin
      Y           := X.Left;
      X.Left := Y.Right;
      if Y.Right /= T.Nil
      then
         Y.Right.P := X;
      end if;
      Y.P := X.P;
      if X.P = T.Nil
      then
         T.Root := Y;
      elsif X = X.P.Right
      then
         X.P.Right := Y;
      else
         X.P.Left := Y;
      end if;
      Y.Right := X;
      X.P     := Y;
   end Right_Rotate;


   procedure RB_Insert_Fixup
     (T : in out Tree_T;
      X : in     Node_Ref_T)
      --
      -- [Cormen] p. 316: RB-INSERT-FIXUP(T,z)
      --
   is
      Y : Node_Ref_T;
      Z : Node_Ref_T := X;
   begin
      while Z.P.Color = Red
      loop
         if Z.P = Z.P.P.Left
         then
            Y := Z.P.P.Right;
            if Y.Color = Red
            then
               Z.P.Color        := Black;
               Y.Color               := Black;
               Z.P.P.Color := Red;
               Z                          := Z.P.P;
            else
               if Z = Z.P.Right
               then
                  Z := Z.P;
                  Left_Rotate
                    (T => T,
                     X => Z);
               end if;
               Z.P.Color        := Black;
               Z.P.P.Color := Red;
               Right_Rotate
                 (T => T,
                  X => Z.P.P);
            end if;
         else -- Same as "then" clause with "right" and "left" exchanged
            Y := Z.P.P.Left;
            if Y.Color = Red
            then
               Z.P.Color        := Black;
               Y.Color               := Black;
               Z.P.P.Color := Red;
               Z                          := Z.P.P;
            else
               if Z = Z.P.Left
               then
                  Z := Z.P;
                  Right_Rotate
                    (T => T,
                     X => Z);
               end if;
               Z.P.Color        := Black;
               Z.P.P.Color := Red;
               Left_Rotate
                 (T => T,
                  X => Z.P.P);
            end if;
         end if;
      end loop;
      T.Root.Color := Black;
   end RB_Insert_Fixup;


   procedure RB_Insert
     (T : in out Tree_T;
      Z : in     Node_Ref_T)
      --
      -- [Cormen] p. 315: RB-INSERT(T,z)
      --
   is
      X : Node_Ref_T;
      Y : Node_Ref_T;
   begin
      Y := T.Nil;
      X := T.Root;
      while X /= T.Nil
      loop
         Y := X;
         if Z.Key < X.Key
         then
            X := X.Left;
         else
            X := X.Right;
         end if;
      end loop;
      Z.P := Y;
      if Y = T.Nil
      then
         T.Root := Z;
      elsif Z.Key < Y.Key
      then
         Y.Left := Z;
      else
         Y.Right := Z;
      end if;
      Z.Left  := T.Nil;
      Z.Right := T.Nil;
      Z.Color := Red;
      RB_Insert_Fixup
        (T => T,
         X => Z);
   end RB_Insert;


   procedure RB_Transplant
     (T : in out Tree_T;
      U : in     Node_Ref_T;
      V : in     Node_Ref_T)
      --
      -- [Cormen] p. 323: RB-TRANSPLANT(T,u,v)
      --
   is
   begin
      if U.P = T.Nil
      then
         T.Root := V;
      elsif U = U.P.Left
      then
         U.P.Left := V;
      else
         U.P.Right := V;
      end if;
      V.P := U.P;
   end RB_Transplant;


   procedure RB_Delete_Fixup
     (T : in out Tree_T;
      Y : in     Node_Ref_T)
      --
      -- [Cormen] p. 326: RB-DELETE-FIXUP(T,x)
      --
   is
      X : Node_Ref_T := Y;
      W : Node_Ref_T;
   begin
      while X /= T.Root and X.Color = Black
      loop
         if X = X.P.Left
         then
            W := X.P.Right;
            if W.Color = Red
            then
               W.Color        := Black;
               X.P.Color := Red;
               Left_Rotate
                 (T => T,
                  X => X.P);
               W := X.P.Right;
            end if;
            if W.Left.Color = Black and W.Right.Color = Black
            then
               W.Color := Red;
               X            := X.P;
            else
               if W.Right.Color = Black
               then
                  W.Left.Color := Black;
                  W.Color           := Red;
                  Right_Rotate
                    (T => T,
                     X => W);
                  W := X.P.Right;
               end if;
               W.Color            := X.P.Color;
               X.P.Color     := Black;
               W.Right.Color := Black;
               Left_Rotate
                 (T => T,
                  X => X.P);
               X := T.Root;
            end if;
         else -- Same as "then" clause with "right" and "left" exchanged
            W := X.P.Left;
            if W.Color = Red
            then
               W.Color        := Black;
               X.P.Color := Red;
               Right_Rotate
                 (T => T,
                  X => X.P);
               W := X.P.Left;
            end if;
            if W.Right.Color = Black and W.Left.Color = Black
            then
               W.Color := Red;
               X            := X.P;
            else
               if W.Left.Color = Black
               then
                  W.Right.Color := Black;
                  W.Color            := Red;
                  Left_Rotate
                    (T => T,
                     X => W);
                  W := X.P.Left;
               end if;
               W.Color           := X.P.Color;
               X.P.Color    := Black;
               W.Left.Color := Black;
               Right_Rotate
                 (T => T,
                  X => X.P);
               X := T.Root;
            end if;
         end if;
      end loop;
      X.Color := Black;
   end RB_Delete_Fixup;


   procedure RB_Delete
     (T : in out Tree_T;
      Z : in     Node_Ref_T)
      --
      -- [Cormen] p. 324: RB-DELETE(T,z)
      --
   is
      X                : Node_Ref_T;
      Y                : Node_Ref_T;
      Y_Original_Color : Color_T;
   begin
      Y                := Z;
      Y_Original_Color := Y.Color;
      if Z.Left = T.Nil
      then
         X := Z.Right;
         RB_Transplant
           (T => T,
            U => Z,
            V => Z.Right);
      elsif Z.Right = T.Nil
      then
         X := Z.Left;
         RB_Transplant
           (T => T,
            U => Z,
            V => Z.Left);
      else
         Y := Tree_Minimum
             (T => T,
              X => Z.Right);
         Y_Original_Color := Y.Color;
         X                := Y.Right;
         if Y.P = Z
         then
            X.P := Y;
         else
            pragma Assert (Y.P /= null and Y.Right /= null);
            RB_Transplant
              (T => T,
               U => Y,
               V => Y.Right);
            Y.Right        := Z.Right;
            Y.Right.P := Y;
         end if;
         pragma Assert (Z.P /= null);
         RB_Transplant
           (T => T,
            U => Z,
            V => Y);
         Y.Left        := Z.Left;
         Y.Left.P := Y;
         Y.Color       := Z.Color;
      end if;
      if Y_Original_Color = Black
      then
         RB_Delete_Fixup
           (T => T,
            Y => X);
      end if;
   end RB_Delete;


end RB_Trees.Core;
