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
	self assert: (outerWorld includes: nestedBody) not.
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


{ #category : 'examples - presentation' }
CFPhysicsExamples >> manuallyPresentedBodyPose [
	<gtExample>
	| space worldElement body world |
	space := BlSpace new.
	worldElement := BlElement new
		size: 600 @ 400;
		yourself.
	body := BlElement new
		size: 80 @ 50;
		background: Color blue;
		yourself.
	space root addChild: worldElement.
	worldElement addChild: body.
	world := worldElement physics beWorld.
	body physics.
	world synchroniseMembership.
	body physics translation: 240 @ 140 rotation: 0.35.
	self assert: body physics position equals: 240 @ 140.
	self assert: body physics rotation equals: 0.35.
	self assert: body physics presentation isAttached.
	^ space
]
