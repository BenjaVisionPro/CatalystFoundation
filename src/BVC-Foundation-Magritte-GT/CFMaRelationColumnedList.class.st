"I am responsible for a Foundation columned relation list whose single-item selection navigates cyclically."

Class {
	#name : 'CFMaRelationColumnedList',
	#superclass : 'BrColumnedList',
	#category : 'BVC-Foundation-Magritte-GT-Elements',
	#package : 'BVC-Foundation-Magritte-GT',
	#tag : 'Elements'
}

{ #category : 'api - selection' }
CFMaRelationColumnedList >> selectNext [
	| aMaximum anIndex |
	aMaximum := self maxSelectionIndex.
	aMaximum isZero ifTrue: [ ^ self ].

	self selectedIndices
		ifEmpty: [ ^ self selectOne: 1 ]
		ifNotEmpty: [ :theIndices |
			anIndex := theIndices first.
			^ self selectOne: (anIndex >= aMaximum
				ifTrue: [ 1 ]
				ifFalse: [ anIndex + 1 ]) ]
]

{ #category : 'api - selection' }
CFMaRelationColumnedList >> selectPrevious [
	| aMaximum anIndex |
	aMaximum := self maxSelectionIndex.
	aMaximum isZero ifTrue: [ ^ self ].

	self selectedIndices
		ifEmpty: [ ^ self selectOne: aMaximum ]
		ifNotEmpty: [ :theIndices |
			anIndex := theIndices first.
			^ self selectOne: (anIndex <= 1
				ifTrue: [ aMaximum ]
				ifFalse: [ anIndex - 1 ]) ]
]
