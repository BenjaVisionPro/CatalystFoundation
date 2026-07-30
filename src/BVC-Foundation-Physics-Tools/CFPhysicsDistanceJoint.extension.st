Extension { #name : 'CFPhysicsDistanceJoint' }

{ #category : '*bvc-foundation-physics-tools' }
CFPhysicsDistanceJoint >> inspectInPhysicsOverlay: anInspector [
	anInspector inspect: self usingContent: CFPhysicsJointInspectorContent newContent
]
