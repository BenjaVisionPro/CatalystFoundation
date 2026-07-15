Class {
	#name : 'CFMotionAdoptionOperation',
	#superclass : 'Object',
	#instVars : [ 'container', 'sourceContainer', 'preview', 'committedElement', 'previewIndex', 'sourceSnapshot', 'destinationSnapshot', 'operation', 'overlay' ],
	#category : 'BVC-Foundation-Motion-Effects',
	#package : 'BVC-Foundation-Motion-Effects'
}

{ #category : 'instance creation' }
CFMotionAdoptionOperation class >> adopt: aPreview as: aCommittedElement in: aContainer duration: aDuration easing: anInterpolator [
	^ self adopt: aPreview as: aCommittedElement from: aContainer to: aContainer duration: aDuration easing: anInterpolator
]

{ #category : 'instance creation' }
CFMotionAdoptionOperation class >> adopt: aPreview as: aCommittedElement from: aSourceContainer to: aDestinationContainer duration: aDuration easing: anInterpolator [
	^ self new
		container: aDestinationContainer;
		sourceContainer: aSourceContainer;
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
	overlay ifNotNil: [ overlay release ].
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

{ #category : 'accessing' }
CFMotionAdoptionOperation >> destinationSnapshot [ ^ destinationSnapshot ]

{ #category : 'testing' }
CFMotionAdoptionOperation >> isCancelled [ ^ operation isCancelled ]

{ #category : 'testing' }
CFMotionAdoptionOperation >> isCompleted [ ^ operation isCompleted ]

{ #category : 'testing' }
CFMotionAdoptionOperation >> isRunning [ ^ operation isRunning ]

{ #category : 'accessing' }
CFMotionAdoptionOperation >> operation [ ^ operation ]

{ #category : 'accessing' }
CFMotionAdoptionOperation >> overlay [ ^ overlay ]

{ #category : 'accessing' }
CFMotionAdoptionOperation >> preview [ ^ preview ]

{ #category : 'accessing' }
CFMotionAdoptionOperation >> preview: anElement [ preview := anElement ]

{ #category : 'accessing' }
CFMotionAdoptionOperation >> previewIndex [ ^ previewIndex ]

{ #category : 'accessing' }
CFMotionAdoptionOperation >> sourceContainer: anElement [ sourceContainer := anElement ]

{ #category : 'accessing' }
CFMotionAdoptionOperation >> sourceSnapshot [ ^ sourceSnapshot ]

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
	| insertionIndex opacity geometryTrack |
	self validateBeforeStarting.
	previewIndex := sourceContainer children indexOf: preview.
	sourceSnapshot := CFMotionGeometrySnapshot of: preview in: preview space root.
	sourceContainer == container ifFalse: [ overlay := CFMotionOverlay on: preview in: preview space root ].
	insertionIndex := sourceContainer == container
		ifTrue: [ previewIndex ]
		ifFalse: [ container children size + 1 ].
	committedElement opacity: 0.0.
	container addChild: committedElement at: insertionIndex.
	destinationSnapshot := CFMotionGeometrySnapshot of: committedElement in: sourceSnapshot coordinateSpace.
	opacity := CFOpacityMotionProperty uniqueInstance.
	geometryTrack := CFMotionGeometryTrack
		on: committedElement
		from: sourceSnapshot
		to: destinationSnapshot.
	operation := CFMotionOperation
		coordinator: container space cfMotionCoordinator
		tracks: {
			CFMotionPropertyTrack on: preview property: opacity target: 0.0.
			CFMotionPropertyTrack on: committedElement property: opacity target: 1.0.
			geometryTrack }.
	operation
		duration: aDuration;
		easing: anInterpolator;
		start.
	operation onTerminalDo: [ :aCompletedOperation |
		aCompletedOperation isCompleted ifTrue: [ self removePreviewIfPresent ].
		overlay ifNotNil: [ overlay release ] ]
]

{ #category : 'private - validation' }
CFMotionAdoptionOperation >> validateBeforeStarting [
	preview == committedElement ifTrue: [
		self error: 'An adoption needs distinct preview and committed elements' ].
	container isAttachedToSceneGraph ifFalse: [
		self error: 'An adoption container must be attached to a BlSpace' ].
	preview parent == sourceContainer ifFalse: [ self error: 'An adoption preview must belong to its declared source container' ].
	sourceContainer isAttachedToSceneGraph ifFalse: [
		self error: 'An adoption source container must be attached to a BlSpace' ].
	sourceContainer space == container space ifFalse: [ self error: 'An adoption containers must share a BlSpace' ].
	committedElement hasParent ifTrue: [
		self error: 'An adoption committed element must be detached before handoff' ]
]
