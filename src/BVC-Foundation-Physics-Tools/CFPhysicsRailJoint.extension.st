Extension { #name : 'CFPhysicsRailJoint' }

{ #category : '*bvc-foundation-physics-tools' }
CFPhysicsRailJoint >> inspectInPhysicsOverlay: anInspector [
	anInspector inspect: self usingContent: CFPhysicsJointInspectorContent newContent
]
