Class {
	#name : 'CFMotionAppearanceOperation',
	#superclass : 'Object',
	#instVars : [ 'container', 'element', 'operation', 'kind', 'insertionIndex', 'effect' ],
	#category : 'BVC-Foundation-Motion-Effects',
	#package : 'BVC-Foundation-Motion-Effects'
}

{ #category : 'instance creation' }
CFMotionAppearanceOperation class >> appear: anElement in: aContainer duration: aDuration easing: anInterpolator [
	^ self
		appear: anElement
		in: aContainer
		at: nil
		using: CFMotionEffects scaleAndFadeIn
		duration: aDuration
		easing: anInterpolator
]

{ #category : 'instance creation' }
CFMotionAppearanceOperation class >> appear: anElement in: aContainer using: anEffect duration: aDuration easing: anInterpolator [
	^ self appear: anElement in: aContainer at: nil using: anEffect duration: aDuration easing: anInterpolator
]

{ #category : 'instance creation' }
CFMotionAppearanceOperation class >> appear: anElement in: aContainer at: anIndex duration: aDuration easing: anInterpolator [
	^ self
		appear: anElement
		in: aContainer
		at: anIndex
		using: CFMotionEffects scaleAndFadeIn
		duration: aDuration
		easing: anInterpolator
]

{ #category : 'instance creation' }
CFMotionAppearanceOperation class >> appear: anElement in: aContainer at: anIndex using: anEffect duration: aDuration easing: anInterpolator [
	^ self new
		container: aContainer;
		element: anElement;
		insertionIndex: anIndex;
		effect: anEffect;
		kind: #appear;
		startWithDuration: aDuration easing: anInterpolator;
		yourself
]

{ #category : 'instance creation' }
CFMotionAppearanceOperation class >> disappear: anElement duration: aDuration easing: anInterpolator [
	^ self disappear: anElement using: CFMotionEffects scaleAndFadeOut duration: aDuration easing: anInterpolator
]

{ #category : 'instance creation' }
CFMotionAppearanceOperation class >> disappear: anElement using: anEffect duration: aDuration easing: anInterpolator [
	anElement hasParent ifFalse: [ self error: 'A disappearing element must have a parent' ].
	^ self new
		container: anElement parent;
		element: anElement;
		effect: anEffect;
		kind: #disappear;
		startWithDuration: aDuration easing: anInterpolator;
		yourself
]

{ #category : 'controlling' }
CFMotionAppearanceOperation >> cancel [
	operation ifNotNil: [ operation cancelAndRestore ].
	kind = #appear ifTrue: [ self removeElementIfPresent ].
	^ self
]

{ #category : 'accessing' }
CFMotionAppearanceOperation >> container [ ^ container ]

{ #category : 'accessing' }
CFMotionAppearanceOperation >> container: anElement [ container := anElement ]

{ #category : 'accessing' }
CFMotionAppearanceOperation >> element [ ^ element ]

{ #category : 'accessing' }
CFMotionAppearanceOperation >> element: anElement [ element := anElement ]

{ #category : 'accessing' }
CFMotionAppearanceOperation >> effect [ ^ effect ]

{ #category : 'accessing' }
CFMotionAppearanceOperation >> effect: anEffect [ effect := anEffect ]

{ #category : 'testing' }
CFMotionAppearanceOperation >> isCancelled [ ^ operation isCancelled ]

{ #category : 'testing' }
CFMotionAppearanceOperation >> isCompleted [ ^ operation isCompleted ]

{ #category : 'testing' }
CFMotionAppearanceOperation >> isRunning [ ^ operation isRunning ]

{ #category : 'accessing' }
CFMotionAppearanceOperation >> insertionIndex [ ^ insertionIndex ]

{ #category : 'accessing' }
CFMotionAppearanceOperation >> insertionIndex: anInteger [ insertionIndex := anInteger ]

{ #category : 'accessing' }
CFMotionAppearanceOperation >> kind [ ^ kind ]

{ #category : 'accessing' }
CFMotionAppearanceOperation >> kind: aSymbol [ kind := aSymbol ]

{ #category : 'accessing' }
CFMotionAppearanceOperation >> operation [ ^ operation ]

{ #category : 'private - controlling' }
CFMotionAppearanceOperation >> removeElementIfPresent [
	element hasParent ifTrue: [ element parent removeChild: element ]
]

{ #category : 'private - starting' }
CFMotionAppearanceOperation >> startWithDuration: aDuration easing: anInterpolator [
	kind = #appear
		ifTrue: [ self startAppearingWithDuration: aDuration easing: anInterpolator ]
		ifFalse: [ self startDisappearingWithDuration: aDuration easing: anInterpolator ]
]

{ #category : 'private - starting' }
CFMotionAppearanceOperation >> startAppearingWithDuration: aDuration easing: anInterpolator [
	container isAttachedToSceneGraph ifFalse: [
		self error: 'An appearance container must be attached to a BlSpace' ].
	element hasParent ifTrue: [
		self error: 'An appearing element must be detached before insertion' ].
	insertionIndex
		ifNil: [ container addChild: element ]
		ifNotNil: [ container addChild: element at: insertionIndex ].
	element
		visibility: BlVisibility visible;
		opacity: 0.0.
	operation := effect playOn: element duration: aDuration easing: anInterpolator
]

{ #category : 'private - starting' }
CFMotionAppearanceOperation >> startDisappearingWithDuration: aDuration easing: anInterpolator [
	operation := effect playOn: element duration: aDuration easing: anInterpolator.
	operation onTerminalDo: [ :aCompletedOperation |
		(aCompletedOperation isCompleted and: [ element opacity closeTo: 0.0 ]) ifTrue: [
			self removeElementIfPresent ] ]
]
