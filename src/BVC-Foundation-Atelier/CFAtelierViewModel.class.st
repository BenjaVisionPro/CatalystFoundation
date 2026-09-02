"I am the public view-model entry point for editing an ordinary Magritte-described object as a Foundation Atelier.

I deliberately inherit Foundation Magritte's rendering and memento behaviour unchanged. Atelier does not choose a parallel presentation: the object's Magritte container continues to select its Foundation presentation through the existing CFMaViewModel machinery.

When Atelier-owned orchestration UI such as a palette is configured, I arrange it around that unchanged Foundation form rather than rendering the form myself."
Class {
	#name : 'CFAtelierViewModel',
	#superclass : 'CFMaViewModel',
	#instVars : [
		'palette'
	],
	#category : 'BVC-Foundation-Atelier-UI',
	#package : 'BVC-Foundation-Atelier',
	#tag : 'UI'
}

{ #category : 'api - converting' }
CFAtelierViewModel >> asElement [
	| aFormElement |
	self presentationDo: [ :aPresentation |
		aPresentation
			relationItemElementDo: [ :aRow :anObject :aDescription :aMemento |
				CFAtelierRelationDropTarget
					installOn: aRow
					targetObject: anObject
					memento: aMemento
					description: aDescription ];
			relationElementDo: [ :aRelationElement :aDescription :aMemento |
				CFAtelierRelationDropSurface
					installOn: aRelationElement
					memento: aMemento
					description: aDescription ] ].
	aFormElement := super asElement.
	palette ifNil: [ ^ aFormElement ].
	^ CFAtelierElement new
		palette: palette;
		formElement: aFormElement;
		yourself
]

{ #category : 'accessing' }
CFAtelierViewModel >> palette [
	^ palette
]

{ #category : 'accessing' }
CFAtelierViewModel >> palette: anAtelierPalette [
	palette := anAtelierPalette
]
