"
I adapt Foundation navigation intent onto ordinary Phlow and, when present,
the existing GT Tree Pager.

I deliberately know the Tree Pager API so relation renderers do not have to.
Navigation is scoped to the current pane's immediate following links. Normal spawning remains standard Phlow; branch-preserving activation is used by Foundation's alternate-click navigation.
"
Class {
	#name : 'CFMaPhlowNavigation',
	#superclass : 'Object',
	#category : 'BVC-Foundation-Magritte-GT',
	#package : 'BVC-Foundation-Magritte-GT'
}

{ #category : 'api - navigating' }
CFMaPhlowNavigation class >> selectFrom: anElement object: anObject [
	self
		treePagerPaneContaining: anElement
		ifFound: [ :aPaneElement |
			| anExistingLink |
			self ensureTreePagerPolicyIn: aPaneElement navigationContext pagerElement.
			anExistingLink := self
				immediateSpawnedLinkFrom: aPaneElement paneModel
				showing: anObject.
			anExistingLink
				ifNotNil: [
					^ self
						activateAndFocus: anExistingLink
						from: aPaneElement ]
				ifNil: [
					^ anElement phlow selectObject: anObject ] ]
		ifNone: [
			^ anElement phlow selectObject: anObject ]
]

{ #category : 'api - navigating' }
CFMaPhlowNavigation class >> closeSpawnedInspectorFrom: anElement object: anObject [
	self
		treePagerPaneContaining: anElement
		ifFound: [ :aPaneElement |
			| anExistingLink |
			self ensureTreePagerPolicyIn: aPaneElement navigationContext pagerElement.
			anExistingLink := self
				immediateSpawnedLinkFrom: aPaneElement paneModel
				showing: anObject.
			anExistingLink ifNotNil: #remove ]
		ifNone: [ ]
]

{ #category : 'api - navigating' }
CFMaPhlowNavigation class >> navigateFrom: anElement to: anObject [
	self
		navigateFrom: anElement
		to: anObject
		preservingCurrentBranch: false
]

{ #category : 'api - navigating' }
CFMaPhlowNavigation class >> navigatePreservingCurrentBranchFrom: anElement to: anObject [
	self
		navigateFrom: anElement
		to: anObject
		preservingCurrentBranch: true
]

{ #category : 'private - navigating' }
CFMaPhlowNavigation class >> navigateFrom: anElement to: anObject preservingCurrentBranch: shouldPreserveCurrentBranch [
	self
		treePagerPaneContaining: anElement
		ifFound: [ :aPaneElement |
			| anExistingLink |
			self ensureTreePagerPolicyIn: aPaneElement navigationContext pagerElement.
			anExistingLink := self
				immediateLinkFrom: aPaneElement paneModel
				showing: anObject.
			anExistingLink
				ifNotNil: [
					^ self
						activateAndFocus: anExistingLink
						from: aPaneElement ]
				ifNil: [
					shouldPreserveCurrentBranch ifTrue: [
						aPaneElement paneModel inactivateLink ].
					^ anElement phlow spawnObject: anObject ] ]
		ifNone: [
			^ anElement phlow spawnObject: anObject ]
]

{ #category : 'private - tree pager' }
CFMaPhlowNavigation class >> ensureTreePagerPolicyIn: aPagerElement [
	aPagerElement
		removeEventHandlersSuchThat: [ :eachHandler |
			eachHandler isKindOf: CFMaTreePagerPruneRemovedBranchHandler ];
		addEventHandler: CFMaTreePagerPruneRemovedBranchHandler new
]

{ #category : 'private - tree pager' }
CFMaPhlowNavigation class >> immediateLinkFrom: aPaneModel showing: anObject [
	^ aPaneModel followingLinks
		detect: [ :aLink |
			| aTool |
			aLink isRemoved ifFalse: [
				aTool := aLink paneModel phlowTool.
				(aTool respondsTo: #object)
					and: [ aTool object == anObject ] ] ]
		ifNone: [ nil ]
]

{ #category : 'private - tree pager' }
CFMaPhlowNavigation class >> immediateSpawnedLinkFrom: aPaneModel showing: anObject [
	^ aPaneModel spawnedFollowingLinks
		detect: [ :aLink |
			| aTool |
			aTool := aLink paneModel phlowTool.
			(aTool respondsTo: #object)
				and: [ aTool object == anObject ] ]
		ifNone: [ nil ]
]

{ #category : 'private - tree pager' }
CFMaPhlowNavigation class >> activateAndFocus: aLink from: aPaneElement [
	| aChildPaneModel |
	aChildPaneModel := aLink paneModel.

	"An existing immediate child is navigation identity, not a request to
	spawn another inspector. Expand it if needed, then make it the active
	child branch."
	aLink
		expand;
		activate.

	"Tree Pager updates its pane elements asynchronously after link-state
	changes. Enqueue after activation so GT performs its own model->UI update
	before we reveal/focus the existing child."
	BlTaskAction
		enqueueElement: aPaneElement
		action: [
			| aNavigationContext aPagerElement |
			aNavigationContext := aPaneElement navigationContext.
			aNavigationContext ifNotNil: [
				aPagerElement := aNavigationContext pagerElement.
				aPagerElement
					usedOrCachedChildNodeForPaneModel: aChildPaneModel
					ifFound: [ :aChildPaneElement |
						aChildPaneElement
							fireEvent: (GtTreePagerScrollToColumnWish new
								column: aChildPaneModel depthIndex).
						aChildPaneElement focusTarget requestFocus ]
					ifNone: [ ] ] ]
]

{ #category : 'private - tree pager' }
CFMaPhlowNavigation class >> treePagerPaneContaining: anElement ifFound: aFoundBlock ifNone: aNoneBlock [
	^ anElement
		allParentsDetect: [ :eachParent |
			eachParent isKindOf: GtTreePagerPaneElement ]
		ifFound: aFoundBlock
		ifNone: aNoneBlock
]
