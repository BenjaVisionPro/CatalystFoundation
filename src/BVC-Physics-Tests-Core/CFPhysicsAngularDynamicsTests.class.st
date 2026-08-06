Class {
	#name : 'CFPhysicsAngularDynamicsTests',
	#superclass : 'CFPhysicsTestCase',
	#category : 'BVC-Physics-Tests-Core',
	#package : 'BVC-Physics-Tests-Core'
}

{ #category : 'tests - angular dynamics' }
CFPhysicsAngularDynamicsTests >> testAngularImpulseChangesDynamicAngularVelocityByInverseInertia [
	<gtExample>
	| body impulse expected |
	body := self newBodyWithSequence: 1.
	impulse := 12.0.
	expected := impulse * body inverseInertia.
	body applyAngularImpulse: impulse.
	self assert: (body angularVelocity closeTo: expected)
]

{ #category : 'tests - angular dynamics' }
CFPhysicsAngularDynamicsTests >> testZeroAngularImpulseDoesNotWakeSleepingBody [
	<gtExample>
	| body |
	body := self newBodyWithSequence: 1.
	body sleep.
	body applyAngularImpulse: 0.0.
	self deny: body isAwake
]

{ #category : 'tests - angular dynamics' }
CFPhysicsAngularDynamicsTests >> testStaticBodyIgnoresAngularImpulse [
	<gtExample>
	| body |
	body := self newBodyWithSequence: 1.
	body beStatic.
	body applyAngularImpulse: 12.0.
	self assert: body angularVelocity equals: 0.0
]
