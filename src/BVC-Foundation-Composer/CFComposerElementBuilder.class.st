Class {
	#name : 'CFComposerElementBuilder',
	#superclass : 'CFMaElementBuilder',
	#instVars : [
		'formController'
	],
	#category : 'BVC-Foundation-Composer',
	#package : 'BVC-Foundation-Composer'
}

{ #category : 'accessing' }
CFComposerElementBuilder >> formController [
	^ formController
]

{ #category : 'accessing' }
CFComposerElementBuilder >> formController: aComposerFormController [
	formController := aComposerFormController
]

{ #category : 'private - building' }
CFComposerElementBuilder >> addComposerRelationUsing: aDescription [
	| anElement |
	anElement := CFComposerRelationElement
		memento: self memento
		description: aDescription
		formController: formController.
	self addFieldElement: anElement using: aDescription
]

{ #category : 'private - building' }
CFComposerElementBuilder >> addFormResetShortcutTo: anElement [
	"Composer reset is coordinated by the root form controller; child fields must not reset independently."
]

{ #category : 'visiting-description' }
CFComposerElementBuilder >> visitToManyRelationDescription: aDescription [
	self addComposerRelationUsing: aDescription
]

{ #category : 'visiting-description' }
CFComposerElementBuilder >> visitToOneRelationDescription: aDescription [
	self addComposerRelationUsing: aDescription
]
