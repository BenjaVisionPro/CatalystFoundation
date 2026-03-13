Extension {
	#name : 'BlSvgPathBuilder'
}

{ #category : '*bvc-foundation-magritte-gt' }
BlSvgPathBuilder >> ellipticalArc: r xrot: xrot large: large sweep: sweep to: pt [
	self addSegment: ((BlSvgPathEllipticalArcSegment absolute: absolute)
		radii: r;
		xAxisRotation: xrot;
		largeArcFlag: large ~= 0;
		sweepFlag: sweep ~= 0;
		arcTo: pt;
		yourself)
]
