Class {
	#name : 'CFPhysicsMondrianTestAnchor',
	#superclass : 'BlAnchorRelativeToElementBounds',
	#category : 'BVC-Foundation-Physics-Tests',
	#package : 'BVC-Foundation-Physics-Tests'
}

{ #category : 'accessing' }
CFPhysicsMondrianTestAnchor class >> label [
	^ 'Physics Mondrian test anchor'
]

{ #category : 'geometry' }
CFPhysicsMondrianTestAnchor >> positionWithinBounds: aParentBounds [
	^ aParentBounds bottomLeft
]
