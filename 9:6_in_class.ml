type 'a my_option =
    |None
    |Type of 'a

let rec lookup (pairs_list: ('a * 'b) list) (key : 'a): 'b my_option =
        match pairs_list with
        |[] -> None
        |head::tail -> match head with
                    |(heady,  taily) -> if heady = key then Type taily
                                else lookup tail key

type 'a tree =
    |Empty
    |Branch of 'a * 'a tree list

let rec size (tree: 'a tree) : int =
    match tree with
    |Empty -> 0
    |Branch (r, lis) -> match lis with
                    |[]-> 1
                    |head :: tail -> List.fold_left (fun count remlist -> count + size remlist) (size head) tail
