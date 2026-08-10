"
I provide executable regression examples for the private integration seam between Physics and Motion.

I deliberately inspect Physics body-state and Motion presentation objects to verify presentation composition, lifecycle, transform ownership and unit conversion. These examples document integration invariants rather than application-facing Physics API.
"
Class {
	#name : 'CFPhysicsMotionIntegrationExamples',
	#superclass : 'Object',
	#category : 'BVC-Physics-Examples',
	#package : 'BVC-Physics-Examples'
}

{ #category : 'examples - motion integration' }
CFPhysicsMotionIntegrationExamples >> physicsPresentationComposesWithOtherMotionTransforms [
	<gtExample>
	| space host body world state physicsPresentation channel scalePresentation |
	space := BlSpace new.
	host := BlElement new size: 320 @ 200.
	body := BlElement new size: 20 @ 20.
	host addChild: body.
	space root addChild: host.
	space pulse.
	world := host physics beWorld.
	world owner physics makeChildrenDynamic.
	state := world bodyStateFor: body.
	state position: 40 @ 20.
	world present.
	physicsPresentation := (CFPhysicsWorldMotionIntegration for: world) manualPresentation presentationFor: state.
	channel := physicsPresentation channel.
	scalePresentation := CFMotionTransformPresentation on: body using: channel.
	scalePresentation scale: 0.5 @ 0.75.
	self assert: physicsPresentation ownsCurrentTransformation.
	self assert: scalePresentation ownsCurrentTransformation.
	state position: 60 @ 30.
	world present.
	self assert: physicsPresentation ownsCurrentTransformation.
	self assert: scalePresentation ownsCurrentTransformation.
	scalePresentation release.
	self assert: physicsPresentation ownsCurrentTransformation.
	((CFPhysicsWorldMotionIntegration for: world) manualPresentation presentationFor: state) release.
	^ channel
]

{ #category : 'examples - motion integration' }
CFPhysicsMotionIntegrationExamples >> releasingPhysicsPresentationPreservesOtherMotionTransforms [
	<gtExample>
	| space host body applicationTransformation world state physicsPresentation channel scalePresentation |
	space := BlSpace new.
	host := BlElement new size: 320 @ 200.
	body := BlElement new size: 20 @ 20.
	host addChild: body.
	space root addChild: host.
	space pulse.
	body transformDo: [ :builder | builder translateBy: 8 @ 0 ].
	applicationTransformation := body transformation.
	world := host physics beWorld.
	world owner physics makeChildrenDynamic.
	state := world bodyStateFor: body.
	state position: 40 @ 20.
	world present.
	physicsPresentation := (CFPhysicsWorldMotionIntegration for: world) manualPresentation presentationFor: state.
	channel := physicsPresentation channel.
	scalePresentation := CFMotionTransformPresentation on: body using: channel.
	scalePresentation scale: 0.8 @ 0.8.
	((CFPhysicsWorldMotionIntegration for: world) manualPresentation presentationFor: state) release.
	self assert: physicsPresentation isActive not.
	self assert: scalePresentation ownsCurrentTransformation.
	scalePresentation release.
	self assert: body transformation == applicationTransformation.
	^ channel
]

{ #category : 'examples - motion integration' }
CFPhysicsMotionIntegrationExamples >> bodyMutationDoesNotPresentOutsideMotion [
	<gtExample>
	| space host body world state |
	space := BlSpace new.
	host := BlElement new size: 320 @ 200.
	body := BlElement new size: 20 @ 20.
	host addChild: body.
	space root addChild: host.
	space pulse.
	world := host physics beWorld.
	world owner physics makeChildrenDynamic.
	state := world bodyStateFor: body.
	self assert: ((CFPhysicsWorldMotionIntegration for: world) manualPresentation isPresenting: state) not.
	state position: 40 @ 20.
	state rotation: Float pi / 4.0.
	state translation: 60 @ 30 rotation: Float pi / 2.0.
	self assert: state position equals: 60 @ 30.
	self assert: state rotation equals: Float pi / 2.0.
	self assert: ((CFPhysicsWorldMotionIntegration for: world) manualPresentation isPresenting: state) not.
	world present.
	self assert: ((CFPhysicsWorldMotionIntegration for: world) manualPresentation isPresenting: state).
	((CFPhysicsWorldMotionIntegration for: world) manualPresentation presentationFor: state) release.
	^ state
]

{ #category : 'examples - motion integration' }
CFPhysicsMotionIntegrationExamples >> physicsPresentationConvertsPhysicsRotationToMotionDegrees [
	<gtExample>
	| space host body world state presentation |
	space := BlSpace new.
	host := BlElement new size: 320 @ 200.
	body := BlElement new size: 20 @ 20.
	host addChild: body.
	space root addChild: host.
	space pulse.
	world := host physics beWorld.
	world owner physics makeChildrenDynamic.
	state := world bodyStateFor: body.
	state rotation: Float pi / 2.0.
	world present.
	presentation := (CFPhysicsWorldMotionIntegration for: world) manualPresentation presentationFor: state.
	self assert: presentation rotation equals: 90.0.
	presentation release.
	^ presentation
]

{ #category : 'examples - motion integration' }
CFPhysicsMotionIntegrationExamples >> manualPhysicsSteppingDoesNotPresent [
	<gtExample>
	| space host body world state initialPosition |
	space := BlSpace new.
	host := BlElement new size: 320 @ 200.
	body := BlElement new size: 20 @ 20.
	host addChild: body.
	space root addChild: host.
	space pulse.
	world := host physics beWorld.
	world
		gravity: 0 @ 0;
		stepDuration: 10 milliSeconds.
	world owner physics makeChildrenDynamic.
	state := world bodyStateFor: body.
	state
		position: 20 @ 20;
		velocity: 100 @ 0.
	initialPosition := state position.
	world step: 2.
	self assert: state position x > initialPosition x.
	self assert: ((CFPhysicsWorldMotionIntegration for: world) manualPresentation isPresenting: state) not.
	world present.
	self assert: ((CFPhysicsWorldMotionIntegration for: world) manualPresentation isPresenting: state).
	((CFPhysicsWorldMotionIntegration for: world) manualPresentation presentationFor: state) release.
	^ world
]

{ #category : 'examples - motion integration' }
CFPhysicsMotionIntegrationExamples >> stepAndPresentRemainsExplicit [
	<gtExample>
	| space host body world state initialPosition result |
	space := BlSpace new.
	host := BlElement new size: 320 @ 200.
	body := BlElement new size: 20 @ 20.
	host addChild: body.
	space root addChild: host.
	space pulse.
	world := host physics beWorld.
	world
		gravity: 0 @ 0;
		stepDuration: 10 milliSeconds.
	world owner physics makeChildrenDynamic.
	state := world bodyStateFor: body.
	state
		position: 20 @ 20;
		velocity: 100 @ 0.
	initialPosition := state position.
	result := world stepAndPresent.
	self assert: result == world lastStepResult.
	self assert: state position x > initialPosition x.
	self assert: ((CFPhysicsWorldMotionIntegration for: world) manualPresentation isPresenting: state).
	((CFPhysicsWorldMotionIntegration for: world) manualPresentation presentationFor: state) release.
	^ result
]
