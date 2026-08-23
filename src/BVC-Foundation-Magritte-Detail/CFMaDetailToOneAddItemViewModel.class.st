Class {
	#name : 'CFMaDetailToOneAddItemViewModel',
	#superclass : 'CFMaToOneAddItemViewModel',
	#category : 'BVC-Foundation-Magritte-Detail',
	#package : 'BVC-Foundation-Magritte-Detail'
}

{ #category : 'private - instance creation' }
CFMaDetailToOneAddItemViewModel >> newClassChoiceAddElement [
	^ self installAddButtonEnablementOn:
		(CFMaDetailAddPopupElement classChoiceFor: self)
]

{ #category : 'private - instance creation' }
CFMaDetailToOneAddItemViewModel >> newImmediateAddButton [
	^ self installAddButtonEnablementOn:
		(CFMaDetailAddPopupElement immediateFor: self)
]
