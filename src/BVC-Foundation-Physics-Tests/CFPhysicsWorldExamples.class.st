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
	self assert: (body physics owningWorld == outerWorld) not.
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
	self assert: (firstWorld includes: body) not.
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
	self assert: (nestedWorld includes: nested) not.
	self assert: nested physics owningWorld == outerWorld.
	^ nested
]


{ #category : 'examples - worlds' }
CFPhysicsWorldExamples >> ownedWorldAndOwningWorldAreDistinct [
    <gtExample>
    | owner body world |
    owner := BlElement new.
    body := BlElement new.
    owner addChild: body.
    world := owner physics beWorld.
    world synchroniseMembership.
    self assert: owner physics ownedWorld equals: world.
    self assert: body physics ownedWorld equals: nil.
    self assert: body physics owningWorld equals: world.
    ^ body
]
