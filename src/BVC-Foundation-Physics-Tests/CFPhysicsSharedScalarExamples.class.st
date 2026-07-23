Class {
	#name : 'CFPhysicsSharedScalarExamples',
	#superclass : 'Object',
	#category : 'BVC-Foundation-Physics-Tests',
	#package : 'BVC-Foundation-Physics-Tests'
}

{ #category : 'examples - shared scalar' }
CFPhysicsSharedScalarExamples >> sharedScalarRetainsAndUpdatesItsValue [
	<gtExample>
	| scalar |
	scalar := CFPhysicsSharedScalar value: 12.
	self assert: scalar value equals: 12.0.
	self assert: scalar physicsValue equals: 12.0.
	scalar value: 34.
	self assert: scalar value equals: 34.0.
	^ scalar
]

{ #category : 'examples - shared scalar' }
CFPhysicsSharedScalarExamples >> ordinaryPhysicsValuesResolveWithoutWrapping [
	<gtExample>
	self assert: 42 physicsValue equals: 42.
	self assert: nil physicsValue isNil.
	^ 42
]

{ #category : 'examples - shared scalar' }
CFPhysicsSharedScalarExamples >> springObservesSharedValuesAtEachPreparation [
	<gtExample>
	| first second spring restLength stiffness damping maximumForce firstVelocity |
	first := CFPhysicsCleanSlateTests new
		cleanSlateBodyWithSequence: 1 position: 0 @ 0 extent: 20 @ 20.
	second := CFPhysicsCleanSlateTests new
		cleanSlateBodyWithSequence: 2 position: 100 @ 0 extent: 20 @ 20.
	restLength := CFPhysicsSharedScalar value: 50.
	stiffness := CFPhysicsSharedScalar value: 10.
	damping := CFPhysicsSharedScalar value: 0.
	maximumForce := CFPhysicsSharedScalar value: 100000.
	spring := CFPhysicsSpringConstraint between: first and: second.
	spring
		restLength: restLength;
		stiffness: stiffness;
		damping: damping;
		maximumForce: maximumForce.
	self assert: spring restLength == restLength.
	self assert: spring stiffness == stiffness.
	spring prepareForStep: 0.01.
	firstVelocity := first velocity x.
	first velocity: 0 @ 0.
	second velocity: 0 @ 0.
	stiffness value: 20.
	spring prepareForStep: 0.01.
	self assert: (first velocity x closeTo: firstVelocity * 2).
	^ spring
]

{ #category : 'examples - shared scalar' }
CFPhysicsSharedScalarExamples >> springStillAcceptsAndClampsOrdinaryNumbers [
	<gtExample>
	| first second spring |
	first := CFPhysicsCleanSlateTests new
		cleanSlateBodyWithSequence: 1 position: 0 @ 0 extent: 20 @ 20.
	second := CFPhysicsCleanSlateTests new
		cleanSlateBodyWithSequence: 2 position: 100 @ 0 extent: 20 @ 20.
	spring := CFPhysicsSpringConstraint between: first and: second.
	spring
		restLength: -10;
		stiffness: -20;
		damping: -30;
		maximumForce: -40.
	self assert: spring restLength equals: 0.0.
	self assert: spring stiffness equals: 0.0.
	self assert: spring damping equals: 0.0.
	self assert: spring maximumForce equals: 0.0.
	spring prepareForStep: 0.01.
	self assert: first velocity equals: 0 @ 0.
	self assert: second velocity equals: 0 @ 0.
	^ spring
]

{ #category : 'examples - shared scalar' }
CFPhysicsSharedScalarExamples >> constantForceResponseObservesSharedForceAndDistance [
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
CFPhysicsSharedScalarExamples >> sharedValuesAreIndependent [
	<gtExample>
	| first second |
	first := CFPhysicsSharedScalar value: 10.
	second := CFPhysicsSharedScalar value: 10.
	first value: 20.
	self assert: first value equals: 20.0.
	self assert: second value equals: 10.0.
	^ { first. second }
]
