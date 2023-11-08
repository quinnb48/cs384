(*
rules:
(x,t) in L                          rule 1
----------
|> |- x : t

---------------                     rule 2
|> |- () : unit

|>U{(x,t1)} |-e : t2
---------------------------         rule 3
|> |- (Lx: t1 .e): t1 -> t2

|>|- e1:t1 -> t2    |>|- e2:t1      rule 4
------------------------------      e1 is function with type e1 -> t2, e2 has type e1
|> |- e1 e2 : t2                    then e1 (e2) has type t2

|>|- e2:t
------------------------------      rule 5
|>|- (Lx:t.e1)e2 -> e1[e2/t]

|> |- e : forall 'a . t2
------------------------            rule 6
|> |- e t1 : t2 [t1 / 'a]

 |> U {('a is a type)} |- e : t
------------------------------      rule 7
|> |- /\ 'a . e : forall 'a . t

Are the following System F terms well-typed, and if so what are their types?
(Note: you do not have to go through and build proof trees for these terms,
though it may be helpful if you're having trouble figuring out the type.)

& (x : 'a). x : x
--------------------
/\ 'a . & (x : 'a) . x : 'a -> 'a

s z
---------------------
&(z : 'a) . s (s z) : s 'a
----------------------------------------
& (s : 'a -> 'a) . &(z : 'a) . s (s z) : 'a -> 'a
-----------------------------------------
/\ 'a. & (s : 'a -> 'a) . &(z : 'a) . s (s z) : forall 'a . 'a -> 'a

/\ 'a . /\ 'b . /\ 'c . & f : 'a -> 'b -> 'c . & x : 'b . & y : 'a . f y x

(/\ 'a . &x : 'a . x) (/\ 'b . &y : 'b . y) (/\ 'c . &z : 'c . z)


Are the following System Fw types well-formed, and if so what are their kinds?

forall 'a :: * . 'a -> 'a

forall 'a :: * . 'a -> forall 'b :: * 'b

(& 'a :: * . 'a -> 'a) (& 'b :: * . 'b -> 'b)


Are the following System Fw terms well-typed, and if so what are their types?

(/\ 'a :: * . & x : 'a . x) (forall 'b :: *. 'b -> 'b)

/\ 'a :: * .
  & x : (forall 'b :: * . 'b -> 'a) .
    /\ 'd :: * .
      & y : 'd .
        x 'd y
*)
