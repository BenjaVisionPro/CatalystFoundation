Class {
	#name : 'CFMaDetailAddItemViewModel',
	#superclass : 'CFMaAddItemViewModel',
	#category : 'BVC-Foundation-Magritte-Detail',
	#package : 'BVC-Foundation-Magritte-Detail'
}

{ #category : 'private - instance creation' }
CFMaDetailAddItemViewModel >> newClassChoiceAddElement [
	| anAddElement aDropdownAptitude |
	anAddElement := CFMaDetailAddPopupElement new.
	aDropdownAptitude := BrGlamorousWithExplicitDropdownAptitude
		handle: [ CFMaDetailAddPopupElement new
			popupBackgroundColor: CFMaDetailPopupMetrics menuBackgroundColor;
			popupOpen: true;
			yourself ]
		content: [ self newClassChoiceContent ].
	aDropdownAptitude
		withGainFocusOnShow;
		menuContainerDo: [ :aContainer |
			aContainer
				padding: BlInsets empty;
				geometry: (BlChildrenWrappingGeometry
					cornerRadius: CFMaDetailPopupMetrics menuCornerRadius
					enlargedBy: 0.5);
				background: CFMaDetailPopupMetrics menuBackgroundColor;
				border: (BlBorder paint: (Color black alpha: 0.18) width: 0.5);
				aptitude: BrShadowAptitude new ].
	anAddElement addAptitude: aDropdownAptitude.
	^ anAddElement
]

{ #category : 'private - instance creation' }
CFMaDetailAddItemViewModel >> newImmediateAddButton [
	^ CFMaDetailAddPopupElement new
		when: BlClickEvent do: [ :anEvent | self onClick: anEvent currentTarget ];
		yourself
]

{ #category : 'private - instance creation' }
CFMaDetailAddItemViewModel >> newClassChoiceContent [
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
		background: Color transparent;
		border: BlBorder empty;
		items: self newItemClasses;
		yourself.
	^ aList
]
