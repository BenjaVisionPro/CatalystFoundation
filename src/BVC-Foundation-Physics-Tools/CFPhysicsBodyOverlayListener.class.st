Class {
	#name : 'CFPhysicsBodyOverlayListener',
	#superclass : 'BlCustomEventHandler',
	#instVars : [ 'overlayElement' ],
	#category : 'BVC-Foundation-Physics-Tools',
	#package : 'BVC-Foundation-Physics-Tools'
}

{ #category : 'instance creation' }
CFPhysicsBodyOverlayListener class >> for: anOverlayElement [
	^ self new overlayElement: anOverlayElement; yourself
]

{ #category : 'accessing' }
CFPhysicsBodyOverlayListener >> overlayElement: anElement [ overlayElement := anElement ]

{ #category : 'events' }
CFPhysicsBodyOverlayListener >> eventsToHandle [
	^ {
		BlElementExtentChangedEvent.
		BlElementPositionInSpaceChangedEvent.
		BlElementTransformationInSpaceChangedEvent.
		BlElementRemovedFromSceneGraphEvent }
]

{ #category : 'events' }
CFPhysicsBodyOverlayListener >> elementExtentChangedEvent: anEvent [ overlayElement refresh ]

{ #category : 'events' }
CFPhysicsBodyOverlayListener >> elementPositionInSpaceChangedEvent: anEvent [ overlayElement refresh ]

{ #category : 'events' }
CFPhysicsBodyOverlayListener >> elementTransformationInSpaceChangedEvent: anEvent [ overlayElement refresh ]

{ #category : 'events' }
CFPhysicsBodyOverlayListener >> elementRemovedFromSceneGraphEvent: anEvent [ overlayElement refreshOverlay ]
