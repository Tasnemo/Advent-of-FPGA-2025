open! Core
open! Hardcaml
open! Signal

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

let create scope ({ clock; clear; start; v_in; v_valid; v_last } : _ I.t) : _ O.t =
  let spec = Reg_spec.create ~clock ~clear () in
  let open Always in
  let sm = State_machine.create (module States) spec in

  let hits = Variable.reg spec ~width:16 in
  let g_off = Variable.reg spec ~width:16 in
  let done_ = Variable.wire ~default:gnd () in

  let v_init = signal_of_int 16 50 in

  compile
    [ sm.switch
        [ ( Idle
          , [ when_
                start
                [ hits <--. 0
                ; g_off <--. 0
                ; sm.set_next Run
                ]
            ] )
        ; ( Run
          , [ when_
                v_valid
                [ let n_off = g_off.value +: v_in in
                  let pos = v_init +: n_off in
                  (* Check mod 100 hit *)
                  when_ (pos %: 100 ==: 0) [ hits <-- hits.value +: 1 ];
                  g_off <-- n_off;
                  when_ v_last [ sm.set_next Done ]
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
