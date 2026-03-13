Extension {
	#name : 'BlSvgPathQuadraticBezierSegment'
}

{ #category : '*bvc-foundation-magritte-gt' }
BlSvgPathQuadraticBezierSegment >> lastControlPointForCurrentPoint: aCurrentPoint [
	^ self isAbsolute
		ifTrue: [ self viaPoint ]
		ifFalse: [ (aCurrentPoint - self curveTo) + self viaPoint ]
]
