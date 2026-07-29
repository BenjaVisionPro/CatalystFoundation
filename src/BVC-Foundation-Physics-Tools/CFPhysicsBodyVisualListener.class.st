Class {
	#name : 'CFPhysicsBodyVisualListener',
	#superclass : 'BlCustomEventHandler',
	#instVars : [ 'visual' ],
	#category : 'BVC-Foundation-Physics-Tools',
	#package : 'BVC-Foundation-Physics-Tools'
}

{ #category : 'instance creation' }
CFPhysicsBodyVisualListener class >> for: aVisual [
	^ self new visual: aVisual; yourself
]

{ #category : 'accessing' }
CFPhysicsBodyVisualListener >> visual: aVisual [ visual := aVisual ]

{ #category : 'events' }
CFPhysicsBodyVisualListener >> eventsToHandle [
	^ {
		BlElementExtentChangedEvent.
		BlElementPositionInSpaceChangedEvent.
		BlElementTransformationInSpaceChangedEvent.
		BlElementRemovedFromSceneGraphEvent }
]

{ #category : 'events' }
CFPhysicsBodyVisualListener >> elementExtentChangedEvent: anEvent [ visual update ]

{ #category : 'events' }
CFPhysicsBodyVisualListener >> elementPositionInSpaceChangedEvent: anEvent [ visual update ]

{ #category : 'events' }
CFPhysicsBodyVisualListener >> elementTransformationInSpaceChangedEvent: anEvent [ visual update ]

{ #category : 'events' }
CFPhysicsBodyVisualListener >> elementRemovedFromSceneGraphEvent: anEvent [ visual refreshOverlay ]
