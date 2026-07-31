Extension { #name : 'CFPhysicsDistanceJoint' }

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
				showRestLengthMarkerAtFraction: self restLength / distance
				from: firstPoint
				to: secondPoint ]
]

{ #category : '*bvc-physics-tools' }
CFPhysicsDistanceJoint >> addPhysicsOverlayInspectorGroupsTo: anInspectorContent [
	anInspectorContent addGroup: 'Distance' fields: {
		#restLength -> 'Rest length'.
		#currentLength -> 'Current length'.
		#accumulatedImpulse -> 'Accumulated impulse' }
]

{ #category : '*bvc-physics-tools' }
CFPhysicsDistanceJoint >> refreshPhysicsOverlayInspector: anInspectorContent [
	| points |
	points := self endpointPair worldPoints.
	anInspectorContent
		diagnosticNumber: self restLength at: #restLength;
		diagnosticNumber: (points second - points first) r at: #currentLength;
		diagnosticNumber: self accumulatedImpulse at: #accumulatedImpulse
]

