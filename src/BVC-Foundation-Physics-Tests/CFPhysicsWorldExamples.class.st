Class {
	#name : 'CFPhysicsWorldExamples',
	#superclass : 'Object',
	#category : 'BVC-Foundation-Physics-Tests',
	#package : 'BVC-Foundation-Physics-Tests'
}

{ #category : 'examples - membership' }
CFPhysicsWorldExamples >> nearestAncestorWorldOwnsElement [
	<gtExample>
	| outer nested body outerWorld nestedWorld |
	outer := BlElement new.
	nested := BlElement new.
	body := BlElement new.
	outer addChild: nested.
	nested addChild: body.
	outerWorld := outer physics beWorld.
	nestedWorld := nested physics beWorld.
	body physics.
	self assert: body physics owningWorld == nestedWorld.
	self deny: body physics owningWorld == outerWorld.
	^ body
]

{ #category : 'examples - membership' }
CFPhysicsWorldExamples >> reparentingTransfersMembership [
	<gtExample>
	| firstOwner secondOwner body firstWorld secondWorld |
	firstOwner := BlElement new.
	secondOwner := BlElement new.
	body := BlElement new.
	firstOwner addChild: body.
	firstWorld := firstOwner physics beWorld.
	secondWorld := secondOwner physics beWorld.
	body physics.
	firstWorld synchroniseMembership.
	self assert: (firstWorld includes: body).
	firstOwner removeChild: body.
	secondOwner addChild: body.
	firstWorld synchroniseMembership.
	secondWorld synchroniseMembership.
	self deny: (firstWorld includes: body).
	self assert: (secondWorld includes: body).
	self assert: body physics owningWorld == secondWorld.
	^ body
]

{ #category : 'examples - membership' }
CFPhysicsWorldExamples >> worldOwnerBelongsToAncestorWorldOnly [
	<gtExample>
	| outer nested outerWorld nestedWorld |
	outer := BlElement new.
	nested := BlElement new.
	outer addChild: nested.
	outerWorld := outer physics beWorld.
	nestedWorld := nested physics beWorld.
	outerWorld synchroniseMembership.
	nestedWorld synchroniseMembership.
	self assert: (outerWorld includes: nested).
	self deny: (nestedWorld includes: nested).
	self assert: nested physics owningWorld == outerWorld.
	^ nested
]
