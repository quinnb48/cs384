module type FIFO = sig
    type 'a fifo
    val empty : 'a fifo
    val add : 'a fifo -> 'a -> 'a fifo
    val pop : 'a fifo -> ('a * 'a fifo)
    va; is_empty : 'a fifo -> bool
end

module fifo: FIFO = struct
    type 'a fifo = 'a list

    let empty : 'a fifo = []

    let add (f : 'a fifo)(e: 'a) = e :: f

    let pop : (f: 'a fifo) = match List.rev f with
        | h :: t -> (h, List.rev t)
        | [] -> failwith "Empty List"

    let is_empty = List_is_empty
end

(*
module type MONOID = sig
  type t
  val empty : t
  val append : t -> t -> t
end
*)

module type GROUP = sig
    type t
    val times : t -> t -> t
    val one : t
    val inverse : t -> t
end

module IntGroup : GROUP = struct
    type t = int
    let times (a : t)(b : t)= a + b
    let one = 0
    let inverse (a:t) = -a
end

module GroupOps = functor (G: Group)  -> struct
    include G
    let rec exponent(v: G.t)(n : int): G.t = if n = 0 then v else exponent(G.times v v)(n-1)  
end
