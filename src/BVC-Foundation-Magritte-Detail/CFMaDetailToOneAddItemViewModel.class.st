Class {
	#name : 'CFMaDetailToOneAddItemViewModel',
	#superclass : 'CFMaToOneAddItemViewModel',
	#category : 'BVC-Foundation-Magritte-Detail',
	#package : 'BVC-Foundation-Magritte-Detail'
}

{ #category : 'private - instance creation' }
CFMaDetailToOneAddItemViewModel >> newClassChoiceAddElement [
	| anAddElement aDropdownAptitude |
	anAddElement := CFMaDetailAddPopupElement new.
	aDropdownAptitude := CFMaDetailDropdownAptitude
		handle: [ CFMaDetailAddPopupElement new
			visibility: BlVisibility hidden;
			yourself ]
		content: [ self newClassChoiceContent ].
	aDropdownAptitude
		withGainFocusOnShow;
		menuContainerDo: [ :aContainer |
			aContainer
				padding: BlInsets empty;
				aptitude: (BrStyleCommonAptitude new
					default: [ :aStyle |
						aStyle
							background: Color transparent;
							border: BlBorder empty ]) ].
	anAddElement addAptitude: aDropdownAptitude.
	^ self installAddButtonEnablementOn: anAddElement
]

{ #category : 'private - instance creation' }
CFMaDetailToOneAddItemViewModel >> newImmediateAddButton [
	| anAddElement |
	anAddElement := CFMaDetailAddPopupElement new
		when: BlClickEvent do: [ :anEvent | self onClick: anEvent currentTarget ];
		yourself.
	^ self installAddButtonEnablementOn: anAddElement
]

{ #category : 'private - instance creation' }
CFMaDetailToOneAddItemViewModel >> newClassChoiceContent [
	| aList |
	aList := BrSimpleList new
		itemStencil: [ :anItemType :aListWidget | CFMaDetailPopupOptionElement new ];
		itemDataBinder: [ :anItemElement :aClass :anItemIndex |
			anItemElement
				text: aClass displayString;
				activateBlock: [
					(self shouldDisableNewItemClass: aClass) ifFalse: [
						self addItemForClass: aClass from: anItemElement.
						anItemElement fireEvent: BrDropdownHideWish new ] ] ];
		hFitContent;
		vFitContent;
		padding: (BlInsets all: CFMaDetailPopupMetrics menuInset);
		geometry: (BlRoundedRectangleGeometry cornerRadius: CFMaDetailPopupMetrics menuCornerRadius);
		background: (Color white alpha: 0.96);
		border: (BlBorder paint: (Color black alpha: 0.18) width: 0.5);
		addAptitude: BrShadowAptitude new;
		items: self newItemClasses;
		yourself.
	^ aList
]
