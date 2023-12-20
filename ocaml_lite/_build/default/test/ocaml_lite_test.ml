open OUnit2

let tests = "test suite for ocaml_lite" >::: [
    Lexer.lex_tests;
    Lexer.parse_tests;
    Lexer.type_checker_tests;
    Lexer.interpreter_tests;
  ]

let _ = run_test_tt_main tests


(* "label" >:: (fun _ -> assert_equal ~printer:<print_function>
  <expected_result> <expression>)

- "label" is replaced by any string (this label is reported for each test which fails),
- <expected_result> is an expression of some type 'a representing the result you want to see,
- <expression> is an OCaml expression to evaluate, the result of which should be <expected_result>
- <print_function> is a function of type 'a -> string telling the test framework how to represent
<expression> and <expected_result>. You may omit ~printer:<print_function> if you wish, but then
you will only get a notification that the test failed, and you won't have any information about
the expected or computed results.

  "label" >:: (fun _ -> try
    let _ = <expression> in
    assert_failure "message 1"
  with
  | <error_pattern> -> assert_bool "" true
  | _ -> assert_failure "message 2")

 - for when you want a error

Parser tests (some of these trees are no longer correct after editing/review):
Let x (s: string) : int =
    match s with
    |TString => if s = "hi" then 1 else False ;;
(* Should become: *)
progp(endmain) -> Bindp (FuncBind) -> Id; param_listp; typp; exprp;
            _____________________________/ ____________/ ______/
paramp(Ps); param_listp(Nil)            TInt      exprp (EMatch)
   |                                              /
Id; typp                     exprp(Id); pipesp(Pipep)
     |                                   |
TString                        branchp(Branch)
                                       |
                                  Id; exprp(EIf)
                                       |
                        exprp(BEq); exprp(EInt); exprp(EFalse)
                            |
                 exprp(EId); exprp(EVar)

Type hat =
    |bonnet of TString
    |tophat of TInt
    |transform of TInt -> TString
    |aaa of TUnit
    |bbb of TBool
    |genteel of (TInt)
    |boo
    |tup of TInt * TBool * TString ;;
(* Should become: *)
progp(endmain) -> bindp(typebind) -> Id; typ_pipesp(pipes_typ);
                                          /
    typ_branchp(BranchIdTyp); typ_pipesp(pipes_typ)
        |                                 |
    Id; typp      typ_branchp(BranchIdTyp); typ_pipesp(pipes_typ)
         |            |                          |
        TString    Id; typp        typ_branchp(BranchIdTyp); typ_pipesp(pipes_typ)
                        |          /                             |
                      TInt    Id; typp   typ_branchp(BranchIdTyp); typ_pipesp(pipes_typ)
                                    |          |                        |
                            TInt->TSTring   Id; typp   typ_branchp(BranchIdTyp); typ_pipesp(pipes_typ)
                                                 |          |                             |
                                              TUnit      Id; typp        typ_branchp(BranchIdTyp); typ_pipesp(pipes_typ)
                                                               |           |                             |
                                                            TBool       Id; typp     typ_branch(BranchId); typ_pipesp(pipe_typ)
                                                                             |         |                       |
                                                                            TInt      Id           typ_branchp(BranchIdTyp)
                                                                                                  |
                                                                                                id; typp
                                                                                                     |
                                                                                            TInt * TBool * TString

let math (i: int) =
    if 1 + 2 * 3 / 4 - 5 mod 2 = !true && i < 5 then if i = 2 || "h" ^ "i" = 3 then true else false else () ;;
(* should become: *) (* should fail typechecks *)
progp(endmain) -> bindp(funcbind) -> Id; param_listp(PLS); exprp(EIf)
                           _____________/                    |
paramp(Ps); param_listp(Nil)            exprp(BAnd); exprp(EIf); exprp(EUnit);
    |                                          |              \
Id; typp                             exprp(BEq); exprp(BLt)     exprp(BOr); exprp(True); exprp(False);
     |                                   |           \                  \_________
    TInt                    exprp(BPlus); exprp(Not)  exprp(EId); exprp(EInt)    exprp(BEq); exprp(BEq)
                              |                 \                               /                    \
                    exprp(EInt); exprp(BMinus)   exprp(ETrue)     exprp(EVar); exprp(EInt)   exprp(BConcat); exprp(EInt)
                                      |                                                               |
                        exprp(EDivide); exprp(EMod)                                          exprp(EVar); exprp(EVar)
                             |                   \
                    exprp(ETimes); exprp(EInt)   exprp(EInt); exprp(EInt)
                           |
                exprp(EInt); exprp(EInt)

let rec a i (s: TString): TString =
    if 0 < i then s ^ (a (i-1) s) else s ;;
let count3 : TString =
    (a 3 "a ") ;;
(* should become:*)
progp(main) -> bindp(funcbindrec); progp(endmain)
               |                                \______
Id; param_listp(PLS); typp(TSTring); exprp(Eif)        bindp(funcbind)
        |                                |                           \________
paramp(P); param_listp(PLS)    exprp(BLT); exprp(BConcat); exprp(EVar)     Id; param_listp(Nil); typp(TString); exprp(EFuncApp)
  |             |                   |                  \                                    ____________________/
  Id           paramp(ps)   exprp(EInt); exprp(EID) exprp(EID); exprp(EFuncApp)      exprp(EId); exprp(EList)
                |                                                     |                             |
            Id; typp(TString)                          exprp(EID); exprp(EList)           exprp(EInt); exprp(EListEnd)
                                                                     |                                        |
                                                    exprp(EParen); exprp(EListEnd)                               EVar
                                                     |               |
                                                 exprp(BSub)        EID
                                                      |
                                                exprp(EID); exprp(EInt)


type color =
    | red
    | blue
    | purple of color * color;;

let check_color =
    let shoe = purple in match shoe with
    |red =>  "red"
    |purple (r, b) => match r with
        |red => match b with
            |blue => "combo!"
            |red => "that's just red"
        |blue => match b with
            |red => "combo!"
            |blue => "that's just blue"
    |blue => "blue" ;;
(* should become:*) (* should not run as would be intended by spacing above*)
progp(Main) -> bindp(Typebind); progp(endmain)
              /                        |
Id; type_pipesp(Pipes_typ)         bindp(FuncBind)
           |                                    \
typ_branchp(BranchId); type_pipesp(Pipes_typ)   Id; param_listp(Nil); exprp(ELet)
|                        |                                               /
Id    typ_branchp(BranchId); type_pipesp(Pipe_typ)    Id; param_listp(Nil); exprp(EFuncApp); exprp(EMatch)
       |                    |                                              /                    |
       Id     typ_branchp(BranchIdTyp)                exprp(EID); func_app(EList)        exprp(EID); pipesp(Pipes)
                |                                                  |                                     |
                Id; typp(UserTy)                        exprp(EID); func_app(EListEnd)    branchp(branch); pipesp(Pipe)
                                                                     |                      |                  |
                                                                exprp(EID)              Id; exprp(EVar)  branchp(branchs);
                                                                                                         /
                                                                                  Id; varsp(NameList); exprp(EMatch);
                                                                                     /                      |
                                                                           Id; id_lstp(Name)        exprp(EID); pipesp(Pipe)
                                                                              /                                /
                                                                            Id;                    branchp(Branch)
                                                                                                        |
                                                                                                id; expr(EMatch)
                                                                                                      |
                                                                                            branchp(Branch); pipesp(Pipes)
                                                                                                /               |
                                                                                    Id; exprp(EVar)  branchp(Branch); pipesp(Pipe)
                                                                                                        /               |
                                                                                                Id; exprp(EVar)    branchp(Branch)
                                                                                                                        |
                                                                                                            Id; exprp(EMatch)
                                                                                                                        |
                                                                                                            exprp(EID); pipesp(Pipes)
                                                                                                                          |
                                                                                                            branchp(Branch); pipesp(Pipes)
                                                                                                            /                    |
                                                                                                   Id; exprp(EVar)        branchp(Branch); pipesp(Pipe)
                                                                                                                            |              /
                                                                                                                Id; exprp(EVar)   branchp(Branch)
                                                                                                                                        |
                                                                                                                                Id; exprp(EVar)

Let rec whoo =
    Fun hoo_3 : TUnit -> TInt -> TBool => Fun (a: TUnit) (b: TInt) c : TString => 2 + 3 mod 1
(* should become: *)
progp(endmain) -> bindp(FuncBindRec)
                  /
Id; param_lstp(PLS); exprp(EFun);
        |                       \
paramp(P); paramp_lstp(Nil)  paramp(P); param_lstp(Nil); typp(FuncTy); exprp(EFun)
 |                              |                          /            |
 Id                             Id      typp(TUnit); typp(Functy)     paramp(Ps); param_lstp(PLS); exprp(BPlus)
                                                     /                /              |                      \
                                typp(TInt); typp(TBool)    Id; typp(TUnit)   paramp(Ps); param_lstp(PLS)   exprp(EInt); exprp(BMod)
                                                                            /                  |                             |
                                                               Id; Typp(TInt)    paramp(Ps); param_lstp(Nil)         exprp(EInt); exprp(EInt)
                                                                                  |
                                                                                  Id

let rec factorial (n: TInt) : TInt =
    if n = 0 then 1
    else (factorial (n-1)) * n ;;
(* should become:*)
progp(endmain) -> bindp(FuncBindRec)
                    /
Id; param_lstp(PLS); exprp(EIf)
         |                    \
paramp(PS); param_lstp(Nil)  exprp(BEq); exprp(EInt); exprp(BTimes)
  |                              |                          |
Id; typp(TInt)        exprp(EId); exprp(EInt)    exprp(EFuncApp); exprp(EID)
                                                        |
                                                Id; func_app(EListEnd)
                                                        |
                                                    exprp(BSub)
                                                       |
                                             exprp(EID); exprp(EInt)

let rec power (n: TInt) (p: TInt) : TInt =
    if p = 0 then 1
    else n * (power n (p-1)) ;;
(* should become:*)
progp(endmain) -> bindp(FuncBindRec)
                    /
Id; param_lstp(PLS); exprp(EIf)
        |                     \
paramp(PS); param_lstp(PLS)  exprp(BEq); exprp(EInt); exprp(BTimes);
   |                   \               \________                  \______
Id; typp(TInt)  paramp(PS); param_lst(Nil)   exprp(EID); exprp(EInt)   exprp(EID); exprp(EFuncApp)
                     |                                                               /
                Id; typp(TInt)                                      Id; func_app(EList)
                                                                            |
                                                                  exprp(EID); func_app(EListEnd)
                                                                                    |
                                                                                exprp(BSub)
                                                                                    |
                                                                            exprp(EID); exprp(EInt)



Typechecker tests:
Let x (s: TString) : TInt =
    match s with
    |TString => if s = "hi" then 1 else 0 ;;
(* Should pass *)

Let x (s: TString) : TInt =
    match s with
    |TString => if s = "hi" then 1 else False ;;
(* Should fail *)

Type hat =
    |bonnet of TString
    |tophat of TInt
    |transform of TInt -> TString
    |aaa of TUnit
    |bbb of TBool
    |genteel of (TInt)
    |boo
    |tup of TInt * TBool * TString ;;
(* Should pass *)

let rec a i (s: TString): TString =
    if 0 < i then s ^ (a (i-1) s) else s ;;
let count3 : TString =
    (a 3 "a ") ;;
(* should pass *)

let math (i: TInt) =
    if 1 + 2 * 3 / 4 - 5 mod 2 = !true and i < 5 then if i = 2 or "h" ^ "i" = 3 then true else false else () ;;
(* should fail *)

Type color =
    | red
    | blue
    | purple of color * color;;

let check_color =
    let shoe = (purple red blue) in match shoe with
            |red =>  "red"
            |purple (r, b) => match r with
                |red => match b with
                    |blue => "combo!"
                    |red => "that's just red"
                    |blue => match b with
                        |red => "combo!"
                        |blue => "that's just blue"
                        |blue => "blue" ;;
(* should pass *)

Let rec whoo =
    Fun hoo_3 : TUnit -> TInt -> TBool => Fun (a: TUnit) (b: TInt) c : TString => 2 + 3 mod 1
(* should pass? *)

let rec factorial (n: TInt) : TInt =
    if n = 0 then 1
    else (factorial (n-1)) * n ;;
(* should pass *)

let rec factorial (n: TBool) : TInt =
    if n = 0 then 1
    else (factorial (n-1)) * n ;;
(* should fail *)

let rec power (n: TInt) (p: TInt) : TInt =
    if p = 0 then 1
    else n * (power n (p-1)) ;;
(* should pass *)

let rec power (n: TString) (p: TInt) : TInt =
    if p = 0 then 1
    else n * (power n (p-1)) ;;
(* should fail *)

Interpreter tests:
Let x (s: TString) : TInt =
    match s with
    |TString => if s = "hi" then 1 else False ;;
(* Should give: *)
    (s type = TString):
            (s = "hi") = true: 1 (TInt)
            (s = "hi") = false: False (TInt)

Type hat =
    |bonnet of TString
    |tophat of TInt
    |transform of TInt -> TString
    |aaa of TUnit
    |bbb of TBool
    |genteel of (TInt)
    |boo
    |tup of TInt * TBool * TString ;;
(* Should just pass *)

let rec a i (s: TString): TString =
    if 0 < i then s ^ (a (i-1) s) else s ;;
let count3 : TString =
    (a 3 "a ") ;;
(* should give: *)
 (0 < i):
        s ^ (a (i-1) s)
 (0 >= i):
        s

(a 3 "a "):
let rec a 3 "a ": TString =
    if 0 < 3 then "a " ^ (a (3-1) "a ") else "a " ;;
        (*should be option 1*)
(a (3-1) "a "):
let rec a 2 "a ": TString =
    if 0 < 2 then "a " ^ (a (2-1) "a ") else "a " ;;
        (*should be option 1*)
(a (2-1) "a "):
let rec a 1 "a ": TString =
    if 0 < 1 then "a " ^ (a (1-1) "a ") else "a " ;;
        (*should be option 1*)
(a (1-1) "a "):
let rec a 0 "a ": TString =
    if 0 < 0 then "a " ^ (a (0-1) "a ") else "a " ;;
        (*should be option 2*)


Type color =
    | red
    | blue
    | purple of color * color;;

let check_color =
    let shoe = (purple r b) in match shoe with
            |red =>  "red"
            |purple (r, b) => match r with
                |red => match b with
                    |blue => "combo!"
                    |red => "that's just red"
                    |blue => match b with
                        |red => "combo!"
                        |blue => "that's just blue"
                        |blue => "blue" ;;
(* should fail due to doubles? *)

Let rec whoo =
    Fun hoo_3 : TUnit -> TInt -> TBool => Fun (a: TUnit) (b: TInt) c : TString => 2 + 3 mod 1
(* should fail? *)

let rec factorial (n: TInt) : TInt =
    if n = 0 then 1
    else (factorial (n-1)) * n ;;
(* should pass *)
(n = 0): True, then
    1 (TInt)
(n != 0): False, then
    (factorial (n-1)) * n:
        TInt

let factorial (n: TInt) : TInt =
    if n = 0 then 1
    else (factorial (n-1)) * n ;;
(* should fail due to not being rec *)

let rec power (n: TInt) (p: TInt) : TInt =
    if p = 0 then 1
    else n * (power n (p-1)) ;;
(* should give: *)
( p = 0 ): True, then
    1 (TInt)
( p != 0): False, then
    n * (power n (p-1)):
        TInt

 *)
