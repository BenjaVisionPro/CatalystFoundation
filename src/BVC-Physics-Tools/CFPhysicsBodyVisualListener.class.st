Class {
	#name : 'CFPhysicsBodyVisualListener',
	#superclass : 'BlCustomEventHandler',
	#instVars : [ 'visual' ],
	#category : 'BVC-Physics-Tools',
	#package : 'BVC-Physics-Tools'
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
