Extension { #name : 'BlElement' }

{ #category : '*BVC-Foundation-Magritte-GT' }
BlElement >> beWithoutCompositionLayer [
	"Render me without requesting a composition layer. This is the inverse of
	#beInSingleCompositionLayer and #beInSeparateCompositionLayer."

	visuals := visuals compositingMode: BlCompositingWithoutLayerMode uniqueInstance
]
