(*
<term> ::= ( <term> ) | $id | <term> <term> | & $id . <term> |
         | let $id = <term> in <term>

G = gamma, & = lambda, V = for all, a = alpha, s = polytype

(x, T) in G
------------(var)
G|- x : T

{(x, T1)} U G |- e : T2
-----------------------(Abs)
G|- &x .e : T1->T2

G|- e : Va . s
---------------(Inst)
G |- e    : s[T1/a]

G |- e1 : T1->T2    G|- e2:T1
-----------------------------(App)
G |- e1 e2 : T2

G |-e1: s   {(x,s)}U G|- e2:T
----------------------------- (let)
G |- let x = e1 in e2 : T

G|- e: s     a not free in G
----------------------------(gen)
G|-       e: Va.s


using 'a or 'b to represent some type i don't have enough context to figure
out yet

let id x = x ;;
type: input x = 'a, returns 'a -> 'a

let int_id1 (x : int) = x
type: returns int -> int

let int_id2 x : int = x ;;
type: output x = int, input x = int, returns  int -> int

let flip f x y = f y x ;;
type: type x = 'a, type y = 'a, type f = 'a -> 'a -> 'b, returns
'a -> 'a -> 'b -> 'a -> 'a ->  'a -> 'a -> 'b

let flip_specific f (x : int) y = f y x ;;
type: x = int, y = int, f = int -> int -> 'a, returns
int -> int -> 'a -> int -> int ->  int -> int -> 'a

let rec fact n = if n = 0 then 1 else fact (n - 1) ;;
type: type n = int, returns int -> int (or  int ->  func int -> int ?)

let value = (fun f => (f 4, f "string")) (fun x => x) ;;

type my_type =
  | A
  | B of int
  | C of bool * string ;;

let int_of_my_type v = match v with
  | A => 0
  | B i => i
  | C (b, s) => if b then int_of_string s else ~ (int_of_string s) ;;

let mystery a b = match a with
  | A => b ()
  | B i => string_of_int i
  | C (v, s) => s ^ (b ())
*)
