"
I prune Tree Pager branches when GT closes/removes their inspector pane.

GT normally keeps a removed link in the model so it can later be restored.
Foundation navigation deliberately does not keep that hidden history: once a
child inspector is closed, its incoming link is removed from the parent's
followingLinks. The whole descendant branch therefore becomes unreachable
from that parent.
"
Class {
	#name : 'CFMaTreePagerPruneRemovedBranchHandler',
	#superclass : 'BlCustomEventHandler',
	#instVars : [
		'pagerElement'
	],
	#category : 'BVC-Foundation-Magritte-GT',
	#package : 'BVC-Foundation-Magritte-GT'
}

{ #category : 'api - accessing' }
CFMaTreePagerPruneRemovedBranchHandler >> eventsToHandle [
	^ #()
]

{ #category : 'private - announcements' }
CFMaTreePagerPruneRemovedBranchHandler >> onLinkStateChanged: anAnnouncement [
	anAnnouncement newState isRemoved ifFalse: [ ^ self ].
	pagerElement ifNil: [ ^ self ].

	"Do not mutate followingLinks from inside GT's link-state notification.
	Let GT finish its own removed-state update, then structurally prune it."
	BlTaskAction
		enqueueElement: pagerElement
		action: [
			| aLink |
			aLink := anAnnouncement linkModel.
			aLink isRemoved ifTrue: [
				aLink removeFromPreviousPane ] ]
]

{ #category : 'api - hooks' }
CFMaTreePagerPruneRemovedBranchHandler >> onInstalledIn: anElement [
	super onInstalledIn: anElement.
	pagerElement := anElement.
	anElement pagerModel announcer weak
		when: GtTreePagerLinkModelStateChanged
		send: #onLinkStateChanged:
		to: self
]

{ #category : 'api - hooks' }
CFMaTreePagerPruneRemovedBranchHandler >> onUninstalledIn: anElement [
	anElement hasPagerModel ifTrue: [
		anElement pagerModel announcer unsubscribe: self ].
	pagerElement := nil.
	super onUninstalledIn: anElement
]
