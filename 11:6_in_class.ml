(* Hindly-Milner system:
<term> ::= ( <term> ) | $id | <term> <term> | & $id . <term> |
         | let $id = <term> in <term>

G = gamma, L = lambda, V = for all(?), a = alpha, s = polytype

(x, T) in G
------------(var)
G|- x : T

{(x, T1)} U G |- e : T2
-----------------------(Abs)
G|- L x .e : T1->T2

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

let id = L x.x in (id 2, id ())
id: V t0. t0 -> t0
id 2 : t1     id (): t2
[Vt0.t0->t0 ~~ t3->t1,
Vt0 t0 ->t0 ~~ t4->t2,
t3 ~~ int, t4 ~~ unit]

&x. x
work by var rule
 "when we typecheck &x. x, we generate a new type variable (t0) and we add
 the type binding (x, t0) to the context. Then when we go to typecheck the body
 of the lambda (x) we find that x has type t0 so we can conclude that &x. x has
 type t0 -> t0 for some type t0."

&x. x + 1
x must be int
&x is type int -> int
should work by abs rule

&x. 1 + (not x)
x must be a bool
cannot add bool + int
should fail

&f. &x. &y. f y x

let flip = &f. &x. &y. f y x in flip (&x. &y. x && (not y))

let twice = &f. &x. f (f x) in twice (&x. x + 1) 0

let twice = &f. &x. f (f x) in
let x = twice (&x. x + 1) 0 in
twice (&x. not x) false

(&f. let x = f (&x. x + 1) 0 in f (&x. not x) false) (&f. &x. f (f x))
*)
