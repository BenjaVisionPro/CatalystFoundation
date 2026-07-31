Class {
	#name : 'CFPhysicsContactVisualState',
	#superclass : 'Object',
	#instVars : [ 'key', 'firstBody', 'normal', 'firstPoint', 'secondPoint', 'firstSeparation', 'secondSeparation', 'pointCount' ],
	#category : 'BVC-Physics-Core',
	#package : 'BVC-Physics-Core'
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
		firstSeparation := points first separation ].
	pointCount > 1 ifTrue: [
		secondPoint := points second position.
		secondSeparation := points second separation ].
	^ self
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
CFPhysicsContactVisualState >> firstSeparation [ ^ firstSeparation ]
{ #category : 'accessing' }
CFPhysicsContactVisualState >> secondSeparation [ ^ secondSeparation ]
