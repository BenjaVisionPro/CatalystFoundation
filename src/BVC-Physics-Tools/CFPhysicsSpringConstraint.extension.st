Extension { #name : 'CFPhysicsSpringConstraint' }

{ #category : '*bvc-physics-tools' }
CFPhysicsSpringConstraint >> inspectInPhysicsOverlay: anInspector [
	anInspector inspect: self usingContent: CFPhysicsSpringInspectorContent newContent
]
