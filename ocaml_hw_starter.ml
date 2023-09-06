type bstree =
  | Lf
  | Br of int * bstree * bstree

let rec insert (t : bstree) (i : int) : bstree =
  match t with
  | Lf -> Br (i, Lf, Lf)
  | Br (n, left, right) ->
    if i = n then t
    else if i < n then Br (n, insert left i, right)
    else Br (n, left, insert right i)

let insert_all (t : bstree) (is : int list) : bstree =
  List.fold_left insert t is

type arith =
  | Plus of arith * arith
  | Times of arith * arith
  | Negate of arith
  | Var of string
  | Num of int

(* NOTE: you may modify the function declarations as long as the names and
   types remain the same. For example, you might need to add "rec" in some
   declarations. *)

   let rec remove_duplicates (lst : 'a list) : 'a list =
        let rec is_dup n lsty =
            match lsty with
            | [] -> lst
            | head :: tail -> if head = n then lsty
                             else is_dup n tail
         in
         let rec loop left right =
             match right with
             | [] -> left
             | head::tail -> if is_dup head left = lst then loop left tail
                               else loop (head::left) right
         in
         List.rev (loop [] lst)

let rec prefix_sum (lst : int list) : int list =
  match lst with
  |[] -> lst
  |head :: tail -> match tail with
                |[] -> lst
                |head2 :: [] -> prefix_sum((head2+head)::[])
                |head2 :: tail2 -> prefix_sum((head2+head)::tail2)

let suffix_sum (lst : int list) : int list =
    let reversy = prefix_sum(List.rev lst) in
    List.rev reversy

let table (f : 'a -> 'b -> 'c) (xs : 'a list)
          (ys : 'b list) : ('a * 'b * 'c) list list=
        let rec help2 (xhead2: 'a) (yss: 'b list): ('a * 'b * 'c ) list =
            match yss with
                |[] -> []
                |yhead::ytail -> (xhead2,yhead,f xhead2 yhead):: (help2 xhead2 ytail)
        in

        let rec help  (xss : 'a list)
                  (yss : 'b list) =
            match xss with
            |[] -> []
            |xhead::xtail -> (help2 xhead  ys) :: (help xtail ys)
        in help xs ys



    (* lists_sq = new list of lists;
        for each numx in x :
            for each numy in y:
                lists_sq[numx] = (numx, numy, f(numx,numy)) *)


(* let binaries (n : int) : string list =
  failwith "Not implemented"

let without (t : bstree) (v : int) : bstree =
  failwith "Not implemented"

let flatten (t : bstree) : int list =
  failwith "Not implemented"

let free_vars (expr : arith) : string list =
  failwith "Not implemented"

let subst (id : string) (v : arith) (expr : arith) : arith =
  failwith "Not implemented"

type prop

let pprint (p : prop) : string =
  failwith "Not implemented"
 *)
