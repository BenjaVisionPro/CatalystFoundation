Extension { #name : 'CFPhysicsDistanceJoint' }

{ #category : '*bvc-physics-tools' }
CFPhysicsDistanceJoint >> physicsOverlayWorldPoints [
	^ self endpointPair worldPoints
]

{ #category : '*bvc-physics-tools' }
CFPhysicsDistanceJoint >> inspectInPhysicsOverlay: anInspector [
	anInspector inspect: self usingContent: CFPhysicsJointInspectorContent newContent
]

{ #category : '*bvc-physics-tools' }
CFPhysicsDistanceJoint >> updatePhysicsOverlayVisual: aVisual from: firstPoint to: secondPoint worldPoints: worldPoints [
	| distance |
	distance := (worldPoints second - worldPoints first) r.
	distance isZero
		ifTrue: [ aVisual hideRestLengthMarker ]
		ifFalse: [
			aVisual
				showRestLengthMarkerAtFraction: self length / distance
				from: firstPoint
				to: secondPoint ]
]

{ #category : '*bvc-physics-tools' }
CFPhysicsDistanceJoint >> addPhysicsOverlayInspectorGroupsTo: anInspectorContent [
	anInspectorContent addGroup: 'Distance' fields: {
		#length -> 'Length'.
		#currentLength -> 'Current length'.
		#springEnabled -> 'Spring enabled'.
		#hertz -> 'Hertz'.
		#dampingRatio -> 'Damping ratio'.
		#impulse -> 'Impulse' }
]

{ #category : '*bvc-physics-tools' }
CFPhysicsDistanceJoint >> refreshPhysicsOverlayInspector: anInspectorContent [
	| points |
	points := self endpointPair worldPoints.
	anInspectorContent
		diagnosticNumber: self length at: #length;
		diagnosticNumber: (points second - points first) r at: #currentLength;
		text: self springEnabled printString at: #springEnabled;
		diagnosticNumber: self hertz at: #hertz;
		diagnosticNumber: self dampingRatio at: #dampingRatio;
		diagnosticNumber: self impulse at: #impulse
]

