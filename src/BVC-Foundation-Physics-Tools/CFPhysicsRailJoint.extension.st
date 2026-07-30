Extension { #name : 'CFPhysicsRailJoint' }

{ #category : '*bvc-foundation-physics-tools' }
CFPhysicsRailJoint >> inspectInPhysicsOverlay: anInspector [
	anInspector inspect: self usingContent: CFPhysicsJointInspectorContent newContent
]

{ #category : '*bvc-foundation-physics-tools' }
CFPhysicsRailJoint >> updatePhysicsOverlayVisual: aVisual from: firstPoint to: secondPoint worldPoints: worldPoints [
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
