open! Core

let parse_input input_file =
  In_channel.read_lines input_file
  |> List.map ~f:String.strip
  |> List.filter ~f:(fun s -> not (String.is_empty s))
  |> List.map ~f:Int.of_string
;;
