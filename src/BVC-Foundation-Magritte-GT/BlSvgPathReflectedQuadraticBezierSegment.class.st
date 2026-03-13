Class {
	#name : 'BlSvgPathReflectedQuadraticBezierSegment',
	#superclass : 'BlSvgPathSegment',
	#instVars : [
		'previousQuadraticBezierSegment',
		'curveTo',
		'lastControlPoint'
	],
	#category : 'BVC-Foundation-Magritte-GT',
	#package : 'BVC-Foundation-Magritte-GT'
}

{ #category : 'comparing' }
BlSvgPathReflectedQuadraticBezierSegment >> = anObject [
	self == anObject
		ifTrue: [ ^ true ].
	self class = anObject class
		ifFalse: [ ^ false ].

	^ curveTo = anObject curveTo
		and: [ isAbsolute = anObject isAbsolute
		and: [ previousQuadraticBezierSegment = anObject previousQuadraticBezierSegment ] ]
]

{ #category : 'accessing' }
BlSvgPathReflectedQuadraticBezierSegment >> curveTo [
	^ curveTo
]

{ #category : 'accessing' }
BlSvgPathReflectedQuadraticBezierSegment >> curveTo: anObject [
	curveTo := anObject
]

{ #category : 'executing' }
BlSvgPathReflectedQuadraticBezierSegment >> executeOn: aBuilder [
	| aViaPoint aPreviousRelativeControlPoint |

	aViaPoint := self previousQuadraticBezierSegment
		ifNil: [
			self isAbsolute
				ifTrue: [ aBuilder currentPoint ]
				ifFalse: [ 0 @ 0 ] ]
		ifNotNil: [ :aPreviousQuadraticBezierSegment |
			aPreviousRelativeControlPoint := aBuilder currentPoint
				- (aPreviousQuadraticBezierSegment
					lastControlPointForCurrentPoint: aBuilder currentPoint).
			self isAbsolute
				ifTrue: [ aBuilder currentPoint + aPreviousRelativeControlPoint ]
				ifFalse: [ aPreviousRelativeControlPoint ] ].

	lastControlPoint := self isAbsolute
		ifTrue: [ aViaPoint ]
		ifFalse: [ aBuilder currentPoint + aViaPoint ].

	aBuilder curveVia: aViaPoint to: self curveTo
]

{ #category : 'comparing' }
BlSvgPathReflectedQuadraticBezierSegment >> hash [
	^ curveTo hash
		bitXor: (isAbsolute hash bitXor: previousQuadraticBezierSegment hash)
]

{ #category : 'testing' }
BlSvgPathReflectedQuadraticBezierSegment >> isQuadraticBezier [
	^ true
]

{ #category : 'accessing' }
BlSvgPathReflectedQuadraticBezierSegment >> lastControlPoint [
	^ lastControlPoint
]

{ #category : 'accessing' }
BlSvgPathReflectedQuadraticBezierSegment >> lastControlPointForCurrentPoint: aCurrentPoint [
	^ lastControlPoint ifNil: [ aCurrentPoint ]
]

{ #category : 'printing' }
BlSvgPathReflectedQuadraticBezierSegment >> printOn: aStream [
	aStream
		nextPutAll: 'Reflected quadratic bezier ';
		nextPutAll: self printAbsolute;
		nextPutAll: ' to ';
		print: self curveTo
]

{ #category : 'accessing' }
BlSvgPathReflectedQuadraticBezierSegment >> previousQuadraticBezierSegment [
	^ previousQuadraticBezierSegment
]

{ #category : 'accessing' }
BlSvgPathReflectedQuadraticBezierSegment >> previousQuadraticBezierSegment: anObject [
	previousQuadraticBezierSegment := anObject
]
