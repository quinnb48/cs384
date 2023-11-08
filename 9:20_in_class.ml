(*
dup:
-----------------------
<S |> x> -> S|> x, x>

over:
-----------------------------
<S |> x, y> -> <S |> y, x, y>

drop:
-----------------------
<S |> y, x> -> S|> y>

swap:
--------------------------
<S |> x, y> -> <S |> y, x>

rot:
--------------------------------
<S |> z, y, x> -> <S |> y, x, z> *)

(* Define semantics for the remaining Forth commands: drop, over, swap, and rot.

A Forth program might be represented in OCaml as a list of commands, where commands are defined by:

type command = Int of int | Plus | Minus | Times | Divide
             | Dup | Drop | Over | Rot | Swap
Write an interpreter for our subset of Forth in OCaml. (Hint: An OCaml list is already a stack--:: pushes a new element on to the stack and pattern matching on h :: t gives you the top of the stack as h and the stack with h popped off as t). Here is a high-level structure you can use (feel free to change this if you don't like it):

let interpret (program : command list) : int list =
  let rec process_command (stack : int list) (c : command) : int list =
    (* Your code here... *)
  in
  List.fold_left process_command [] program
The idea here is that process_command handles the stack changes for a single command while fold_left handles the composition of commands.

Write some fun Forth programs and use your interpreter to run them. *)

type command = Int of int | Plus | Minus | Times | Divide
             | Dup | Drop | Over | Rot | Swap

let interpret (program: command list) : int list =
        let rec process_command (stack : int list) (c : command) : int list =
        match program with
            |[] -> stack
            |h :: t -> match c with
                    | Int i -> i :: stack
                    | Plus -> (match stack with hd::(b::tl) -> (hd + b):: tl )
                    | Minus -> (match stack with hd::(b::tl) -> (hd - b):: tl )
                    | Times -> (match stack with hd::(b::tl) -> (hd * b):: tl )
                    | Divide -> (match stack with hd::(b::tl) -> (hd / b):: tl )
                    | Dup -> (match stack with hd::tl -> hd :: hd :: tl )
                    | Drop -> (match stack with hd::tl -> tl )
                    | Over -> (match stack with hd::(b::tl) -> b::hd::b::tl))
                    | Rot -> (match stack with hd::(b::(c::tl)) -> c::hd::b::tl))
                    | Swap -> (match stack with hd::(b::tl) -> b :: hd :: tl )

    in List.fold_left process_command [] program
