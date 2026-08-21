"I hold Foundation presentation hints for one Magritte field. I am platform-independent, mutable only while a presentation resolves one field, and contain no live UI state."

Class {
	#name : 'CFMaFieldConfiguration',
	#superclass : 'Object',
	#instVars : [
		'icon'
	],
	#category : 'BVC-Foundation-Magritte-Core-Field',
	#package : 'BVC-Foundation-Magritte-Core',
	#tag : 'Field'
}

{ #category : 'accessing' }
CFMaFieldConfiguration >> icon [
	^ icon ifNil: [ icon := CFMaFieldIconConfiguration new ]
]
