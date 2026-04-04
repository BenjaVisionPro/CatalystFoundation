Class {
	#name : 'CFMaElementBuilder',
	#superclass : 'GtMagritteElementBuilder',
	#category : 'BVC-Foundation-Magritte-GT',
	#package : 'BVC-Foundation-Magritte-GT'
}

{ #category : 'elements' }
CFMaElementBuilder >> addFieldElement: aFieldElement using: aDescription [
	| aLabel |
	aLabel := self builderUtilityClass
			newFieldLabelWithSpace: self defaultSpacing
			using: aDescription.

	aDescription hasComment
		ifTrue: [ GtMagritteBuilderUtility addCommentTooltip: aLabel using: aDescription.
			GtMagritteBuilderUtility addCommentTooltip: aFieldElement using: aDescription ].

	self labelContainerDo: [ :aContainer | aContainer addChild: aLabel ].
	self fieldContainerDo: [ :aContainer | aContainer addChild: aFieldElement ].
	^ aLabel
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
