"I present a BrToggle as the compact Motion-driven switch used by the Detail presentation."

Class {
	#name : 'CFMaDetailSwitchAptitude',
	#superclass : 'BrToggleAptitude',
	#instVars : [
		'thumb',
		'thumbOffset',
		'trackColor',
		'activeMotion'
	],
	#category : 'BVC-Foundation-Magritte-Detail',
	#package : 'BVC-Foundation-Magritte-Detail'
}

{ #category : 'defaults' }
CFMaDetailSwitchAptitude class >> activeTrackColor [
	^ CFMaDetailColours highlight
]

{ #category : 'defaults' }
CFMaDetailSwitchAptitude class >> animationDuration [
	^ 120 milliSeconds
]

{ #category : 'defaults' }
CFMaDetailSwitchAptitude class >> inactiveTrackColor [
	^ Color r: 220 g: 220 b: 220 range: 255
]

{ #category : 'defaults' }
CFMaDetailSwitchAptitude class >> thumbTravel [
	^ 14
]

{ #category : 'initialization' }
CFMaDetailSwitchAptitude >> initialize [
	super initialize.
	thumbOffset := 0.0.
	trackColor := self class inactiveTrackColor.
	activeMotion := nil.
	thumb := BlElement new
		background: Color white;
		geometry: (BlRoundedRectangleGeometry cornerRadius: 7);
		constraintsDo: [ :c |
			c horizontal exact: 20.
			c vertical exact: 14.
			c frame horizontal alignLeft.
			c frame vertical alignCenter ];
		yourself.

	self
		addChangeProperty: #(widget layout) with: [ BlFrameLayout new ];
		addChangeProperty: #(widget geometry) with: [ BlRoundedRectangleGeometry cornerRadius: 8 ];
		addChangeProperty: #(widget size) with: [ 36 @ 16 ];
		addChangeProperty: #(widget padding) with: [ BlInsets all: 1 ];
		addChangeProperty: #(widget border) with: [ BlBorder empty ];
		addChangeProperty: #(widget background) with: [ self class inactiveTrackColor ];
		addChangeAddChildAs: #(cfDetailSwitchThumb) with: [ thumb ]
]

{ #category : 'initialization' }
CFMaDetailSwitchAptitude >> initializeListeners [
	super initializeListeners.
	self
		when: BrToggleActivatedEvent
		do: [ :anEvent | self toggleActivated ];
		when: BrToggleDeactivatedEvent
		do: [ :anEvent | self toggleDeactivated ]
]

{ #category : 'private - motion' }
CFMaDetailSwitchAptitude >> applyThumbOffset: anOffset [
	thumbOffset := anOffset.
	thumb transformDo: [ :aTransform |
		aTransform
			topLeftOrigin;
			translateBy: thumbOffset @ 0 ]
]

{ #category : 'accessing' }
CFMaDetailSwitchAptitude >> thumbOffset [
	^ thumbOffset
]

{ #category : 'private - motion' }
CFMaDetailSwitchAptitude >> applyTrackColor: aColor [
	trackColor := aColor.
	self widgetDo: [ :aWidget | aWidget background: aColor ]
]

{ #category : 'private - motion' }
CFMaDetailSwitchAptitude >> motionToThumbOffset: aTargetOffset trackColor: aTargetColor in: aWidget [
	| thumbMotion colorMotion |
	thumbMotion := CFMaDetailSwitchThumbMotionBehaviour
		on: thumb
		aptitude: self
		target: aTargetOffset.
	colorMotion := CFMaDetailSwitchTrackColorMotionBehaviour
		on: aWidget
		aptitude: self
		target: aTargetColor.
	^ (CFMotion
		coordinator: aWidget space motionCoordinator
		tracks: { thumbMotion. colorMotion })
		duration: self class animationDuration;
		easing: BlEasing linear;
		holdAtDestination;
		yourself
]

{ #category : 'private - motion' }
CFMaDetailSwitchAptitude >> retargetToThumbOffset: aTargetOffset trackColor: aTargetColor [
	self widgetDo: [ :aWidget |
		| requestedTranslation requestedColor |
		aWidget isAttachedToSceneGraph ifFalse: [
			self applyThumbOffset: aTargetOffset.
			^ self applyTrackColor: aTargetColor ].

		(activeMotion isNil or: [ activeMotion isCancelled or: [ activeMotion isCompleted ] ])
			ifTrue: [
				activeMotion := (self
					motionToThumbOffset: aTargetOffset
					trackColor: aTargetColor
					in: aWidget) start ]
			ifFalse: [
				requestedTranslation := CFMaDetailSwitchThumbMotionBehaviour
					on: thumb
					aptitude: self
					target: aTargetOffset.
				requestedColor := CFMaDetailSwitchTrackColorMotionBehaviour
					on: aWidget
					aptitude: self
					target: aTargetColor.
				activeMotion
					retarget: { requestedTranslation. requestedColor }
					duration: self class animationDuration
					easing: BlEasing linear ] ]
]

{ #category : 'accessing' }
CFMaDetailSwitchAptitude >> trackColor [
	^ trackColor
]

{ #category : 'event handling' }
CFMaDetailSwitchAptitude >> toggleActivated [
	self
		retargetToThumbOffset: self class thumbTravel
		trackColor: self class activeTrackColor
]

{ #category : 'event handling' }
CFMaDetailSwitchAptitude >> toggleDeactivated [
	self
		retargetToThumbOffset: 0.0
		trackColor: self class inactiveTrackColor
]

{ #category : 'lifecycle' }
CFMaDetailSwitchAptitude >> onUninstalledIn: anElement [
	activeMotion ifNotNil: [ activeMotion cancelAndRestore ].
	activeMotion := nil.
	super onUninstalledIn: anElement
]
