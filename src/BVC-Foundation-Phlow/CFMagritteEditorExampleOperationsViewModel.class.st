Class {
	#name : 'CFMagritteEditorExampleOperationsViewModel',
	#superclass : 'CFOperationsViewModel',
	#category : 'BVC-Foundation-Phlow',
	#package : 'BVC-Foundation-Phlow'
}

{ #category : 'accessing' }
CFMagritteEditorExampleOperationsViewModel >> elementClass [
	^ CFMagritteEditorExampleOperationsElement
]

{ #category : 'accessing' }
CFMagritteEditorExampleOperationsViewModel >> footerLines [
	^ #('This object is using a custom operations tool contributed through <cfInspectorTool>.' 'The embedded editor is still the standard Foundation Magritte editor.')
]

{ #category : 'accessing' }
CFMagritteEditorExampleOperationsViewModel >> headerMetadataText [
	^ 'Example operations · ', super headerMetadataText
]

{ #category : 'api - accessing' }
CFMagritteEditorExampleOperationsViewModel >> toolIcon [
	^ BrGlamorousVectorIcons settings
]
