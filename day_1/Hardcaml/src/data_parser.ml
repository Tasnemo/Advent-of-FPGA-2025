open! Core
let parse_input input_file =
  let max_up = 6 in
  let levels = List.init (max_up + 1) ~f:Fn.id in
  let make_prefix d =
    if d = 0 then "" else String.concat (List.init d ~f:(fun _ -> "../"))
  in
  let candidates =
    List.concat_map levels ~f:(fun d ->
      let p = make_prefix d in
      [ p ^ input_file; p ^ "test/" ^ input_file ])
  in
  let existing = List.find candidates ~f:Stdlib.Sys.file_exists in
  let read path =
    In_channel.read_lines path
    |> List.map ~f:String.strip
    |> List.filter ~f:(fun s -> not (String.is_empty s))
    |> List.map ~f:(fun s ->
         let len = String.length s in
         if len = 0 then failwith "empty line"
         else
           let parse_num i = Int.of_string (String.sub s ~pos:i ~len:(len - i)) in
           let mod100 x = ((x % 100) + 100) % 100 in
           match s.[0] with
           | 'R' -> mod100 (parse_num 1)
           | 'L' -> mod100 (- parse_num 1)
           | _ -> mod100 (Int.of_string s))
  in
  match existing with
  | None -> read input_file
  | Some path -> read path
;;
