Extension { #name : 'MAOptionDescription' }

{ #category : '*BVC-Foundation-Magritte-GT' }
MAOptionDescription >> blocOptionIconStencil [
	^ self
		propertyAt: #blocOptionIconStencil
		ifAbsent: [ nil ]
]

{ #category : '*BVC-Foundation-Magritte-GT' }
MAOptionDescription >> blocOptionIconStencil: aBlock [
	self
		propertyAt: #blocOptionIconStencil
		put: aBlock
]
