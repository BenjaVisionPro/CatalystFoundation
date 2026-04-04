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
	self isClassSubject ifTrue: [ ^ #('This class opts into the Foundation operations tool.' ) ].
	^ #('This object is using a custom operations view model.' 'The embedded editor is still the standard Foundation Magritte editor.')
]

{ #category : 'accessing' }
CFMagritteEditorExampleOperationsViewModel >> headerMetadataText [
	self isClassSubject ifTrue: [ ^ 'CFMagritteEditorExample class operations' ].
	^ 'Example operations · ', super headerMetadataText
]

{ #category : 'api - accessing' }
CFMagritteEditorExampleOperationsViewModel >> toolIcon [
	^ BrGlamorousVectorIcons settings
]
