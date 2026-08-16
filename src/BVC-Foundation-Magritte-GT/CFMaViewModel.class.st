Class {
	#name : 'CFMaViewModel',
	#superclass : 'GtMagritteViewModel',
	#instVars : [
		'formElementBlock',
		'elementBuilderBlock',
		'presentationClass'
	],
	#category : 'BVC-Foundation-Magritte-GT',
	#package : 'BVC-Foundation-Magritte-GT'
}

{ #category : 'api - instance creation' }
CFMaViewModel class >> forObject: anObject [
	^ self new
		mementoBlock: [ CFMaMemento model: anObject ] object: anObject;
		yourself
]

{ #category : 'api - instance creation' }
CFMaViewModel class >> forObject: anObject memento: aMemento [
	^ self new
		mementoBlock: [ aMemento ] object: anObject;
		yourself
]


{ #category : 'initialization' }
CFMaViewModel >> initialize [
	super initialize.
	presentationClass := CFMaPresentation
]

{ #category : 'accessing' }
CFMaViewModel >> presentationClass [
	^ presentationClass
]

{ #category : 'accessing' }
CFMaViewModel >> presentationClass: aPresentationClass [
	presentationClass := aPresentationClass
]

{ #category : 'callbacks' }
CFMaViewModel >> formElementDo: aBlock [
	formElementBlock := aBlock
]

{ #category : 'callbacks' }
CFMaViewModel >> elementBuilderDo: aBlock [
	elementBuilderBlock := aBlock
]

{ #category : 'initialization' }
CFMaViewModel >> formContainerStencilForMemento: aMemento [
	"An explicitly supplied Magritte form stencil is consumer-owned. Do not
	adapt it to Foundation's default stencil builder."
	^ aMemento magritteDescription
		propertyAt: #blocElementContainerStencil
		ifPresent: [ :aStencil | aStencil ]
		ifAbsent: [ CFMaFormStencilBuilder new ]
]

{ #category : 'initialization' }
CFMaViewModel >> initializeForm: theFrame forMemento: aMemento [
	^ self
		initializeForm: theFrame
		forMemento: aMemento
		includeImplicitActions: includeImplicitActions
]

{ #category : 'initialization' }
CFMaViewModel >> initializeForm: theFrame forMemento: aMemento includeImplicitActions: aBoolean [
	| aContainer aStencil anElementBuilder |
	theFrame userData at: self class gtMementoSymbol put: aMemento.

	theFrame removeChildren.

	aStencil := self formContainerStencilForMemento: aMemento.

	aContainer := aStencil
		memento: aMemento;
		asElement.

	theFrame addChild: aContainer.
	formElementBlock ifNotNil: [ :aBlock | aBlock cull: aContainer ].
	aContainer requestStyle.

	anElementBuilder := elementBuilderBlock
		ifNil: [ presentationClass new ]
		ifNotNil: [ :aBlock | aBlock value ].

	anElementBuilder
		includeImplicitActions: aBoolean;
		form: theFrame;
		memento: aMemento;
		addButtons: self actions;
		build.
	^ self onElementCreated cull: theFrame
]

{ #category : 'api - converting' }
CFMaViewModel >> asElement [
	| aFrame aResizerAptitude |
	aFrame := CFMaFormRootElement new.

	aResizerAptitude := BrLayoutResizerAptitude new.
	"The generated Foundation form child should fill the Phlow-facing async host."
	aResizerAptitude hAnyToMatchParent: [ aFrame children ].

	aFrame
		hMatchParent;
		vFitContent;
		constraintsDo: [ :c |
			c frame horizontal alignCenter.
			c frame vertical alignCenter ];
		addAptitude: aResizerAptitude;
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

{ #category : 'api - converting' }
CFMaViewModel >> asEmbeddedElement [
	| aFrame aResizerAptitude |
	aFrame := CFMaFormRootElement new beEmbedded.

	aResizerAptitude := BrLayoutResizerAptitude new.
	aResizerAptitude hAnyToMatchParent: [ aFrame children ].

	aFrame
		constraintsDo: [ :c |
			c frame horizontal alignCenter.
			c frame vertical alignTop ];
		addAptitude: aResizerAptitude;
		withAsyncFutureDo: [ :anElementFuture |
			anElementFuture
				whenPending: [ :theContainer |
					theContainer addChild: (BrLabel new
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
								c frame vertical alignTop ]) ];
				whenSuccess: [ :theFrame :aMemento |
					self
						initializeForm: theFrame
						forMemento: aMemento
						includeImplicitActions: false ] ].

	aFrame asyncFuture
		executionConfiguration: GtMagritteBuilderUtility executionConfiguration.
	aFrame asyncFuture future: self mementoFuture.
	^ aFrame
]
