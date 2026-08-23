"I hold Foundation presentation hints for one Magritte field. I am platform-independent, mutable only while a presentation resolves one field, and contain no live UI state."

Class {
	#name : 'CFMaFieldConfiguration',
	#superclass : 'Object',
	#instVars : [
		'icon',
		'representation'
	],
	#category : 'BVC-Foundation-Magritte-Core-Field',
	#package : 'BVC-Foundation-Magritte-Core',
	#tag : 'Field'
}

{ #category : 'initialization' }
CFMaFieldConfiguration >> initialize [
	super initialize.
	representation := CFMaTextConfiguration new
]

{ #category : 'accessing' }
CFMaFieldConfiguration >> icon [
	^ icon ifNil: [ icon := CFMaFieldIconConfiguration new ]
]

{ #category : 'accessing' }
CFMaFieldConfiguration >> representation [
	^ representation
]

{ #category : 'configuration - representation' }
CFMaFieldConfiguration >> beText [
	representation := CFMaTextConfiguration new.
	^ representation
]

{ #category : 'configuration - representation' }
CFMaFieldConfiguration >> bePopup [
	representation := CFMaPopupConfiguration new.
	^ representation
]

{ #category : 'configuration - representation' }
CFMaFieldConfiguration >> beSlider [
	representation := CFMaSliderConfiguration new.
	^ representation
]

{ #category : 'configuration - representation' }
CFMaFieldConfiguration >> beList [
	representation := CFMaListConfiguration new.
	^ representation
]

{ #category : 'configuration - representation' }
CFMaFieldConfiguration >> beEmbeddedForms [
	representation := CFMaEmbeddedFormsConfiguration new.
	^ representation
]
