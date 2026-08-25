Class {
	#name : 'CFMaDetailDropdownAptitude',
	#superclass : 'BrGlamorousWithExplicitDropdownAptitude',
	#instVars : [
		'pinnedRowIndex',
		'pinnedRowIndexBlock'
	],
	#category : 'BVC-Foundation-Magritte-Detail',
	#package : 'BVC-Foundation-Magritte-Detail'
}

{ #category : 'private - event management' }
CFMaDetailDropdownAptitude >> onHidden [
	super onHidden.
	pinnedRowIndex := nil.
	self widgetDo: [ :aWidget | aWidget popupOpen: false ]
]

{ #category : 'private - event management' }
CFMaDetailDropdownAptitude >> onShown [
	pinnedRowIndex := nil.
	self pinnedRowIndex.
	super onShown.
	self widgetDo: [ :aWidget | aWidget popupOpen: true ]
]

{ #category : 'accessing' }
CFMaDetailDropdownAptitude >> pinRowIndexUsing: aBlock [
	pinnedRowIndexBlock := aBlock
]

{ #category : 'accessing' }
CFMaDetailDropdownAptitude >> pinnedRowIndex [
	pinnedRowIndex ifNil: [
		pinnedRowIndex := pinnedRowIndexBlock
			ifNil: [ 1 ]
			ifNotNil: [ pinnedRowIndexBlock value ] ].
	^ pinnedRowIndex
]
