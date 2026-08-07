Class {
	#name : 'CFPhysicsOrientationRestoringForceTests',
	#superclass : 'TestCase',
	#category : 'BVC-Physics-Tests-Core',
	#package : 'BVC-Physics-Tests-Core'
}

{ #category : 'examples - orientation restoring' }
CFPhysicsOrientationRestoringForceTests >> testOrientationRestoringReturnsItsElementToCapturedRotation [
	<gtExample>
	| owner element world force target |
	owner := BlElement new size: 400 @ 300; yourself.
	element := BlElement new size: 80 @ 40; yourself.
	owner addChild: element.
	world := owner physics beWorld.
	world gravity: 0 @ 0.
	world owner physics makeChildrenDynamic.
	target := 0.35.
	element physics rotation: target.
	force := element physics restoreOrientation.
	world step.
	element physics rotation: target + 0.8; angularVelocity: 4.0.
	1 to: 360 do: [ :index | world step ].
	self assert: ((element physics rotation - target) abs < 0.003).
	self assert: (element physics angularVelocity abs < 0.02).
	^ force
]

{ #category : 'examples - orientation restoring' }
CFPhysicsOrientationRestoringForceTests >> testOrientationRestoringUsesTheShortestAngularPath [
	<gtExample>
	| owner element world force initialVelocity |
	owner := BlElement new size: 400 @ 300; yourself.
	element := BlElement new size: 80 @ 40; yourself.
	owner addChild: element.
	world := owner physics beWorld.
	world gravity: 0 @ 0.
	world owner physics makeChildrenDynamic.
	element physics rotation: Float pi - 0.1.
	force := element physics restoreOrientation.
	element physics rotation: Float pi negated + 0.1.
	world step.
	initialVelocity := element physics angularVelocity.
	self assert: initialVelocity < 0.0.
	^ force
]

{ #category : 'examples - orientation restoring' }
CFPhysicsOrientationRestoringForceTests >> testOrientationRestoringActsOnlyOnItsBody [
	<gtExample>
	| owner first second world force secondRotation |
	owner := BlElement new size: 400 @ 300; yourself.
	first := BlElement new size: 80 @ 40; yourself.
	second := BlElement new size: 80 @ 40; yourself.
	owner addChildren: { first. second }.
	world := owner physics beWorld.
	world gravity: 0 @ 0.
	world owner physics makeChildrenDynamic.
	first physics position: 40 @ 100.
	second physics position: 240 @ 100.
	force := first physics restoreOrientation.
	first physics rotation: 0.8.
	secondRotation := 0.6.
	second physics rotation: secondRotation.
	world step.
	self assert: first physics angularVelocity isZero not.
	self assert: second physics rotation equals: secondRotation.
	self assert: second physics angularVelocity isZero.
	^ force
]

{ #category : 'examples - orientation restoring' }
CFPhysicsOrientationRestoringForceTests >> testOrientationRestoringAllowsFastCollisionSpinToDecayNaturally [
	<gtExample>
	| force slowResponse fastResponse |
	force := CFPhysicsOrientationRestoringForce new
		angularResponseVelocityScale: 4.0;
		yourself.
	slowResponse := force responseFactorForAngularVelocity: 1.0.
	fastResponse := force responseFactorForAngularVelocity: 12.0.
	self assert: fastResponse < slowResponse.
	self assert: fastResponse > 0.0.
	self assert: slowResponse < 1.0.
	^ force
]

{ #category : 'tests - orientation restoring' }
CFPhysicsOrientationRestoringForceTests >> testNonWakingOrientationRestoringForceLeavesSleepingBodyAsleep [
	<gtExample>
	| body force |
	body := CFPhysicsBody new.
	body element: (BlElement new size: 80 @ 40; yourself).
	force := CFPhysicsOrientationRestoringForce new
		body: body;
		wakesBodies: false;
		yourself.
	body rotation: 0.8.
	body putToSleep.
	force applyForStep: 1.0 / 60.0.
	self assert: body isSleeping.
	self assert: body torque equals: 0.0.
	^ force
]
