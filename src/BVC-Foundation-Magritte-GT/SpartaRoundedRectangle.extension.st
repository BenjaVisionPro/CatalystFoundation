Extension { #name : 'SpartaRoundedRectangle' }

{ #category : '*BVC-Foundation-Magritte-GT' }
SpartaRoundedRectangle >> insetBy: aNumber [
	"Temporary Foundation probe: keep rounded-rectangle inset geometry concentric
	by moving each corner radius by the same signed inset as the bounds."
	| l r t b insetRadii |

	l := self left + aNumber.
	r := left max: self right - aNumber.
	t := self top + aNumber.
	b := top max: self bottom - aNumber.

	insetRadii := SpartaCornerRadii fromArray: {
		(self topLeftRadius - aNumber) max: 0.
		(self topRightRadius - aNumber) max: 0.
		(self bottomRightRadius - aNumber) max: 0.
		(self bottomLeftRadius - aNumber) max: 0 }.

	^ self class new
		left: l
		top: t
		right: r
		bottom: b
		radii: insetRadii
]
