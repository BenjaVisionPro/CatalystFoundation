Class {
	#name : 'CFPhysicsMondrianTestAnchor',
	#superclass : 'BlAnchorRelativeToElementBounds',
	#category : 'BVC-Physics-Tests-Mondrian',
	#package : 'BVC-Physics-Tests-Mondrian'
}

{ #category : 'accessing' }
CFPhysicsMondrianTestAnchor class >> label [
	^ 'Physics Mondrian test anchor'
]

{ #category : 'geometry' }
CFPhysicsMondrianTestAnchor >> positionWithinBounds: aParentBounds [
	^ aParentBounds bottomLeft
]
