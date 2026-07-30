Extension { #name : 'CFPhysicsRevoluteJoint' }

{ #category : '*bvc-foundation-physics-tools' }
CFPhysicsRevoluteJoint >> inspectInPhysicsOverlay: anInspector [
	anInspector inspect: self usingContent: CFPhysicsJointInspectorContent newContent
]
