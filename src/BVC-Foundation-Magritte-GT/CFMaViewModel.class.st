Class {
	#name : 'CFMaViewModel',
	#superclass : 'GtMagritteViewModel',
	#instVars : [
		'formElementBlock',
		'elementBuilderBlock',
		'presentationBlock'
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

{ #category : 'api - converting' }
CFMaViewModel >> asElement [
	| aFrame |
	aFrame := self newFormRootElement.
	aFrame
		withAsyncFutureDo: [ :anElementFuture |
			anElementFuture
				whenPending: [ :theContainer | ];
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

{ #category : 'private - building' }
CFMaViewModel >> newFormRootElement [
	| aFrame aResizerAptitude |
	aFrame := CFMaFormRootElement new.
	aResizerAptitude := BrLayoutResizerAptitude new.
	aResizerAptitude hAnyToMatchParent: [ aFrame children ].
	aFrame
		hMatchParent;
		vFitContent;
		constraintsDo: [ :c |
			c frame horizontal alignCenter.
			c frame vertical alignCenter ];
		addAptitude: aResizerAptitude.
	^ aFrame
]

{ #category : 'api - converting' }
CFMaViewModel >> preparedElementForMemento: aMemento [
	| aFrame |
	aFrame := self newFormRootElement.
	self initializeForm: aFrame forMemento: aMemento.
	^ aFrame
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

{ #category : 'callbacks' }
CFMaViewModel >> formElementDo: aBlock [
	formElementBlock := aBlock
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
		ifNil: [
			aMemento magritteDescription blocPresentationStencil
				memento: aMemento;
				build ]
		ifNotNil: [ :aBlock | aBlock value ].

	anElementBuilder
		includeImplicitActions: aBoolean;
		form: theFrame;
		memento: aMemento;
		addButtons: self actions.
	presentationBlock ifNotNil: [ :aBlock | aBlock value: anElementBuilder ].
	anElementBuilder build.
	^ self onElementCreated cull: theFrame
]

{ #category : 'callbacks' }
CFMaViewModel >> presentationDo: aBlock [
	"Configure the presentation selected by the Magritte container after Foundation has supplied its form and memento, but before it builds. This is a consumer configuration seam; it does not change presentation selection."
	presentationBlock := aBlock
]

