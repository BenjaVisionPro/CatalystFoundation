Class {
	#name : 'CFPhysicsContactVisual',
	#superclass : 'Object',
	#instVars : [ 'context', 'root', 'state', 'contactLine', 'firstPointMarker', 'secondPointMarker', 'firstNormalLine', 'secondNormalLine', 'firstSeparationLine', 'secondSeparationLine' ],
	#category : 'BVC-Physics-Tools',
	#package : 'BVC-Physics-Tools'
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
	state := aState.
	^ self update
]

{ #category : 'updating' }
CFPhysicsContactVisual >> update [
	| first second |
	state ifNil: [ ^ self ].
	state pointCount > 0
		ifTrue: [
			first := context
				overlayPointFromWorld: state firstPoint
				attachedTo: state firstBody.
			self showMarker: firstPointMarker at: first.
			self showLine: firstNormalLine from: first to: (context
				overlayPointFromWorld: state firstPoint + (state normal * 24.0)
				attachedTo: state firstBody).
			self updateSeparationLine: firstSeparationLine from: first to: (context
				overlayPointFromWorld: state firstPoint + (state normal * state firstSeparation)
				attachedTo: state firstBody) separation: state firstSeparation ]
		ifFalse: [ self hideFirstPoint ].
	state pointCount > 1
		ifTrue: [
			second := context
				overlayPointFromWorld: state secondPoint
				attachedTo: state firstBody.
			self showMarker: secondPointMarker at: second.
			self showLine: secondNormalLine from: second to: (context
				overlayPointFromWorld: state secondPoint + (state normal * 24.0)
				attachedTo: state firstBody).
			self updateSeparationLine: secondSeparationLine from: second to: (context
				overlayPointFromWorld: state secondPoint + (state normal * state secondSeparation)
				attachedTo: state firstBody) separation: state secondSeparation.
			self showLine: contactLine from: first to: second ]
		ifFalse: [ self hideSecondPoint. contactLine visibility: BlVisibility gone ].
	^ self
]

{ #category : 'accessing' }
CFPhysicsContactVisual >> state [
	^ state
]

{ #category : 'accessing' }
CFPhysicsContactVisual >> firstPointPosition [
	^ firstPointMarker position + (3 @ 3)
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
CFPhysicsContactVisual >> updateSeparationLine: aLine from: displayedPoint to: separationPoint separation: separation [
	separation isZero ifTrue: [ ^ aLine visibility: BlVisibility gone ].
	aLine border: (BlBorder
		paint: ((separation < 0 ifTrue: [ Color red ] ifFalse: [ Color yellow ]) alpha: 0.8)
		width: 2).
	self showLine: aLine from: displayedPoint to: separationPoint
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
