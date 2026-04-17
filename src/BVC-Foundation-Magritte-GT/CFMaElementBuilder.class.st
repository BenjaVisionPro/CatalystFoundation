Class {
	#name : 'CFMaElementBuilder',
	#superclass : 'GtMagritteElementBuilder',
	#instVars : [
		'currentGroup'
	],
	#category : 'BVC-Foundation-Magritte-GT',
	#package : 'BVC-Foundation-Magritte-GT'
}

{ #category : 'elements' }
CFMaElementBuilder >> addFieldElement: aFieldElement using: aDescription [
	| aFieldWrapper |
	self emitGroupFor: aDescription.
	aFieldWrapper := CFMaFieldElement
		description: aDescription
		memento: self memento
		editorElement: aFieldElement.

	aDescription hasComment
		ifTrue: [ CFMaBuilderUtility addCommentTooltip: aFieldWrapper using: aDescription.
			CFMaBuilderUtility addCommentTooltip: aFieldElement using: aDescription ].

	self fieldContainerDo: [ :aContainer | aContainer addChild: aFieldWrapper ].
	^ aFieldWrapper
]

{ #category : 'icons' }
CFMaElementBuilder >> addIconUsing: aDescription [
	| anElement |
	(aDescription isKindOf: CFMaFontAwesomeIconDescription)
		ifFalse: [ ^ super addIconUsing: aDescription ].

	anElement := aDescription isReadOnly
		ifTrue: [ GtMagritteBuilderUtility newIconWithMemento: self memento using: aDescription ]
		ifFalse: [ CFMaFontAwesomeIconFieldStencilBuilder new
				memento: self memento;
				description: aDescription;
				asElement ].

	self addFieldElement: anElement using: aDescription
]

{ #category : 'defaults' }
CFMaElementBuilder >> builderUtilityClass [
	^ CFMaBuilderUtility
]

{ #category : 'private - building' }
CFMaElementBuilder >> emitGroupFor: aDescription [
	| aGroupName |
	(aDescription respondsTo: #group) ifFalse: [ ^ self ].
	aGroupName := aDescription perform: #group.
	aGroupName ifNil: [ ^ self ].
	currentGroup = aGroupName ifTrue: [ ^ self ].
	currentGroup := aGroupName.
	self fieldContainerDo: [ :aContainer |
		aContainer addChild: (self builderUtilityClass newGroupLabelUsing: aGroupName) ]
]
