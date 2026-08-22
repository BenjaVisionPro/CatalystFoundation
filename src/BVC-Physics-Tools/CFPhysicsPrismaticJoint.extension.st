Extension { #name : 'CFPhysicsPrismaticJoint' }

{ #category : '*bvc-physics-tools' }
CFPhysicsPrismaticJoint >> addPhysicsOverlayInspectorGroupsTo: content [
	content
		addGroup: 'Prismatic' fields: { #localAxisA -> 'Local axis A'. #referenceAngle -> 'Reference angle' };
		addGroup: 'Spring' fields: { #springEnabled -> 'Enabled'. #targetTranslation -> 'Target translation'. #hertz -> 'Hertz'. #dampingRatio -> 'Damping ratio' };
		addGroup: 'Limits' fields: { #limitsEnabled -> 'Enabled'. #lowerTranslation -> 'Lower translation'. #upperTranslation -> 'Upper translation' };
		addGroup: 'Motor' fields: { #motorEnabled -> 'Enabled'. #motorSpeed -> 'Speed'. #maximumMotorForce -> 'Maximum force' };
		addGroup: 'Solver' fields: { #perpendicularImpulse -> 'Perpendicular impulse'. #angularImpulse -> 'Angular impulse'. #springImpulse -> 'Spring impulse'. #lowerLimitImpulse -> 'Lower impulse'. #upperLimitImpulse -> 'Upper impulse'. #motorImpulse -> 'Motor impulse' }
]

{ #category : '*bvc-physics-tools' }
CFPhysicsPrismaticJoint >> inspectInPhysicsOverlay: anInspector [ anInspector inspect: self usingContent: CFPhysicsJointInspector newContent
]

{ #category : '*bvc-physics-tools' }
CFPhysicsPrismaticJoint >> physicsOverlayWorldAxis [
	^ self bodyA ifNil: [ self localAxisA ] ifNotNil: [ :body | body worldVectorForBodyLocalVector: self localAxisA ]
]

{ #category : '*bvc-physics-tools' }
CFPhysicsPrismaticJoint >> physicsOverlayWorldPoints [ ^ self endpointPair worldPoints
]

{ #category : '*bvc-physics-tools' }
CFPhysicsPrismaticJoint >> refreshPhysicsOverlayInspector: content [
	content
		diagnosticPoint: self localAxisA at: #localAxisA;
		diagnosticNumber: self referenceAngle at: #referenceAngle;
		text: self springEnabled printString at: #springEnabled;
		diagnosticNumber: self targetTranslation at: #targetTranslation;
		diagnosticNumber: self hertz at: #hertz;
		diagnosticNumber: self dampingRatio at: #dampingRatio;
		text: self limitsEnabled printString at: #limitsEnabled;
		diagnosticNumber: self lowerTranslation at: #lowerTranslation;
		diagnosticNumber: self upperTranslation at: #upperTranslation;
		text: self motorEnabled printString at: #motorEnabled;
		diagnosticNumber: self motorSpeed at: #motorSpeed;
		diagnosticNumber: self maximumMotorForce at: #maximumMotorForce;
		diagnosticNumber: self perpendicularImpulse at: #perpendicularImpulse;
		diagnosticNumber: self angularImpulse at: #angularImpulse;
		diagnosticNumber: self springImpulse at: #springImpulse;
		diagnosticNumber: self lowerLimitImpulse at: #lowerLimitImpulse;
		diagnosticNumber: self upperLimitImpulse at: #upperLimitImpulse;
		diagnosticNumber: self motorImpulse at: #motorImpulse
]

{ #category : '*bvc-physics-tools' }
CFPhysicsPrismaticJoint >> updatePhysicsOverlayVisual: visual from: firstPoint to: secondPoint worldPoints: worldPoints [
	| axisStart axisEnd displayedAxis railStart railEnd normal lowerPoint upperPoint tickHalfLength |
	visual hideRestLengthMarker.
	axisStart := visual context overlayPointFromWorld: worldPoints first.
	axisEnd := visual context overlayPointFromWorld: worldPoints first + self physicsOverlayWorldAxis.
	displayedAxis := axisEnd - axisStart.
	displayedAxis r isZero ifTrue: [ ^ visual hideRail ].
	displayedAxis := displayedAxis / displayedAxis r.
	self limitsEnabled
		ifTrue: [ railStart := firstPoint + (displayedAxis * self lowerTranslation). railEnd := firstPoint + (displayedAxis * self upperTranslation) ]
		ifFalse: [ railStart := firstPoint - (displayedAxis * 60.0). railEnd := firstPoint + (displayedAxis * 60.0) ].
	visual showRailFrom: railStart to: railEnd.
	self limitsEnabled ifFalse: [ visual lowerLimitMarker visibility: BlVisibility gone. visual upperLimitMarker visibility: BlVisibility gone. ^ self ].
	normal := displayedAxis y negated @ displayedAxis x. tickHalfLength := 6.0.
	lowerPoint := firstPoint + (displayedAxis * self lowerTranslation).
	upperPoint := firstPoint + (displayedAxis * self upperTranslation).
	visual showRailLimitFrom: lowerPoint - (normal * tickHalfLength) to: lowerPoint + (normal * tickHalfLength) on: visual lowerLimitMarker.
	visual showRailLimitFrom: upperPoint - (normal * tickHalfLength) to: upperPoint + (normal * tickHalfLength) on: visual upperLimitMarker
]
