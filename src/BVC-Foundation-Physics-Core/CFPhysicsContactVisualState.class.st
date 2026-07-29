Class {
	#name : 'CFPhysicsContactVisualState',
	#superclass : 'Object',
	#instVars : [ 'key', 'firstBody', 'normal', 'firstPoint', 'secondPoint', 'firstPointInFirstBody', 'secondPointInFirstBody', 'firstNormalPointInFirstBody', 'secondNormalPointInFirstBody', 'firstSeparationPointInFirstBody', 'secondSeparationPointInFirstBody', 'firstSeparation', 'secondSeparation', 'pointCount' ],
	#category : 'BVC-Foundation-Physics-Core',
	#package : 'BVC-Foundation-Physics-Core'
}

{ #category : 'updating' }
CFPhysicsContactVisualState >> updateFrom: aContact [
	| manifold points |
	key := aContact key.
	firstBody := aContact firstBody.
	manifold := aContact manifold.
	normal := manifold normal.
	points := manifold contactPoints.
	pointCount := points size min: 2.
	pointCount > 0 ifTrue: [
		firstPoint := points first position.
		firstSeparation := points first separation.
		firstPointInFirstBody := self localPointForWorldPoint: firstPoint.
		firstNormalPointInFirstBody := self localPointForWorldPoint: firstPoint + (normal * 24.0).
		firstSeparationPointInFirstBody := self localPointForWorldPoint: firstPoint + (normal * firstSeparation) ].
	pointCount > 1 ifTrue: [
		secondPoint := points second position.
		secondSeparation := points second separation.
		secondPointInFirstBody := self localPointForWorldPoint: secondPoint.
		secondNormalPointInFirstBody := self localPointForWorldPoint: secondPoint + (normal * 24.0).
		secondSeparationPointInFirstBody := self localPointForWorldPoint: secondPoint + (normal * secondSeparation) ].
	^ self
]

{ #category : 'private - updating' }
CFPhysicsContactVisualState >> localPointForWorldPoint: aPoint [
	^ firstBody shapeState
		localPointForWorldPoint: aPoint
		position: firstBody position
		rotation: firstBody rotation
]

{ #category : 'accessing' }
CFPhysicsContactVisualState >> key [ ^ key ]
{ #category : 'accessing' }
CFPhysicsContactVisualState >> firstBody [ ^ firstBody ]
{ #category : 'accessing' }
CFPhysicsContactVisualState >> normal [ ^ normal ]
{ #category : 'accessing' }
CFPhysicsContactVisualState >> pointCount [ ^ pointCount ]
{ #category : 'accessing' }
CFPhysicsContactVisualState >> firstPoint [ ^ firstPoint ]
{ #category : 'accessing' }
CFPhysicsContactVisualState >> secondPoint [ ^ secondPoint ]
{ #category : 'accessing' }
CFPhysicsContactVisualState >> firstPointInFirstBody [ ^ firstPointInFirstBody ]
{ #category : 'accessing' }
CFPhysicsContactVisualState >> secondPointInFirstBody [ ^ secondPointInFirstBody ]
{ #category : 'accessing' }
CFPhysicsContactVisualState >> firstNormalPointInFirstBody [ ^ firstNormalPointInFirstBody ]
{ #category : 'accessing' }
CFPhysicsContactVisualState >> secondNormalPointInFirstBody [ ^ secondNormalPointInFirstBody ]
{ #category : 'accessing' }
CFPhysicsContactVisualState >> firstSeparationPointInFirstBody [ ^ firstSeparationPointInFirstBody ]
{ #category : 'accessing' }
CFPhysicsContactVisualState >> secondSeparationPointInFirstBody [ ^ secondSeparationPointInFirstBody ]
{ #category : 'accessing' }
CFPhysicsContactVisualState >> firstSeparation [ ^ firstSeparation ]
{ #category : 'accessing' }
CFPhysicsContactVisualState >> secondSeparation [ ^ secondSeparation ]
