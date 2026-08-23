Class {
	#name : 'CFMaDetailAddItemViewModel',
	#superclass : 'CFMaAddItemViewModel',
	#category : 'BVC-Foundation-Magritte-Detail',
	#package : 'BVC-Foundation-Magritte-Detail'
}

{ #category : 'private - instance creation' }
CFMaDetailAddItemViewModel >> newClassChoiceAddElement [
	^ CFMaDetailAddPopupElement classChoiceFor: self
]

{ #category : 'private - instance creation' }
CFMaDetailAddItemViewModel >> newImmediateAddButton [
	^ CFMaDetailAddPopupElement immediateFor: self
]
