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

{ #category : 'api - converting' }
CFMaViewModel >> asElement [
	| aFrame |
	aFrame := CFMaFormRootElement new.

	aFrame
		matchParent;
		constraintsDo: [ :c |
			c frame horizontal alignCenter.
			c frame vertical alignCenter ];
		addAptitude: (BrLayoutResizerAptitude new
			hAnyToMatchParent: [ aFrame children ];
			vAnyToMatchParent: [ aFrame children ]);
		withAsyncFutureDo: [ :anElementFuture |
			anElementFuture
				whenPending: [ :theContainer |
					theContainer
						addChild: (BrLabel new
							fitContent;
							aptitude: (BrGlamorousLabelAptitude new
								foreground: BrGlamorousColors disabledButtonTextColor);
							text: 'Preparing...';
							constraintsDo: [ :c |
								c frame horizontal alignCenter.
								c frame vertical alignCenter ]) ];
				whenError: [ :theContainer :anError |
					theContainer userData at: self class gtMementoSymbol put: anError.

					theContainer
						removeChildren;
						addChild: (anError asDebuggableElement
							hFitContentLimited;
							vFitContent;
							constraintsDo: [ :c |
								c frame horizontal alignCenter.
								c frame vertical alignCenter ]) ];
				whenSuccess: [ :theFrame :aMemento | self initializeForm: theFrame forMemento: aMemento ] ].

	aFrame asyncFuture
		executionConfiguration: GtMagritteBuilderUtility executionConfiguration.
	aFrame asyncFuture future: self mementoFuture.

	^ aFrame
]
