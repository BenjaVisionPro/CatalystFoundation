Extension { #name : 'CFPhysicsWeldJoint' }

{ #category : '*bvc-physics-tools' }
CFPhysicsWeldJoint >> inspectInPhysicsOverlay: anInspector [
	anInspector inspect: self usingContent: CFPhysicsJointInspectorContent newContent
]

{ #category : '*bvc-physics-tools' }
CFPhysicsWeldJoint >> updatePhysicsOverlayVisual: aVisual from: firstPoint to: secondPoint worldPoints: worldPoints [
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
		overlayPointFromWorld: pivotWorld + (referenceWorldAngle cos @ referenceWorldAngle sin)
		attachedTo: self bodyA) -
		(aVisual context overlayPointFromWorld: pivotWorld attachedTo: self bodyA).
	referenceDirection r isZero ifTrue: [ ^ aVisual hideRevoluteDecoration ].
	referenceDirection := referenceDirection / referenceDirection r.
	referenceEnd := pivotPoint + (referenceDirection * 28.0).
	aVisual
		showFixedLockFrom: pivotPoint
		to: referenceEnd
		direction: referenceDirection;
		showHitTargetFrom: pivotPoint - (referenceDirection * 10.0)
		to: referenceEnd + (referenceDirection * 6.0)
]

{ #category : '*bvc-physics-tools' }
CFPhysicsWeldJoint >> addPhysicsOverlayInspectorGroupsTo: anInspectorContent [
	anInspectorContent
		addGroup: 'Fixed' fields: {
			#referenceAngle -> 'Reference angle' };
		addGroup: 'Solver' fields: {
			#accumulatedImpulse -> 'Linear impulse'.
			#accumulatedAngularImpulse -> 'Angular impulse' }
]

{ #category : '*bvc-physics-tools' }
CFPhysicsWeldJoint >> refreshPhysicsOverlayInspector: anInspectorContent [
	anInspectorContent
		diagnosticNumber: self referenceAngle at: #referenceAngle;
		diagnosticPoint: self accumulatedImpulse at: #accumulatedImpulse;
		diagnosticNumber: self accumulatedAngularImpulse at: #accumulatedAngularImpulse
]

