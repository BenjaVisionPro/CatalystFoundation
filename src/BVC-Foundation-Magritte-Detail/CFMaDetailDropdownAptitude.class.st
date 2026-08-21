Class {
	#name : 'CFMaDetailDropdownAptitude',
	#superclass : 'BrGlamorousWithExplicitDropdownAptitude',
	#category : 'BVC-Foundation-Magritte-Detail',
	#package : 'BVC-Foundation-Magritte-Detail'
}

{ #category : 'private - event management' }
CFMaDetailDropdownAptitude >> onHidden [
	super onHidden.
	self widgetDo: [ :aWidget | aWidget popupOpen: false ]
]

{ #category : 'private - event management' }
CFMaDetailDropdownAptitude >> onShown [
	super onShown.
	self widgetDo: [ :aWidget | aWidget popupOpen: true ]
]
