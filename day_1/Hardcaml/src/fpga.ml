open! Core
open! Hardcaml
open! Hardcaml.Signal
open! Cyclesim_float_ops

(* Combinational integer remainder: signal %: int -> signal *)
let ( %: ) (a : Signal.t) (divisor : int) : Signal.t =
  let rem_width = Int.ceil_log2 (divisor + 1) in
  let rec compute i rem =
    if i < 0 then rem
    else
      let bit = select a ~high:i ~low:i in
      let rem_shift = rem @: bit in
      let divisor_s = of_int_trunc ~width:(width rem_shift) divisor in
      let ge = ~:(rem_shift <: divisor_s) in
      let sub = rem_shift -: divisor_s in
      let rem' = Signal.mux2 ge sub rem_shift in
      compute (i - 1) rem'
  in
  select (compute (width a - 1) (zero rem_width)) ~high:(rem_width - 1) ~low:0


module I = struct
  type 'a t =
    { clock : 'a
    ; clear : 'a
    ; start : 'a
    ; v_in : 'a [@bits 16]
    ; v_valid : 'a
    ; v_last : 'a
    }
  [@@deriving hardcaml]
end

module O = struct
  type 'a t =
    { done_ : 'a
    ; result : 'a [@bits 16]
    }
  [@@deriving hardcaml]
end

module States = struct
  type t =
    | Idle
    | Run
    | Done
  [@@deriving sexp_of, compare ~localize, enumerate]
end

let create _scope ({ clock; clear; start; v_in; v_valid; v_last } : _ I.t) : _ O.t =
  let spec = Reg_spec.create ~clock ~clear () in
  let open Always in
  let sm = State_machine.create (module States) spec in

  let hits = Variable.reg spec ~width:16 in
  let done_ = Variable.wire ~default:gnd () in

  let rem_width = Int.ceil_log2 (100 + 1) in
  let pos_width = rem_width in
  let sum_width = 16 in

  let pos = Variable.reg spec ~width:pos_width in
  

  compile
    [ sm.switch
        [ ( Idle
          , [ when_
                start
                [ hits <--. 0
                ; pos <--. 50
                ; sm.set_next Run
                ]
            ] )
        ; ( Run
          , [ when_
                v_valid
                [ let actions =
                      (* compute new position = (current_pos + delta) mod 100 *)
                      let pos_ext = (zero (sum_width - pos_width)) @: pos.value in
                      let delta = v_in in
                      let sum = pos_ext +: delta in
                      let rem = sum %: 100 in
                      [ when_ (rem ==: zero rem_width) [ hits <-- hits.value +: of_int_trunc ~width:(width hits.value) 1 ]
                      ; pos <-- rem
                    ; when_ v_last [ sm.set_next Done ]
                    ]
                  in
                  when_ v_valid actions
                ]
            ] )
        ; ( Done
          , [ done_ <-- vdd
            ; when_ start [ sm.set_next Idle ]
            ] )
        ]
    ];

  { done_ = done_.value; result = hits.value }
;;

let hierarchical scope =
  let module Scoped = Hierarchy.In_scope (I) (O) in
  Scoped.hierarchical ~scope ~name:"fpga" create
;;

