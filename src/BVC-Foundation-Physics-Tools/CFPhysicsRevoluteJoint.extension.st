Extension { #name : 'CFPhysicsRevoluteJoint' }

{ #category : '*bvc-foundation-physics-tools' }
CFPhysicsRevoluteJoint >> inspectInPhysicsOverlay: anInspector [
	anInspector inspect: self usingContent: CFPhysicsJointInspectorContent newContent
]

{ #category : '*bvc-foundation-physics-tools' }
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
		overlayPointFromWorld: pivotWorld + (referenceWorldAngle cos @ referenceWorldAngle sin)) -
		(aVisual context overlayPointFromWorld: pivotWorld).
	referenceDirection r isZero ifTrue: [ ^ aVisual hideRevoluteDecoration ].
	referenceDirection := referenceDirection / referenceDirection r.
	radius := 28.0.
	referenceEnd := pivotPoint + (referenceDirection * radius).
	aVisual showReferenceRayFrom: pivotPoint to: referenceEnd.
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
