Extension { #name : 'CFPhysicsSpringConstraint' }

{ #category : '*bvc-foundation-physics-tools' }
CFPhysicsSpringConstraint >> inspectInPhysicsOverlay: anInspector [
	anInspector inspect: self usingContent: CFPhysicsSpringInspectorContent newContent
]
