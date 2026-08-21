"I present a BrToggle as the compact switch used by the Detail presentation."

Class {
	#name : 'CFMaDetailSwitchAptitude',
	#superclass : 'BrToggleAptitude',
	#instVars : [
		'thumb'
	],
	#category : 'BVC-Foundation-Magritte-Detail',
	#package : 'BVC-Foundation-Magritte-Detail'
}

{ #category : 'defaults' }
CFMaDetailSwitchAptitude class >> activeTrackColor [
	^ CFMaDetailColours highlight
]

{ #category : 'defaults' }
CFMaDetailSwitchAptitude class >> inactiveTrackColor [
	^ Color r: 220 g: 220 b: 220 range: 255
]

{ #category : 'initialization' }
CFMaDetailSwitchAptitude >> initialize [
	super initialize.
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
		addChangeAddChildAs: #(cfDetailSwitchThumb) with: [ thumb ].

	self default: [ :aStyle |
		aStyle background: self class inactiveTrackColor ].
	self deactivated: [ :aStyle |
		aStyle background: self class inactiveTrackColor ].
	self activated: [ :aStyle |
		aStyle background: self class activeTrackColor ]
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

{ #category : 'event handling' }
CFMaDetailSwitchAptitude >> toggleActivated [
	thumb constraintsDo: [ :c | c frame horizontal alignRight ]
]

{ #category : 'event handling' }
CFMaDetailSwitchAptitude >> toggleDeactivated [
	thumb constraintsDo: [ :c | c frame horizontal alignLeft ]
]
