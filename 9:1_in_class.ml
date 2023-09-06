type day =
    |String

let weekday (str : string) : bool =
    match str with
    | "Monday" -> true
    | "Tuesday" -> true
    | "Wednesday" -> true
    | "Thursday" -> true
    | "Friday" -> true
    | "Saturday" -> true
    | "Sunday" -> true
    |  _ -> false

type int_option =
    | None
    | Integer of int

let default : int -> int_option -> int =
    match int_option with
    |int -> int
    |_ -> None

let nth (l: list) (n: int): int list -> int -> int_option =
    if n >= l.length then None
    else int_option = l.n
