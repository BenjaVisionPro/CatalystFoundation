Class {
	#name : 'CFPhysicsCircleCollision',
	#superclass : 'Object',
	#category : 'BVC-Foundation-Physics-Collision',
	#package : 'BVC-Foundation-Physics-Collision'
}

{ #category : 'private' }
CFPhysicsCircleCollision class >> clamp: aNumber between: aMinimum and: aMaximum [
	^ (aNumber max: aMinimum) min: aMaximum
]

{ #category : 'collision' }
CFPhysicsCircleCollision class >> manifoldBetweenCircle: firstBody andCircle: secondBody [
	| firstCentre secondCentre delta distanceSquared radiusSum distance normal penetration point |
	firstCentre := firstBody shapeState circleCentreAt: firstBody position.
	secondCentre := secondBody shapeState circleCentreAt: secondBody position.
	delta := secondCentre - firstCentre.
	distanceSquared := delta x squared + delta y squared.
	radiusSum := firstBody shapeState radius + secondBody shapeState radius.
	distanceSquared > radiusSum squared ifTrue: [ ^ nil ].
	distance := distanceSquared sqrt.
	normal := distance = 0
		ifTrue: [ 1 @ 0 ]
		ifFalse: [ delta / distance ].
	penetration := radiusSum - distance.
	point := firstCentre + (normal * firstBody shapeState radius).
	^ (CFPhysicsManifold normal: normal penetration: penetration)
		points: { point };
		yourself
]

{ #category : 'collision' }
CFPhysicsCircleCollision class >> manifoldBetweenCircle: circleBody andRectangle: rectangleBody [
	| centre bounds closest delta distanceSquared radius distance normal penetration point leftDistance rightDistance topDistance bottomDistance minimumDistance |
	centre := circleBody shapeState circleCentreAt: circleBody position.
	bounds := rectangleBody aabb.
	closest :=
		(self clamp: centre x between: bounds minimum x and: bounds maximum x)
		@
		(self clamp: centre y between: bounds minimum y and: bounds maximum y).
	delta := closest - centre.
	distanceSquared := delta x squared + delta y squared.
	radius := circleBody shapeState radius.
	distanceSquared > 0 ifTrue: [
		distanceSquared > radius squared ifTrue: [ ^ nil ].
		distance := distanceSquared sqrt.
		normal := delta / distance.
		penetration := radius - distance.
		point := closest.
		^ (CFPhysicsManifold normal: normal penetration: penetration)
			points: { point };
			yourself ].
	leftDistance := centre x - bounds minimum x.
	rightDistance := bounds maximum x - centre x.
	topDistance := centre y - bounds minimum y.
	bottomDistance := bounds maximum y - centre y.
	minimumDistance := leftDistance min: (rightDistance min: (topDistance min: bottomDistance)).
	minimumDistance = leftDistance
		ifTrue: [ normal := 1 @ 0. point := bounds minimum x @ centre y ].
	minimumDistance = rightDistance
		ifTrue: [ normal := -1 @ 0. point := bounds maximum x @ centre y ].
	minimumDistance = topDistance
		ifTrue: [ normal := 0 @ 1. point := centre x @ bounds minimum y ].
	minimumDistance = bottomDistance
		ifTrue: [ normal := 0 @ -1. point := centre x @ bounds maximum y ].
	penetration := radius + minimumDistance.
	^ (CFPhysicsManifold normal: normal penetration: penetration)
		points: { point };
		yourself
]

{ #category : 'collision' }
CFPhysicsCircleCollision class >> manifoldBetweenRectangle: rectangleBody andCircle: circleBody [
	| manifold |
	manifold := self manifoldBetweenCircle: circleBody andRectangle: rectangleBody.
	manifold ifNil: [ ^ nil ].
	manifold normal: manifold normal * -1.
	^ manifold
]
