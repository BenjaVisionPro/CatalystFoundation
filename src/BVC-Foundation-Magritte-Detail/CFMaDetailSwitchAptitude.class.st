"I present a BrToggle as the compact animated switch used by the Detail presentation."

Class {
	#name : 'CFMaDetailSwitchAptitude',
	#superclass : 'BrToggleAptitude',
	#instVars : [
		'thumb',
		'thumbOffset',
		'trackColor',
		'switchAnimation'
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
	switchAnimation := nil.
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
		do: [ :anEvent | self toggleActivated ].
	self
		when: BrToggleDeactivatedEvent
		do: [ :anEvent | self toggleDeactivated ]
]

{ #category : 'private - animation' }
CFMaDetailSwitchAptitude >> applyStateWithThumbOffset: aThumbOffset trackColor: aTrackColor to: aWidget [
	thumbOffset := aThumbOffset.
	trackColor := aTrackColor.
	thumb transformDo: [ :aTransform |
		aTransform
			topLeftOrigin;
			translateBy: thumbOffset @ 0 ].
	aWidget background: trackColor
]

{ #category : 'private - animation' }
CFMaDetailSwitchAptitude >> animateToThumbOffset: aTargetOffset trackColor: aTargetColor [
	self widgetDo: [ :aWidget |
		| thumbTransition colorTransition |
		aWidget isAttachedToSceneGraph ifFalse: [
			^ self
				applyStateWithThumbOffset: aTargetOffset
				trackColor: aTargetColor
				to: aWidget ].

		switchAnimation ifNotNil: [ switchAnimation stopIfRunning ].

		thumbTransition := BlNumberTransition new
			from: thumbOffset;
			to: aTargetOffset;
			duration: self class animationDuration;
			onStepDo: [ :anOffset |
				thumbOffset := anOffset.
				thumb transformDo: [ :aTransform |
					aTransform
						topLeftOrigin;
						translateBy: thumbOffset @ 0 ] ];
			yourself.

		colorTransition := BlColorTransition new
			from: trackColor;
			to: aTargetColor;
			duration: self class animationDuration;
			onStepDo: [ :aColor |
				trackColor := aColor.
				aWidget background: trackColor ];
			yourself.

		switchAnimation := BlParallelAnimation
			with: { thumbTransition. colorTransition }.
		switchAnimation onFinishedDo: [
			self
				applyStateWithThumbOffset: aTargetOffset
				trackColor: aTargetColor
				to: aWidget.
			switchAnimation := nil ].
		aWidget addAnimation: switchAnimation ]
]

{ #category : 'event handling' }
CFMaDetailSwitchAptitude >> toggleActivated [
	self
		animateToThumbOffset: self class thumbTravel
		trackColor: self class activeTrackColor
]

{ #category : 'event handling' }
CFMaDetailSwitchAptitude >> toggleDeactivated [
	self
		animateToThumbOffset: 0.0
		trackColor: self class inactiveTrackColor
]
