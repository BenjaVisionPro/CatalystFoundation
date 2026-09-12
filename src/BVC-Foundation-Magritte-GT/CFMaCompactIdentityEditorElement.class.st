"
I am GT Magritte's one-line editor adapted only to the geometry of a compact
object identity.

I preserve GtMagritteOneLineEditorElement's field-view-model, readOnly,
conversion, validation and observable-value behavior. I remove form-field
margins and apply the compact identity slot typography after the standard
description aptitude, so entering edit mode does not move the text.
"
Class {
	#name : 'CFMaCompactIdentityEditorElement',
	#superclass : 'GtMagritteOneLineEditorElement',
	#instVars : [
		'compactIndex'
	],
	#category : 'BVC-Foundation-Magritte-GT-Widgets',
	#package : 'BVC-Foundation-Magritte-GT',
	#tag : 'Widgets'
}

{ #category : 'configuration' }
CFMaCompactIdentityEditorElement >> compactIndex: anInteger [
	compactIndex := anInteger.
	self hasFieldViewModel ifTrue: [ self updateEditorAptitude ].
	^ self
]

{ #category : 'initialization' }
CFMaCompactIdentityEditorElement >> initialize [
	super initialize.
	compactIndex := 1.
	self
		margin: BlInsets empty;
		padding: BlInsets empty;
		hFitContentLimited;
		vFitContent
]

{ #category : 'private - updating' }
CFMaCompactIdentityEditorElement >> updateEditorAptitude [
	editorAptitude ifNotNil: [ :anAptitude |
		self removeAptitude: anAptitude ].

	editorAptitude := BrGlamorousRegularEditorAptitude new
		glamorousRegularFont;
		foreground: (compactIndex = 1
			ifTrue: [ self theme typography primaryForeground ]
			ifFalse: [ self theme typography tertiaryForeground ]);
		yourself.
	compactIndex = 1 ifFalse: [
		editorAptitude fontSize: self theme typography supportingFontSize ].
	self addAptitude: editorAptitude
]
