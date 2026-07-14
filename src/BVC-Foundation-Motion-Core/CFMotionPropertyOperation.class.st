Class {
	#name : 'CFMotionPropertyOperation',
	#superclass : 'Object',
	#instVars : [
		'element', 'property', 'propertyKey', 'coordinator', 'animation',
		'duration', 'easing', 'targetValue', 'generation', 'cancelled', 'completed'
	],
	#category : 'BVC-Foundation-Motion-Core',
	#package : 'BVC-Foundation-Motion-Core'
}

{ #category : 'instance creation' }
CFMotionPropertyOperation class >> on: anElement property: aProperty [
	^ self new element: anElement; property: aProperty; initializeCoordinator; yourself
]

{ #category : 'initialization' }
CFMotionPropertyOperation >> initialize [
	super initialize.
	duration := 180 milliSeconds.
	easing := BlDecelerateInterpolator factor: 1.4.
	generation := 0.
	cancelled := false.
	completed := false
]

{ #category : 'accessing' }
CFMotionPropertyOperation >> element: anElement [ element := anElement ]

{ #category : 'accessing' }
CFMotionPropertyOperation >> property: aProperty [
	property := aProperty.
	propertyKey := CFMotionPropertyKey element: element property: property
]

{ #category : 'initialization' }
CFMotionPropertyOperation >> initializeCoordinator [
	element isAttachedToSceneGraph
		ifFalse: [ self error: 'A motion subject must be attached to a BlSpace' ].
	coordinator := element space cfMotionCoordinator
]

{ #category : 'configuration' }
CFMotionPropertyOperation >> duration: aDuration [ duration := aDuration ]

{ #category : 'configuration' }
CFMotionPropertyOperation >> easing: anInterpolator [ easing := anInterpolator ]

{ #category : 'testing' }
CFMotionPropertyOperation >> isRunning [ ^ animation notNil and: [ animation isRunning ] ]

{ #category : 'testing' }
CFMotionPropertyOperation >> isCancelled [ ^ cancelled ]

{ #category : 'testing' }
CFMotionPropertyOperation >> isCompleted [ ^ completed ]

{ #category : 'accessing' }
CFMotionPropertyOperation >> targetValue [ ^ targetValue ]

{ #category : 'playing' }
CFMotionPropertyOperation >> retargetTo: aValue [
	| owner |
	owner := coordinator ownerOf: propertyKey.
	(owner notNil and: [ owner ~~ self ])
		ifTrue: [ ^ owner retargetTo: aValue ].
	cancelled := false.
	completed := false.
	targetValue := aValue.
	coordinator claim: propertyKey for: self.
	self startFromCurrentPresentation.
	^ self
]

{ #category : 'private - playing' }
CFMotionPropertyOperation >> startFromCurrentPresentation [
	| currentValue currentGeneration newAnimation |
	generation := generation + 1.
	currentGeneration := generation.
	animation ifNotNil: [ :oldAnimation |
		animation := nil.
		oldAnimation stopIfRunning ].
	currentValue := property valueOf: element.
	currentValue = targetValue ifTrue: [
		property value: targetValue of: element.
		completed := true.
		coordinator release: propertyKey from: self.
		^ self ].
	newAnimation := BlNumberTransition new
		from: currentValue;
		to: targetValue;
		duration: duration;
		easing: easing;
		onStepDo: [ :value | property value: value of: element ];
		yourself.
	animation := newAnimation.
	newAnimation onFinishedDo: [
		(animation == newAnimation and: [ generation = currentGeneration ]) ifTrue: [
			animation := nil.
			cancelled ifFalse: [
				property value: targetValue of: element.
				completed := true ].
			coordinator release: propertyKey from: self ] ].
	element addAnimation: newAnimation
]

{ #category : 'controlling' }
CFMotionPropertyOperation >> cancel [
	generation := generation + 1.
	cancelled := true.
	completed := false.
	animation ifNotNil: [ :current |
		animation := nil.
		current stopIfRunning ].
	coordinator release: propertyKey from: self
]
