Class {
	#name : 'CFPhysicsSharedScalarTests',
	#superclass : 'TestCase',
	#category : 'BVC-Physics-Tests-Behaviours',
	#package : 'BVC-Physics-Tests-Behaviours'
}

{ #category : 'examples - shared scalar' }
CFPhysicsSharedScalarTests >> sharedScalarRetainsAndUpdatesItsValue [
	<gtExample>
	| scalar |
	scalar := CFPhysicsSharedScalar value: 12.
	self assert: scalar value equals: 12.0.
	scalar value: 34.
	self assert: scalar value equals: 34.0.
	^ scalar
]

{ #category : 'examples - shared scalar' }
CFPhysicsSharedScalarTests >> ordinaryPhysicsValuesResolveWithoutWrapping [
	<gtExample>
	self assert: 42 value equals: 42.
	self assert: nil value isNil.
	^ 42
]

{ #category : 'examples - shared scalar' }
CFPhysicsSharedScalarTests >> constantForceResponseObservesSharedForceAndDistance [
	<gtExample>
	| force maximumDistance response |
	force := CFPhysicsSharedScalar value: 250.
	maximumDistance := CFPhysicsSharedScalar value: 100.
	response := CFPhysicsConstantForceResponse new
		force: force;
		maximumDistance: maximumDistance;
		yourself.
	self assert: response force == force.
	self assert: response maximumDistance == maximumDistance.
	self assert: (response forceMagnitudeAtDistance: 50) equals: 250.0.
	force value: 500.
	self assert: (response forceMagnitudeAtDistance: 50) equals: 500.0.
	maximumDistance value: 25.
	self assert: (response forceMagnitudeAtDistance: 50) equals: 0.0.
	response maximumDistance: nil.
	self assert: (response forceMagnitudeAtDistance: 5000) equals: 500.0.
	^ response
]

{ #category : 'examples - shared scalar' }
CFPhysicsSharedScalarTests >> sharedValuesAreIndependent [
	<gtExample>
	| first second |
	first := CFPhysicsSharedScalar value: 10.
	second := CFPhysicsSharedScalar value: 10.
	first value: 20.
	self assert: first value equals: 20.0.
	self assert: second value equals: 10.0.
	^ { first. second }
]
