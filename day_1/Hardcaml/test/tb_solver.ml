open! Core
open! Hardcaml
open! Hardcaml_waveterm
open! Hardcaml_test_harness
module Fpga = Hardcaml_day1.Fpga
module Data_parser = Hardcaml_day1.Data_parser
module Harness = Cyclesim_harness.Make (Fpga.I) (Fpga.O)

let streaming_testbench (sim : Harness.Sim.t) =
  let i = Cyclesim.inputs sim in
  let o = Cyclesim.outputs sim in
  let cycle ?n () = Cyclesim.cycle ?n sim in
  
  let dataset = Data_parser.parse_input "input.txt" in
  
  i.clear := Bits.vdd;
  cycle ();
  i.clear := Bits.gnd;
  cycle ();
  
  i.start := Bits.vdd;
  cycle ();
  i.start := Bits.gnd;
  
  let rec feed l =
    match l with
    | [] -> ()
    | [x] -> 
        i.v_in := Bits.of_int ~width:16 x;
        i.v_valid := Bits.vdd;
        i.v_last := Bits.vdd;
        cycle ();
        i.v_valid := Bits.gnd;
        i.v_last := Bits.gnd;
    | x :: tl ->
        i.v_in := Bits.of_int ~width:16 x;
        i.v_valid := Bits.vdd;
        cycle ();
        i.v_valid := Bits.gnd;
        feed tl
  in
  
  feed dataset;
  
  let rec wait_done () =
    if Bits.to_bool !(o.done_) then ()
    else (cycle (); wait_done ())
  in
  wait_done ();
  
  let res = Bits.to_unsigned_int !(o.result) in
  print_s [%message "Result" (res : int)]
;;

let%expect_test "Fpga test" =
  Harness.run_advanced ~create:Fpga.hierarchical streaming_testbench;
  [%expect {| (Result (res 969)) |}] 
;;
