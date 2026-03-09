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

{ #category : 'defaults' }
CFMaElementBuilder >> builderUtilityClass [
	^ CFMaBuilderUtility
]
