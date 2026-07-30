Extension { #name : 'CFPhysicsFixedJoint' }

{ #category : '*bvc-foundation-physics-tools' }
CFPhysicsFixedJoint >> inspectInPhysicsOverlay: anInspector [
	anInspector inspect: self usingContent: CFPhysicsJointInspectorContent newContent
]
