(define (problem bring-ball-to-r1)
   (:domain rooms)
   (:objects c1 - character
             ball - item
			 r1 r2 r3 - room)


(:init
(connected r1 r2)
(connected r2 r1)
(connected r2 r3)
(connected r3 r2)
(in ball r3)
(at c1 r1)
(free-hand c1)
)


(:goal (in ball r1))

)


