Class {
	#name : 'CFPhysicsAnchoredEndpointPair',
	#superclass : 'CFPhysicsEndpointPair',
	#instVars : [ 'anchorA', 'anchorB' ],
	#category : 'BVC-Foundation-Physics-Core',
	#package : 'BVC-Foundation-Physics-Core'
}

{ #category : 'instance creation' }
CFPhysicsAnchoredEndpointPair class >> anchorA: firstAnchor anchorB: secondAnchor [
	^ self new
		anchorA: firstAnchor;
		anchorB: secondAnchor;
		yourself
]

{ #category : 'accessing' }
CFPhysicsAnchoredEndpointPair >> anchorA [
	^ anchorA
]

{ #category : 'accessing' }
CFPhysicsAnchoredEndpointPair >> anchorA: anAnchor [
	anchorA := anAnchor
]

{ #category : 'accessing' }
CFPhysicsAnchoredEndpointPair >> anchorB [
	^ anchorB
]

{ #category : 'accessing' }
CFPhysicsAnchoredEndpointPair >> anchorB: anAnchor [
	anchorB := anAnchor
]

{ #category : 'accessing' }
CFPhysicsAnchoredEndpointPair >> bodyA [
	^ anchorA body
]

{ #category : 'accessing' }
CFPhysicsAnchoredEndpointPair >> bodyB [
	^ anchorB body
]

{ #category : 'geometry' }
CFPhysicsAnchoredEndpointPair >> worldPoints [
	^ { anchorA worldPoint. anchorB worldPoint }
]


{ #category : 'accessing' }
CFPhysicsAnchoredEndpointPair >> world [
	| firstWorld secondWorld |
	firstWorld := anchorA world.
	secondWorld := anchorB world.
	(firstWorld notNil and: [ firstWorld == secondWorld ])
		ifFalse: [ self error: 'Both endpoints must belong to the same physics world' ].
	^ firstWorld
]
