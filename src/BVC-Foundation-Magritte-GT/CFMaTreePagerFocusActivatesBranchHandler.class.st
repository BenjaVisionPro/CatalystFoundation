"
I make the Tree Pager branch containing user interaction the active branch.

I am installed once on the Tree Pager flow-panes element by
CFMaPhlowNavigation. Focus events cover focusable inspector content. Primary
mouse-down events cover inspector surfaces that do not themselves take focus.
Both paths activate the pane's existing previous link; GT remains responsible
for the branch/link state transition itself.
"
Class {
	#name : 'CFMaTreePagerFocusActivatesBranchHandler',
	#superclass : 'BlCustomEventHandler',
	#category : 'BVC-Foundation-Magritte-GT',
	#package : 'BVC-Foundation-Magritte-GT'
}

{ #category : 'api - accessing' }
CFMaTreePagerFocusActivatesBranchHandler >> eventsToHandle [
	^ { BlFocusInEvent. BlMouseDownEvent }
]

{ #category : 'private - event handling' }
CFMaTreePagerFocusActivatesBranchHandler >> activateBranchContaining: anEvent [
	anEvent target
		allParentsDetect: [ :eachParent |
			eachParent isKindOf: GtTreePagerPaneElement ]
		ifFound: [ :aPaneElement |
			aPaneElement paneModel previousLink
				ifNotNil: [ :aLink | aLink activate ] ]
		ifNone: [ ]
]

{ #category : 'event handling' }
CFMaTreePagerFocusActivatesBranchHandler >> focusInEvent: anEvent [
	self activateBranchContaining: anEvent
]

{ #category : 'event handling' }
CFMaTreePagerFocusActivatesBranchHandler >> mouseDownEvent: anEvent [
	anEvent primaryButtonPressed ifFalse: [ ^ self ].
	self activateBranchContaining: anEvent
]
