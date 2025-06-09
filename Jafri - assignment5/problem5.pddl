(define (problem problem5)
  (:domain rooms)

  (:objects
    agent                         - character
    r1 r2 r3 r4 r5 r6             - room
    hw1 hw2 hw3 hw4               - room
    red-key blue-key green-key    - key
    orb                           - item
  )

  (:init
    ;; Agent starts in room r1
    (at agent r1)

    ;; --- BIDIRECTIONAL “connected” for every hallway (same map) ---
    (connected r1  hw1)  (connected hw1  r1)
    (connected hw1 r2)   (connected r2   hw1)
    (connected hw1 hw2)  (connected hw2  hw1)
    (connected hw2 hw3)  (connected hw3  hw2)
    (connected hw3 r3)   (connected r3   hw3)
    (connected hw3 r4)   (connected r4   hw3)
    (connected hw3 hw4)  (connected hw4  hw3)
    (connected hw4 r5)   (connected r5   hw4)
    (connected r5 r6)    (connected r6   r5)

    ;; Place exactly three keys + the single “orb” in r6:
    (in red-key   r2)  ;; unlocks hw2<->hw3
    (in blue-key  r3)  ;; unlocks hw3<->r4
    (in green-key r4)  ;; unlocks hw3<->hw4
    (in orb       r6)  ;; the one item to bring back

    ;; Three locked-door facts (unidirectional “locked-door” is fine—move checks only “connected”):
    (locked-door hw2 hw3)
    (locked-door hw3 r4)
    (locked-door hw3 hw4)

    ;; Map each key to its lock:
    (is-key red-key   hw2 hw3)
    (is-key blue-key  hw3 r4)
    (is-key green-key hw3 hw4)

    ;; Agent’s hand is free initially
    (free-hand agent)
  )

  (:goal
    ;; Ultimately, we want “orb” in r1
    (in orb r1)
  )
)
