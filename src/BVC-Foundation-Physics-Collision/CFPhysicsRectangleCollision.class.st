Class {
	#name : 'CFPhysicsRectangleCollision',
	#superclass : 'Object',
	#category : 'BVC-Foundation-Physics-Collision',
	#package : 'BVC-Foundation-Physics-Collision'
}

{ #category : 'collision' }
CFPhysicsRectangleCollision class >> contactBetween: firstBody and: secondBody [
	| firstBounds secondBounds overlap firstCentre secondCentre normal penetration |
	firstBounds := firstBody aabb.
	secondBounds := secondBody aabb.
	(firstBounds overlaps: secondBounds) ifFalse: [ ^ nil ].
	overlap := firstBounds overlapWith: secondBounds.
	firstCentre := firstBounds centre.
	secondCentre := secondBounds centre.
	overlap x < overlap y
		ifTrue: [
			normal := (secondCentre x >= firstCentre x)
				ifTrue: [ 1 @ 0 ]
				ifFalse: [ -1 @ 0 ].
			penetration := overlap x ]
		ifFalse: [
			normal := (secondCentre y >= firstCentre y)
				ifTrue: [ 0 @ 1 ]
				ifFalse: [ 0 @ -1 ].
			penetration := overlap y ].
	^ CFPhysicsContact
		first: firstBody
		second: secondBody
		normal: normal
		penetration: penetration
]
