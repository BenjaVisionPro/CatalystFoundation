Extension { #name : 'CFObject' }

{ #category : '*bvc-foundation-magritte-gt' }
CFObject >> asGtMagritteViewModel [
	"Hijack GT's Margritte"
  ^ CFMagritteViewModel forObject: self
]
