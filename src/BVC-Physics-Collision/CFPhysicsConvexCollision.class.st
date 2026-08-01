"
I build a contact manifold for a general convex body pair.

My responsibility is to combine GJK intersection detection with EPA penetration recovery when specialised shape paths are unsuitable.
"
Class {
	#name : 'CFPhysicsConvexCollision',
	#superclass : 'Object',
	#category : 'BVC-Physics-Collision',
	#package : 'BVC-Physics-Collision'
}

{ #category : 'collision' }
CFPhysicsConvexCollision class >> manifoldBetween: firstBody and: secondBody [
	| simplex |
	(firstBody aabb overlaps: secondBody aabb) ifFalse: [ ^ nil ].
	simplex := CFPhysicsGJK simplexBetween: firstBody and: secondBody.
	simplex ifNil: [ ^ nil ].
	^ CFPhysicsEPA manifoldBetween: firstBody and: secondBody fromSimplex: simplex
]
