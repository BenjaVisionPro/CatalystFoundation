Class {
	#name : 'CFPhysicsContainmentConstraint',
	#superclass : 'Object',
	#instVars : [ 'body', 'margin', 'restitution', 'active' ],
	#category : 'BVC-Foundation-Physics-Core',
	#package : 'BVC-Foundation-Physics-Core'
}

{ #category : 'instance creation' }
CFPhysicsContainmentConstraint class >> on: aBodyState [
	^ self new
		body: aBodyState;
		yourself
]

{ #category : 'initialization' }
CFPhysicsContainmentConstraint >> initialize [
	super initialize.
	margin := 0.0.
	restitution := 0.0.
	active := true
]

{ #category : 'accessing' }
CFPhysicsContainmentConstraint >> body [ ^ body ]

{ #category : 'accessing' }
CFPhysicsContainmentConstraint >> body: aBodyState [ body := aBodyState ]

{ #category : 'configuration' }
CFPhysicsContainmentConstraint >> margin [ ^ margin ]

{ #category : 'configuration' }
CFPhysicsContainmentConstraint >> margin: aNumber [ margin := aNumber asFloat max: 0.0 ]

{ #category : 'configuration' }
CFPhysicsContainmentConstraint >> restitution [ ^ restitution ]

{ #category : 'configuration' }
CFPhysicsContainmentConstraint >> restitution: aNumber [
	restitution := (aNumber asFloat max: 0.0) min: 1.0
]

{ #category : 'testing' }
CFPhysicsContainmentConstraint >> isActive [ ^ active ]

{ #category : 'stepping' }
CFPhysicsContainmentConstraint >> prepareForBounds: aRectangle [
	active ifFalse: [ ^ self ].
	body applyContainmentConstraint: self bounds: aRectangle
]

{ #category : 'stepping' }
CFPhysicsContainmentConstraint >> applyToDynamicBodyInBounds: aRectangle [
	| minimum maximum bodyBounds position velocity correctedX correctedY velocityX velocityY |
	minimum := aRectangle origin + (margin @ margin).
	maximum := aRectangle corner - (margin @ margin).
	maximum x < minimum x ifTrue: [ maximum := minimum x @ maximum y ].
	maximum y < minimum y ifTrue: [ maximum := maximum x @ minimum y ].
	bodyBounds := body aabb.
	position := body position.
	velocity := body velocity.
	correctedX := position x + ((minimum x - bodyBounds minimum x) max: 0.0)
		+ ((maximum x - bodyBounds maximum x) min: 0.0).
	correctedY := position y + ((minimum y - bodyBounds minimum y) max: 0.0)
		+ ((maximum y - bodyBounds maximum y) min: 0.0).
	velocityX := velocity x.
	velocityY := velocity y.
	(bodyBounds minimum x < minimum x and: [ velocityX < 0 ]) ifTrue: [
		velocityX := velocityX negated * restitution ].
	(bodyBounds maximum x > maximum x and: [ velocityX > 0 ]) ifTrue: [
		velocityX := velocityX negated * restitution ].
	(bodyBounds minimum y < minimum y and: [ velocityY < 0 ]) ifTrue: [
		velocityY := velocityY negated * restitution ].
	(bodyBounds maximum y > maximum y and: [ velocityY > 0 ]) ifTrue: [
		velocityY := velocityY negated * restitution ].
	(correctedX ~= position x or: [ correctedY ~= position y ]) ifTrue: [
		body translateBy: (correctedX @ correctedY) - position.
		body velocity: velocityX @ velocityY.
		body wake ]
]

{ #category : 'controlling' }
CFPhysicsContainmentConstraint >> release [ active := false ]
