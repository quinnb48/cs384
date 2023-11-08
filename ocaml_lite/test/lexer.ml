open OUnit2
open Ocaml_lite.Lexer
open Ocaml_lite.Parser
open Ocaml_lite.Ast

let lex_tests = "test suite for tokenize" >::: [
    "random code" >::
    (fun _ -> assert_equal
        [Let; Id "f"; LParen; Id "x"; Colon; TInt; RParen; Colon; TString;
         Eq; If; Id "x"; Lt; Int 0; Then; String "neg"; Else; String "pos"]
        (tokenize
           "let f (x : int) : string = if x < 0 then \"neg\" else \"pos\""));

    "all tokens" >::
    (fun _ -> assert_equal
      [Let; Rec; If; Then; Else; Fun; True; False; Mod; TInt; TBool; TString;
       TUnit; Eq; Plus; Minus; Times; Divide; Lt; Concat; And; Or; Not;
       Negate; DoubleSemicolon; Colon; Arrow; LParen; RParen;
       Id "function_name"; Int 32; String "str"; Pipe; DoubleArrow]
      (tokenize ("let rec if then else fun true false mod int bool string " ^
                 "unit =+-*/<^ && || not ~;;: -> () function_name 32 " ^
                 "\"str\"|=>")));

    "underscore id" >::
    (fun _ -> assert_equal [Id "_x32"] (tokenize "_x32"));

    "number id" >::
    (fun _ -> assert_equal [Int 32; Id "xyz"] (tokenize "32xyz"));
  ]

let parse_tests = "test suite for parser" >::: [
    "FuncBind" >::
    (fun _ -> assert_equal ~printer:print_prog_parens
      (EndMain(FuncBind("x",(PLS(Ps("s",StringTy),Nil)),IntTy,EMatch(EID "s",Pipep(Branch("str",EIf(BEq(EID "s",EVar "hi"),EInt 1,EFalse)))))))
      (parse "let x (s: string) : int = match s with |str => if s = \"hi\" then 1 else false ;;") );

    "TypeBind">::
    (fun _ -> assert_equal ~printer:print_prog_parens
    (EndMain(TypeBind("hat", Pipes_typ(BranchIdTyp("bonnet",StringTy),Pipes_typ(BranchIdTyp("tophat",IntTy),Pipes_typ(BranchIdTyp("transform",FuncTy(IntTy,StringTy)),Pipes_typ(BranchIdTyp("aaa",UnitTy),Pipes_typ(BranchIdTyp("bbb",BoolTy),Pipes_typ(BranchIdTyp("genteel",ParenTy (IntTy)),Pipes_typ(BranchId("boo"),Pipe_typ(BranchIdTyp("tup",TuplTy(TuplTy(IntTy,BoolTy),StringTy)))))))))))))
    (parse "type hat = |bonnet of string |tophat of int |transform of int -> string |aaa of unit |bbb of bool |genteel of (int) |boo |tup of int * bool * string ;;"));

    "Math test">::
    (fun _ -> assert_equal ~printer:print_prog_parens
    (EndMain(FuncBind("math", PLS(Ps("i",IntTy),Nil), NilTy, EIf(BAnd(BEq(BMinus(BPlus(EInt 1,BDivide(BTimes(EInt 2, EInt 3),EInt 4)),BMod(EInt 5, EInt 2)),UNot(ETrue)), BLt(EID "i", EInt 5)), EIf(BOr(BEq(EID"i",EInt 2),BEq(BConcat(EVar"h", EVar"i"),EInt 3)), ETrue, EFalse),EUnit))))
    (parse "let math (i: int) = if 1 + 2 * 3 / 4 - 5 mod 2 = not true && i <  5 then if i = 2 || \"h\" ^ \"i\" = 3 then true else false else () ;;"));

    "2MainFunc/Function application test">::
    (fun _ -> assert_equal ~printer:print_prog_parens
    (Main(FuncBindRec("a", PLS(P("i"),PLS(Ps("s", StringTy), Nil)), StringTy, EIf(BLt(EInt 0, EID "i"), BConcat(EID "s" , EFuncApp(EID "a", EList(EParen(BMinus(EID "i",EInt 1)), EListEnd (EID "s")))), EID "s")),EndMain(FuncBind("count3", Nil, StringTy, EFuncApp(EID "a",EList(EInt 3, EListEnd (EVar "a ")))))))
    (parse "let rec a i (s: string): string = if 0 < i then s ^ (a (i-1) s) else s ;; let count3 : string = (a 3 \"a \") ;;"));

    "Type/Nested Match test">::
    (fun _ -> assert_equal ~printer: print_prog_parens
    (Main(TypeBind("color", Pipes_typ(BranchId "red",Pipes_typ(BranchId "blue",Pipe_typ(BranchIdTyp("purple",TuplTy(UserTy "color", UserTy "color")))))), EndMain(FuncBind("check_color",Nil, NilTy, ELet("shoe",Nil,NilTy,EID "purple",EMatch(EID "shoe",Pipesp(Branch("red",EVar "red"),Pipep(Branchs("purple",NameList("r",IdL("b",Nil)),EMatch(EID "r",Pipep(Branch("red", EMatch( EID "b",Pipesp(Branch("blue", EVar "combo!"),Pipesp(Branch("red", EVar "that's just red"),Pipep(Branch("blue", EMatch(EID "b", Pipesp(Branch("red", EVar "combo!"),Pipesp(Branch("blue",EVar "that's just blue"),Pipep(Branch("blue", EVar "blue"))))))))))))))))))))))
    (parse "type color = | red | blue | purple of color * color;; let check_color = let shoe = purple in match shoe with |red =>  \"red\" |purple (r, b) => match r with |red => match b with |blue => \"combo!\" |red => \"that's just red\" |blue => match b with |red => \"combo!\" |blue => \"that's just blue\" |blue => \"blue\" ;;"));

    "EFun test">::
    (fun _ -> assert_equal ~printer: print_prog_parens
    (EndMain(FuncBindRec("whoo", Nil, NilTy, EFun(P "whoo_3", Nil, FuncTy(UnitTy,FuncTy(IntTy,BoolTy)), EFun(Ps("a", UnitTy),PLS(Ps("b", IntTy),PLS(P ("c"), Nil)),StringTy,BPlus(EInt 2, BMod(EInt 3, EInt 1)))))))
    (parse "let rec whoo = fun whoo_3 : unit -> int -> bool => fun (a: unit) (b: int) c : string => 2 + 3 mod 1;;"));

    "Factorial test">::
    (fun _ -> assert_equal ~printer: print_prog_parens
    (EndMain(FuncBindRec("factorial", PLS(Ps("n",IntTy),Nil), IntTy, EIf(BEq(EID"n", EInt 0), EInt 1, BTimes(EFuncApp(EID "factorial", EListEnd(EParen(BMinus(EID"n",EInt 1)))),EID"n")))))
    (parse "let rec factorial (n: int) : int = if n = 0 then 1 else (factorial (n-1)) * n ;;"));

    "Power test">::
    (fun _ -> assert_equal ~printer: print_prog_parens
    (EndMain(FuncBindRec("power", PLS(Ps("n",IntTy),PLS(Ps("p", IntTy),Nil)), IntTy, EIf(BEq(EID"p", EInt 0), EInt 1, BTimes(EID"n",EFuncApp(EID "power", EList(EID "n", EListEnd(EParen(BMinus(EID"p",EInt 1))))))))))
    (parse "let rec power (n: int) (p: int) : int = if p = 0 then 1 else n * (power n (p-1)) ;;"));
]

let type_checker_tests = "test suite for type checker" >::: [

]

let interpreter_tests = "test suite for interpreter" >::: [

]
