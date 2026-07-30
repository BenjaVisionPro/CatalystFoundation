Extension { #name : 'CFPhysicsDistanceJoint' }

{ #category : '*bvc-foundation-physics-tools' }
CFPhysicsDistanceJoint >> inspectInPhysicsOverlay: anInspector [
	anInspector inspect: self usingContent: CFPhysicsJointInspectorContent newContent
]

{ #category : '*bvc-foundation-physics-tools' }
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

