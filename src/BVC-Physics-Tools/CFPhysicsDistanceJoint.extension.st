Extension { #name : 'CFPhysicsDistanceJoint' }

{ #category : '*bvc-physics-tools' }
CFPhysicsDistanceJoint >> physicsOverlayWorldPoints [
	^ self endpointPair worldPoints
]

{ #category : '*bvc-physics-tools' }
CFPhysicsDistanceJoint >> inspectInPhysicsOverlay: anInspector [
	anInspector inspect: self usingContent: CFPhysicsJointInspectorContent newContent
]

{ #category : '*bvc-physics-tools' }
CFPhysicsDistanceJoint >> updatePhysicsOverlayVisual: aVisual from: firstPoint to: secondPoint worldPoints: worldPoints [
	| distance |
	distance := (worldPoints second - worldPoints first) r.
	distance isZero
		ifTrue: [ aVisual hideRestLengthMarker ]
		ifFalse: [
			aVisual
				showRestLengthMarkerAtFraction: self length / distance
				from: firstPoint
				to: secondPoint ]
]

{ #category : '*bvc-physics-tools' }
CFPhysicsDistanceJoint >> addPhysicsOverlayInspectorGroupsTo: anInspectorContent [
	anInspectorContent addGroup: 'Distance' fields: {
		#length -> 'Length'.
		#currentLength -> 'Current length'.
		#springEnabled -> 'Spring enabled'.
		#hertz -> 'Hertz'.
		#dampingRatio -> 'Damping ratio'.
		#limitsEnabled -> 'Limits enabled'.
		#minimumLength -> 'Minimum length'.
		#maximumLength -> 'Maximum length'.
		#motorEnabled -> 'Motor enabled'.
		#motorSpeed -> 'Motor speed'.
		#maximumMotorForce -> 'Maximum motor force'.
		#impulse -> 'Spring/rigid impulse'.
		#lowerLimitImpulse -> 'Lower limit impulse'.
		#upperLimitImpulse -> 'Upper limit impulse'.
		#motorImpulse -> 'Motor impulse' }
]

{ #category : '*bvc-physics-tools' }
CFPhysicsDistanceJoint >> refreshPhysicsOverlayInspector: anInspectorContent [
	| points |
	points := self endpointPair worldPoints.
	anInspectorContent
		diagnosticNumber: self length at: #length;
		diagnosticNumber: self currentLength at: #currentLength;
		text: self springEnabled printString at: #springEnabled;
		diagnosticNumber: self hertz at: #hertz;
		diagnosticNumber: self dampingRatio at: #dampingRatio;
		text: self limitsEnabled printString at: #limitsEnabled;
		diagnosticNumber: self minimumLength at: #minimumLength;
		diagnosticNumber: self maximumLength at: #maximumLength;
		text: self motorEnabled printString at: #motorEnabled;
		diagnosticNumber: self motorSpeed at: #motorSpeed;
		diagnosticNumber: self maximumMotorForce at: #maximumMotorForce;
		diagnosticNumber: self impulse at: #impulse;
		diagnosticNumber: self lowerLimitImpulse at: #lowerLimitImpulse;
		diagnosticNumber: self upperLimitImpulse at: #upperLimitImpulse;
		diagnosticNumber: self motorImpulse at: #motorImpulse
]
