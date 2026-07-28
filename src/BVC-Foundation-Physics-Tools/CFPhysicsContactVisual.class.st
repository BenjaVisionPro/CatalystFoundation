Class {
	#name : 'CFPhysicsContactVisual',
	#superclass : 'Object',
	#instVars : [ 'context', 'root', 'contactLine', 'firstPointMarker', 'secondPointMarker', 'firstNormalLine', 'secondNormalLine', 'firstSeparationLine', 'secondSeparationLine' ],
	#category : 'BVC-Foundation-Physics-Tools',
	#package : 'BVC-Foundation-Physics-Tools'
}

{ #category : 'instance creation' }
CFPhysicsContactVisual class >> in: aRoot context: aContext [
	^ self new root: aRoot; context: aContext; initializeVisual; yourself
]

{ #category : 'private - initialization' }
CFPhysicsContactVisual >> root: anElement [ root := anElement ]
{ #category : 'private - initialization' }
CFPhysicsContactVisual >> context: aContext [ context := aContext ]

{ #category : 'initialization' }
CFPhysicsContactVisual >> initializeVisual [
	contactLine := self newLinePaint: (Color magenta alpha: 0.55) width: 1.
	firstPointMarker := self newPointMarker.
	secondPointMarker := self newPointMarker.
	firstNormalLine := self newLinePaint: (Color green alpha: 0.8) width: 1.
	secondNormalLine := self newLinePaint: (Color green alpha: 0.8) width: 1.
	firstSeparationLine := self newLinePaint: (Color red alpha: 0.8) width: 2.
	secondSeparationLine := self newLinePaint: (Color red alpha: 0.8) width: 2.
	{ contactLine. firstPointMarker. secondPointMarker. firstNormalLine. secondNormalLine. firstSeparationLine. secondSeparationLine }
		do: [ :element | root addChild: element ].
	^ self
]

{ #category : 'private - building' }
CFPhysicsContactVisual >> newPointMarker [
	^ BlElement new
		geometry: BlCircleGeometry new;
		size: 6 @ 6;
		background: (Color magenta alpha: 0.9);
		constraintsDo: [ :c | c ignoreByLayout ];
		preventMeAndChildrenMouseEvents;
		visibility: BlVisibility gone;
		yourself
]

{ #category : 'private - building' }
CFPhysicsContactVisual >> newLinePaint: aPaint width: aNumber [
	^ BlLineElement new
		fromAnchor: (BlAbsolutePositionAnchor position: 0 @ 0);
		toAnchor: (BlAbsolutePositionAnchor position: 0 @ 0);
		border: (BlBorder paint: aPaint width: aNumber);
		constraintsDo: [ :c | c ignoreByLayout ];
		preventMeAndChildrenMouseEvents;
		visibility: BlVisibility gone;
		yourself
]

{ #category : 'updating' }
CFPhysicsContactVisual >> updateFrom: aState [
	| first second normal |
	normal := aState normal.
	aState pointCount > 0
		ifTrue: [
			first := context overlayPointFromWorld: aState firstPoint.
			self showMarker: firstPointMarker at: first.
			self showLine: firstNormalLine from: first to: (context overlayPointFromWorld: aState firstPoint + (normal * 24.0)).
			self updateSeparationLine: firstSeparationLine from: first point: aState firstPoint normal: normal separation: aState firstSeparation ]
		ifFalse: [ self hideFirstPoint ].
	aState pointCount > 1
		ifTrue: [
			second := context overlayPointFromWorld: aState secondPoint.
			self showMarker: secondPointMarker at: second.
			self showLine: secondNormalLine from: second to: (context overlayPointFromWorld: aState secondPoint + (normal * 24.0)).
			self updateSeparationLine: secondSeparationLine from: second point: aState secondPoint normal: normal separation: aState secondSeparation.
			self showLine: contactLine from: first to: second ]
		ifFalse: [ self hideSecondPoint. contactLine visibility: BlVisibility gone ].
	^ self
]

{ #category : 'private - updating' }
CFPhysicsContactVisual >> showMarker: anElement at: aPoint [
	anElement relocate: aPoint - (3 @ 3); visibility: BlVisibility visible
]

{ #category : 'private - updating' }
CFPhysicsContactVisual >> showLine: aLine from: firstPoint to: secondPoint [
	aLine
		fromAnchor: (BlAbsolutePositionAnchor position: firstPoint);
		toAnchor: (BlAbsolutePositionAnchor position: secondPoint);
		visibility: BlVisibility visible
]

{ #category : 'private - updating' }
CFPhysicsContactVisual >> updateSeparationLine: aLine from: displayedPoint point: worldPoint normal: normal separation: separation [
	separation isZero ifTrue: [ ^ aLine visibility: BlVisibility gone ].
	aLine border: (BlBorder
		paint: ((separation < 0 ifTrue: [ Color red ] ifFalse: [ Color yellow ]) alpha: 0.8)
		width: 2).
	self showLine: aLine from: displayedPoint to: (context overlayPointFromWorld: worldPoint + (normal * separation))
]

{ #category : 'private - updating' }
CFPhysicsContactVisual >> hideFirstPoint [
	firstPointMarker visibility: BlVisibility gone.
	firstNormalLine visibility: BlVisibility gone.
	firstSeparationLine visibility: BlVisibility gone
]

{ #category : 'private - updating' }
CFPhysicsContactVisual >> hideSecondPoint [
	secondPointMarker visibility: BlVisibility gone.
	secondNormalLine visibility: BlVisibility gone.
	secondSeparationLine visibility: BlVisibility gone
]

{ #category : 'controlling' }
CFPhysicsContactVisual >> remove [
	{ contactLine. firstPointMarker. secondPointMarker. firstNormalLine. secondNormalLine. firstSeparationLine. secondSeparationLine }
		do: [ :element | element hasParent ifTrue: [ element removeFromParent ] ]
]
