Extension { #name : 'CFPhysicsRailJoint' }

{ #category : '*bvc-foundation-physics-tools' }
CFPhysicsRailJoint >> inspectInPhysicsOverlay: anInspector [
	anInspector inspect: self usingContent: CFPhysicsJointInspectorContent newContent
]

{ #category : '*bvc-foundation-physics-tools' }
CFPhysicsRailJoint >> updatePhysicsOverlayVisual: aVisual from: firstPoint to: secondPoint worldPoints: worldPoints [
	aVisual hideRestLengthMarker
]

