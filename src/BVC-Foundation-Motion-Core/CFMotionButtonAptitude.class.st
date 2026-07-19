Class {
	#name : 'CFMotionButtonAptitude',
	#superclass : 'BrAptitude',
	#instVars : [ 'activeMotion', 'pressed', 'downHandler', 'upHandler', 'dragStartHandler', 'dragEnterHandler', 'dragLeaveHandler', 'dragEndHandler' ],
	#category : 'BVC-Foundation-Motion-Core',
	#package : 'BVC-Foundation-Motion-Core'
}

{ #category : 'accessing' }
CFMotionButtonAptitude >> activeMotion [ ^ activeMotion ]

{ #category : 'private - playing' }
CFMotionButtonAptitude >> compressIn: anElement [
	(activeMotion isNil or: [ activeMotion isCompleted or: [ activeMotion isCancelled ] ])
		ifTrue: [
			activeMotion := (CFMotionBuilder compress
				element: anElement;
				duration: 120 milliSeconds;
				easing: (BlDecelerateInterpolator factor: 1.4);
				build)
				start ]
		ifFalse: [
			activeMotion holdAtDestination: true.
			self retarget: 0.96 @ 0.96 in: anElement ]
]

{ #category : 'private - playing' }
CFMotionButtonAptitude >> releaseIn: anElement [
	activeMotion ifNil: [ ^ self ].
	activeMotion holdAtDestination: false.
	self retarget: 1 @ 1 in: anElement
]

{ #category : 'private - playing' }
CFMotionButtonAptitude >> retarget: aScale in: anElement [
	activeMotion
		retarget: (CFMotionScaleTrack on: anElement from: 1 @ 1 to: aScale)
		duration: 120 milliSeconds
		easing: (BlDecelerateInterpolator factor: 1.4)
]

{ #category : 'lifecycle' }
CFMotionButtonAptitude >> onInstalledIn: anElement [
	super onInstalledIn: anElement.
	downHandler := BlEventHandler on: BlMouseDownEvent do: [ :anEvent |
		anEvent primaryButtonPressed ifTrue: [
			pressed := true.
			self compressIn: anElement ] ].
	upHandler := BlEventHandler on: BlMouseUpEvent do: [ :anEvent |
		anEvent primaryButtonPressed ifTrue: [
			pressed := false.
			self releaseIn: anElement ] ].
	dragStartHandler := BlEventHandler on: BlDragStartEvent do: [ :anEvent |
		anEvent isPrimaryButtonDrag ifTrue: [ pressed := true ] ].
	dragLeaveHandler := BlEventHandler on: BlDragLeaveEvent do: [ :anEvent |
		(anEvent isPrimaryButtonDrag and: [ pressed ]) ifTrue: [
			activeMotion holdAtDestination: true.
			self retarget: 1 @ 1 in: anElement ] ].
	dragEnterHandler := BlEventHandler on: BlDragEnterEvent do: [ :anEvent |
		(anEvent isPrimaryButtonDrag and: [ pressed ]) ifTrue: [ self compressIn: anElement ] ].
	dragEndHandler := BlEventHandler on: BlDragEndEvent do: [ :anEvent |
		anEvent isPrimaryButtonDrag ifTrue: [
			pressed := false.
			self releaseIn: anElement ] ].
	anElement addEventHandler: downHandler.
	anElement addEventHandler: upHandler.
	anElement addEventHandler: dragStartHandler.
	anElement addEventHandler: dragEnterHandler.
	anElement addEventHandler: dragLeaveHandler.
	anElement addEventHandler: dragEndHandler
]

{ #category : 'lifecycle' }
CFMotionButtonAptitude >> onUninstalledIn: anElement [
	activeMotion ifNotNil: [ activeMotion cancelAndRestore ].
	activeMotion := nil.
	pressed := false.
	{ downHandler . upHandler . dragStartHandler . dragEnterHandler . dragLeaveHandler . dragEndHandler }
		do: [ :each | each ifNotNil: [ anElement removeEventHandler: each ] ].
	downHandler := nil.
	upHandler := nil.
	dragStartHandler := nil.
	dragEnterHandler := nil.
	dragLeaveHandler := nil.
	dragEndHandler := nil.
	super onUninstalledIn: anElement
]
