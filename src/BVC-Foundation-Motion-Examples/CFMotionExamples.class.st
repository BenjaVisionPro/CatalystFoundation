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
CFMotionExamples >> opacityMotion [
	<gtExample>
	| space element operation |
	space := self spaceWithElement.
	element := space root children first.
	element opacity: 0.2.
	operation := (CFMotion on: element) opacityTo: 1.0.
	self assert: operation targetValue equals: 1.0.
	self assert: (space cfMotionCoordinator ownerOf:
		(CFMotionPropertyKey
			element: element
			property: CFOpacityMotionProperty uniqueInstance)) == operation.
	^ space
]

{ #category : 'examples - retargeting' }
CFMotionExamples >> opacityRetargetsExistingOperation [
	<gtExample>
	| space element first second key |
	space := self spaceWithElement.
	element := space root children first.
	first := (CFMotion on: element) opacityTo: 0.2.
	second := (CFMotion on: element) opacityTo: 0.8.
	key := CFMotionPropertyKey
		element: element
		property: CFOpacityMotionProperty uniqueInstance.
	self assert: first == second.
	self assert: first targetValue equals: 0.8.
	self assert: (space cfMotionCoordinator ownerOf: key) == first.
	^ space
]

{ #category : 'examples - effects' }
CFMotionExamples >> fadeEffect [
	<gtExample>
	| space element operation |
	space := self spaceWithElement.
	element := space root children first.
	element opacity: 0.
	operation := CFMotionEffects fadeIn playOn: element.
	self assert: operation targetValue equals: 1.0.
	^ space
]

{ #category : 'examples - layout' }
CFMotionExamples >> layoutTransaction [
	<gtExample>
	| space container first second transaction |
	space := BlSpace new.
	container := BlElement new
		layout: BlLinearLayout vertical;
		constraintsDo: [ :c |
			c horizontal matchParent.
			c vertical fitContent ];
		yourself.
	first := BlElement new size: 100 @ 40; background: Color veryLightGray; yourself.
	second := BlElement new size: 100 @ 40; background: Color lightGray; yourself.
	container addChildren: { first. second }.
	space root addChild: container.
	space pulse.
	transaction := (CFMotion layoutIn: container)
		affecting: { first. second };
		mutate: [ container addChildFirst: (BlElement new size: 100 @ 30) ];
		play.
	^ space
]
