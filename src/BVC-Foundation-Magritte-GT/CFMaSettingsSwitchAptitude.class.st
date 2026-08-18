"I present a BrToggle as Foundation's compact settings switch."

Class {
	#name : 'CFMaSettingsSwitchAptitude',
	#superclass : 'BrToggleAptitude',
	#instVars : [
		'thumb'
	],
	#category : 'BVC-Foundation-Magritte-GT-Presentations-Settings',
	#package : 'BVC-Foundation-Magritte-GT',
	#tag : 'Presentations-Settings'
}

{ #category : 'defaults' }
CFMaSettingsSwitchAptitude class >> activeTrackColor [
	^ Color r: 10 g: 132 b: 255 range: 255
]

{ #category : 'defaults' }
CFMaSettingsSwitchAptitude class >> inactiveTrackColor [
	^ Color r: 220 g: 220 b: 220 range: 255
]

{ #category : 'initialization' }
CFMaSettingsSwitchAptitude >> initialize [
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
		addChangeAddChildAs: #(cfSettingsSwitchThumb) with: [ thumb ].

	self default: [ :aStyle |
		aStyle background: self class inactiveTrackColor ].
	self deactivated: [ :aStyle |
		aStyle background: self class inactiveTrackColor ].
	self activated: [ :aStyle |
		aStyle background: self class activeTrackColor ]
]

{ #category : 'event handling' }
CFMaSettingsSwitchAptitude >> toggleActivated [
	thumb constraintsDo: [ :c | c frame horizontal alignRight ]
]

{ #category : 'event handling' }
CFMaSettingsSwitchAptitude >> toggleDeactivated [
	thumb constraintsDo: [ :c | c frame horizontal alignLeft ]
]
