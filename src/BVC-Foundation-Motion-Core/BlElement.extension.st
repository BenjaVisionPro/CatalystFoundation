Extension { #name : 'BlElement' }

{ #category : '*BVC-Foundation-Motion-Core' }
BlElement >> motion [
	^ CFMotionBuilder on: self
]
