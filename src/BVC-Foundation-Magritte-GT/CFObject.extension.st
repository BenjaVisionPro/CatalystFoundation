Extension { #name : 'CFObject' }

{ #category : '*bvc-foundation-magritte-gt' }
CFObject >> asGtMagritteViewModel [
	"Hijack GT's Margritte"
  ^ CFMaViewModel forObject: self
]

{ #category : '*bvc-foundation-magritte-gt' }
CFObject >> magritteDescription [
	^ super magritteDescription
		blocElementContainerStencil: [ :aMemento | CFMaFormStencilBuilder new memento: aMemento ];
		yourself
]
