Class {
	#name : 'CFPhysicsJointTests',
	#superclass : 'CFPhysicsTestCase',
	#category : 'BVC-Physics-Tests-Core',
	#package : 'BVC-Physics-Tests-Core'
}

{ #category : 'tests - distance joints' }
CFPhysicsJointTests >> testDistanceJointSpringUsesBox2DSoftConstraint [
	<gtExample>
	| owner first second world joint result prepared |
	owner := BlElement new size: 400 @ 300; yourself.
	first := BlElement new size: 20 @ 20; yourself.
	second := BlElement new size: 20 @ 20; yourself.
	owner addChildren: { first. second }.
	world := owner physics beWorld.
	world gravity: 0 @ 0.
	world owner physics makeChildrenDynamic.
	first physics position: 0 @ 0.
	second physics position: 100 @ 0.
	joint := first physics distanceJointTo: second.
	joint
		length: 50;
		springEnabled: true;
		hertz: 3;
		dampingRatio: 1.
	result := world step.
	prepared := result constraints first.
	self assert: prepared springEnabled.
	self assert: prepared biasRate > 0.0.
	self assert: prepared massCoefficient > 0.0.
	self assert: first physics velocity x > 0.0.
	self assert: second physics velocity x < 0.0.
	^ result
]
{ #category : 'tests - distance joints' }
CFPhysicsJointTests >> testDistanceJointPreparesBox2DLengthLimitsAndAxialMotor [
	<gtExample>
	| first second joint bodyStates step prepared |
	first := self newBodyWithSequence: 1 position: 0 @ 0 extent: 20 @ 20.
	second := self newBodyWithSequence: 2 position: 100 @ 0 extent: 20 @ 20.
	joint := CFPhysicsDistanceJoint between: first and: second.
	joint
		springEnabled: true;
		hertz: 3.0;
		limitLengthFrom: 60.0 to: 40.0;
		limitsEnabled: true;
		motorEnabled: true;
		motorSpeed: -20.0;
		maximumMotorForce: 30.0.
	bodyStates := IdentityDictionary new
		at: first put: (CFPhysicsBodyStepState on: first);
		at: second put: (CFPhysicsBodyStepState on: second);
		yourself.
	step := CFPhysicsStep
		timeStep: 1.0 / 60.0
		substeps: 4
		contactHertz: 30.0
		dampingRatio: 10.0.
	prepared := (CFPhysicsDistanceJointConstraintBuilder new
		constraintsFrom: { joint } bodyStates: bodyStates step: step) first.
	self assert: joint minimumLength equals: 40.0.
	self assert: joint maximumLength equals: 60.0.
	self assert: prepared limitsEnabled.
	self assert: prepared minimumLength equals: 40.0.
	self assert: prepared maximumLength equals: 60.0.
	self assert: prepared motorEnabled.
	self assert: prepared motorSpeed equals: -20.0.
	self assert: prepared maximumMotorImpulse equals: 30.0 * step substepTime.
	^ prepared
]
{ #category : 'tests - distance joints' }
CFPhysicsJointTests >> testDistanceJointLengthLimitOpposesExcessExtension [
	<gtExample>
	| owner first second world joint result prepared |
	owner := BlElement new size: 400 @ 300; yourself.
	first := BlElement new size: 20 @ 20; yourself.
	second := BlElement new size: 20 @ 20; yourself.
	owner addChildren: { first. second }.
	world := owner physics beWorld.
	world gravity: 0 @ 0.
	world owner physics makeChildrenDynamic.
	first physics position: 0 @ 0.
	second physics position: 100 @ 0.
	joint := first physics distanceJointTo: second.
	joint
		length: 100.0;
		springEnabled: true;
		hertz: 3.0;
		limitLengthFrom: 40.0 to: 60.0;
		limitsEnabled: true.
	result := world step.
	prepared := result constraints first.
	self assert: prepared upperLimitImpulse > 0.0.
	self assert: first physics position x > 0.0.
	self assert: second physics position x < 100.0.
	^ result
]
{ #category : 'tests - distance joints' }
CFPhysicsJointTests >> testDistanceJointAxialMotorDrivesRelativeMotion [
	<gtExample>
	| owner first second world joint result prepared |
	owner := BlElement new size: 400 @ 300; yourself.
	first := BlElement new size: 20 @ 20; yourself.
	second := BlElement new size: 20 @ 20; yourself.
	owner addChildren: { first. second }.
	world := owner physics beWorld.
	world gravity: 0 @ 0.
	world owner physics makeChildrenDynamic.
	"Keep both bodies clear of the world's default containment boundary so it
	does not overwrite the solver's outward motor response during commit."
	first physics position: 100 @ 0.
	second physics position: 200 @ 0.
	joint := first physics distanceJointTo: second.
	joint
		springEnabled: true;
		hertz: 0.0;
		motorEnabled: true;
		motorSpeed: 100.0;
		maximumMotorForce: 100000.0.
	result := world step.
	prepared := result constraints first.
	self assert: prepared motorImpulse > 0.0.
	self assert: first physics position x < 100.0.
	self assert: second physics position x > 200.0.
	^ result
]
{ #category : 'tests - distance joints' }
CFPhysicsJointTests >> testDistanceJointCapturesItsEndpointDistance [
	<gtExample>
	| first second joint |
	first := self newBodyWithSequence: 1 position: 0 @ 0 extent: 20 @ 20.
	second := self newBodyWithSequence: 2 position: 100 @ 0 extent: 20 @ 20.
	joint := CFPhysicsDistanceJoint between: first and: second.
	self assert: joint anchorA class equals: CFPhysicsBodyCentreAnchor.
	self assert: joint anchorB class equals: CFPhysicsBodyCentreAnchor.
	self assert: joint bodyA == first.
	self assert: joint bodyB == second.
	self assert: joint length equals: 100.0.
	self assert: joint currentLength equals: 100.0.
	^ joint
]
{ #category : 'tests - distance joints' }
CFPhysicsJointTests >> testDistanceJointsAreOwnedAndRetiredByThePhysicsWorld [
	<gtExample>
	| owner first second third world attached unrelated |
	owner := BlElement new size: 400 @ 300; yourself.
	first := BlElement new size: 20 @ 20; yourself.
	second := BlElement new size: 20 @ 20; yourself.
	third := BlElement new size: 20 @ 20; yourself.
	owner addChildren: { first. second. third }.
	world := owner physics beWorld.
	world owner physics makeChildrenDynamic.
	attached := first physics distanceJointTo: second.
	unrelated := second physics distanceJointTo: third.
	self assert: first physics distanceJoints equals: { attached }.
	self assert: second physics distanceJoints equals: { attached. unrelated }.
	owner removeChild: first.
	self assert: world distanceJoints equals: { unrelated }.
	self assert: attached isActive not.
	self assert: unrelated isActive.
	^ world
]
{ #category : 'tests - distance joints' }
CFPhysicsJointTests >> testDestroyingADistanceJointWakesBothSleepingEndpoints [
	<gtExample>
	| owner first second world joint |
	owner := BlElement new size: 400 @ 300; yourself.
	first := BlElement new size: 20 @ 20; yourself.
	second := BlElement new size: 20 @ 20; yourself.
	owner addChildren: { first. second }.
	world := owner physics beWorld.
	world owner physics makeChildrenDynamic.
	joint := first physics distanceJointTo: second.
	first physics body sleep.
	second physics body sleep.
	self assert: first physics body isAwake not.
	self assert: second physics body isAwake not.
	world removeDistanceJoint: joint.
	self assert: joint isActive not.
	self assert: first physics body isAwake.
	self assert: second physics body isAwake.
	^ world
]
{ #category : 'tests - distance joints' }
CFPhysicsJointTests >> testDistanceJointParticipatesInTheIslandSolver [
	<gtExample>
	| owner first second world joint result |
	owner := BlElement new size: 400 @ 300; yourself.
	first := BlElement new size: 20 @ 20; yourself.
	second := BlElement new size: 20 @ 20; yourself.
	owner addChildren: { first. second }.
	world := owner physics beWorld.
	world containment disable.
	world gravity: 0 @ 0.
	world owner physics makeChildrenDynamic.
	first physics position: 0 @ 0.
	second physics position: 100 @ 0.
	joint := first physics distanceJointTo: second.
	joint length: 50.
	result := world step.
	self assert: result constraints size equals: 1.
	self assert: result constraints first class equals: CFPhysicsPreparedDistanceJoint.
	self assert: result islands size equals: 1.
	self assert: result islands first constraints equals: result constraints.
	self assert: first physics position x > 0.
	self assert: second physics position x < 100.
	self assert: result contactSolveResults isEmpty.
	self assert: result hitEvents isEmpty.
	^ result
]
{ #category : 'tests - distance joints' }
CFPhysicsJointTests >> testDistanceJointCanAnchorABodyToTheWorld [
	<gtExample>
	| owner element world bodyAnchor worldAnchor joint result |
	owner := BlElement new size: 400 @ 300; yourself.
	element := BlElement new size: 20 @ 20; yourself.
	owner addChild: element.
	world := owner physics beWorld.
	world gravity: 0 @ 0.
	world owner physics makeChildrenDynamic.
	element physics position: 0 @ 0.
	bodyAnchor := element physics localAnchorAt: 10 @ 10.
	worldAnchor := world anchorAt: 100 @ 10.
	joint := bodyAnchor distanceJointTo: worldAnchor.
	joint length: 50.
	result := world step.
	self assert: joint bodyA == element physics body.
	self assert: joint bodyB isNil.
	self assert: result constraints size equals: 1.
	self assert: result islands size equals: 1.
	self assert: element physics position x > 0.
	^ result
]
{ #category : 'tests - distance joints' }
CFPhysicsJointTests >> testMovingAWorldAnchorWakesItsSleepingDistanceJointBody [
	<gtExample>
	| owner element world bodyAnchor worldAnchor joint |
	owner := BlElement new size: 400 @ 300; yourself.
	element := BlElement new size: 20 @ 20; yourself.
	owner addChild: element.
	world := owner physics beWorld.
	world gravity: 0 @ 0.
	world owner physics makeChildrenDynamic.
	element physics position: 0 @ 0.
	bodyAnchor := element physics localAnchorAt: 10 @ 10.
	worldAnchor := world anchorAt: 10 @ 10.
	joint := bodyAnchor distanceJointTo: worldAnchor.
	joint length: 0.
	element physics body sleep.
	worldAnchor point: 110 @ 10.
	self assert: element physics body isAwake.
	world step.
	self assert: element physics position x > 0.
	^ joint
]
{ #category : 'tests - distance joints' }
CFPhysicsJointTests >> testRetuningDistanceJointRestLengthWakesItsSleepingEndpoints [
	<gtExample>
	| owner first second world joint |
	owner := BlElement new size: 400 @ 300; yourself.
	first := BlElement new size: 20 @ 20; yourself.
	second := BlElement new size: 20 @ 20; yourself.
	owner addChildren: { first. second }.
	world := owner physics beWorld.
	world owner physics makeChildrenDynamic.
	joint := first physics distanceJointTo: second.
	first physics body sleep.
	second physics body sleep.
	joint length: joint length + 10.
	self assert: first physics body isAwake.
	self assert: second physics body isAwake.
	^ joint
]
{ #category : 'tests - distance joints' }
CFPhysicsJointTests >> testOffCentreDistanceJointProducesAngularResponse [
	<gtExample>
	| owner first second world firstAnchor secondAnchor joint |
	owner := BlElement new size: 400 @ 300; yourself.
	first := BlElement new size: 20 @ 20; yourself.
	second := BlElement new size: 20 @ 20; yourself.
	owner addChildren: { first. second }.
	world := owner physics beWorld.
	world gravity: 0 @ 0.
	world owner physics makeChildrenDynamic.
	first physics position: 0 @ 0.
	second physics position: 100 @ 0.
	second physics beStatic.
	firstAnchor := first physics localAnchorAt: 20 @ 0.
	secondAnchor := second physics localAnchorAt: 0 @ 20.
	joint := firstAnchor distanceJointTo: secondAnchor.
	joint length: 20.
	world step.
	self assert: first physics angularVelocity abs > 0.0.
	self assert: second physics angularVelocity equals: 0.0.
	^ joint
]
{ #category : 'tests - revolute joints' }
CFPhysicsJointTests >> testRevoluteJointCapturesItsAnchoredPivot [
	<gtExample>
	| first second firstAnchor secondAnchor joint |
	first := self newBodyWithSequence: 1 position: 0 @ 0 extent: 20 @ 20.
	second := self newBodyWithSequence: 2 position: 30 @ 0 extent: 20 @ 20.
	firstAnchor := CFPhysicsLocalAnchor on: first at: 30 @ 10.
	secondAnchor := CFPhysicsLocalAnchor on: second at: 0 @ 10.
	joint := CFPhysicsRevoluteJoint betweenAnchor: firstAnchor andAnchor: secondAnchor.
	self assert: joint bodyA == first.
	self assert: joint bodyB == second.
	self assert: joint anchorA == firstAnchor.
	self assert: joint anchorB == secondAnchor.
	self assert: joint accumulatedImpulse equals: 0 @ 0.
	self assert: joint springEnabled not.
	self assert: joint hertz equals: 0.0.
	self assert: joint dampingRatio equals: 0.0.
	self assert: joint targetAngle equals: 0.0.
	self assert: joint springImpulse equals: 0.0.
	^ joint
]
{ #category : 'tests - revolute joints' }
CFPhysicsJointTests >> testRevoluteJointParticipatesInTheIslandSolver [
	<gtExample>
	| owner first second world firstAnchor secondAnchor joint result |
	owner := BlElement new size: 400 @ 300; yourself.
	first := BlElement new size: 20 @ 20; yourself.
	second := BlElement new size: 20 @ 20; yourself.
	owner addChildren: { first. second }.
	world := owner physics beWorld.
	world gravity: 0 @ 0.
	world owner physics makeChildrenDynamic.
	first physics position: 0 @ 0.
	second physics position: 30 @ 0.
	second physics beStatic.
	firstAnchor := first physics localAnchorAt: 30 @ 10.
	secondAnchor := second physics localAnchorAt: 0 @ 10.
	joint := firstAnchor revoluteJointTo: secondAnchor.
	first physics velocity: 100 @ 0.
	result := world step.
	self assert: world revoluteJoints equals: { joint }.
	self assert: result constraints size equals: 1.
	self assert: result constraints first class equals: CFPhysicsPreparedRevoluteJoint.
	self assert: result islands size equals: 1.
	self assert: (first physics velocity x closeTo: 0.0).
	^ result
]
{ #category : 'tests - revolute joints' }
CFPhysicsJointTests >> testRevoluteJointCanAnchorABodyToTheWorld [
	<gtExample>
	| owner element world bodyAnchor worldAnchor joint result |
	owner := BlElement new size: 400 @ 300; yourself.
	element := BlElement new size: 20 @ 20; yourself.
	owner addChild: element.
	world := owner physics beWorld.
	world gravity: 0 @ 0.
	world owner physics makeChildrenDynamic.
	element physics position: 0 @ 0.
	bodyAnchor := element physics localAnchorAt: 10 @ 10.
	worldAnchor := world anchorAt: 10 @ 10.
	joint := bodyAnchor revoluteJointTo: worldAnchor.
	element physics velocity: 100 @ 0.
	result := world step.
	self assert: joint bodyA == element physics body.
	self assert: joint bodyB isNil.
	self assert: result constraints size equals: 1.
	self assert: result islands size equals: 1.
	self assert: (element physics velocity x closeTo: 0.0).
	^ result
]
{ #category : 'tests - revolute joints' }
CFPhysicsJointTests >> testMovingAWorldAnchorWakesItsSleepingRevoluteJointBody [
	<gtExample>
	| owner element world bodyAnchor worldAnchor joint |
	owner := BlElement new size: 400 @ 300; yourself.
	element := BlElement new size: 20 @ 20; yourself.
	owner addChild: element.
	world := owner physics beWorld.
	world gravity: 0 @ 0.
	world owner physics makeChildrenDynamic.
	element physics position: 0 @ 0.
	bodyAnchor := element physics localAnchorAt: 10 @ 10.
	worldAnchor := world anchorAt: 10 @ 10.
	joint := bodyAnchor revoluteJointTo: worldAnchor.
	element physics body sleep.
	worldAnchor point: 110 @ 10.
	self assert: element physics body isAwake.
	world step.
	self assert: element physics position x > 0.
	^ joint
]
{ #category : 'tests - revolute joints' }
CFPhysicsJointTests >> testRevoluteJointMotorDrivesRelativeAngularVelocity [
	<gtExample>
	| owner first second world firstAnchor secondAnchor joint result |
	owner := BlElement new size: 400 @ 300; yourself.
	first := BlElement new size: 20 @ 20; yourself.
	second := BlElement new size: 20 @ 20; yourself.
	owner addChildren: { first. second }.
	world := owner physics beWorld.
	world gravity: 0 @ 0.
	world owner physics makeChildrenDynamic.
	first physics position: 0 @ 0.
	second physics position: 30 @ 0.
	second physics beStatic.
	firstAnchor := first physics localAnchorAt: 30 @ 10.
	secondAnchor := second physics localAnchorAt: 0 @ 10.
	joint := firstAnchor revoluteJointTo: secondAnchor.
	joint
		motorEnabled: true;
		motorSpeed: 10.0;
		maximumMotorTorque: 1000.0.
	result := world step.
	self assert: result constraints first motorEnabled.
	self assert: first physics angularVelocity < 0.0.
	self assert: second physics angularVelocity equals: 0.0.
	^ result
]
{ #category : 'tests - revolute joints' }
CFPhysicsJointTests >> testRevoluteJointMotorTorqueIsConvertedToASubstepImpulse [
	<gtExample>
	| owner first second world firstAnchor secondAnchor joint result prepared |
	owner := BlElement new size: 400 @ 300; yourself.
	first := BlElement new size: 20 @ 20; yourself.
	second := BlElement new size: 20 @ 20; yourself.
	owner addChildren: { first. second }.
	world := owner physics beWorld.
	world gravity: 0 @ 0.
	world owner physics makeChildrenDynamic.
	first physics position: 0 @ 0.
	second physics position: 30 @ 0.
	second physics beStatic.
	firstAnchor := first physics localAnchorAt: 30 @ 10.
	secondAnchor := second physics localAnchorAt: 0 @ 10.
	joint := firstAnchor revoluteJointTo: secondAnchor.
	joint
		motorEnabled: true;
		motorSpeed: 10.0;
		maximumMotorTorque: 1000.0.
	result := world step.
	prepared := result constraints first.
	self assert: (prepared maximumMotorImpulse closeTo: 1000.0 * result step substepTime).
	^ result
]
{ #category : 'tests - revolute joints' }
CFPhysicsJointTests >> testRevoluteJointMotorConfigurationPreservesItsAccumulatedImpulse [
	<gtExample>
	| first second joint |
	first := self newBodyWithSequence: 1 position: 0 @ 0 extent: 20 @ 20.
	second := self newBodyWithSequence: 2 position: 30 @ 0 extent: 20 @ 20.
	joint := CFPhysicsRevoluteJoint between: first and: second.
	joint motorImpulse: 3.0.
	joint motorSpeed: 7.0.
	self assert: (joint motorImpulse closeTo: 3.0).
	joint maximumMotorTorque: 11.0.
	self assert: (joint motorImpulse closeTo: 3.0).
	joint motorEnabled: true.
	self assert: (joint motorImpulse closeTo: 0.0).
	^ joint
]
{ #category : 'tests - revolute joints' }
CFPhysicsJointTests >> testRevoluteJointAllowsEqualLimitAngles [
	<gtExample>
	| first second joint |
	first := self newBodyWithSequence: 1 position: 0 @ 0 extent: 20 @ 20.
	second := self newBodyWithSequence: 2 position: 30 @ 0 extent: 20 @ 20.
	joint := CFPhysicsRevoluteJoint between: first and: second.
	joint limitAnglesFrom: 0.25 to: 0.25.
	self assert: (joint lowerAngle closeTo: 0.25).
	self assert: (joint upperAngle closeTo: 0.25).
	^ joint
]
{ #category : 'tests - revolute joints' }
CFPhysicsJointTests >> testRevoluteJointSpringDrivesRelativeAngleTowardItsTarget [
	<gtExample>
	| owner element world bodyAnchor worldAnchor joint initialRotation result |
	owner := BlElement new size: 400 @ 300; yourself.
	element := BlElement new size: 20 @ 20; yourself.
	owner addChild: element.
	world := owner physics beWorld.
	world gravity: 0 @ 0.
	world owner physics makeChildrenDynamic.
	element physics position: 0 @ 0.
	element physics rotation: 0.5.
	bodyAnchor := element physics localAnchorAt: 10 @ 10.
	worldAnchor := world anchorAt: 10 @ 10.
	joint := bodyAnchor revoluteJointTo: worldAnchor.
	joint
		springEnabled: true;
		targetAngle: 0.0;
		hertz: 5.0;
		dampingRatio: 1.0.
	initialRotation := element physics rotation abs.
	result := world step.
	self assert: result constraints first springEnabled.
	self assert: joint springImpulse abs > 0.0.
	self assert: element physics rotation abs < initialRotation.
	^ result
]
{ #category : 'tests - revolute joints' }
CFPhysicsJointTests >> testRevoluteJointLimitsBoundAnAnchoredElementRotation [
	<gtExample>
	| owner element world bodyAnchor worldAnchor joint result |
	owner := BlElement new size: 400 @ 300; yourself.
	element := BlElement new size: 20 @ 20; yourself.
	owner addChild: element.
	world := owner physics beWorld.
	world containment disable.
	world gravity: 0 @ 0.
	world owner physics makeChildrenDynamic.
	element physics position: 0 @ 0.
	bodyAnchor := element physics localAnchorAt: 10 @ 10.
	worldAnchor := world anchorAt: 10 @ 10.
	joint := bodyAnchor revoluteJointTo: worldAnchor.
	joint
		limitAnglesFrom: -0.25 to: 0.25;
		limitsEnabled: true.
	element physics rotation: 0.5.
	result := world step.
	self assert: result constraints first limitsEnabled.
	self assert: result constraints first limitBaseAngle equals: -0.5.
	self assert: element physics rotation abs < 0.5.
	self assert: (element physics angularVelocity closeTo: 0.0).
	^ result
]
{ #category : 'tests - prismatic joints' }
CFPhysicsJointTests >> testPrismaticJointCouplesOffsetPerpendicularAndAngularConstraints [
	<gtExample>
	| owner element world joint state prepared solver axis normal leverA leverB |
	owner := BlElement new size: 400 @ 300; yourself.
	element := BlElement new size: 20 @ 20; yourself.
	owner addChild: element.
	world := owner physics beWorld.
	world gravity: 0 @ 0.
	world owner physics makeChildrenDynamic.
	element physics
		position: 100 @ 100;
		velocity: 0 @ 100;
		angularVelocity: 50.0.
	joint := (element physics localAnchorAt: 0 @ 0)
		prismaticJointTo: (world anchorAt: 100 @ 0)
		along: 1 @ 0.
	state := world captureStateAfterSynchronisation.
	prepared := (CFPhysicsPrismaticJointConstraintBuilder new
		constraintsFrom: state joints
		bodyStates: state bodyStates
		step: state step) first.
	solver := CFPhysicsSoftStepSolver
		step: state step
		bodyStates: state orderedBodyStates
		constraints: #().
	solver solvePrismaticJointConstraint: prepared biasEnabled: false.
	axis := solver prismaticJointAxisFor: prepared.
	normal := axis y negated @ axis x.
	leverA := solver prismaticJointLeverAFor: prepared direction: normal.
	leverB := solver prismaticJointLeverBFor: prepared direction: normal.
	self assert: leverA ~= 0.0.
	self assert: ((solver
		prismaticJointVelocityFor: prepared
		direction: normal
		leverA: leverA
		leverB: leverB) closeTo: 0.0).
	self assert: ((solver weldJointRelativeAngularVelocity: prepared) closeTo: 0.0).
	^ prepared
]
{ #category : 'tests - prismatic joints' }
CFPhysicsJointTests >> testPrismaticJointConstrainsAnAnchoredElementToItsAxis [
	<gtExample>
	| owner element world bodyAnchor worldAnchor joint result |
	owner := BlElement new size: 400 @ 300; yourself.
	element := BlElement new size: 20 @ 20; yourself.
	owner addChild: element.
	world := owner physics beWorld.
	world gravity: 0 @ 0.
	world owner physics makeChildrenDynamic.
	element physics position: 0 @ 0.
	bodyAnchor := element physics localAnchorAt: 10 @ 10.
	worldAnchor := world anchorAt: 10 @ 10.
	joint := bodyAnchor prismaticJointTo: worldAnchor along: 1 @ 0.
	element physics velocity: 100 @ 100.
	element physics angularVelocity: 10.0.
	result := world step.
	self assert: world prismaticJoints equals: { joint }.
	self assert: result constraints size equals: 1.
	self assert: result constraints first class equals: CFPhysicsPreparedPrismaticJoint.
	self assert: (element physics velocity y closeTo: 0.0).
	self assert: (element physics angularVelocity closeTo: 0.0).
	^ result
]
{ #category : 'tests - prismatic joints' }
CFPhysicsJointTests >> testPrismaticJointLimitsBoundAnAnchoredElementTravel [
	<gtExample>
	| owner element world bodyAnchor worldAnchor joint result |
	owner := BlElement new size: 400 @ 300; yourself.
	element := BlElement new size: 20 @ 20; yourself.
	owner addChild: element.
	world := owner physics beWorld.
	world gravity: 0 @ 0.
	world owner physics makeChildrenDynamic.
	element physics position: 0 @ 0.
	bodyAnchor := element physics localAnchorAt: 10 @ 10.
	worldAnchor := world anchorAt: 10 @ 10.
	joint := bodyAnchor prismaticJointTo: worldAnchor along: 1 @ 0.
	joint
		limitTranslationFrom: -10 to: 10;
		limitsEnabled: true.
	element physics position: 20 @ 0.
	result := world step.
	self assert: result constraints first limitsEnabled.
	self assert: result constraints first baseTranslation equals: 20.0.
	self assert: (element physics position x < 20.0).
	self assert: (element physics velocity x closeTo: 0.0).
	^ result
]
{ #category : 'tests - prismatic joints' }
CFPhysicsJointTests >> testMouseJointRespectsAPrismaticAxis [
	<gtExample>
	| owner element world bodyAnchor worldAnchor joint mouseJoint result |
	owner := BlElement new size: 400 @ 300; yourself.
	element := BlElement new size: 20 @ 20; yourself.
	owner addChild: element.
	world := owner physics beWorld.
	world gravity: 0 @ 0.
	world owner physics makeChildrenDynamic.
	element physics position: 0 @ 0.
	bodyAnchor := element physics localAnchorAt: 10 @ 10.
	worldAnchor := world anchorAt: 10 @ 10.
	joint := bodyAnchor prismaticJointTo: worldAnchor along: 1 @ 0.
	joint
		limitTranslationFrom: -10 to: 10;
		limitsEnabled: true.
	mouseJoint := CFPhysicsMouseJoint body: element physics body target: 10 @ 10.
	mouseJoint
		target: 1000 @ 1000;
		maximumForce: 100000.0.
	world addMouseJoint: mouseJoint.
	result := world step.
	self assert: (element physics velocity y closeTo: 0.0).
	self assert: (element physics position y abs < element physics position x abs).
	self assert: (element physics position x > 0.0).
	self assert: (element physics position x < 10.0).
	^ result
]
{ #category : 'tests - mouse joints' }
CFPhysicsJointTests >> testMouseJointDefaultsMatchBox2D [
	<gtExample>
	| body joint |
	body := self newBodyWithSequence: 1 position: 0 @ 0 extent: 20 @ 20.
	joint := CFPhysicsMouseJoint body: body target: 0 @ 0.
	self assert: joint hertz equals: 4.0.
	self assert: joint dampingRatio equals: 1.0.
	self assert: joint maximumForce equals: 1.0.
	self assert: joint collideConnected not.
	^ joint
]
{ #category : 'tests - weld joints' }
CFPhysicsJointTests >> testWeldJointCapturesItsReferenceAngle [
	<gtExample>
	| first second joint |
	first := self newBodyWithSequence: 1 position: 0 @ 0 extent: 20 @ 20.
	second := self newBodyWithSequence: 2 position: 30 @ 0 extent: 20 @ 20.
	first rotation: 0.25.
	second rotation: 0.75.
	joint := CFPhysicsWeldJoint between: first and: second.
	self assert: joint bodyA == first.
	self assert: joint bodyB == second.
	self assert: joint referenceAngle equals: 0.5.
	self assert: joint accumulatedAngularImpulse equals: 0.0.
	self assert: joint linearHertz equals: 0.0.
	self assert: joint linearDampingRatio equals: 0.0.
	self assert: joint angularHertz equals: 0.0.
	self assert: joint angularDampingRatio equals: 0.0.
	^ joint
]
{ #category : 'tests - weld joints' }
CFPhysicsJointTests >> testWeldJointPreparesIndependentLinearAndAngularSoftness [
	<gtExample>
	| owner element world bodyAnchor worldAnchor joint result prepared |
	owner := BlElement new size: 400 @ 300; yourself.
	element := BlElement new size: 20 @ 20; yourself.
	owner addChild: element.
	world := owner physics beWorld.
	world gravity: 0 @ 0.
	world owner physics makeChildrenDynamic.
	element physics position: 0 @ 0.
	bodyAnchor := element physics localAnchorAt: 10 @ 10.
	worldAnchor := world anchorAt: 10 @ 10.
	joint := bodyAnchor weldJointTo: worldAnchor.
	joint
		linearHertz: 4.0;
		linearDampingRatio: 0.5;
		angularHertz: 7.0;
		angularDampingRatio: 0.75.
	result := world step.
	prepared := result constraints first.
	self assert: prepared linearSoftnessEnabled.
	self assert: prepared angularSoftnessEnabled.
	self assert: (prepared linearBiasRate > 0.0).
	self assert: (prepared angularBiasRate > 0.0).
	self assert: ((prepared linearBiasRate closeTo: prepared angularBiasRate) not).
	^ prepared
]
{ #category : 'tests - weld joints' }
CFPhysicsJointTests >> testWeldJointAnchorsABodyOrientationToTheWorld [
	<gtExample>
	| owner element world bodyAnchor worldAnchor joint result |
	owner := BlElement new size: 400 @ 300; yourself.
	element := BlElement new size: 20 @ 20; yourself.
	owner addChild: element.
	world := owner physics beWorld.
	world gravity: 0 @ 0.
	world owner physics makeChildrenDynamic.
	element physics position: 0 @ 0.
	bodyAnchor := element physics localAnchorAt: 10 @ 10.
	worldAnchor := world anchorAt: 10 @ 10.
	joint := bodyAnchor weldJointTo: worldAnchor.
	element physics angularVelocity: 10.0.
	result := world step.
	self assert: world weldJoints equals: { joint }.
	self assert: result constraints size equals: 1.
	self assert: result constraints first class equals: CFPhysicsPreparedWeldJoint.
	self assert: result islands size equals: 1.
	self assert: (element physics angularVelocity closeTo: 0.0).
	^ result
]
{ #category : 'tests - weld joints' }
CFPhysicsJointTests >> testWeldJointPreparationUnwindsTheReferenceAngleError [
	<gtExample>
	| first second firstAnchor secondAnchor joint builder bodyStates step prepared |
	first := self newBodyWithSequence: 1 position: 0 @ 0 extent: 20 @ 20.
	second := self newBodyWithSequence: 2 position: 20 @ 0 extent: 20 @ 20.
	first rotation: 3.1.
	second rotation: -3.1.
	firstAnchor := CFPhysicsLocalAnchor on: first at: 10 @ 10.
	secondAnchor := CFPhysicsLocalAnchor on: second at: 10 @ 10.
	joint := CFPhysicsWeldJoint betweenAnchor: firstAnchor andAnchor: secondAnchor.
	joint referenceAngle: 0.0.
	bodyStates := IdentityDictionary new
		at: first put: (CFPhysicsBodyStepState on: first);
		at: second put: (CFPhysicsBodyStepState on: second);
		yourself.
	step := CFPhysicsStep
		timeStep: 1.0 / 60.0
		substeps: 4
		contactHertz: 30.0
		dampingRatio: 10.0.
	builder := CFPhysicsWeldJointConstraintBuilder new.
	prepared := builder constraintFrom: joint bodyStates: bodyStates step: step.
	self assert: (prepared baseAngle closeTo: (2.0 * Float pi) - 6.2).
	^ prepared
]
{ #category : 'tests - motor joints' }
CFPhysicsJointTests >> testMotorJointPreservesConfiguredRelativeTransform [
	<gtExample>
	| owner firstElement secondElement world first second joint |
	owner := BlElement new size: 200 @ 200; yourself.
	firstElement := BlElement new size: 20 @ 20; yourself.
	secondElement := BlElement new size: 20 @ 20; yourself.
	owner addChildren: { firstElement. secondElement }.
	world := owner physics beWorld.
	world gravity: 0 @ 0.
	world owner physics makeChildrenDynamic.
	first := firstElement physics body.
	second := secondElement physics body.
	first position: 0 @ 0.
	first beStatic.
	second position: 40 @ 0.
	joint := CFPhysicsMotorJoint between: first and: second.
	joint maximumForce: 100000.0; maximumTorque: 100000.0.
	world addMotorJoint: joint.
	second position: 80 @ 0.
	10 timesRepeat: [ world step ].
	self assert: second position x < 80.
	^ joint
]
{ #category : 'tests - motor joints' }
CFPhysicsJointTests >> testMotorJointPreservesRelativeTransformBetweenDynamicBodies [
	<gtExample>
	| owner firstElement secondElement world first second joint initialCentre |
	owner := BlElement new size: 200 @ 200; yourself.
	firstElement := BlElement new size: 20 @ 20; yourself.
	secondElement := BlElement new size: 20 @ 20; yourself.
	owner addChildren: { firstElement. secondElement }.
	world := owner physics beWorld.
	world gravity: 0 @ 0.
	world owner physics makeChildrenDynamic.
	first := firstElement physics body.
	second := secondElement physics body.
	first position: 0 @ 0.
	second position: 40 @ 0.
	initialCentre := (first position + second position) / 2.0.
	joint := CFPhysicsMotorJoint between: first and: second.
	joint maximumForce: 100000.0; maximumTorque: 100000.0.
	world addMotorJoint: joint.
	second position: 80 @ 0.
	10 timesRepeat: [ world step ].
	self assert: (second position - first position) x < 80.0.
	self assert: (second position - first position) x > 40.0.
	self assert: (((first position + second position) / 2.0) x closeTo: initialCentre x + 20.0).
	^ joint
]
{ #category : 'tests - motor joints' }
CFPhysicsJointTests >> testMotorJointLinearImpulseIsCappedBySubstepForce [
	<gtExample>
	| owner firstElement secondElement world first second joint state solution prepared expectedMaximum |
	owner := BlElement new size: 200 @ 200; yourself.
	firstElement := BlElement new size: 20 @ 20; yourself.
	secondElement := BlElement new size: 20 @ 20; yourself.
	owner addChildren: { firstElement. secondElement }.
	world := owner physics beWorld.
	world gravity: 0 @ 0.
	world owner physics makeChildrenDynamic.
	first := firstElement physics body.
	second := secondElement physics body.
	first position: 0 @ 0.
	first beStatic.
	second position: 40 @ 0.
	joint := CFPhysicsMotorJoint between: first and: second.
	joint maximumForce: 100.0; maximumTorque: 0.0.
	world addMotorJoint: joint.
	second position: 80 @ 0.
	state := world captureStateAfterSynchronisation.
	solution := world stepPipeline solve: state.
	prepared := solution pipelineResult jointConstraints
		detect: [ :each | each class == CFPhysicsPreparedMotorJoint ].
	expectedMaximum := state step substepTime * joint maximumForce.
	self assert: (prepared maximumLinearImpulse closeTo: expectedMaximum).
	self assert: prepared linearImpulse r <= expectedMaximum.
	self assert: prepared linearImpulse r > 0.0.
	^ prepared
]
{ #category : 'tests - motor joints' }
CFPhysicsJointTests >> testMotorJointLinearOffsetMatchesBox2DWithRotatedBodyA [
	<gtExample>
	| owner firstElement secondElement world first second joint state prepared |
	owner := BlElement new size: 200 @ 200; yourself.
	firstElement := BlElement new size: 20 @ 20; yourself.
	secondElement := BlElement new size: 20 @ 20; yourself.
	owner addChildren: { firstElement. secondElement }.
	world := owner physics beWorld.
	world gravity: 0 @ 0.
	world owner physics makeChildrenDynamic.
	first := firstElement physics body.
	second := secondElement physics body.
	first position: 0 @ 0; rotation: Float pi / 2.0.
	second position: 40 @ 0.
	joint := CFPhysicsMotorJoint between: first and: second.
	world addMotorJoint: joint.
	state := world captureStateAfterSynchronisation.
	prepared := (CFPhysicsMotorJointConstraintBuilder new
		constraintsFrom: state joints
		bodyStates: state bodyStates
		step: state step) first.
	self assert: joint linearOffset equals: 40 @ 0.
	self assert: (prepared baseLinearSeparation closeTo: 0 @ 0).
	^ prepared
]
{ #category : 'tests - motor joints' }
CFPhysicsJointTests >> testMotorJointAngularDriveUsesTheShortestArcAcrossWrap [
	<gtExample>
	| first second joint bodyStates step prepared solver firstState secondState |
	first := self newBodyWithSequence: 1 position: 0 @ 0 extent: 20 @ 20.
	second := self newBodyWithSequence: 2 position: 20 @ 0 extent: 20 @ 20.
	joint := CFPhysicsMotorJoint between: first and: second.
	joint maximumForce: 0.0; maximumTorque: 100000.0.
	bodyStates := IdentityDictionary new
		at: first put: (CFPhysicsBodyStepState on: first);
		at: second put: (CFPhysicsBodyStepState on: second);
		yourself.
	step := CFPhysicsStep
		timeStep: 1.0 / 60.0
		substeps: 4
		contactHertz: 30.0
		dampingRatio: 10.0.
	prepared := (CFPhysicsMotorJointConstraintBuilder new
		constraintsFrom: { joint }
		bodyStates: bodyStates
		step: step) first.
	firstState := bodyStates at: first.
	secondState := bodyStates at: second.
	firstState angularVelocity: 3.1 / step substepTime.
	secondState angularVelocity: -3.1 / step substepTime.
	firstState integratePositionBy: step substepTime.
	secondState integratePositionBy: step substepTime.
	firstState angularVelocity: 0.0.
	secondState angularVelocity: 0.0.
	solver := CFPhysicsSoftStepSolver
		step: step
		bodyStates: { firstState. secondState }
		constraints: #().
	solver solveMotorJointConstraint: prepared biasEnabled: true.
	self assert: firstState angularVelocity > 0.0.
	self assert: secondState angularVelocity < 0.0.
	^ prepared
]
{ #category : 'tests - prismatic joints' }
CFPhysicsJointTests >> testPrismaticJointMotorDrivesAlongItsLocalAxis [
	<gtExample>
	| owner element world joint |
	owner := BlElement new size: 400 @ 300; yourself.
	element := BlElement new size: 20 @ 20; yourself.
	owner addChild: element.
	world := owner physics beWorld.
	world gravity: 0 @ 0.
	world owner physics makeChildrenDynamic.
	joint := (element physics localAnchorAt: 10 @ 10)
		prismaticJointTo: (world anchorAt: 10 @ 10)
		along: 1 @ 0.
	joint motorEnabled: true; motorSpeed: 100.0; maximumMotorForce: 100000.0.
	world step.
	self assert: element physics velocity x > 0.0.
	self assert: (element physics velocity y closeTo: 0.0).
	^ joint
]
{ #category : 'tests - prismatic joints' }
CFPhysicsJointTests >> testPrismaticJointSpringTargetsTranslation [
	<gtExample>
	| owner element world joint initialError |
	owner := BlElement new size: 400 @ 300; yourself.
	element := BlElement new size: 20 @ 20; yourself.
	owner addChild: element.
	world := owner physics beWorld.
	world gravity: 0 @ 0.
	world owner physics makeChildrenDynamic.
	joint := (element physics localAnchorAt: 10 @ 10)
		prismaticJointTo: (world anchorAt: 10 @ 10)
		along: 1 @ 0.
	joint springEnabled: true; targetTranslation: 20.0; hertz: 5.0; dampingRatio: 1.0.
	initialError := 20.0.
	10 timesRepeat: [ world step ].
	self assert: (20.0 - element physics position x) abs < initialError.
	^ joint
]
{ #category : 'tests - prismatic joints' }
CFPhysicsJointTests >> testPrismaticJointAxisRotatesWithBodyA [
	<gtExample>
	| owner firstElement secondElement world joint state prepared |
	owner := BlElement new size: 400 @ 300; yourself.
	firstElement := BlElement new size: 20 @ 20; yourself.
	secondElement := BlElement new size: 20 @ 20; yourself.
	owner addChildren: { firstElement. secondElement }.
	world := owner physics beWorld.
	world gravity: 0 @ 0.
	world owner physics makeChildrenDynamic.
	firstElement physics rotation: Float pi / 2.0.
	joint := (firstElement physics localAnchorAt: 10 @ 10)
		prismaticJointTo: (secondElement physics localAnchorAt: 10 @ 10)
		along: 0 @ 1.
	state := world captureStateAfterSynchronisation.
	prepared := (CFPhysicsPrismaticJointConstraintBuilder new constraintsFrom: state joints bodyStates: state bodyStates step: state step) first.
	self assert: (joint localAxisA closeTo: 1 @ 0).
	self assert: (prepared axis closeTo: 0 @ 1).
	^ prepared
]
{ #category : 'tests - joint lifecycle' }
CFPhysicsJointTests >> testCreatingAJointBetweenSleepingIslandsKeepsBothIslandsSleeping [
	<gtExample>
	| world graph first second joint island |
	world := CFPhysicsWorld new.
	graph := world persistentIslandGraph.
	first := self newBodyWithSequence: 1.
	second := self newBodyWithSequence: 2.
	first world: world.
	second world: world.
	first sleepLocally.
	second sleepLocally.
	joint := CFPhysicsDistanceJoint between: first and: second.
	world addDistanceJoint: joint.
	graph mergeIslands.
	island := graph islandForBody: first.
	self assert: first isSleeping.
	self assert: second isSleeping.
	self assert: (graph islandForBody: second) == island.
	self assert: (graph islandForConstraint: joint) == island.
	^ joint
]
{ #category : 'tests - joint lifecycle' }
CFPhysicsJointTests >> testCreatingAJointBetweenAwakeAndSleepingIslandsWakesTheSleepingIsland [
	<gtExample>
	| world graph first second joint island |
	world := CFPhysicsWorld new.
	graph := world persistentIslandGraph.
	first := self newBodyWithSequence: 1.
	second := self newBodyWithSequence: 2.
	first world: world.
	second world: world.
	second sleepLocally.
	joint := CFPhysicsDistanceJoint between: first and: second.
	world addDistanceJoint: joint.
	graph mergeIslands.
	island := graph islandForBody: first.
	self assert: first isAwake.
	self assert: second isAwake.
	self assert: (graph islandForBody: second) == island.
	self assert: (graph islandForConstraint: joint) == island.
	^ joint
]
