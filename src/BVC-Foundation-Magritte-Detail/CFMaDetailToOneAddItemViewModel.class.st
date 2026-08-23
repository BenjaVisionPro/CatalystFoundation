Class {
	#name : 'CFMaDetailToOneAddItemViewModel',
	#superclass : 'CFMaToOneAddItemViewModel',
	#category : 'BVC-Foundation-Magritte-Detail',
	#package : 'BVC-Foundation-Magritte-Detail'
}

{ #category : 'private - instance creation' }
CFMaDetailToOneAddItemViewModel >> newClassChoiceAddElement [
	^ self installAddButtonEnablementOn: (BrButton new
		aptitude: BrGlamorousButtonWithIconCircularAptitude
			+ ((BrGlamorousWithExplicitDropdownAptitude
				handle: [ self newClassChoiceHandle ]
				content: [ self newClassChoiceContent ])
					withGainFocusOnShow;
					yourself);
		icon: BrGlamorousVectorIcons add;
		label: 'Add item';
		constraintsDo: [ :c | c flow vertical alignCenter ];
		yourself)
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
