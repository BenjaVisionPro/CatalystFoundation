Extension { #name : 'CFPhysicsFixedJoint' }

{ #category : '*bvc-foundation-physics-tools' }
CFPhysicsFixedJoint >> inspectInPhysicsOverlay: anInspector [
	anInspector inspect: self usingContent: CFPhysicsJointInspectorContent newContent
]

{ #category : '*bvc-foundation-physics-tools' }
CFPhysicsFixedJoint >> updatePhysicsOverlayVisual: aVisual from: firstPoint to: secondPoint worldPoints: worldPoints [
	aVisual hideRestLengthMarker
]

