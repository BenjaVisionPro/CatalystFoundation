Class {
	#name : 'CFMotionAdoptionOperation',
	#superclass : 'Object',
	#instVars : [ 'container', 'preview', 'committedElement', 'previewIndex', 'operation' ],
	#category : 'BVC-Foundation-Motion-Effects',
	#package : 'BVC-Foundation-Motion-Effects'
}

{ #category : 'instance creation' }
CFMotionAdoptionOperation class >> adopt: aPreview as: aCommittedElement in: aContainer duration: aDuration easing: anInterpolator [
	^ self new
		container: aContainer;
		preview: aPreview;
		committedElement: aCommittedElement;
		startWithDuration: aDuration easing: anInterpolator;
		yourself
]

{ #category : 'controlling' }
CFMotionAdoptionOperation >> cancel [
	operation isCompleted ifTrue: [ ^ self ].
	operation ifNotNil: [ operation cancelAndRestore ].
	self removeCommittedElementIfPresent.
	^ self
]

{ #category : 'accessing' }
CFMotionAdoptionOperation >> committedElement [ ^ committedElement ]

{ #category : 'accessing' }
CFMotionAdoptionOperation >> committedElement: anElement [ committedElement := anElement ]

{ #category : 'accessing' }
CFMotionAdoptionOperation >> container [ ^ container ]

{ #category : 'accessing' }
CFMotionAdoptionOperation >> container: anElement [ container := anElement ]

{ #category : 'testing' }
CFMotionAdoptionOperation >> isCancelled [ ^ operation isCancelled ]

{ #category : 'testing' }
CFMotionAdoptionOperation >> isCompleted [ ^ operation isCompleted ]

{ #category : 'testing' }
CFMotionAdoptionOperation >> isRunning [ ^ operation isRunning ]

{ #category : 'accessing' }
CFMotionAdoptionOperation >> operation [ ^ operation ]

{ #category : 'accessing' }
CFMotionAdoptionOperation >> preview [ ^ preview ]

{ #category : 'accessing' }
CFMotionAdoptionOperation >> preview: anElement [ preview := anElement ]

{ #category : 'accessing' }
CFMotionAdoptionOperation >> previewIndex [ ^ previewIndex ]

{ #category : 'private - controlling' }
CFMotionAdoptionOperation >> removeCommittedElementIfPresent [
	committedElement hasParent ifTrue: [ committedElement parent removeChild: committedElement ]
]

{ #category : 'private - controlling' }
CFMotionAdoptionOperation >> removePreviewIfPresent [
	preview hasParent ifTrue: [ preview parent removeChild: preview ]
]

{ #category : 'private - starting' }
CFMotionAdoptionOperation >> startWithDuration: aDuration easing: anInterpolator [
	self validateBeforeStarting.
	previewIndex := container children indexOf: preview.
	committedElement opacity: 0.0.
	container addChild: committedElement at: previewIndex.
	operation := CFMotionEffects
		crossFadeFrom: preview
		to: committedElement
		duration: aDuration
		easing: anInterpolator.
	operation onTerminalDo: [ :aCompletedOperation |
		aCompletedOperation isCompleted ifTrue: [ self removePreviewIfPresent ] ]
]

{ #category : 'private - validation' }
CFMotionAdoptionOperation >> validateBeforeStarting [
	preview == committedElement ifTrue: [
		self error: 'An adoption needs distinct preview and committed elements' ].
	container isAttachedToSceneGraph ifFalse: [
		self error: 'An adoption container must be attached to a BlSpace' ].
	preview parent == container ifFalse: [
		self error: 'An adoption preview must belong to its declared container' ].
	committedElement hasParent ifTrue: [
		self error: 'An adoption committed element must be detached before handoff' ]
]
