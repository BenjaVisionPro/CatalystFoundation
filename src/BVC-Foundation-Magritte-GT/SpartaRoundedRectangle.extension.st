Extension { #name : 'SpartaRoundedRectangle' }

{ #category : '*BVC-Foundation-Magritte-GT' }
SpartaRoundedRectangle >> insetBy: aNumber [
    "Answer a sparta geometry that is inset from the receiver by delta. delta is a number.
    Geometry becomes smaller if delta is positive"
    <return: #SpartaGeometry>
    | l r t b insetCornerRadii |

    l := self left + aNumber.
    r := left max: self right - aNumber.
    t := self top + aNumber.
    b := top max: self bottom - aNumber.

    insetCornerRadii := SpartaCornerRadii fromArray: {
        (self topLeftRadius - aNumber) max: 0.
        (self topRightRadius - aNumber) max: 0.
        (self bottomRightRadius - aNumber) max: 0.
        (self bottomLeftRadius - aNumber) max: 0 }.

    ^ self class new
        left: l
        top: t
        right: r
        bottom: b
        radii: insetCornerRadii
]
