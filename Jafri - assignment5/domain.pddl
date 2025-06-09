(define (domain rooms)
  (:requirements :adl :typing)
  (:types key item - holdable 
          character room
         )

(:predicates 
(at ?c - character ?r - room)
(connected ?a - room ?b - room)
(in ?i - holdable ?r - room)
(holds ?c - character ?i - holdable)
(free-hand ?c - character)
(locked-door ?from - room ?to - room)
(is-key ?k - key ?from - room ?to - room))

(:action move
  :parameters (?who - character ?from - room ?to - room )
  :precondition (and (at ?who ?from) (connected ?from ?to))
  :effect (and (not (at ?who ?from))
               (at ?who ?to)))
			   
(:action pick-up
  :parameters (?who - character ?at - room ?what - holdable)
  :precondition (and (free-hand ?who)
                     (at ?who ?at)
					 (in ?what ?at))
  :effect (and (not (free-hand ?who))
               (not (in ?what ?at))
			   (holds ?who ?what)))
			   
(:action drop
  :parameters (?who - character ?at - room ?what - holdable)
  :precondition (and (holds ?who ?what)
                     (at ?who ?at))
  :effect (and (free-hand ?who)
               (in ?what ?at)
			   (not (holds ?who ?what))))

(:action unlock
  :parameters (?who - character ?from - room ?to - room ?key - key)
  :precondition (and (locked-door ?from ?to)
                     (is-key ?key ?from ?to)
                     (holds ?who ?key)
                     (at ?who ?from))
  :effect (and (not (holds ?who ?key))
               (free-hand ?who)
               (not (locked-door ?from ?to))
               (not (locked-door ?to ?from))
               (connected ?from ?to)
               (connected ?to ?from))
)

)
  
  
