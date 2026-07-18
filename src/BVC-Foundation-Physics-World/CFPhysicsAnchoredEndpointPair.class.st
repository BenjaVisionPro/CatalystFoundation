Class {
	#name : 'CFPhysicsAnchoredEndpointPair',
	#superclass : 'CFPhysicsEndpointPair',
	#instVars : [ 'anchorA', 'anchorB' ],
	#category : 'BVC-Foundation-Physics-World',
	#package : 'BVC-Foundation-Physics-World'
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
CFPhysicsAnchoredEndpointPair >> worldPointA [
	^ anchorA worldPoint
]

{ #category : 'geometry' }
CFPhysicsAnchoredEndpointPair >> worldPointB [
	^ anchorB worldPoint
]
