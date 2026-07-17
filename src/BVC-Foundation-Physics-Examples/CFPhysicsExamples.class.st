Class {
	#name : 'CFPhysicsExamples',
	#superclass : 'Object',
	#category : 'BVC-Foundation-Physics-Examples',
	#package : 'BVC-Foundation-Physics-Examples'
}

{ #category : 'examples - worlds' }
CFPhysicsExamples >> nestedPhysicsWorlds [
	<gtExample>
	| root outerBody nestedWorldElement nestedBody outerWorld nestedWorld |
	root := BlElement new.
	outerBody := BlElement new.
	nestedWorldElement := BlElement new.
	nestedBody := BlElement new.
	root addChild: outerBody.
	root addChild: nestedWorldElement.
	nestedWorldElement addChild: nestedBody.
	outerWorld := root physics beWorld.
	nestedWorld := nestedWorldElement physics beWorld.
	outerBody physics.
	nestedBody physics.
	outerWorld synchroniseMembership.
	nestedWorld synchroniseMembership.
	self assert: (outerWorld includes: outerBody).
	self assert: (outerWorld includes: nestedWorldElement).
	self deny: (outerWorld includes: nestedBody).
	self assert: (nestedWorld includes: nestedBody).
	^ root
]

{ #category : 'examples - worlds' }
CFPhysicsExamples >> physicsWorldWithOneBody [
	<gtExample>
	| root body world |
	root := BlElement new.
	body := BlElement new.
	root addChild: body.
	world := root physics beWorld.
	body physics.
	world synchroniseMembership.
	self assert: (world includes: body).
	^ root
]
