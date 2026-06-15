Class {
	#name : 'CFMaViewModel',
	#superclass : 'GtMagritteViewModel',
	#category : 'BVC-Foundation-Magritte-GT',
	#package : 'BVC-Foundation-Magritte-GT'
}

{ #category : 'initialization' }
CFMaViewModel >> formContainerStencilForMemento: aMemento [
	^ aMemento magritteDescription
		propertyAt: #blocElementContainerStencil
		ifPresent: [ :aStencil | aStencil asStencilBuilder: CFMaFormStencilBuilder ]
		ifAbsent: [ CFMaFormStencilBuilder new ]
]

{ #category : 'initialization' }
CFMaViewModel >> initializeForm: theFrame forMemento: aMemento [
	| aContainer aStencil |
	theFrame userData at: self class gtMementoSymbol put: aMemento.

	theFrame removeChildren.

	aStencil := self formContainerStencilForMemento: aMemento.

	aContainer := aStencil
		memento: aMemento;
		asElement.

	theFrame addChild: aContainer.
	aContainer requestStyle.

	CFMaElementBuilder new
		includeImplicitActions: includeImplicitActions;
		form: theFrame;
		memento: aMemento;
		addButtons: self actions;
		build.
	^ self onElementCreated cull: theFrame
]
