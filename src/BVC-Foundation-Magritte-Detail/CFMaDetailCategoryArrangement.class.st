Class {
	#name : 'CFMaDetailCategoryArrangement',
	#superclass : 'Object',
	#category : 'BVC-Foundation-Magritte-Detail',
	#package : 'BVC-Foundation-Magritte-Detail'
}

{ #category : 'testing' }
CFMaDetailCategoryArrangement class >> isAbstract [
	^ self = CFMaDetailCategoryArrangement
]

{ #category : 'testing' }
CFMaDetailCategoryArrangement >> isTabs [ ^ false ]

{ #category : 'testing' }
CFMaDetailCategoryArrangement >> isAccordions [ ^ false ]

{ #category : 'testing' }
CFMaDetailCategoryArrangement >> isSections [ ^ false ]
