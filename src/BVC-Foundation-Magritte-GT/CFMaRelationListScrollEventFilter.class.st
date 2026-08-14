Class {
	#name : 'CFMaRelationListScrollEventFilter',
	#superclass : 'BlBasicEventHandler',
	#category : 'BVC-Foundation-Magritte-GT',
	#package : 'BVC-Foundation-Magritte-GT'
}

{ #category : 'accessing' }
CFMaRelationListScrollEventFilter >> eventClass [
	^ BlMouseWheelEvent
]

{ #category : 'api - event managing' }
CFMaRelationListScrollEventFilter >> handleEvent: anEvent [
	anEvent sendTo: self
]

{ #category : 'mouse handlers' }
CFMaRelationListScrollEventFilter >> mouseWheelEvent: anEvent [
	anEvent isTouch ifTrue: [ ^ self ].

	anEvent currentTarget
		allParentsDetect: [ :eachParent |
			eachParent isKindOf: CFSmoothScrollableElement ]
		ifFound: [ :aScrollableElement |
			(aScrollableElement smoothScrollWheelEvent: anEvent)
				ifTrue: [ anEvent consumed: true ] ]
		ifNone: [ ]
]

{ #category : 'api - event managing' }
CFMaRelationListScrollEventFilter >> wantsEvent: anEvent [
	^ anEvent class == self eventClass
		or: [ anEvent class inheritsFrom: self eventClass ]
]
