Extension { #name : 'CFObject' }

{ #category : '*bvc-foundation-magritte-gt' }
CFObject >> asGtMagritteViewModel [
	"Hijack GT's Magritte rendering while preserving the GT rendering contract."
	^ CFMaViewModel forObject: self
]
