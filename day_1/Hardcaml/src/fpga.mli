open! Hardcaml

module I : sig
  type 'a t =
    { clock : 'a
    ; clear : 'a
    ; start : 'a
    ; v_in : 'a
    ; v_valid : 'a
    ; v_last : 'a
    }
  [@@deriving hardcaml]
end

module O : sig
  type 'a t =
    { done_ : 'a
    ; result : 'a
    }
  [@@deriving hardcaml]
end

val create : Scope.t -> Signal.t I.t -> Signal.t O.t
val hierarchical : Scope.t -> Signal.t I.t -> Signal.t O.t
