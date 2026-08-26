"
I make the Tree Pager branch containing focus the active branch.

I am installed once on the Tree Pager flow-panes element by
CFMaPhlowNavigation. Focus events bubble from the pane's descendants, so the
policy applies to the whole inspector without modifying GTUI or individual
tools.
"
Class {
	#name : 'CFMaTreePagerFocusActivatesBranchHandler',
	#superclass : 'BlCustomEventHandler',
	#category : 'BVC-Foundation-Magritte-GT',
	#package : 'BVC-Foundation-Magritte-GT'
}

{ #category : 'api - accessing' }
CFMaTreePagerFocusActivatesBranchHandler >> eventsToHandle [
	^ { BlFocusInEvent }
]

{ #category : 'event handling' }
CFMaTreePagerFocusActivatesBranchHandler >> focusInEvent: anEvent [
	anEvent target
		allParentsDetect: [ :eachParent |
			eachParent isKindOf: GtTreePagerPaneElement ]
		ifFound: [ :aPaneElement |
			aPaneElement paneModel previousLink
				ifNotNil: [ :aLink | aLink activate ] ]
		ifNone: [ ]
]
