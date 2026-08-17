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

{ #category : 'layout' }
CFMaSettingsMemoEditorElement >> baselineOffset [
	^ self
		allChildrenBreadthFirstDetect: [ :each |
			each isKindOf: BrTextEditorParagraphElement ]
		ifFound: [ :aParagraphElement |
			aParagraphElement
				allChildrenBreadthFirstDetect: [ :each |
					each isKindOf: BlTextElement ]
				ifFound: [ :aTextElement |
					aTextElement baselineOffset
						+ aParagraphElement padding top
						+ self padding top ]
				ifNone: [ 0 ] ]
		ifNone: [ 0 ]
]

{ #category : 'layout' }
CFMaSettingsMemoEditorElement >> supportsBaseline [
	^ true
]
