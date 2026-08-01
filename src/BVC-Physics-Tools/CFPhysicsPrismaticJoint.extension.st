Extension { #name : 'CFPhysicsPrismaticJoint' }

{ #category : '*bvc-physics-tools' }
CFPhysicsPrismaticJoint >> physicsOverlayWorldPoints [
	^ self endpointPair worldPoints
]

{ #category : '*bvc-physics-tools' }
CFPhysicsPrismaticJoint >> inspectInPhysicsOverlay: anInspector [
	anInspector inspect: self usingContent: CFPhysicsJointInspectorContent newContent
]

{ #category : '*bvc-physics-tools' }
CFPhysicsPrismaticJoint >> updatePhysicsOverlayVisual: aVisual from: firstPoint to: secondPoint worldPoints: worldPoints [
	| axisStart axisEnd displayedAxis railStart railEnd normal lowerPoint upperPoint tickHalfLength |
	aVisual hideRestLengthMarker.
	axisStart := aVisual context overlayPointFromWorld: worldPoints second.
	axisEnd := aVisual context overlayPointFromWorld: worldPoints second + self axis.
	displayedAxis := axisEnd - axisStart.
	displayedAxis r isZero ifTrue: [ ^ aVisual hideRail ].
	displayedAxis := displayedAxis / displayedAxis r.
	self limitsEnabled
		ifTrue: [
			railStart := secondPoint + (displayedAxis * (self referenceTranslation + self lowerTranslation)).
			railEnd := secondPoint + (displayedAxis * (self referenceTranslation + self upperTranslation)) ]
		ifFalse: [
			railStart := secondPoint - (displayedAxis * 60.0).
			railEnd := secondPoint + (displayedAxis * 60.0) ].
	aVisual showRailFrom: railStart to: railEnd.
	self limitsEnabled ifFalse: [
		aVisual lowerLimitMarker visibility: BlVisibility gone.
		aVisual upperLimitMarker visibility: BlVisibility gone.
		^ self ].
	normal := displayedAxis y negated @ displayedAxis x.
	tickHalfLength := 6.0.
	lowerPoint := secondPoint + (displayedAxis * (self referenceTranslation + self lowerTranslation)).
	upperPoint := secondPoint + (displayedAxis * (self referenceTranslation + self upperTranslation)).
	aVisual
		showRailLimitFrom: lowerPoint - (normal * tickHalfLength)
		to: lowerPoint + (normal * tickHalfLength)
		on: aVisual lowerLimitMarker.
	aVisual
		showRailLimitFrom: upperPoint - (normal * tickHalfLength)
		to: upperPoint + (normal * tickHalfLength)
		on: aVisual upperLimitMarker
]

{ #category : '*bvc-physics-tools' }
CFPhysicsPrismaticJoint >> addPhysicsOverlayInspectorGroupsTo: anInspectorContent [
	anInspectorContent
		addGroup: 'Rail' fields: {
			#axis -> 'Axis'.
			#referenceTranslation -> 'Reference translation'.
			#referenceAngle -> 'Reference angle' };
		addGroup: 'Limits' fields: {
			#limitsEnabled -> 'Enabled'.
			#lowerTranslation -> 'Lower translation'.
			#upperTranslation -> 'Upper translation' };
		addGroup: 'Solver' fields: {
			#accumulatedPerpendicularImpulse -> 'Perpendicular impulse'.
			#accumulatedAngularImpulse -> 'Angular impulse' }
]

{ #category : '*bvc-physics-tools' }
CFPhysicsPrismaticJoint >> refreshPhysicsOverlayInspector: anInspectorContent [
	anInspectorContent
		diagnosticPoint: self axis at: #axis;
		diagnosticNumber: self referenceTranslation at: #referenceTranslation;
		diagnosticNumber: self referenceAngle at: #referenceAngle;
		text: self limitsEnabled printString at: #limitsEnabled;
		diagnosticNumber: self lowerTranslation at: #lowerTranslation;
		diagnosticNumber: self upperTranslation at: #upperTranslation;
		diagnosticNumber: self accumulatedPerpendicularImpulse at: #accumulatedPerpendicularImpulse;
		diagnosticNumber: self accumulatedAngularImpulse at: #accumulatedAngularImpulse
]

