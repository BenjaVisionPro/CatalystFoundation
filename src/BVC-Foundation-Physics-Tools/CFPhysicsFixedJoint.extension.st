Extension { #name : 'CFPhysicsFixedJoint' }

{ #category : '*bvc-foundation-physics-tools' }
CFPhysicsFixedJoint >> inspectInPhysicsOverlay: anInspector [
	anInspector inspect: self usingContent: CFPhysicsJointInspectorContent newContent
]

{ #category : '*bvc-foundation-physics-tools' }
CFPhysicsFixedJoint >> updatePhysicsOverlayVisual: aVisual from: firstPoint to: secondPoint worldPoints: worldPoints [
	| pivotPoint pivotWorld bodyAAngle referenceWorldAngle referenceDirection referenceEnd |
	aVisual
		hideRestLengthMarker;
		hideRail;
		hideRevoluteDecoration.
	pivotPoint := (firstPoint + secondPoint) / 2.0.
	pivotWorld := (worldPoints first + worldPoints second) / 2.0.
	aVisual showPivotAt: pivotPoint.
	bodyAAngle := self bodyA ifNil: [ 0.0 ] ifNotNil: [ :body | body rotation ].
	referenceWorldAngle := bodyAAngle + self referenceAngle.
	referenceDirection := (aVisual context
		overlayPointFromWorld: pivotWorld + (referenceWorldAngle cos @ referenceWorldAngle sin)) -
		(aVisual context overlayPointFromWorld: pivotWorld).
	referenceDirection r isZero ifTrue: [ ^ aVisual hideRevoluteDecoration ].
	referenceDirection := referenceDirection / referenceDirection r.
	referenceEnd := pivotPoint + (referenceDirection * 28.0).
	aVisual
		showFixedLockFrom: pivotPoint
		to: referenceEnd
		direction: referenceDirection
]

{ #category : '*bvc-foundation-physics-tools' }
CFPhysicsFixedJoint >> addPhysicsOverlayInspectorGroupsTo: anInspectorContent [
	anInspectorContent
		addGroup: 'Fixed' fields: {
			#referenceAngle -> 'Reference angle' };
		addGroup: 'Solver' fields: {
			#accumulatedImpulse -> 'Linear impulse'.
			#accumulatedAngularImpulse -> 'Angular impulse' }
]

{ #category : '*bvc-foundation-physics-tools' }
CFPhysicsFixedJoint >> refreshPhysicsOverlayInspector: anInspectorContent [
	anInspectorContent
		diagnosticNumber: self referenceAngle at: #referenceAngle;
		diagnosticPoint: self accumulatedImpulse at: #accumulatedImpulse;
		diagnosticNumber: self accumulatedAngularImpulse at: #accumulatedAngularImpulse
]

