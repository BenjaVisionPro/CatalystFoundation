"
I provide one configured manifold to tests exercising contact lifecycle independently of collision geometry.
"
Class {
	#name : 'CFPhysicsFixedManifoldGenerator',
	#superclass : 'Object',
	#instVars : [ 'manifold' ],
	#category : 'BVC-Physics-Tests-Core',
	#package : 'BVC-Physics-Tests-Core'
}

{ #category : 'instance creation' }
CFPhysicsFixedManifoldGenerator class >> manifold: aManifold [
	^ self new
		manifold: aManifold;
		yourself
]

{ #category : 'accessing' }
CFPhysicsFixedManifoldGenerator >> manifold: aManifold [
	manifold := aManifold
]

{ #category : 'generating' }
CFPhysicsFixedManifoldGenerator >> manifoldBetweenBody: firstBody andBody: secondBody [
	^ manifold
]

{ #category : 'generating' }
CFPhysicsFixedManifoldGenerator >> manifoldBetweenBodyState: firstBodyState andBodyState: secondBodyState [
	^ manifold
]

{ #category : 'generating' }
CFPhysicsFixedManifoldGenerator >> manifoldBetweenShapeState: firstShapeState transform: firstTransform andShapeState: secondShapeState transform: secondTransform [
	^ manifold
]

{ #category : 'generating' }
CFPhysicsFixedManifoldGenerator >> manifoldBetweenBodyState: firstBodyState andBodyState: secondBodyState speculativeDistance: speculativeDistance [
	^ manifold
]

{ #category : 'generating' }
CFPhysicsFixedManifoldGenerator >> manifoldBetweenShapeState: firstShapeState transform: firstTransform andShapeState: secondShapeState transform: secondTransform speculativeDistance: speculativeDistance [
	^ manifold
]


{ #category : 'generating' }
CFPhysicsFixedManifoldGenerator >> manifoldForPair: aPair bodyStates: bodyStates speculativeDistance: speculativeDistance simplexCache: simplexCache [
	^ manifold
]
