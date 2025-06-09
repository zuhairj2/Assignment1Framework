(define (problem problem4)
  (:domain rooms)

  (:objects
    agent           - character
    r1 r2 r3 r4 r5 r6  - room
    hw1 hw2 hw3 hw4    - room
    vase coin lamp scroll orb  - item
  )

  (:init
    ;; Agent starts in room r1
    (at agent r1)

    ;; --- BIDIRECTIONAL “connected” for every hallway ---
    (connected r1  hw1)  (connected hw1  r1)
    (connected hw1 r2)   (connected r2   hw1)
    (connected hw1 hw2)  (connected hw2  hw1)
    (connected hw2 hw3)  (connected hw3  hw2)
    (connected hw3 r3)   (connected r3   hw3)
    (connected hw3 r4)   (connected r4   hw3)
    (connected hw3 hw4)  (connected hw4  hw3)
    (connected hw4 r5)   (connected r5   hw4)
    (connected r5 r6)    (connected r6   r5)

    ;; Place exactly ONE item in each of r2..r6:
    (in vase   r2)
    (in coin   r3)
    (in lamp   r4)
    (in scroll r5)
    (in orb    r6)

    ;; Agent’s hand is free initially:
    (free-hand agent)
  )

  (:goal
    (and
      (in vase   r1)
      (in coin   r1)
      (in lamp   r1)
      (in scroll r1)
      (in orb    r1)
    )
  )
)
