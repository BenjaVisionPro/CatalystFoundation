"I specify the Box2D 3.1.1 Wheel joint defaults introduced by the first implementation increment."
Class {
	#name : 'CFPhysicsJointDefaultsTests',
	#superclass : 'TestCase',
	#category : 'BVC-Physics-Tests-Core',
	#package : 'BVC-Physics-Tests-Core'
}

{ #category : 'examples - wheel joint' }
CFPhysicsJointDefaultsTests >> wheelJointDefaultsMatchBox2D [
	<gtExample>
	| joint |
	joint := CFPhysicsWheelJoint new.
	self assert: joint localAxisA equals: 0 @ 1.
	self assert: joint springEnabled.
	self assert: (joint hertz closeTo: 1.0).
	self assert: (joint dampingRatio closeTo: 0.7).
	self assert: joint limitsEnabled not.
	self assert: (joint lowerTranslation closeTo: 0.0).
	self assert: (joint upperTranslation closeTo: 0.0).
	self assert: joint motorEnabled not.
	self assert: (joint motorSpeed closeTo: 0.0).
	self assert: (joint maximumMotorTorque closeTo: 0.0).
	self assert: (joint perpendicularImpulse closeTo: 0.0).
	self assert: (joint springImpulse closeTo: 0.0).
	self assert: (joint lowerLimitImpulse closeTo: 0.0).
	self assert: (joint upperLimitImpulse closeTo: 0.0).
	self assert: (joint motorImpulse closeTo: 0.0).
	^ joint
]
