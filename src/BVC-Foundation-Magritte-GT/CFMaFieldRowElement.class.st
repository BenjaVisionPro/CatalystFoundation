Class {
	#name : 'CFMaFieldRowElement',
	#superclass : 'BrVerticalPane',
	#instVars : [
		'memento',
		'description',
		'fieldElement',
		'changeIndicator',
		'validationIndicator',
		'revertButton'
	],
	#category : 'BVC-Foundation-Magritte-GT-Widgets',
	#package : 'BVC-Foundation-Magritte-GT',
	#tag : 'Widgets'
}

{ #category : 'initialization' }
CFMaFieldRowElement >> initialize [
	super initialize.
	self
		hMatchParent;
		vFitContent;
		cellSpacing: 3
]

{ #category : 'initialization' }
CFMaFieldRowElement >> memento: aMemento description: aDescription field: anElement label: aLabelElement [
	| editorFrame editorAndActions actionColumn |
	memento := aMemento.
	description := aDescription.
	fieldElement := anElement.

	changeIndicator := self newStatusIndicatorWith: (Color r: 0.74 g: 0.58 b: 0.08 alpha: 0.95).
	validationIndicator := self newStatusIndicatorWith: (Color r: 0.72 g: 0.22 b: 0.22 alpha: 0.95).
	revertButton := self newRevertButton.

	editorFrame := BrFrame new
		hMatchParent;
		vFitContent;
		layout: BlFrameLayout new;
		addChild: fieldElement as: #field;
		addChild: changeIndicator as: #changeIndicator;
		addChild: validationIndicator as: #validationIndicator;
		yourself.

	actionColumn := BrVerticalPane new
		hExact: 24;
		vFitContent;
		addChild: revertButton as: #revert;
		yourself.

	editorAndActions := BrHorizontalPane new
		hMatchParent;
		vFitContent;
		cellSpacing: 5;
		addChild: editorFrame as: #editor;
		addChild: actionColumn as: #actions;
		yourself.

	self
		addChild: aLabelElement as: #label;
		addChild: editorAndActions as: #editorAndActions.

	self observeValueState.
	self observeValidationState
]

{ #category : 'private - elements' }
CFMaFieldRowElement >> newRevertButton [
	^ BrButton new
		beTinySize;
		fitContent;
		aptitude: BrGlamorousButtonWithIconAptitude new;
		icon: BrGlamorousVectorIcons refresh;
		disabled;
		action: [ :aButton |
			| aValue |
			aValue := (memento readObservableValueUsing: description) valueOrNil.
			GtMagritteBuilderUtility
				write: aValue originalValue
				using: description
				memento: memento
				element: aButton ];
		yourself
]

{ #category : 'private - elements' }
CFMaFieldRowElement >> newStatusIndicatorWith: aColor [
	^ BlElement new
		size: 9 @ 9;
		geometry: BlEllipseGeometry new;
		background: aColor;
		visibility: BlVisibility gone;
		constraintsDo: [ :c |
			c ignoreByLayout.
			c ignored horizontal alignRight.
			c ignored vertical alignTop ];
		margin: (BlInsets top: 5 right: 5 bottom: 0 left: 0);
		yourself
]

{ #category : 'private - observing' }
CFMaFieldRowElement >> observeValidationState [
	validationIndicator withAsyncSinkDo: [ :anElementSink |
		anElementSink
			sink: AsyncPeekSink new;
			whenUpdate: [ :anIndicator :aSink |
				anIndicator visibility: (aSink value isSuccess
					ifTrue: [ BlVisibility gone ]
					ifFalse: [ BlVisibility visible ]) ].
		(memento validatorUsing: description) observe: anElementSink ]
]

{ #category : 'private - observing' }
CFMaFieldRowElement >> observeValueState [
	changeIndicator withAsyncSinkDo: [ :anElementSink |
		anElementSink
			sink: AsyncPeekSink new;
			whenUpdate: [ :anIndicator :aSink |
				| isChanged |
				isChanged := aSink value isChanged.
				anIndicator visibility: (isChanged
					ifTrue: [ BlVisibility visible ]
					ifFalse: [ BlVisibility gone ]).
				revertButton enabled: isChanged ].
		(memento readObservableValueUsing: description) observe: anElementSink ]
]
