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
	| minimum maximum position velocity correctedX correctedY velocityX velocityY |
	(active and: [ body isDynamic ]) ifFalse: [ ^ self ].
	minimum := aRectangle origin + (margin @ margin).
	maximum := aRectangle corner - body extent - (margin @ margin).
	maximum x < minimum x ifTrue: [ maximum := minimum x @ maximum y ].
	maximum y < minimum y ifTrue: [ maximum := maximum x @ minimum y ].
	position := body position.
	velocity := body velocity.
	correctedX := (position x max: minimum x) min: maximum x.
	correctedY := (position y max: minimum y) min: maximum y.
	velocityX := velocity x.
	velocityY := velocity y.
	(position x < minimum x and: [ velocityX < 0 ]) ifTrue: [
		velocityX := velocityX negated * restitution ].
	(position x > maximum x and: [ velocityX > 0 ]) ifTrue: [
		velocityX := velocityX negated * restitution ].
	(position y < minimum y and: [ velocityY < 0 ]) ifTrue: [
		velocityY := velocityY negated * restitution ].
	(position y > maximum y and: [ velocityY > 0 ]) ifTrue: [
		velocityY := velocityY negated * restitution ].
	(correctedX ~= position x or: [ correctedY ~= position y ]) ifTrue: [
		body translateBy: (correctedX @ correctedY) - position.
		body velocity: velocityX @ velocityY.
		body wake ]
]

{ #category : 'controlling' }
CFPhysicsContainmentConstraint >> release [ active := false ]
