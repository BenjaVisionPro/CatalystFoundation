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

{ #category : 'initialization' }
CFMaSettingsSwitchAptitude >> initialize [
	super initialize.
	thumb := BlElement new
		background: Color white;
		geometry: (BlRoundedRectangleGeometry cornerRadius: 9);
		constraintsDo: [ :c |
			c horizontal exact: 18.
			c vertical exact: 18.
			c frame horizontal alignLeft.
			c frame vertical alignCenter ];
		yourself.

	self
		addChangeProperty: #(widget layout) with: [ BlFrameLayout new ];
		addChangeProperty: #(widget geometry) with: [ BlRoundedRectangleGeometry cornerRadius: 11 ];
		addChangeProperty: #(widget size) with: [ 48 @ 22 ];
		addChangeProperty: #(widget padding) with: [ BlInsets all: 2 ];
		addChangeProperty: #(widget border) with: [ BlBorder empty ];
		addChangeAddChildAs: #(cfSettingsSwitchThumb) with: [ thumb ].

	self deactivated: [ :aStyle |
		aStyle background: (Color r: 220 g: 220 b: 220 range: 255) ].
	self activated: [ :aStyle |
		aStyle background: (Color r: 10 g: 132 b: 255 range: 255) ]
]

{ #category : 'event handling' }
CFMaSettingsSwitchAptitude >> toggleActivated [
	thumb constraintsDo: [ :c | c frame horizontal alignRight ]
]

{ #category : 'event handling' }
CFMaSettingsSwitchAptitude >> toggleDeactivated [
	thumb constraintsDo: [ :c | c frame horizontal alignLeft ]
]
