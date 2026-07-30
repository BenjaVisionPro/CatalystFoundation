Extension { #name : 'CFPhysicsRevoluteJoint' }

{ #category : '*bvc-foundation-physics-tools' }
CFPhysicsRevoluteJoint >> inspectInPhysicsOverlay: anInspector [
	anInspector inspect: self usingContent: CFPhysicsJointInspectorContent newContent
]

{ #category : '*bvc-foundation-physics-tools' }
CFPhysicsRevoluteJoint >> updatePhysicsOverlayVisual: aVisual from: firstPoint to: secondPoint worldPoints: worldPoints [
	aVisual hideRestLengthMarker
]

