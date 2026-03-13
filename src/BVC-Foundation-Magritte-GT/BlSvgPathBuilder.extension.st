Extension {
	#name : 'BlSvgPathBuilder'
}

{ #category : '*BVC-Foundation-Magritte-GT' }
BlSvgPathBuilder >> ellipticalArc: r xrot: xrot large: large sweep: sweep to: pt [
	self addSegment: ((BlSvgPathEllipticalArcSegment absolute: absolute)
		radii: r;
		xAxisRotation: xrot;
		largeArcFlag: large ~= 0;
		sweepFlag: sweep ~= 0;
		arcTo: pt;
		yourself)
]

{ #category : '*BVC-Foundation-Magritte-GT' }
BlSvgPathBuilder >> reflectedCurveTo: aPoint [
	| aPreviousQuadraticBezierSegment |
	aPreviousQuadraticBezierSegment := segments
		ifEmpty: [ nil ]
		ifNotEmpty: [ :theSegments |
			| aLastSegment |
			aLastSegment := theSegments last.
			((aLastSegment isKindOf: BlSvgPathQuadraticBezierSegment)
				or: [ aLastSegment isKindOf: BlSvgPathReflectedQuadraticBezierSegment ])
				ifTrue: [ aLastSegment ]
				ifFalse: [ nil ] ].

	self addSegment: ((BlSvgPathReflectedQuadraticBezierSegment absolute: absolute)
		previousQuadraticBezierSegment: aPreviousQuadraticBezierSegment;
		curveTo: aPoint;
		yourself)
]
