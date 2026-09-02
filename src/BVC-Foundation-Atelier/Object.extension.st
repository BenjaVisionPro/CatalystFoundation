Extension { #name : 'Object' }

{ #category : '*BVC-Foundation-Atelier' }
Object >> asAtelier [
	"Open this ordinary Magritte-described object through Atelier while leaving
	presentation selection to Foundation Magritte."
	^ CFAtelierViewModel forObject: self
]

{ #category : '*BVC-Foundation-Atelier' }
Object >> gtAtelierFor: aView [
	<gtView>
	self hasMagritteDescription ifFalse: [ ^ aView empty ].

	^ aView explicit
		title: 'Atelier';
		priority: 50;
		disableAsync;
		stencil: [ self asAtelier asElement ]
]
