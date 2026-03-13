Extension { #name : 'BlSvgPathQuadraticBezierSegment' }

{ #category : '*BVC-Foundation-Magritte-GT' }
BlSvgPathQuadraticBezierSegment >> isQuadraticBezier [
	^ true
]

{ #category : '*BVC-Foundation-Magritte-GT' }
BlSvgPathQuadraticBezierSegment >> lastControlPointForFollowingCurrentPoint: aCurrentPoint [
	^ self isAbsolute
		ifTrue: [ self viaPoint ]
		ifFalse: [ (aCurrentPoint - self curveTo) + self viaPoint ]
]
