Extension { #name : 'CFPhysicsFilterJoint' }

{ #category : '*bvc-physics-tools' }
CFPhysicsFilterJoint >> addPhysicsOverlayInspectorGroupsTo: anInspectorContent [
	anInspectorContent addGroup: 'Filter' fields: { #solverConstraint -> 'Solver constraint' }
]

{ #category : '*bvc-physics-tools' }
CFPhysicsFilterJoint >> inspectInPhysicsOverlay: anInspector [
	anInspector inspect: self usingContent: CFPhysicsJointInspector newContent
]

{ #category : '*bvc-physics-tools' }
CFPhysicsFilterJoint >> physicsOverlayWorldPoints [
	^ { self bodyA worldBodyOrigin. self bodyB worldBodyOrigin }
]

{ #category : '*bvc-physics-tools' }
CFPhysicsFilterJoint >> refreshPhysicsOverlayInspector: anInspectorContent [
	anInspectorContent text: 'None' at: #solverConstraint
]

{ #category : '*bvc-physics-tools' }
CFPhysicsFilterJoint >> updatePhysicsOverlayVisual: aVisual from: firstPoint to: secondPoint worldPoints: worldPoints [
	aVisual
		hideRestLengthMarker;
		hideRail;
		hideRevoluteDecoration
]
