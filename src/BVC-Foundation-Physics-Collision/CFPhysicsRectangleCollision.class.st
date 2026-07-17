Class {
	#name : 'CFPhysicsRectangleCollision',
	#superclass : 'Object',
	#category : 'BVC-Foundation-Physics-Collision',
	#package : 'BVC-Foundation-Physics-Collision'
}

{ #category : 'collision' }
CFPhysicsRectangleCollision class >> manifoldBetween: firstBody and: secondBody [
	| firstBounds secondBounds overlap firstCentre secondCentre normal penetration point |
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
	point :=
		((firstBounds minimum x max: secondBounds minimum x)
			+ (firstBounds maximum x min: secondBounds maximum x) / 2.0)
		@
		((firstBounds minimum y max: secondBounds minimum y)
			+ (firstBounds maximum y min: secondBounds maximum y) / 2.0).
	^ (CFPhysicsManifold normal: normal penetration: penetration)
		points: { point };
		yourself
]
