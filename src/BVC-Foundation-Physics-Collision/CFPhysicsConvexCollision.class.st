Class {
	#name : 'CFPhysicsConvexCollision',
	#superclass : 'Object',
	#category : 'BVC-Foundation-Physics-Collision',
	#package : 'BVC-Foundation-Physics-Collision'
}

{ #category : 'collision' }
CFPhysicsConvexCollision class >> manifoldBetween: firstBody and: secondBody [
	| simplex |
	simplex := CFPhysicsGJK simplexBetween: firstBody and: secondBody.
	simplex ifNil: [ ^ nil ].
	^ CFPhysicsEPA manifoldBetween: firstBody and: secondBody fromSimplex: simplex
]
