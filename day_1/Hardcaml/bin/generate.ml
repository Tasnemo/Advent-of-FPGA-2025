open! Core
open! Hardcaml

let () =
  let module Fpga = Hardcaml_day1.Fpga in
  Command_unix.run
    (Rtl_generator.command
       ~name:"fpga"
       (let open Rtl_generator in
        { create = Fpga.hierarchical; i = (module Fpga.I); o = (module Fpga.O) }))
;;
