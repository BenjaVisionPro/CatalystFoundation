Class {
	#name : 'CFMaElementBuilder',
	#superclass : 'GtMagritteElementBuilder',
	#category : 'BVC-Foundation-Magritte-GT',
	#package : 'BVC-Foundation-Magritte-GT'
}

{ #category : 'elements' }
CFMaElementBuilder >> addFieldElement: aFieldElement using: aDescription [
	| aLabel aText aLabelAptitude |
	"Foundation keeps GT field construction wherever its behaviour is sufficient.
	This method supplies Foundation's shared label chrome; relation visitors may
	provide Foundation editors where GT does not provide the required capability."
	aText := aDescription label asRopedText.
	aDescription isRequired ifTrue: [ aText append: '*' asRopedText ].
	aLabelAptitude := aDescription labelAptitude
		ifNil: [ BrGlamorousLabelAptitude new
			foreground: (Color black alpha: 0.52);
			fontSize: 13 ]
		ifNotNil: #value.
	aLabel := BrLabel new
		id: (GtMagritteFieldLabelId new description: aDescription);
		text: aText;
		aptitude: aLabelAptitude;
		fitContent;
		margin: (BlInsets top: 3 right: 12 bottom: 6 left: 0);
		constraintsDo: [ :c | c grid vertical alignTop ].

	aDescription hasComment ifTrue: [
		GtMagritteBuilderUtility addCommentTooltip: aLabel using: aDescription.
		GtMagritteBuilderUtility addCommentTooltip: aFieldElement using: aDescription ].

	self labelContainerDo: [ :aContainer | aContainer addChild: aLabel ].
	self fieldContainerDo: [ :aContainer | aContainer addChild: aFieldElement ].
	^ aLabel
]


{ #category : 'visiting-description' }
CFMaElementBuilder >> visitToOneRelationDescription: aDescription [
	aDescription blocStencil
		ifNil: [ ^ super visitToOneRelationDescription: aDescription ]
		ifNotNil: [ :aStencil |
			self
				addFieldElement: (aStencil
					memento: self memento;
					description: aDescription;
					asElement)
				using: aDescription ]
]
