(define (problem redistribute)
   (:domain rooms)
   (:objects c1 - character
             red-ball vase green-block - item
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
(connected hw3 r3)
(connected r3 hw3)
(in red-ball r3)
(in vase r2)
(in green-block r2)
(at c1 r1)
(free-hand c1)
)


(:goal (and (in vase r1) (in green-block r1) (in red-ball r1)))

)