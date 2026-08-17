Class {
	#name : 'CFMaSettingsMemoEditorElement',
	#superclass : 'GtMagritteOneLineEditorElement',
	#category : 'BVC-Foundation-Magritte-GT-Elements',
	#package : 'BVC-Foundation-Magritte-GT',
	#tag : 'Elements'
}

{ #category : 'initialization' }
CFMaSettingsMemoEditorElement >> initialize [
	super initialize.
	self
		inputFilter: BrTextEditorNoInputFilter new;
		hMatchParent;
		vFitContent;
		padding: BlInsets empty;
		margin: BlInsets empty
]

{ #category : 'private - updating' }
CFMaSettingsMemoEditorElement >> updateEditorAptitude [
	super updateEditorAptitude.
	editorAptitude fontSize: 13
]
