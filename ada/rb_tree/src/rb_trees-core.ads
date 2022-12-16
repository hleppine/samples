

private generic package RB_Trees.Core is


   function Tree_Minimum
     (T : in Tree_T;
      X : in Node_Ref_T)
     return Node_Ref_T;


   function Tree_Maximum
     (T : in Tree_T;
      X : in Node_Ref_T)
     return Node_Ref_T;


   function Tree_Predecessor
     (T : in Tree_T;
      Z : in Node_Ref_T)
     return Node_Ref_T;


   function Tree_Successor
     (T : in Tree_T;
      Z : in Node_Ref_T)
     return Node_Ref_T;


   function Tree_Search
     (T : in Tree_T;
      K : in Key_T)
     return Node_Ref_T;


   procedure RB_Insert
     (T : in out Tree_T;
      Z : in     Node_Ref_T);


   procedure RB_Delete
     (T : in out Tree_T;
      Z : in     Node_Ref_T);


end RB_Trees.Core;
