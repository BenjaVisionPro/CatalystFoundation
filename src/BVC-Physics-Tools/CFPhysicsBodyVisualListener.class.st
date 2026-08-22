"
I observe the Bloc element represented by a body visual. My responsibility is to refresh or release that visual when the source element changes geometry or leaves the scene graph.
"
Class {
	#name : 'CFPhysicsBodyVisualListener',
	#superclass : 'BlCustomEventHandler',
	#instVars : [
		'visual'
	],
	#category : 'BVC-Physics-Tools',
	#package : 'BVC-Physics-Tools'
}

{ #category : 'instance creation' }
CFPhysicsBodyVisualListener class >> for: aVisual [
	^ self new visual: aVisual; yourself
]

{ #category : 'events' }
CFPhysicsBodyVisualListener >> elementExtentChangedEvent: anEvent [ visual update
]

{ #category : 'events' }
CFPhysicsBodyVisualListener >> elementPositionInSpaceChangedEvent: anEvent [ visual updatePresentation
]

{ #category : 'events' }
CFPhysicsBodyVisualListener >> elementRemovedFromSceneGraphEvent: anEvent [ visual refreshOverlay
]

{ #category : 'events' }
CFPhysicsBodyVisualListener >> elementTransformationInSpaceChangedEvent: anEvent [ visual updatePresentation
]

{ #category : 'events' }
CFPhysicsBodyVisualListener >> eventsToHandle [
	^ {
		BlElementExtentChangedEvent.
		BlElementPositionInSpaceChangedEvent.
		BlElementTransformationInSpaceChangedEvent.
		BlElementRemovedFromSceneGraphEvent }
]

{ #category : 'accessing' }
CFPhysicsBodyVisualListener >> visual: aVisual [ visual := aVisual
]
