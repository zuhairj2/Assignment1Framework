(define (problem grab-all-to-r1)
   (:domain rooms)
   (:objects c1 - character
             red-ball vase green-block - item
             the-key - key
			 r1 hw1 hw2 hw3 r2 r3 - room)


(:init
(connected r1 hw1)
(connected hw1 r1)
(connected hw1 hw2)
(connected hw2 hw1)
(connected hw2 hw3)
(connected hw3 hw2)
(connected hw3 r2)
(connected r2 hw3)
(locked-door r3 hw3)
(locked-door hw3 r3)
(is-key the-key r3 hw3)
(is-key the-key hw3 r3)
(in red-ball r3)
(in vase r2)
(in the-key r2)
(in green-block r2)
(at c1 r1)
(free-hand c1)
)


(:goal (forall (?i - item) (in ?i r1)))


)


