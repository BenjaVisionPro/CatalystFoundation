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
CFMaBuilderUtility class >> newFieldLabelUsing: aDescription [
	| aText labelAptitude |
	aText := aDescription label asRopedText.

	labelAptitude := aDescription labelAptitude
			ifNil: [ BrGlamorousLabelAptitude new
				foreground: (Color black alpha: 0.28) ]
			ifNotNil: #value.

	^ BrLabel new
		id: (GtMagritteFieldLabelId new description: aDescription);
		text: aText;
		aptitude: labelAptitude;
		hMatchParent;
		fitContent;
		margin: (BlInsets top: 0 right: 0 bottom: 4 left: 12);
		when: BlClickEvent
			do: [ :anEvent |
				anEvent modifiers isAlt
					ifTrue: [ anEvent consumed: true.
						anEvent target phlow spawnObject: aDescription ] ]
]

{ #category : 'elements' }
CFMaBuilderUtility class >> newFieldLabelWithSpace: aSpaceNumber using: aDescription [
	^ self newFieldLabelUsing: aDescription
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
		padding: (BlInsets all: 12);
		cellSpacing: 8;
		background: (Color black alpha: 0.05);
		yourself
]

{ #category : 'elements' }
CFMaBuilderUtility class >> newGroupLabelUsing: aGroupName [
	^ BrLabel new
		aptitude: (BrGlamorousLabelAptitude new foreground: (Color black alpha: 0.28));
		text: aGroupName asString asUppercase;
		hMatchParent;
		fitContent;
		margin: (BlInsets top: 2 right: 0 bottom: 6 left: 0);
		yourself
]
