Class {
	#name : 'CFPhysicsOrientationRestoringExamples',
	#superclass : 'Object',
	#category : 'BVC-Foundation-Physics-Tests-Examples',
	#package : 'BVC-Foundation-Physics-Tests'
}

{ #category : 'examples - orientation restoring' }
CFPhysicsOrientationRestoringExamples >> orientationRestoringReturnsItsElementToCapturedRotation [
	<gtExample>
	| owner element world behaviour target |
	owner := BlElement new size: 400 @ 300; yourself.
	element := BlElement new size: 80 @ 40; yourself.
	owner addChild: element.
	world := owner physics beWorld.
	world gravity: 0 @ 0.
	world synchroniseMembership.
	target := 0.35.
	element physics rotation: target.
	behaviour := element physics restoreOrientation.
	behaviour stiffness: 36.0; damping: 6.0.
	world step.
	element physics rotation: target + 0.8; angularVelocity: 4.0.
	1 to: 360 do: [ :index | world step ].
	self assert: ((element physics rotation - target) abs < 0.003).
	self assert: (element physics angularVelocity abs < 0.02).
	^ behaviour
]

{ #category : 'examples - orientation restoring' }
CFPhysicsOrientationRestoringExamples >> orientationRestoringUsesTheShortestAngularPath [
	<gtExample>
	| owner element world behaviour initialVelocity |
	owner := BlElement new size: 400 @ 300; yourself.
	element := BlElement new size: 80 @ 40; yourself.
	owner addChild: element.
	world := owner physics beWorld.
	world gravity: 0 @ 0.
	world synchroniseMembership.
	element physics rotation: Float pi - 0.1.
	behaviour := element physics restoreOrientation.
	world step.
	element physics rotation: Float pi negated + 0.1.
	world step.
	initialVelocity := element physics angularVelocity.
	self assert: initialVelocity < 0.0.
	^ behaviour
]

{ #category : 'examples - orientation restoring' }
CFPhysicsOrientationRestoringExamples >> orientationRestoringActsOnlyOnItsAttachedElement [
	<gtExample>
	| owner first second world behaviour secondRotation |
	owner := BlElement new size: 400 @ 300; yourself.
	first := BlElement new size: 80 @ 40; yourself.
	second := BlElement new size: 80 @ 40; yourself.
	owner addChildren: { first. second }.
	world := owner physics beWorld.
	world gravity: 0 @ 0.
	world synchroniseMembership.
	behaviour := first physics restoreOrientation.
	world step.
	first physics rotation: 0.8.
	secondRotation := 0.6.
	second physics rotation: secondRotation.
	world step.
	self assert: first physics angularVelocity isZero not.
	self assert: second physics rotation equals: secondRotation.
	self assert: second physics angularVelocity isZero.
	^ behaviour
]

{ #category : 'examples - orientation restoring' }
CFPhysicsOrientationRestoringExamples >> orientationRestoringAllowsFastCollisionSpinToDecayNaturally [
	<gtExample>
	| behaviour slowResponse fastResponse |
	behaviour := CFPhysicsOrientationRestoringBehaviour new
		angularResponseVelocityScale: 4.0;
		yourself.
	slowResponse := behaviour responseFactorForAngularVelocity: 1.0.
	fastResponse := behaviour responseFactorForAngularVelocity: 12.0.
	self assert: fastResponse < slowResponse.
	self assert: fastResponse > 0.0.
	self assert: slowResponse < 1.0.
	^ behaviour
]
