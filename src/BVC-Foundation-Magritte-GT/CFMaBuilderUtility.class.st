Class {
	#name : 'CFMaBuilderUtility',
	#superclass : 'Object',
	#category : 'BVC-Foundation-Magritte-GT',
	#package : 'BVC-Foundation-Magritte-GT'
}

{ #category : 'elements' }
CFMaBuilderUtility class >> newChooseIconAffordanceFor: aDescription [
	^ BrLabel new
		aptitude: BrLabelAptitude new;
		text: aDescription chooseIconLabel;
		padding: (BlInsets all: 4);
		fitContent;
		yourself
]

{ #category : 'elements' }
CFMaBuilderUtility class >> newFieldLabelWithSpace: aSpaceNumber using: aDescription [
	| aText labelAptitude |
	aText := aDescription label asRopedText.

	labelAptitude := aDescription labelAptitude
			ifNil: [ BrGlamorousLabelAptitude new
					foreground: BrGlamorousColors disabledButtonTextColor ]
			ifNotNil: #value.

	^ BrLabel new
		id: (GtMagritteFieldLabelId new description: aDescription);
		text: aText;
		aptitude: labelAptitude;
		fitContent;
		margin: (BlInsets
				top: 2
				right: (aSpaceNumber ifNil: [ GtMagritteBuilderUtility defaultSpaceNumber ])
				bottom: (aSpaceNumber ifNil: [ GtMagritteBuilderUtility defaultSpaceNumber ])
				left: 0);
		constraintsDo: [ :c | c grid vertical alignTop ];
		when: BlClickEvent
			do: [ :anEvent |
				anEvent modifiers isAlt
					ifTrue: [ anEvent consumed: true.
						anEvent target phlow spawnObject: aDescription ] ]
]

{ #category : 'icons' }
CFMaBuilderUtility class >> newFontAwesomeIconFor: aSelectorSymbol using: aDescription [
	| anIconLibrary |
	anIconLibrary := aDescription iconLibraryClass style: aDescription styleName.
	^ [ ((anIconLibrary icon: aSelectorSymbol) asElement asScalableElement size: aDescription iconSize) ]
		on: Error
		do: [ self newChooseIconAffordanceFor: aDescription ]
]

{ #category : 'icons' }
CFMaBuilderUtility class >> newFontAwesomeIconForMetadata: anIconMetadata size: aSize [
	^ [ ((anIconMetadata iconLibraryClass style: anIconMetadata preferredStyleName)
		icon: anIconMetadata selectorSymbol) asElement asScalableElement size: aSize ]
		on: Error
		do: [ BrLabel new aptitude: BrLabelAptitude new; text: anIconMetadata selectorSymbol asString; fitContent; yourself ]
]

{ #category : 'icons' }
CFMaBuilderUtility class >> newFontAwesomeIconSelectorFor: anAnchor memento: aMemento description: aDescription [
	^ CFMaFontAwesomeIconSelectorElement new
		fieldViewModel: (GtMagritteFieldViewModel new
				memento: aMemento;
				description: aDescription;
				yourself);
		dropdownAnchor: anAnchor;
		constraintsDo: [ :c |
			c horizontal exact: aDescription selectorExtent x.
			c vertical exact: aDescription selectorExtent y ];
		yourself
]

{ #category : 'elements' }
CFMaBuilderUtility class >> newFormContainerFor: aMemento [
	^ BrVerticalPane new
		in: [ :aPane |
			aPane magritte
				beFieldContainer;
				beToolbarContainer ];
		hMatchParent;
		vFitContent;
		padding: (BlInsets all: 12);
		cellSpacing: 8;
		background: (Color black alpha: 0.05);
		yourself
]

{ #category : 'icons' }
CFMaBuilderUtility class >> newWritableFontAwesomeIconMemento: aMemento using: aDescription [
	| anAnchor |
	anAnchor := BrFrame new
			beFocusable;
			fitContent;
			padding: (BlInsets all: 2);
			yourself.

	anAnchor
		addAptitude: (BrGlamorousWithExplicitDropdownAptitude
				handle: [ self newWritableFontAwesomeIconViewerMemento: aMemento using: aDescription ]
				content: [ self
						newFontAwesomeIconSelectorFor: anAnchor
						memento: aMemento
						description: aDescription ]).

	anAnchor
		withAsyncSinkDo: [ :anElementSink | 
			anElementSink
				sink: AsyncPeekSink new;
				whenUpdate: [ :aContainer :aSink | 
					| aValue anIcon |
					aValue := aSink value currentValue.
					anIcon := aValue
							ifNil: [ self newChooseIconAffordanceFor: aDescription ]
							ifNotNil: [ self newFontAwesomeIconFor: aValue using: aDescription ].
					aContainer
						removeChildren;
						addChild: anIcon ].
			(aMemento readObservableValueUsing: aDescription) observe: anElementSink ].

	^ anAnchor
]

{ #category : 'icons' }
CFMaBuilderUtility class >> newWritableFontAwesomeIconViewerMemento: aMemento using: aDescription [
	| aFrame |
	aFrame := BrFrame new.
	aFrame
		fitContent;
		padding: (BlInsets all: 2);
		constraintsDo: [ :c | 
			c grid vertical alignCenter.
			c grid horizontal alignLeft ];
		withAsyncSinkDo: [ :anElementSink | 
			anElementSink
				sink: AsyncPeekSink new;
				whenUpdate: [ :aContainer :aSink | 
					| aValue anIcon |
					aValue := aSink value currentValue.
					anIcon := aValue
							ifNil: [ self newChooseIconAffordanceFor: aDescription ]
							ifNotNil: [ self newFontAwesomeIconFor: aValue using: aDescription ].
					aContainer
						removeChildren;
						addChild: anIcon ].
			(aMemento readObservableValueUsing: aDescription) observe: anElementSink ].
	^ aFrame
]
