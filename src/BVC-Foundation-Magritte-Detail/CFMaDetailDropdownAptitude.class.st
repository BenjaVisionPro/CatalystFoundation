Class {
	#name : 'CFMaDetailDropdownAptitude',
	#superclass : 'BrGlamorousWithExplicitDropdownAptitude',
	#instVars : [
		'pinnedRowIndex',
		'pinnedRowIndexBlock',
		'pinnedAnchorLeft',
		'dismissRequestHandler',
		'dismissalMotion'
	],
	#category : 'BVC-Foundation-Magritte-Detail',
	#package : 'BVC-Foundation-Magritte-Detail'
}

{ #category : 'defaults' }
CFMaDetailDropdownAptitude class >> blinkCycleDuration [
	^ 160 milliSeconds
]

{ #category : 'defaults' }
CFMaDetailDropdownAptitude class >> fadeDuration [
	^ 200 milliSeconds
]

{ #category : 'private - motion' }
CFMaDetailDropdownAptitude >> blinkMotionFor: anOption in: aMenuContainer [
	| timeline track |
	timeline := CFMotionTimeline new.
	track := CFMotionTimelineTrack
		on: (CFMaDetailPopupSelectionMotionBehaviour
			on: anOption selectionList
			index: anOption selectionIndex)
		in: timeline.
	track
		duration: self class blinkCycleDuration;
		easing: BlEasing linear.
	timeline repeat: 2.
	^ CFMotion
		timeline: timeline
		coordinator: aMenuContainer space motionCoordinator
]

{ #category : 'private - motion' }
CFMaDetailDropdownAptitude >> cancelDismissalMotion [
	dismissalMotion ifNotNil: [
		dismissalMotion state isTerminal ifFalse: [ dismissalMotion cancelAndRestore ] ].
	dismissalMotion := nil
]

{ #category : 'private - motion' }
CFMaDetailDropdownAptitude >> fadeMotionFor: aMenuContainer [
	| timeline track |
	timeline := CFMotionTimeline new.
	track := CFMotionTimelineTrack
		on: (CFMotionPropertyTrack
			on: aMenuContainer
			property: CFMotionOpacityProperty uniqueInstance
			target: 0.0)
		in: timeline.
	track
		starts: self class blinkCycleDuration after: timeline start;
		duration: self class fadeDuration;
		easing: BlEasing linear.
	^ CFMotion
		timeline: timeline
		coordinator: aMenuContainer space motionCoordinator
]

{ #category : 'private - motion' }
CFMaDetailDropdownAptitude >> dismissSelection: anOption [
	self menuContainerDo: [ :aMenuContainer |
		| blink fade |
		aMenuContainer isAttachedToSceneGraph ifFalse: [
			anOption fireEvent: BrDropdownHideWish new.
			^ self ].
		self cancelDismissalMotion.
		blink := self blinkMotionFor: anOption in: aMenuContainer.
		fade := self fadeMotionFor: aMenuContainer.
		dismissalMotion := CFMotion composedOf: { blink. fade }.
		dismissalMotion onTerminalDo: [ :aMotion |
			aMotion isCompleted
				ifTrue: [
					anOption fireEvent: BrDropdownHideWish new.
					aMenuContainer opacity: 1.0 ]
				ifFalse: [
					self error: ('Popup dismissal Motion cancelled. menuAttached={1}; listAttached={2}; sameSpace={3}' format: {
						aMenuContainer isAttachedToSceneGraph.
						anOption selectionList isAttachedToSceneGraph.
						anOption selectionList space == aMenuContainer space }) ].
			dismissalMotion == aMotion ifTrue: [ dismissalMotion := nil ] ].
		dismissalMotion start ]
]

{ #category : 'lifecycle' }
CFMaDetailDropdownAptitude >> onInstalledIn: anElement [
	super onInstalledIn: anElement.
	dismissRequestHandler := BlEventHandler
		on: CFMaDetailPopupDismissRequest
		do: [ :anEvent |
			anEvent handled: true.
			self dismissSelection: anEvent target ].
	self menuContainerDo: [ :aMenuContainer |
		aMenuContainer addEventHandler: dismissRequestHandler ]
]

{ #category : 'private - event management' }
CFMaDetailDropdownAptitude >> onHidden [
	self cancelDismissalMotion.
	self menuContainerDo: [ :aMenuContainer | aMenuContainer opacity: 1.0 ].
	super onHidden.
	pinnedRowIndex := nil.
	pinnedAnchorLeft := nil.
	self widgetDo: [ :aWidget | aWidget popupOpen: false ]
]

{ #category : 'private - event management' }
CFMaDetailDropdownAptitude >> onShown [
	pinnedRowIndex := nil.
	pinnedAnchorLeft := nil.
	self pinnedRowIndex.
	super onShown.
	self widgetDo: [ :aWidget | aWidget popupOpen: true ]
]

{ #category : 'lifecycle' }
CFMaDetailDropdownAptitude >> onUninstalledIn: anElement [
	self cancelDismissalMotion.
	dismissRequestHandler ifNotNil: [
		self menuContainerDo: [ :aMenuContainer |
			aMenuContainer removeEventHandler: dismissRequestHandler ] ].
	dismissRequestHandler := nil.
	super onUninstalledIn: anElement
]

{ #category : 'accessing' }
CFMaDetailDropdownAptitude >> pinnedAnchorLeftUsing: anAnchorLeft [
	pinnedAnchorLeft ifNil: [ pinnedAnchorLeft := anAnchorLeft ].
	^ pinnedAnchorLeft
]

{ #category : 'accessing' }
CFMaDetailDropdownAptitude >> pinRowIndexUsing: aBlock [
	pinnedRowIndexBlock := aBlock
]

{ #category : 'accessing' }
CFMaDetailDropdownAptitude >> pinnedRowIndex [
	pinnedRowIndex ifNil: [
		pinnedRowIndex := pinnedRowIndexBlock
			ifNil: [ 1 ]
			ifNotNil: [ pinnedRowIndexBlock value ] ].
	^ pinnedRowIndex
]
