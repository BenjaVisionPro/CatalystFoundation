Class {
	#name : 'CFMaReadOnlyDescriptionElementBuilder',
	#superclass : 'MAVisitor',
	#instVars : [
		'model',
		'memento',
		'description',
		'element'
	],
	#category : 'BVC-Foundation-Magritte-GT',
	#package : 'BVC-Foundation-Magritte-GT'
}

{ #category : 'instance creation' }
CFMaReadOnlyDescriptionElementBuilder class >> model: aModel memento: aMemento description: aDescription [
	^ self new
		model: aModel;
		memento: aMemento;
		description: aDescription;
		build
]

{ #category : 'accessing' }
CFMaReadOnlyDescriptionElementBuilder >> model: anObject [
	model := anObject
]

{ #category : 'accessing' }
CFMaReadOnlyDescriptionElementBuilder >> memento: aMemento [
	memento := aMemento
]

{ #category : 'accessing' }
CFMaReadOnlyDescriptionElementBuilder >> description: aDescription [
	description := aDescription
]

{ #category : 'api - building' }
CFMaReadOnlyDescriptionElementBuilder >> build [
	| aReadOnlyDescription |
	aReadOnlyDescription := description copy
		beReadOnly;
		yourself.

	description := aReadOnlyDescription.
	memento := GtMagritteMemento
		model: model
		description: aReadOnlyDescription asContainer.

	self visit: aReadOnlyDescription.
	^ element
]

{ #category : 'private - building' }
CFMaReadOnlyDescriptionElementBuilder >> newTextElementUsing: aDescription [
	^ BrColumnCellLabelStencil new
		text: (aDescription readToString: model)
]

{ #category : 'visiting-description' }
CFMaReadOnlyDescriptionElementBuilder >> visitDescription: aDescription [
	element := self newTextElementUsing: aDescription
]

{ #category : 'visiting-description' }
CFMaReadOnlyDescriptionElementBuilder >> visitElementDescription: aDescription [
	self visitDescription: aDescription
]

{ #category : 'visiting-description' }
CFMaReadOnlyDescriptionElementBuilder >> visitIconDescription: aDescription [
	element := GtMagritteBuilderUtility
		newIconWithMemento: memento
		using: aDescription
]
