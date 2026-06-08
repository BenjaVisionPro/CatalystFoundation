Class {
	#name : 'CFCompactListItemElement',
	#superclass : 'BrHorizontalPane',
	#instVars : [
		'viewModel',
		'iconContainer',
		'titleContainer',
		'commentContainer',
		'textContainer'
	],
	#category : 'BVC-Foundation-Magritte-GT',
	#package : 'BVC-Foundation-Magritte-GT'
}

{ #category : 'adding' }
CFCompactListItemElement >> addFieldElement: anElement using: aDescription [
	aDescription cfCompactSlot = #icon ifTrue: [ ^ self addIconFieldElement: anElement ].
	aDescription cfCompactSlot = #title ifTrue: [ ^ self addTitleFieldElement: anElement ].
	^ self addCommentFieldElement: anElement
]

{ #category : 'adding' }
CFCompactListItemElement >> addIconFieldElement: anElement [
	iconContainer
		removeChildren;
		addChild: anElement.
	^ anElement
]

{ #category : 'adding' }
CFCompactListItemElement >> addTitleFieldElement: anElement [
	titleContainer
		removeChildren;
		addChild: anElement.
	^ anElement
]

{ #category : 'adding' }
CFCompactListItemElement >> addCommentFieldElement: anElement [
	commentContainer
		removeChildren;
		addChild: anElement.
	^ anElement
]

{ #category : 'initialization' }
CFCompactListItemElement >> initialize [
	super initialize.

	self
		hMatchParent;
		vFitContent;
		padding: (BlInsets top: 4 right: 8 bottom: 4 left: 8);
		cellSpacing: 8;
		addAptitude: BrGlamorousListItemAptitude new.

	iconContainer := BrFrame new
		size: 20 @ 20;
		margin: (BlInsets top: 2 right: 0 bottom: 0 left: 0);
		yourself.

	titleContainer := BrFrame new
		hMatchParent;
		vFitContent;
		yourself.

	commentContainer := BrFrame new
		hMatchParent;
		vFitContent;
		yourself.

	textContainer := BrVerticalPane new
		hMatchParent;
		vFitContent;
		cellSpacing: 1;
		addChild: titleContainer;
		addChild: commentContainer;
		yourself.

	self
		addChild: iconContainer;
		addChild: textContainer
]

{ #category : 'private - updating' }
CFCompactListItemElement >> initializeForMemento: aMemento [
	self userData at: viewModel class gtMementoSymbol put: aMemento.

	iconContainer removeChildren.
	titleContainer removeChildren.
	commentContainer removeChildren.

	CFMaCompactListItemElementBuilder new
		includeImplicitActions: false;
		form: self;
		memento: aMemento;
		build.

	self requestStyle.
	self requestLayout
]

{ #category : 'accessing' }
CFCompactListItemElement >> viewModel [
	^ viewModel
]

{ #category : 'accessing' }
CFCompactListItemElement >> viewModel: aViewModel [
	viewModel := aViewModel.
	self withAsyncFutureDo: [ :anElementFuture |
		anElementFuture
			whenPending: [ :anElement |
				iconContainer removeChildren.
				titleContainer removeChildren.
				commentContainer removeChildren ];
			whenError: [ :anElement :anError |
				anElement userData at: aViewModel class gtMementoSymbol put: anError.
				iconContainer removeChildren.
				titleContainer removeChildren.
				commentContainer
					removeChildren;
					addChild: (anError asDebuggableElement hFitContentLimited; vFitContent; yourself) ];
			whenSuccess: [ :anElement :aMemento |
				anElement initializeForMemento: aMemento ] ].
	self asyncFuture executionConfiguration: GtMagritteBuilderUtility executionConfiguration.
	self asyncFuture future: aViewModel mementoFuture
]
