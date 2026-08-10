Extension { #name : 'BlElement' }

{ #category : '*BVC-Motion-Core' }
BlElement >> motion [
	^ CFMotionBuilder on: self
]
