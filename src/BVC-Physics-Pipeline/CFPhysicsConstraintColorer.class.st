"
I assign prepared constraints to the Box2D 3.1.1 constraint graph colours.

The first eleven colours contain constraints that share no non-static body;
the twelfth is the serial overflow bucket. Catalyst executes these batches
serially, but keeps the same dependency partition as Box2D's task scheduler.
"
Class {
	#name : 'CFPhysicsConstraintColorer',
	#superclass : 'Object',
	#category : 'BVC-Physics-Pipeline',
	#package : 'BVC-Physics-Pipeline'
}

{ #category : 'constants' }
CFPhysicsConstraintColorer class >> graphColorCount [
	^ 12
]

{ #category : 'constants' }
CFPhysicsConstraintColorer class >> overflowColorIndex [
	^ self graphColorCount
]

{ #category : 'coloring' }
CFPhysicsConstraintColorer class >> colorsFor: constraints [
	| colors bodySets |
	colors := OrderedCollection new: self graphColorCount.
	self graphColorCount timesRepeat: [ colors add: OrderedCollection new ].
	bodySets := (1 to: self graphColorCount - 1) collect: [ :ignored | IdentitySet new ].
	constraints do: [ :constraint |
		| dynamicStates startColor assigned |
		dynamicStates := self dynamicBodyStatesFor: constraint.
		startColor := self firstColorFor: constraint dynamicStateCount: dynamicStates size.
		assigned := (startColor to: self overflowColorIndex - 1) detect: [ :colorIndex |
			| bodySet |
			bodySet := bodySets at: colorIndex.
			dynamicStates noneSatisfy: [ :state | bodySet includes: state ] ] ifNone: [ nil ].
		assigned
			ifNil: [ (colors at: self overflowColorIndex) add: constraint ]
			ifNotNil: [
				(colors at: assigned) add: constraint.
				(bodySets at: assigned) addAll: dynamicStates ] ].
	^ colors collect: #asArray
]

{ #category : 'private - coloring' }
CFPhysicsConstraintColorer class >> dynamicBodyStatesFor: constraint [
	| states |
	states := IdentitySet new.
	{ constraint bodyStateA. constraint bodyStateB } do: [ :state |
		(state notNil and: [ state bodyType isStatic not ]) ifTrue: [ states add: state ] ].
	^ states asArray
]

{ #category : 'private - coloring' }
CFPhysicsConstraintColorer class >> firstColorFor: constraint dynamicStateCount: dynamicStateCount [
	"Box2D reserves colour zero for joints; a static contact begins at colour one."
	^ ((constraint isKindOf: CFPhysicsPreparedConstraint) and: [ dynamicStateCount = 1 ])
		ifTrue: [ 2 ]
		ifFalse: [ 1 ]
]
