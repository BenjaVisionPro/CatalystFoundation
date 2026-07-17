Class {
	#name : 'CFPhysicsPresentationExamples',
	#superclass : 'Object',
	#category : 'BVC-Foundation-Physics-Tests',
	#package : 'BVC-Foundation-Physics-Tests'
}

{ #category : 'examples - presentation' }
CFPhysicsPresentationExamples >> attachedBodyReceivesPresentation [
	<gtExample>
	| space owner body world bodyState |
	space := BlSpace new.
	owner := BlElement new.
	body := BlElement new.
	space root addChild: owner.
	owner addChild: body.
	world := owner physics beWorld.
	body physics.
	world synchroniseMembership.
	bodyState := world bodyStateFor: body.
	self assert: bodyState notNil.
	self assert: bodyState presentation isAttached.
	body physics translation: 25 @ 30 rotation: 0.2.
	self assert: bodyState presentation ownsCurrentTransformation.
	^ bodyState
]

{ #category : 'examples - presentation' }
CFPhysicsPresentationExamples >> detachedBodyHasNoMotionPresentation [
	<gtExample>
	| owner body world bodyState |
	owner := BlElement new.
	body := BlElement new.
	owner addChild: body.
	world := owner physics beWorld.
	body physics.
	world synchroniseMembership.
	bodyState := world bodyStateFor: body.
	self assert: bodyState notNil.
	self assert: bodyState presentation isAttached not.
	^ bodyState
]

{ #category : 'examples - presentation' }
CFPhysicsPresentationExamples >> leavingWorldReleasesPresentation [
	<gtExample>
	| space owner body world bodyState |
	space := BlSpace new.
	owner := BlElement new.
	body := BlElement new.
	space root addChild: owner.
	owner addChild: body.
	world := owner physics beWorld.
	body physics.
	world synchroniseMembership.
	bodyState := world bodyStateFor: body.
	self assert: bodyState presentation isAttached.
	owner removeChild: body.
	world synchroniseMembership.
	self assert: (world bodyStateFor: body) isNil.
	self assert: bodyState presentation isAttached not.
	^ bodyState
]

{ #category : 'examples - presentation' }
CFPhysicsPresentationExamples >> reattachmentCreatesNewPresentation [
	<gtExample>
	| firstSpace secondSpace owner body world bodyState firstMotionPresentation |
	firstSpace := BlSpace new.
	secondSpace := BlSpace new.
	owner := BlElement new.
	body := BlElement new.
	firstSpace root addChild: owner.
	owner addChild: body.
	world := owner physics beWorld.
	body physics.
	world synchroniseMembership.
	bodyState := world bodyStateFor: body.
	firstMotionPresentation := bodyState presentation motionPresentation.
	firstSpace root removeChild: owner.
	world synchroniseMembership.
	self assert: bodyState presentation isAttached not.
	secondSpace root addChild: owner.
	world synchroniseMembership.
	self assert: bodyState presentation isAttached.
	self assert: bodyState presentation motionPresentation ~~ firstMotionPresentation.
	^ bodyState
]
