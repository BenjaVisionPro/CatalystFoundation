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
		geometry: (BlRoundedRectangleGeometry cornerRadius: 10);
		constraintsDo: [ :c |
			c horizontal exact: 20.
			c vertical exact: 20.
			c frame horizontal alignLeft.
			c frame vertical alignCenter ];
		yourself.

	self
		addChangeProperty: #(widget layout) with: [ BlFrameLayout new ];
		addChangeProperty: #(widget geometry) with: [ BlRoundedRectangleGeometry cornerRadius: 13 ];
		addChangeProperty: #(widget size) with: [ 46 @ 26 ];
		addChangeProperty: #(widget padding) with: [ BlInsets all: 3 ];
		addChangeProperty: #(widget border) with: [ BlBorder empty ];
		addChangeAddChildAs: #cfSettingsSwitchThumb with: [ thumb ].

	self deactivated: [ :aStyle |
		aStyle background: (Color r: 224 g: 224 b: 224 range: 255) ].
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
