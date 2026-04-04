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
CFMaBuilderUtility class >> newEditableFieldValueContainer [
	^ BrFrame new
		hMatchParent;
		vFitContent;
		padding: (BlInsets top: 0 right: 0 bottom: 0 left: 0);
		yourself
]

{ #category : 'elements' }
CFMaBuilderUtility class >> newFieldLabelWithSpace: aSpaceNumber using: aDescription [
	| aText labelAptitude |
	aText := aDescription label asRopedText.

	labelAptitude := aDescription labelAptitude
			ifNil: [ BrGlamorousLabelAptitude new
					foreground: (Color black alpha: 0.5) ]
			ifNotNil: #value.

	^ BrLabel new
		id: (GtMagritteFieldLabelId new description: aDescription);
		text: aText;
		aptitude: labelAptitude;
		fitContent;
		margin: (BlInsets
				top: 0
				right: (aSpaceNumber ifNil: [ GtMagritteBuilderUtility defaultSpaceNumber ])
				bottom: 3
				left: 0);
		constraintsDo: [ :c | c grid vertical alignTop ];
		when: BlClickEvent
			do: [ :anEvent |
				anEvent modifiers isAlt
					ifTrue: [ anEvent consumed: true.
						anEvent target phlow spawnObject: aDescription ] ]
]

{ #category : 'elements' }
CFMaBuilderUtility class >> newFieldRowContainer [
	^ BrVerticalPane new
		hMatchParent;
		vFitContent;
		padding: (BlInsets top: 4 right: 0 bottom: 6 left: 0);
		margin: (BlInsets top: 0 right: 0 bottom: 2 left: 0);
		cellSpacing: 2;
		yourself
]

{ #category : 'icons' }
CFMaBuilderUtility class >> newFontAwesomeIconFor: aSelectorSymbol using: aDescription [
	| icon |
	^ [
		icon := aDescription iconLibraryClass
			icon: aSelectorSymbol
			styleName: aDescription styleName.
		icon color: Color black.
		aDescription scaledElementForIcon: icon ]
		on: Error
		do: [ self newChooseIconAffordanceFor: aDescription ]
]

{ #category : 'icons' }
CFMaBuilderUtility class >> newFontAwesomeIconForMetadata: anIconMetadata height: aNumber [
	^ self
		newFontAwesomeIconForMetadata: anIconMetadata
		styleName: anIconMetadata preferredStyleName
		height: aNumber
]

{ #category : 'icons' }
CFMaBuilderUtility class >> newFontAwesomeIconForMetadata: anIconMetadata styleName: aStyleName fitInto: anExtent [
	^ [ | icon |
		icon := anIconMetadata iconLibraryClass
			icon: anIconMetadata selectorSymbol
			styleName: aStyleName.
		icon color: Color black.
		icon asScalableElementSized: (icon extentFittingInto: anExtent) ]
		on: Error
		do: [ BrLabel new aptitude: BrLabelAptitude new; text: anIconMetadata selectorSymbol asString; fitContent; yourself ]
]

{ #category : 'icons' }
CFMaBuilderUtility class >> newFontAwesomeIconForMetadata: anIconMetadata styleName: aStyleName height: aNumber [
	^ [ | icon |
		icon := anIconMetadata iconLibraryClass
			icon: anIconMetadata selectorSymbol
			styleName: aStyleName.
		icon color: Color black.
		icon asScalableElementSized: (icon extentForHeight: aNumber) ]
		on: Error
		do: [ BrLabel new aptitude: BrLabelAptitude new; text: anIconMetadata selectorSymbol asString; fitContent; yourself ]
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
		padding: (BlInsets all: 14);
		cellSpacing: 10;
		background: (Color black alpha: 0.05);
		yourself
]

{ #category : 'elements' }
CFMaBuilderUtility class >> newReadOnlyFieldValueContainer [
	^ BrFrame new
		hMatchParent;
		vFitContent;
		padding: (BlInsets all: 6);
		margin: (BlInsets top: 0 right: 0 bottom: 0 left: 0);
		background: (Color black alpha: 0.035);
		geometry: (BlRoundedRectangleGeometry cornerRadius: 6.0);
		yourself
]
