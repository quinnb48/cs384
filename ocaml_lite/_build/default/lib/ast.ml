(* function has: type, name, parameter (type, name), return type, and definition
definition is list of statements, eg if, let, return, int, comparators, variables, etc*)
type typ =
    | NilTy
    | IntTy
    | BoolTy
    | StringTy
    | UnitTy
    | TuplTy of typ * typ
    | ParenTy of typ
    | FuncTy of typ * typ
    | UserTy of string

type id_lst =
    |Nil
    |IdL of string * id_lst

type param =
    | P of string
    | Ps of string * typ

type param_lst =
    | Nil
    | PLS of param * param_lst

type vars =
    | Name of string
    | NameList of string * id_lst

type branch =
    | Branchs of string * vars * expr
    | Branch of string * expr

and branch_typ =
    | BranchIdTyp of string * typ
    | BranchId of string

and pipes =
    | Pipep of branch
    | Pipesp of branch * pipes

and pipes_typ =
    | Pipe_typ of branch_typ
    | Pipes_typ of branch_typ * pipes_typ

 and expr =
    | EMatch of expr * pipes
    | EInt of int
    | ETrue
    | EFalse
    | EVar of string
    | EID of string
    | EUnit
    | EParen of expr
    | UNot of expr
    | Squig of expr
    | BPlus of expr * expr
    | BMinus of expr * expr
    | BTimes of expr * expr
    | BDivide of expr * expr
    | BMod of expr * expr
    | BLt of expr * expr
    | BEq of expr * expr
    | BConcat of expr * expr
    | BAnd of expr * expr
    | BOr of expr * expr
    | EVars of expr * expr * expr_lst
    | EFuncApp of expr * expr
    | EList of expr * expr
    | EListEnd of expr
    | EFun of param * param_lst * typ * expr
    | EIf of expr * expr * expr
    | ELetRec of string * param_lst * typ * expr * expr
    | ELet of string * param_lst * typ * expr * expr

and expr_lst =
    |Nil
    |ExprL of expr * expr_lst

and bind =
    | TypeBind of string * pipes_typ
    | FuncBindRec of string * param_lst * typ * expr
    | FuncBind of string * param_lst * typ * expr

and prog =
    | EndMain of bind
    | Main of bind * prog


let rec print_lst_expr : expr_lst -> string = function
    |Nil -> ""
    |ExprL (e, l) -> ", " ^ print_expr e ^ print_lst_expr l

and print_lst_param : param_lst -> string = function
    |Nil -> ""
    |PLS (p,l) -> print_param p ^ print_lst_param l

and print_lst_id : id_lst -> string = function
    |Nil -> ""
    |IdL (i, l) -> "| " ^ i ^ print_lst_id l

and typ_to_str : typ -> string = function
    | NilTy -> ""
    | IntTy -> "int"
    | BoolTy -> "bool"
    | StringTy -> "string"
    | UnitTy -> "unit"
    | UserTy s -> s
    | TuplTy (t1, t2) -> typ_to_str t1 ^ " * " ^ typ_to_str t2
    | ParenTy t1 -> "(" ^ typ_to_str t1 ^ ")"
    | FuncTy (t1, t2) -> "(" ^ typ_to_str t1 ^ ") -> (" ^ typ_to_str t2 ^ ")"

and print_param : param -> string = function
    |P s -> s
    |Ps (s, t) -> "(" ^ s ^ " : " ^ typ_to_str t ^ ")"

 and print_vars : vars -> string = function
    | Name s -> s
    | NameList (s, v) -> "(" ^ s ^ ", " ^ print_lst_id v ^ ")"

 and print_branch : branch -> string = function
    | Branchs (s, v, e) -> s ^ print_vars v ^ " => " ^  print_expr e
    | Branch (s, e) -> s ^ " => " ^ print_expr e

and print_branch_typ : branch_typ -> string = function
    |BranchIdTyp (i, t)->  i ^ " of " ^ typ_to_str t
    |BranchId i -> i

 and print_pipes_typ : pipes_typ -> string = function
    | Pipe_typ b -> "| " ^ print_branch_typ b
    | Pipes_typ (b, p) -> "| " ^ print_branch_typ b ^ print_pipes_typ p

 and print_pipes : pipes -> string = function
    | Pipep b -> "| " ^ print_branch b
    | Pipesp (b,p) -> "| " ^ print_branch b ^ print_pipes p

 and print_expr : expr -> string = function
    | EMatch (e, p) -> "Match " ^ print_expr e ^ " with " ^ print_pipes p
    | EInt i -> string_of_int i
    | ETrue -> "true"
    | EFalse -> "false"
    | EVar i -> i
    | EID i -> i
    | EUnit -> "()"
    | EParen e -> "(" ^ print_expr e ^ ")"
    | UNot e -> "!" ^ print_expr e
    | Squig e -> "~" ^ print_expr e
    | BPlus (e1,e2) -> print_expr e1 ^ " + " ^ print_expr e2
    | BMinus (e1,e2) -> print_expr e1 ^ " - " ^ print_expr e2
    | BTimes (e1,e2) -> print_expr e1 ^ " * " ^ print_expr e2
    | BDivide (e1,e2) -> print_expr e1 ^ " / " ^ print_expr e2
    | BMod (e1,e2) -> print_expr e1 ^ " mod " ^ print_expr e2
    | BLt (e1,e2) -> print_expr e1 ^ " < " ^ print_expr e2
    | BEq (e1,e2) -> print_expr e1 ^ " = " ^ print_expr e2
    | BConcat (e1,e2) -> print_expr e1 ^ " ^ " ^ print_expr e2
    | BAnd (e1,e2) -> print_expr e1 ^ " && " ^ print_expr e2
    | BOr (e1,e2) -> print_expr e1 ^ " || " ^ print_expr e2
    | EVars (e1, e2, l) -> "(" ^ print_expr e1 ^ ", " ^ print_expr e2 ^ print_lst_expr l ^ ")"
    | EFuncApp (e1, e2) -> "(" ^ print_expr e1 ^ print_expr e2 ^ ")"
    | EList (e1, e2) -> print_expr e1 ^ print_expr e2
    | EListEnd e -> print_expr e
    | EFun (p, pl, t, e) -> if t != NilTy then "fun " ^ print_param p ^
        print_lst_param pl ^ ": " ^ typ_to_str t ^ " => " ^ print_expr e
        else "fun " ^ print_param p ^ print_lst_param pl ^ " => " ^ print_expr e
    | EIf (e1, e2, e3) -> "if " ^ print_expr e1 ^ " then " ^ print_expr e2 ^
        " else " ^ print_expr e3
    | ELetRec (s,pl,t,e1,e2) -> if t != NilTy then "let rec " ^ s ^ print_lst_param pl ^
        ": " ^ typ_to_str t ^ " = " ^ print_expr e1 ^ " in " ^ print_expr e2
        else "let rec " ^ s ^ print_lst_param pl ^ " = " ^ print_expr e1 ^ " in " ^
        print_expr e2
    | ELet (s,pl,t,e1,e2) -> if t != NilTy then "let " ^ s ^ print_lst_param pl ^
        ": " ^ typ_to_str t ^ " = " ^ print_expr e1 ^ " in " ^ print_expr e2
        else "let " ^ s ^ print_lst_param pl ^ " = " ^ print_expr e1 ^ " in " ^
        print_expr e2

and print_bind : bind -> string = function
    |TypeBind (s, p) -> "type " ^ s ^ " = " ^ print_pipes_typ p
    |FuncBindRec (s, p, t2, e) -> if t2 != NilTy then "let rec " ^ s ^ print_lst_param p ^ ": " ^
        typ_to_str t2 ^ " = " ^ print_expr e
        else "let rec " ^ s ^ print_lst_param p ^ " = " ^ print_expr e
    |FuncBind (s, p, t2, e) -> if t2 != NilTy then "let " ^ s ^ print_lst_param p ^ ": " ^
        typ_to_str t2 ^ " = " ^ print_expr e
        else "let rec " ^ s ^ print_lst_param p ^ " = " ^ print_expr e

and print_prog : prog -> string = function
    | EndMain b -> print_bind b ^ ";;"
    | Main (b,p) -> print_bind b ^ ";; \n" ^ print_prog p


(* This section for testing/debugging mostly*)

let rec print_lst_expr_parens : expr_lst -> string = function
    |Nil -> "Nil"
    |ExprL (e, l) -> "ExprL(" ^ print_expr_parens e ^ ", " ^ print_lst_expr_parens l ^ ")"

and print_lst_param_parens : param_lst -> string = function
    |Nil -> "Nil"
    |PLS (p,l) -> "PLS(" ^ print_param_parens p ^ ", " ^ print_lst_param_parens l ^ ")"

and print_lst_id_parens : id_lst -> string = function
    |Nil -> "Nil"
    |IdL (i, l) -> "IdL(" ^ i ^ ", " ^ print_lst_id_parens l ^ ")"

and typ_to_str_parens : typ -> string = function
    | NilTy -> "NilTy"
    | IntTy -> "IntTy"
    | BoolTy -> "boolTy"
    | StringTy -> "StringTy"
    | UnitTy -> "UnitTy"
    | UserTy s -> "UserTy(" ^ s ^ ")"
    | TuplTy (t1, t2) -> "TuplTy(" ^ typ_to_str_parens t1 ^ ", " ^ typ_to_str_parens t2 ^ ")"
    | ParenTy t1 -> "ParenTy(" ^ typ_to_str_parens t1 ^ ")"
    | FuncTy (t1, t2) -> "FuncTy(" ^ typ_to_str_parens t1 ^ ", " ^ typ_to_str_parens t2 ^ ")"

and print_param_parens : param -> string = function
    |P s -> "P " ^ s
    |Ps (s, t) -> "Ps(" ^ s ^ ", " ^ typ_to_str_parens t ^ ")"

 and print_vars_parens : vars -> string = function
    | Name s -> "Name " ^ s
    | NameList (s, v) -> "NameList(" ^ s ^ ", " ^ print_lst_id_parens v ^ ")"

 and print_branch_parens : branch -> string = function
    | Branchs (s, v, e) -> "Branchs(" ^ s ^ ", " ^ print_vars_parens v ^ ", " ^  print_expr_parens e ^ ")"
    | Branch (s, e) -> "Branch(" ^ s ^ ", " ^ print_expr_parens e ^ ")"

and print_branch_typ_parens : branch_typ -> string = function
    |BranchIdTyp (i, t)->  "BranchIdTyp(" ^ i ^ ", " ^ typ_to_str_parens t ^ ")"
    |BranchId i -> "BranchId " ^ i

 and print_pipes_typ_parens : pipes_typ -> string = function
    | Pipe_typ b -> "Pipe_typ " ^ print_branch_typ_parens b ^ ")"
    | Pipes_typ (b, p) -> "Pipes_typ(" ^ print_branch_typ_parens b ^ ", " ^ print_pipes_typ_parens p ^ ")"

 and print_pipes_parens : pipes -> string = function
    | Pipep b -> "Pipep(" ^ print_branch_parens b ^ ")"
    | Pipesp (b,p) -> "Pipesp(" ^ print_branch_parens b ^ ", " ^ print_pipes_parens p ^ ")"

 and print_expr_parens : expr -> string = function
    | EMatch (e, p) -> "EMatch(" ^ print_expr_parens e ^ ", " ^ print_pipes_parens p ^ ")"
    | EInt i -> "EInt " ^ string_of_int i
    | ETrue -> "ETrue"
    | EFalse -> "EFalse"
    | EVar i -> "EVar " ^ i
    | EID i -> "EID " ^ i
    | EUnit -> "EUnit"
    | EParen e -> "EParen " ^ print_expr_parens e
    | UNot e -> "UNot " ^ print_expr_parens e
    | Squig e -> "Squig " ^ print_expr_parens e
    | BPlus (e1,e2) -> "BPlus(" ^ print_expr_parens e1 ^ ", " ^ print_expr_parens e2 ^ ")"
    | BMinus (e1,e2) -> "BMinus(" ^ print_expr_parens e1 ^ ", " ^ print_expr_parens e2 ^ ")"
    | BTimes (e1,e2) -> "BTimes(" ^ print_expr_parens e1 ^ ", " ^ print_expr_parens e2 ^ ")"
    | BDivide (e1,e2) -> "BDivide(" ^ print_expr_parens e1 ^ ", " ^ print_expr_parens e2 ^ ")"
    | BMod (e1,e2) -> "BMod(" ^ print_expr_parens e1 ^ ", " ^ print_expr_parens e2 ^ ")"
    | BLt (e1,e2) -> "BLt(" ^ print_expr_parens e1 ^ ", " ^ print_expr_parens e2 ^ ")"
    | BEq (e1,e2) -> "BEq(" ^ print_expr_parens e1 ^ ", " ^ print_expr_parens e2 ^ ")"
    | BConcat (e1,e2) -> "BConcat(" ^ print_expr_parens e1 ^ ", " ^ print_expr_parens e2 ^ ")"
    | BAnd (e1,e2) -> "BAnd(" ^ print_expr_parens e1 ^ ", " ^ print_expr_parens e2 ^ ")"
    | BOr (e1,e2) -> "BOr(" ^ print_expr_parens e1 ^ ", " ^ print_expr_parens e2 ^ ")"
    | EVars (e1, e2, l) -> "EVars(" ^ print_expr_parens e1 ^ ", " ^ print_expr_parens e2 ^ ", " ^ print_lst_expr_parens l ^ ")"
    | EFuncApp (e1, e2) -> "EFuncApp(" ^ print_expr_parens e1 ^ ", " ^ print_expr_parens e2 ^ ")"
    | EList (e1, e2) -> "EList(" ^ print_expr_parens e1 ^ ", " ^ print_expr_parens e2 ^")"
    | EListEnd e -> "EListEnd " ^ print_expr_parens e
    | EFun (p, pl, t, e) -> "EFun(" ^ print_param_parens p ^ ", " ^ print_lst_param_parens pl ^ ", " ^ typ_to_str_parens t ^ "," ^ print_expr_parens e ^ ")"
    | EIf (e1, e2, e3) -> "EIf(" ^ print_expr_parens e1 ^ ", " ^ print_expr_parens e2 ^ ",  " ^ print_expr_parens e3 ^ ")"
    | ELetRec (s,pl,t,e1,e2) -> "ELetRec(" ^ s ^ ", " ^ print_lst_param_parens pl ^ ", " ^ typ_to_str_parens t ^ "," ^ print_expr_parens e1 ^ ", " ^ print_expr_parens e2 ^ ")"
    | ELet (s,pl,t,e1,e2) -> "ELet(" ^ s ^ ", " ^ print_lst_param_parens pl ^ ", " ^ typ_to_str_parens t ^ "," ^ print_expr_parens e1 ^ ", " ^ print_expr_parens e2 ^ ")"

and print_bind_parens : bind -> string = function
    |TypeBind (s, p) -> "TypeBind(" ^ s ^ ", " ^ print_pipes_typ_parens p ^ ")"
    |FuncBindRec (s, p, t2, e) -> "FuncBindRec(" ^ s ^ ", " ^ print_lst_param_parens p ^ ", " ^
        typ_to_str_parens t2 ^ ", " ^ print_expr_parens e ^ ")"
    |FuncBind (s, p, t2, e) -> "FuncBind(" ^ s ^ ", " ^ print_lst_param_parens p ^ ", " ^
        typ_to_str_parens t2 ^ ", " ^ print_expr_parens e ^ ")"

and print_prog_parens : prog -> string = function
    | EndMain b -> "EndMain(" ^ print_bind_parens b ^ ")"
    | Main (b,p) -> "Main(" ^ print_bind_parens b ^ ", " ^ print_prog_parens p ^ ")"
