Class {
	#name : 'CFMotionExamples',
	#superclass : 'Object',
	#category : 'BVC-Foundation-Motion-Examples',
	#package : 'BVC-Foundation-Motion-Examples'
}

{ #category : 'examples - setup' }
CFMotionExamples >> spaceWithElement [
	| space element |
	space := BlSpace new.
	element := BlElement new
		size: 120 @ 80;
		background: Color veryLightGray;
		yourself.
	space root addChild: element.
	space pulse.
	^ space
]

{ #category : 'examples - property motion' }
CFMotionExamples >> opacityCompletes [
	<gtExample>
	| space element operation |
	space := self spaceWithElement.
	element := space root children first.
	element opacity: 0.2.
	operation := element motion
		duration: 1 milliSeconds;
		opacity: 1.0.
	self finish: operation in: space.
	self assert: operation isCompleted.
	self assert: element opacity equals: 1.0.
	^ operation
]

{ #category : 'examples - retargeting' }
CFMotionExamples >> opacityRetargetsFromCurrentPresentation [
	<gtExample>
	| space element first second key |
	space := self spaceWithElement.
	element := space root children first.
	element opacity: 0.2.
	first := element motion opacity: 1.0.
	element opacity: 0.6.
	second := element motion opacity: 0.8.
	key := CFMotionPropertyKey
		element: element
		property: CFOpacityMotionProperty uniqueInstance.
	self assert: first == second.
	self assert: (first tracks first startValue) equals: 0.6.
	self assert: (first tracks first targetValue) equals: 0.8.
	self assert: (space cfMotionCoordinator ownerOf: key) == first.
	^ first
]

{ #category : 'examples - ownership' }
CFMotionExamples >> opacityReplacementKeepsOneOwner [
	<gtExample>
	| space element first second key |
	space := self spaceWithElement.
	element := space root children first.
	first := element motion opacity: 0.2.
	second := element motion opacity: 0.8.
	key := CFMotionPropertyKey
		element: element
		property: CFOpacityMotionProperty uniqueInstance.
	self assert: first == second.
	self assert: (space cfMotionCoordinator ownerOf: key) == first.
	self assert: space cfMotionCoordinator activeOperations size equals: 1.
	^ first
]

{ #category : 'examples - cancellation' }
CFMotionExamples >> opacityCancellationPreservesCurrentPresentation [
	<gtExample>
	| space element operation |
	space := self spaceWithElement.
	element := space root children first.
	element opacity: 0.2.
	operation := element motion opacity: 1.0.
	element opacity: 0.6.
	operation cancelPreservingCurrentPresentation.
	self assert: operation isCancelled.
	self assert: element opacity equals: 0.6.
	^ operation
]

{ #category : 'examples - cleanup' }
CFMotionExamples >> opacityCleanupReleasesOwnership [
	<gtExample>
	| space element operation key |
	space := self spaceWithElement.
	element := space root children first.
	operation := element motion opacity: 0.2.
	key := CFMotionPropertyKey
		element: element
		property: CFOpacityMotionProperty uniqueInstance.
	operation cancelSettlingAtEnd.
	self assert: (space cfMotionCoordinator ownerOf: key) isNil.
	self assert: space cfMotionCoordinator activeOperations isEmpty.
	^ operation
]

{ #category : 'examples - inspection' }
CFMotionExamples >> opacityOperationIsInspectable [
	<gtExample>
	| space element operation |
	space := self spaceWithElement.
	element := space root children first.
	operation := element motion opacity: 0.2.
	self assert: operation coordinator == space cfMotionCoordinator.
	self assert: operation tracks size equals: 1.
	self assert: operation trace entries isNotEmpty.
	^ operation
]

{ #category : 'private - running' }
CFMotionExamples >> finish: anOperation in: aSpace [
	aSpace pulse.
	5 milliSeconds wait.
	aSpace pulse.
	^ anOperation
]
