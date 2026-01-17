open! Core
open! Hardcaml

module Fpga = Hardcaml_day1.Fpga

let generate_fpga_rtl () : unit =
  let module C = Circuit.With_interface (Fpga.I) (Fpga.O) in
  let scope = Scope.create ~auto_label_hierarchical_ports:true () in
  let circuit = C.create_exn ~name:"fpga_top" (Fpga.hierarchical scope) in
  let rtl_circuits = Rtl.create ~database:(Scope.circuit_database scope) Verilog [ circuit ] in
  let rtl = Rtl.full_hierarchy rtl_circuits |> Rope.to_string in
  Stdio.print_endline rtl
;;

let fpga_cmd =
  Command.basic
    ~summary:"Generate fpga Verilog"
    [%map_open.Command
      let () = return () in
      fun () -> generate_fpga_rtl ()]

let () =
  Command_unix.run (Command.group ~summary:"" [ "fpga", fpga_cmd ])
;;
