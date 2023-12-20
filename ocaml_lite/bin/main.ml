let parse = Ocaml_lite.Lexer.parse
let typecheck =  Ocaml_lite.Type_checker.check_type
let interpret =  Ocaml_lite.Interpreter.interpret
(* let printy = fun _-> Ocaml_lite.Interpreter.print_itpt *)

let () =
  if Array.length Sys.argv <> 2
  then failwith "Expected exactly one command line argument"
  else
    let ch = In_channel.open_text Sys.argv.(1) in
    let text = In_channel.input_all ch in
    let () = In_channel.close ch in
    let ast = parse text in
    let _ = typecheck ast in
    let _ = (interpret ast) in ()

(* I have spent about 30 minutes trying to get this to function. If i leave it as
was given, it complains about returning something other than unit. I cannot change
interpret's return to be unit because that would mess up the tests. If i try to
just deal with printing the result of interpret with the printy function, it
complains that it doesn't think the function's being applied to enough arguments
for some reason??? and as it is it doesn't think the equality check works for
some reason :/ *)
