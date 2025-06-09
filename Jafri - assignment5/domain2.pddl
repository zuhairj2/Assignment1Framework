(define (domain rooms-two-hands)
  (:requirements :adl :typing)

  (:types
    key item      - holdable
    character
    room
    hand
  )

  (:predicates
    ;; Agent location
    (at ?who - character ?r - room)

    ;; Bidirectional adjacency between rooms will be declared in the problem files
    (connected ?a - room ?b - room)

    ;; “?i is in ?r” (for both keys and items)
    (in ?i - holdable ?r - room)

    ;; “?c holds ?i with hand ?h”
    (holds ?c - character ?h - hand ?i - holdable)

    ;; “?c’s specific hand ?h is free”
    (free-hand ?c - character ?h - hand)

    ;; Locked‐door (used in Problem 7, not here)
    (locked-door ?from - room ?to - room)

    ;; Which key opens which locked door
    (is-key ?k - key ?from - room ?to - room)
  )

  ;; ----------------------------------------------------------------------------
  ;; ACTION: move
  ;;   Move the agent from one room to a connected room (no locking check by default).
  ;;   (When a door is locked, Problem 7 will handle unlocking first.)
  ;; ----------------------------------------------------------------------------
  (:action move
    :parameters (?who - character ?from - room ?to - room)
    :precondition (and
      (at ?who ?from)
      (connected ?from ?to)
    )
    :effect (and
      (not (at ?who ?from))
      (at ?who ?to)
    )
  )

  ;; ----------------------------------------------------------------------------
  ;; ACTION: pick-up
  ;;   Requires: (free-hand ?who ?h), agent and item are in the same room.
  ;; ----------------------------------------------------------------------------
  (:action pick-up
    :parameters (?who - character ?at - room ?what - holdable ?h - hand)
    :precondition (and
      (free-hand ?who ?h)
      (at ?who ?at)
      (in ?what ?at)
    )
    :effect (and
      (not (free-hand ?who ?h))
      (not (in ?what ?at))
      (holds ?who ?h ?what)
    )
  )

  ;; ----------------------------------------------------------------------------
  ;; ACTION: drop
  ;;   Requires: agent holds the item with hand h, agent is in same room.
  ;; ----------------------------------------------------------------------------
  (:action drop
    :parameters (?who - character ?at - room ?what - holdable ?h - hand)
    :precondition (and
      (holds ?who ?h ?what)
      (at ?who ?at)
    )
    :effect (and
      (free-hand ?who ?h)
      (in ?what ?at)
      (not (holds ?who ?h ?what))
    )
  )

  ;; ----------------------------------------------------------------------------
  ;; ACTION: unlock-door
  ;;   Requires: agent holds the correct key in hand ?h, is at “from,” and that door is locked.
  ;;   Effect: remove locked-door, add bidirectional “connected” so move can pass both ways.
  ;; ----------------------------------------------------------------------------
  (:action unlock-door
    :parameters (?who - character ?from - room ?to - room ?k - key ?h - hand)
    :precondition (and
      (holds ?who ?h ?k)
      (at ?who ?from)
      (locked-door ?from ?to)
      (is-key ?k ?from ?to)
    )
    :effect (and
      (not (locked-door ?from ?to))
      (connected ?from ?to)
      (connected ?to ?from)
    )
  )
)
