Extension { #name : 'CFPhysicsRevoluteJoint' }

{ #category : '*bvc-physics-tools' }
CFPhysicsRevoluteJoint >> physicsOverlayWorldPoints [
	^ self endpointPair worldPoints
]

{ #category : '*bvc-physics-tools' }
CFPhysicsRevoluteJoint >> inspectInPhysicsOverlay: anInspector [
	anInspector inspect: self usingContent: CFPhysicsJointInspectorContent newContent
]

{ #category : '*bvc-physics-tools' }
CFPhysicsRevoluteJoint >> updatePhysicsOverlayVisual: aVisual from: firstPoint to: secondPoint worldPoints: worldPoints [
	| rotate pivotPoint pivotWorld bodyAAngle referenceWorldAngle referenceDirection referenceEnd radius lowerDirection upperDirection lowerPoint upperPoint lowerInner upperInner startDegrees endDegrees motorDirection motorStart motorEnd |
	rotate := [ :vector :angle |
		((vector x * angle cos) - (vector y * angle sin))
			@ ((vector x * angle sin) + (vector y * angle cos)) ].
	aVisual hideRestLengthMarker.
	aVisual hideRail.
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
	radius := 28.0.
	referenceEnd := pivotPoint + (referenceDirection * radius).
	aVisual
		showReferenceRayFrom: pivotPoint to: referenceEnd;
		showHitTargetFrom: pivotPoint - (referenceDirection * 10.0)
		to: referenceEnd + (referenceDirection * 6.0).
	self limitsEnabled
		ifTrue: [
			lowerDirection := rotate value: referenceDirection value: self lowerAngle.
			upperDirection := rotate value: referenceDirection value: self upperAngle.
			lowerPoint := pivotPoint + (lowerDirection * (radius + 3.0)).
			upperPoint := pivotPoint + (upperDirection * (radius + 3.0)).
			lowerInner := pivotPoint + (lowerDirection * (radius - 5.0)).
			upperInner := pivotPoint + (upperDirection * (radius - 5.0)).
			aVisual
				showAngleLimitFrom: lowerInner to: lowerPoint on: aVisual lowerAngleMarker;
				showAngleLimitFrom: upperInner to: upperPoint on: aVisual upperAngleMarker.
			startDegrees := referenceDirection theta radiansToDegrees + self lowerAngle radiansToDegrees.
			endDegrees := referenceDirection theta radiansToDegrees + self upperAngle radiansToDegrees.
			aVisual showAllowedAngleFromDegrees: startDegrees toDegrees: endDegrees around: pivotPoint ]
		ifFalse: [
			aVisual lowerAngleMarker visibility: BlVisibility gone.
			aVisual upperAngleMarker visibility: BlVisibility gone.
			aVisual allowedAngleArc visibility: BlVisibility gone ].
	self motorEnabled
		ifTrue: [
			motorDirection := self motorSpeed negative ifTrue: [ -0.35 ] ifFalse: [ 0.35 ].
			motorStart := pivotPoint + ((rotate value: referenceDirection value: motorDirection negated) * 20.0).
			motorEnd := pivotPoint + ((rotate value: referenceDirection value: motorDirection) * 20.0).
			aVisual showMotorCueFrom: motorStart to: motorEnd ]
		ifFalse: [ aVisual motorCue visibility: BlVisibility gone ]
]

{ #category : '*bvc-physics-tools' }
CFPhysicsRevoluteJoint >> addPhysicsOverlayInspectorGroupsTo: anInspectorContent [
	anInspectorContent
		addGroup: 'Rotation' fields: {
			#referenceAngle -> 'Reference angle'.
			#accumulatedImpulse -> 'Accumulated impulse' };
		addGroup: 'Limits' fields: {
			#limitsEnabled -> 'Enabled'.
			#lowerAngle -> 'Lower angle'.
			#upperAngle -> 'Upper angle' };
		addGroup: 'Motor' fields: {
			#motorEnabled -> 'Enabled'.
			#motorSpeed -> 'Speed'.
			#maximumMotorImpulse -> 'Maximum impulse'.
			#motorImpulse -> 'Current impulse' }
]

{ #category : '*bvc-physics-tools' }
CFPhysicsRevoluteJoint >> refreshPhysicsOverlayInspector: anInspectorContent [
	anInspectorContent
		diagnosticNumber: self referenceAngle at: #referenceAngle;
		diagnosticPoint: self accumulatedImpulse at: #accumulatedImpulse;
		text: self limitsEnabled printString at: #limitsEnabled;
		diagnosticNumber: self lowerAngle at: #lowerAngle;
		diagnosticNumber: self upperAngle at: #upperAngle;
		text: self motorEnabled printString at: #motorEnabled;
		diagnosticNumber: self motorSpeed at: #motorSpeed;
		diagnosticNumber: self maximumMotorImpulse at: #maximumMotorImpulse;
		diagnosticNumber: self motorImpulse at: #motorImpulse
]

