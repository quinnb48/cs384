let rec fib n =
    if n <= 0 then 0
    else if n = 1 then 1
    else fib(n-1) + fib(n-2)

let flip : ('a -> 'b -> 'c) -> ('b -> 'a -> 'c) =
    fun b a -> a b

let nth (lst: 'a list) : 'a list n =
    list.n

let rec sum (lst: int list) : int list sm =
    match lst with
    | [] -> 0
    | head :: tail -> sum(tail (sm + head))

let reverse (lst: 'a list) : 'a list =
    list.rev

let append (lst: 'a list) : 'a list (lst2: 'a list) : 'a list =
    match lst with
    | head :: tail -> head :: append tail lst2
    | [] -> lst 2
