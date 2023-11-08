(*
(* OCaml-lite has the same comment syntax as OCaml. *)
(* OCaml-lite has no built-in lists, so we need to define them. We also have
   no way to define type constructors in OCaml-lite, so we need to define a list
   type with respect to a specific element type. *)
type int_list =
  | Nil   (* The | before the first constructor is required. *)
  | Cons of int * int_list ;;

(* Note that each declaration is separated by ;; *)

(* We can define inner functions just like we do in OCaml, and we can give
   explicit types to arguments and return values from functions just like in
   OCaml. *)
let rec remove_duplicates lst =
  let rec remove_all (x : int) (l : int_list) : int_list =
    match l with
    | Nil => Nil   (* Note that match expressions use => rather than -> *)
    | Cons (h, t) => if x = h then remove_all x t else Cons (h, remove_all x t)
  in
  match lst with
  | Nil => Nil
  | Cons (h, t) => Cons (h, remove_duplicates (remove_all h t)) ;;

(* Note that the | before the first branch of the match is required in
   OCaml-lite, while it is opitonal in OCaml. *)

(* In the function string_of_int_list, we use a built-in function string_of_int.
   OCaml-lite has three built-in functions: string_of_int, int_of_string, and
   print_string. *)
let rec string_of_int_list lst =
  match lst with
  | Nil => ""
  | Cons (h, t) => string_of_int h ^ ", " ^ string_of_int_list t ;;

let _ = print_string (string_of_int_list (remove_duplicates
  (Cons (1, Cons (1, Cons (2, Cons (1, Cons (3, Cons (4, Cons (2, Cons (4,
   Cons (5, Cons (1, Cons (2, Nil)))))))))))))) ;;

(* Since we don't have polymorphic lists, we need a new type for lists of
   strings. *)
type string_list =
  | SNil
  | SCons of string * string_list ;;

let rec map f lst =
  match lst with
  | SNil => SNil
  | SCons (h, t) => SCons (f h, map f t) ;;

let rec concat l1 l2 =
  match l1 with
  | SNil => l2
  | SCons (h, t) => SCons (h, concat t l2) ;;

let rec binaries (n : int) : string_list =
  if n = 0
  then SCons ("", SNil)
  else
    let bs = binaries (n - 1) in
    concat (map (fun x => "0" ^ x) bs)   (* fun uses => just like match. *)
           (map (fun (x : string) : string => "1" ^ x) bs) ;;

let rec string_of_string_list (lst : string_list) : string =
  match lst with
  | SNil => ""
  | SCons (h, t) => h ^ ", " ^ string_of_string_list t ;;

let _ = print_string (string_of_string_list (binaries 3)) ;;
*)

type int_list =
  | Nil
  | Cons of int * int_list ;;

(*

let rec sum (i:int_list) =
match i with
|Nil => Nil
|Cons(h,t) => h+ sum t

let rec suffix_sum (i:int_list) =
    match i with
    |Nil => Nil
    | Cons(h,t) => Cons(sum i, suffix_sum t)


 *)

let rec suffix_sum (i: int_list) : int_list =
    match i with
    | Nil => Nil
    | Cons (h, t) => let a = suffix_sum t in Cons (h + a, a);;

(* let rec reverse_list (i: int_list) : int_list =
    match i with
    | Nil => Nil
    | h :: t => Cons (reverse_list t, h);; *)

let prop =
|And prop * prop
|Or prop * prop
|Not prop
|Sym string

let rec pprint p =
match p with
|And (p1, p2) => 
