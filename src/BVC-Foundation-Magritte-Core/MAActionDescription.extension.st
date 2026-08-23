Extension { #name : 'MAActionDescription' }

{ #category : '*bvc-foundation-magritte-core' }
MAActionDescription >> group [
	^ self propertyAt: #cfGroup ifAbsent: [ nil ]
]

{ #category : '*bvc-foundation-magritte-core' }
MAActionDescription >> group: aGroup [
	^ self propertyAt: #cfGroup put: aGroup
]

{ #category : '*bvc-foundation-magritte-core' }
MAActionDescription >> categories [
	^ self propertyAt: #cfCategories ifAbsent: [ #() ]
]

{ #category : '*bvc-foundation-magritte-core' }
MAActionDescription >> categories: aCollection [
	^ self
		propertyAt: #cfCategories
		put: (aCollection ifNil: [ #() ] ifNotNil: [ aCollection asArray ])
]
