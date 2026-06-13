Class {
	#name : 'CFMaListClickToPhlowSelectHandler',
	#superclass : 'BrListClickToSelectHandler',
	#instVars : [
		'transformation'
	],
	#category : 'BVC-Foundation-Magritte-GT',
	#package : 'BVC-Foundation-Magritte-GT'
}

{ #category : 'defaults' }
CFMaListClickToPhlowSelectHandler >> defaultTransformation [
	^ GtPhlowSendTransformation default
]

{ #category : 'initialization' }
CFMaListClickToPhlowSelectHandler >> initialize [
	super initialize.
	transformation := self defaultTransformation
]

{ #category : 'api - accessing' }
CFMaListClickToPhlowSelectHandler >> transformation [
	^ transformation
]

{ #category : 'api - accessing' }
CFMaListClickToPhlowSelectHandler >> transformation: aGtPhlowSendTransformation [
	transformation := aGtPhlowSendTransformation asPhlowSendTransformation
]

{ #category : 'api - accessing' }
CFMaListClickToPhlowSelectHandler >> clickEvent: aBlClickEvent [
	| anItemIndex wasAlreadySelected |

	anItemIndex := aBlClickEvent currentTarget constraints infinite holder dataSourcePosition.
	anItemIndex <= 0
		ifTrue: [ ^ self ].

	wasAlreadySelected := self
		isListWidget: self listWidget
		selectedAt: anItemIndex.

	super clickEvent: aBlClickEvent.

	wasAlreadySelected ifTrue: [
		self selectCurrentSelectionFrom: self listWidget ]
]

{ #category : 'private - testing' }
CFMaListClickToPhlowSelectHandler >> isListWidget: aListWidget selectedAt: anIndex [
	| isSelected |
	isSelected := false.
	aListWidget selectedIndices do: [ :eachIndex |
		eachIndex = anIndex ifTrue: [ isSelected := true ] ].
	^ isSelected
]

{ #category : 'private - selecting' }
CFMaListClickToPhlowSelectHandler >> selectCurrentSelectionFrom: aListWidget [
	| theIndices selectedObject |
	theIndices := aListWidget selectedIndices.
	theIndices isEmpty ifTrue: [ ^ self ].

	selectedObject := aListWidget selectionCallback value: theIndices.
	self transformation
		select: selectedObject
		indices: theIndices
		from: aListWidget
		shouldShowSpace: false
]
