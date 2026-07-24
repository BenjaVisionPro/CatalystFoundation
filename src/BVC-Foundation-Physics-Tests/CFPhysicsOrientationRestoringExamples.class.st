Class {
	#name : 'CFPhysicsOrientationRestoringExamples',
	#superclass : 'Object',
	#category : 'BVC-Foundation-Physics-Tests-Examples',
	#package : 'BVC-Foundation-Physics-Tests'
}

{ #category : 'examples - orientation restoring' }
CFPhysicsOrientationRestoringExamples >> orientationRestoringReturnsABodyToItsCapturedRotation [
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
	behaviour := owner physics restoreOrientations.
	behaviour
		nodes: { element };
		stiffness: 36.0;
		damping: 6.0;
		angularDamping: 8.0.
	world step.
	element physics
		rotation: target + 0.8;
		angularVelocity: 4.0.
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
	behaviour := owner physics restoreOrientations.
	behaviour nodes: { element }.
	world step.
	element physics rotation: Float pi negated + 0.1.
	world step.
	initialVelocity := element physics angularVelocity.
	self assert: initialVelocity < 0.0.
	^ behaviour
]

{ #category : 'examples - orientation restoring' }
CFPhysicsOrientationRestoringExamples >> orientationRestoringRestoresBodyConfigurationWhenRemoved [
	<gtExample>
	| owner element world behaviour |
	owner := BlElement new size: 400 @ 300; yourself.
	element := BlElement new size: 80 @ 40; yourself.
	owner addChild: element.
	world := owner physics beWorld.
	world synchroniseMembership.
	element physics
		density: 1.25;
		angularDamping: 2.0.
	behaviour := owner physics restoreOrientations.
	behaviour
		nodes: { element };
		density: 2.5;
		angularDamping: 8.0.
	world step.
	self assert: element physics density equals: 2.5.
	self assert: element physics angularDamping equals: 8.0.
	behaviour remove.
	self assert: element physics density equals: 1.25.
	self assert: element physics angularDamping equals: 2.0.
	^ element
]
