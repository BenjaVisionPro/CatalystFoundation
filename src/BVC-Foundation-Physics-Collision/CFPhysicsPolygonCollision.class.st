Class {
	#name : 'CFPhysicsPolygonCollision',
	#superclass : 'Object',
	#category : 'BVC-Foundation-Physics-Collision',
	#package : 'BVC-Foundation-Physics-Collision'
}

{ #category : 'collision' }
CFPhysicsPolygonCollision class >> manifoldBetween: firstBody and: secondBody [
	| firstVertices secondVertices bestAxis bestOverlap result point |
	firstVertices := firstBody shapeState collisionVerticesAt: firstBody position.
	secondVertices := secondBody shapeState collisionVerticesAt: secondBody position.
	result := self separatingAxisBetween: firstVertices and: secondVertices.
	result ifNil: [ ^ nil ].
	bestAxis := result first.
	bestOverlap := result second.
	(self dot: (self centreOf: secondVertices) - (self centreOf: firstVertices) with: bestAxis) < 0
		ifTrue: [ bestAxis := bestAxis negated ].
	point := ((self supportPointOf: firstVertices inDirection: bestAxis)
		+ (self supportPointOf: secondVertices inDirection: bestAxis negated)) / 2.0.
	^ (CFPhysicsManifold normal: bestAxis penetration: bestOverlap max: 0.0)
		points: { point };
		yourself
]

{ #category : 'collision' }
CFPhysicsPolygonCollision class >> manifoldBetweenCircle: circleBody andPolygon: polygonBody [
	| circleCentre radius vertices axes closestVertex closestDistance axis result normal penetration point |
	circleCentre := circleBody shapeState circleCentreAt: circleBody position.
	radius := circleBody shapeState radius.
	vertices := polygonBody shapeState collisionVerticesAt: polygonBody position.
	axes := self axesFor: vertices.
	closestVertex := vertices first.
	closestDistance := (closestVertex distanceTo: circleCentre).
	vertices do: [ :each |
		| distance |
		distance := each distanceTo: circleCentre.
		distance < closestDistance ifTrue: [
			closestVertex := each.
			closestDistance := distance ] ].
	axis := circleCentre - closestVertex.
	axis r > 0 ifTrue: [ axes := axes copyWith: axis / axis r ].
	result := self separatingAxisForCircleAt: circleCentre radius: radius polygon: vertices axes: axes.
	result ifNil: [ ^ nil ].
	normal := result first.
	penetration := result second.
	(self dot: (self centreOf: vertices) - circleCentre with: normal) < 0
		ifTrue: [ normal := normal negated ].
	point := circleCentre + (normal * radius).
	^ (CFPhysicsManifold normal: normal penetration: penetration max: 0.0)
		points: { point };
		yourself
]

{ #category : 'collision' }
CFPhysicsPolygonCollision class >> manifoldBetweenPolygon: polygonBody andCircle: circleBody [
	| manifold |
	manifold := self manifoldBetweenCircle: circleBody andPolygon: polygonBody.
	manifold ifNil: [ ^ nil ].
	manifold normal: manifold normal negated.
	^ manifold
]

{ #category : 'private' }
CFPhysicsPolygonCollision class >> axesFor: vertices [
	| axes count |
	axes := OrderedCollection new.
	count := vertices size.
	1 to: count do: [ :index |
		| first second edge normal |
		first := vertices at: index.
		second := vertices at: (index = count ifTrue: [ 1 ] ifFalse: [ index + 1 ]).
		edge := second - first.
		normal := edge y negated @ edge x.
		normal r > 0 ifTrue: [ axes add: normal / normal r ] ].
	^ axes asArray
]

{ #category : 'private' }
CFPhysicsPolygonCollision class >> centreOf: vertices [
	| total |
	total := 0 @ 0.
	vertices do: [ :each | total := total + each ].
	^ total / vertices size asFloat
]

{ #category : 'private' }
CFPhysicsPolygonCollision class >> projectionOf: vertices on: axis [
	| minimum maximum value |
	value := self dot: vertices first with: axis.
	minimum := value.
	maximum := value.
	vertices allButFirst do: [ :each |
		value := self dot: each with: axis.
		minimum := minimum min: value.
		maximum := maximum max: value ].
	^ minimum @ maximum
]

{ #category : 'private' }
CFPhysicsPolygonCollision class >> separatingAxisBetween: firstVertices and: secondVertices [
	| bestAxis bestOverlap axes |
	bestOverlap := Float infinity.
	axes := (self axesFor: firstVertices), (self axesFor: secondVertices).
	axes do: [ :axis |
		| firstProjection secondProjection overlap |
		firstProjection := self projectionOf: firstVertices on: axis.
		secondProjection := self projectionOf: secondVertices on: axis.
		overlap := (firstProjection y min: secondProjection y) - (firstProjection x max: secondProjection x).
		overlap < 0 ifTrue: [ ^ nil ].
		overlap < bestOverlap ifTrue: [
			bestOverlap := overlap.
			bestAxis := axis ] ].
	^ { bestAxis. bestOverlap }
]

{ #category : 'private' }
CFPhysicsPolygonCollision class >> separatingAxisForCircleAt: centre radius: radius polygon: vertices axes: axes [
	| bestAxis bestOverlap |
	bestOverlap := Float infinity.
	axes do: [ :axis |
		| polygonProjection circleProjection overlap centreProjection |
		polygonProjection := self projectionOf: vertices on: axis.
		centreProjection := self dot: centre with: axis.
		circleProjection := (centreProjection - radius) @ (centreProjection + radius).
		overlap := (polygonProjection y min: circleProjection y) - (polygonProjection x max: circleProjection x).
		overlap < 0 ifTrue: [ ^ nil ].
		overlap < bestOverlap ifTrue: [
			bestOverlap := overlap.
			bestAxis := axis ] ].
	^ { bestAxis. bestOverlap }
]

{ #category : 'private' }
CFPhysicsPolygonCollision class >> supportPointOf: vertices inDirection: direction [
	| best bestProjection projection |
	best := vertices first.
	bestProjection := self dot: best with: direction.
	vertices allButFirst do: [ :each |
		projection := self dot: each with: direction.
		projection > bestProjection ifTrue: [
			best := each.
			bestProjection := projection ] ].
	^ best
]

{ #category : 'private' }
CFPhysicsPolygonCollision class >> dot: firstPoint with: secondPoint [
	^ (firstPoint x * secondPoint x) + (firstPoint y * secondPoint y)
]
