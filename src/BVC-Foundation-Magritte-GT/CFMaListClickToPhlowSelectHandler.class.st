Class {
	#name : 'CFMaListClickToPhlowSelectHandler',
	#superclass : 'GtPhlowListHandler',
	#category : 'BVC-Foundation-Magritte-GT',
	#package : 'BVC-Foundation-Magritte-GT'
}

{ #category : 'api - accessing' }
CFMaListClickToPhlowSelectHandler >> eventsToHandle [
	^ { BlClickEvent }
]

{ #category : 'api - event managing' }
CFMaListClickToPhlowSelectHandler >> handleEvent: anEvent [
	self clickEvent: anEvent
]

{ #category : 'api - event managing' }
CFMaListClickToPhlowSelectHandler >> clickEvent: anEvent [
	| aList thePreviousIndices |
	aList := anEvent currentTarget.
	anEvent target == aList ifTrue: [ ^ self ].

	thePreviousIndices := aList selectedIndices.
	thePreviousIndices isEmpty ifTrue: [ ^ self ].

	BlUniverse defer: [
		aList isAttachedToSceneGraph ifTrue: [
			| theCurrentIndices |
			theCurrentIndices := aList selectedIndices.
			theCurrentIndices = thePreviousIndices ifTrue: [
				self selectIndices: theCurrentIndices from: aList ] ] ]
]

{ #category : 'private - selecting' }
CFMaListClickToPhlowSelectHandler >> selectIndices: theIndices from: aList [
	| selectedObject |
	theIndices isEmpty ifTrue: [ ^ self ].

	selectedObject := aList selectionCallback value: theIndices.
	self transformation
		select: selectedObject
		indices: theIndices
		from: aList
		shouldShowSpace: false
]

{ #category : 'api - event managing' }
CFMaListClickToPhlowSelectHandler >> wantsEvent: anEvent [
	^ anEvent isKindOf: BlClickEvent
]
