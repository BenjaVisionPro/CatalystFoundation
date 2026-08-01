Extension { #name : 'CFPhysicsMouseJoint' }

{ #category : '*bvc-physics-tools' }
CFPhysicsMouseJoint >> physicsOverlayWorldPoints [
	^ {
		target.
		bodyB worldPointForBodyLocalPoint: localAnchorB }
]

{ #category : '*bvc-physics-tools' }
CFPhysicsMouseJoint >> inspectInPhysicsOverlay: anInspector [
	anInspector inspect: self usingContent: CFPhysicsJointInspectorContent newContent
]

{ #category : '*bvc-physics-tools' }
CFPhysicsMouseJoint >> updatePhysicsOverlayVisual: aVisual from: firstPoint to: secondPoint worldPoints: worldPoints [
	aVisual
		hideRestLengthMarker;
		hideRail;
		hideRevoluteDecoration
]

{ #category : '*bvc-physics-tools' }
CFPhysicsMouseJoint >> addPhysicsOverlayInspectorGroupsTo: anInspectorContent [
	anInspectorContent
		addGroup: 'Mouse' fields: {
			#target -> 'Target'.
			#hertz -> 'Hertz'.
			#dampingRatio -> 'Damping ratio'.
			#maximumForce -> 'Maximum force' };
		addGroup: 'Solver' fields: {
			#linearImpulse -> 'Linear impulse'.
			#angularImpulse -> 'Angular impulse' }
]

{ #category : '*bvc-physics-tools' }
CFPhysicsMouseJoint >> refreshPhysicsOverlayInspector: anInspectorContent [
	anInspectorContent
		diagnosticPoint: self target at: #target;
		diagnosticNumber: self hertz at: #hertz;
		diagnosticNumber: self dampingRatio at: #dampingRatio;
		diagnosticNumber: self maximumForce at: #maximumForce;
		diagnosticPoint: self linearImpulse at: #linearImpulse;
		diagnosticNumber: self angularImpulse at: #angularImpulse
]
