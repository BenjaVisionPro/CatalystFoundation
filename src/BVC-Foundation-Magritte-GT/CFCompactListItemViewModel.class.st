Class {
	#name : 'CFCompactListItemViewModel',
	#superclass : 'CFMaViewModel',
	#category : 'BVC-Foundation-Magritte-GT',
	#package : 'BVC-Foundation-Magritte-GT'
}

{ #category : 'api - converting' }
CFCompactListItemViewModel >> asElement [
	^ CFCompactListItemElement new
		viewModel: self;
		yourself
]

{ #category : 'api - instance creation' }
CFCompactListItemViewModel class >> forObject: anObject description: aDescriptionOrBlock [
	^ super
		forObject: anObject
		description: [ | aContainer |
			aContainer := aDescriptionOrBlock value asContainer.
			aContainer children do: [ :each | each beReadOnly ].
			aContainer ]
]
