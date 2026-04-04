Class {
	#name : 'CFMaElementBuilder',
	#superclass : 'GtMagritteElementBuilder',
	#category : 'BVC-Foundation-Magritte-GT',
	#package : 'BVC-Foundation-Magritte-GT'
}

{ #category : 'elements' }
CFMaElementBuilder >> addFieldElement: aFieldElement using: aDescription [
	| aLabel aRow aValueContainer |
	aLabel := self builderUtilityClass
			newFieldLabelWithSpace: self defaultSpacing
			using: aDescription.

	aDescription hasComment
		ifTrue: [ GtMagritteBuilderUtility addCommentTooltip: aLabel using: aDescription.
			GtMagritteBuilderUtility addCommentTooltip: aFieldElement using: aDescription ].

	(aDescription isKindOf: MABooleanDescription)
		ifTrue: [ aRow := BrHorizontalPane new
				cellSpacing: 8;
				padding: (BlInsets top: 4 right: 0 bottom: 6 left: 0);
				margin: (BlInsets top: 0 right: 0 bottom: 2 left: 0);
				hMatchParent;
				vFitContent;
				yourself.
			aRow addChild: aFieldElement.
			aRow addChild: aLabel ]
		ifFalse: [ aRow := self builderUtilityClass newFieldRowContainer.
			aValueContainer := aDescription isReadOnly
				ifTrue: [ self builderUtilityClass newReadOnlyFieldValueContainer ]
				ifFalse: [ self builderUtilityClass newEditableFieldValueContainer ].
			aValueContainer addChild: aFieldElement.
			aRow addChild: aLabel.
			aRow addChild: aValueContainer ].

	self fieldContainerDo: [ :aContainer | aContainer addChild: aRow ].
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
