"
I am GT Magritte's one-line editor adapted only to the geometry of a compact
object identity.

I preserve GtMagritteOneLineEditorElement's field-view-model, readOnly,
conversion, validation and observable-value behavior. I remove form-field
margins. The owning compact widget explicitly tells me whether I am its primary
or supporting text line, so entering edit mode does not move or restyle the text.
"
Class {
	#name : 'CFMaCompactIdentityEditorElement',
	#superclass : 'GtMagritteOneLineEditorElement',
	#instVars : [
		'supportingText'
	],
	#category : 'BVC-Foundation-Magritte-GT-Widgets',
	#package : 'BVC-Foundation-Magritte-GT',
	#tag : 'Widgets'
}

{ #category : 'configuration - appearance' }
CFMaCompactIdentityEditorElement >> bePrimaryText [
	supportingText := false.
	self hasFieldViewModel ifTrue: [ self updateEditorAptitude ].
	^ self
]

{ #category : 'configuration - appearance' }
CFMaCompactIdentityEditorElement >> beSupportingText [
	supportingText := true.
	self hasFieldViewModel ifTrue: [ self updateEditorAptitude ].
	^ self
]

{ #category : 'initialization' }
CFMaCompactIdentityEditorElement >> initialize [
	super initialize.
	supportingText := false.
	self
		margin: BlInsets empty;
		padding: BlInsets empty;
		hMatchParent;
		vFitContent
]

{ #category : 'private - updating' }
CFMaCompactIdentityEditorElement >> updateEditorAptitude [
	editorAptitude ifNotNil: [ :anAptitude |
		self removeAptitude: anAptitude ].

	editorAptitude := BrGlamorousRegularEditorAptitude new
		glamorousRegularFont;
		foreground: (supportingText
			ifTrue: [ self theme typography tertiaryForeground ]
			ifFalse: [ self theme typography primaryForeground ]);
		yourself.
	supportingText ifTrue: [
		editorAptitude fontSize: self theme typography supportingFontSize ].
	self addAptitude: editorAptitude
]

