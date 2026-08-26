"
I adapt Foundation navigation intent onto ordinary Phlow and, when present,
the existing GT Tree Pager.

I deliberately know the Tree Pager API so relation renderers do not have to.
Navigation is scoped to the current pane's immediate following links. Normal selection/navigation preserves the pager's active branch. Alternate-click navigation deliberately creates and activates a new sibling branch.
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
			anExistingLink ifNil: [
				anExistingLink := self
					immediateLinkFrom: aPaneElement paneModel
					showing: anObject ].
			anExistingLink
				ifNotNil: [
					anExistingLink isSpawned ifTrue: [
						^ self
							expandAndFocus: anExistingLink
							from: aPaneElement ].
					^ self ]
				ifNil: [
					^ self
						selectPreservingActiveBranchFrom: anElement
						pane: aPaneElement
						object: anObject ] ]
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
		treePagerPaneContaining: anElement
		ifFound: [ :aPaneElement |
			| anExistingLink |
			self ensureTreePagerPolicyIn: aPaneElement navigationContext pagerElement.
			anExistingLink := self
				immediateSpawnedLinkFrom: aPaneElement paneModel
				showing: anObject.
			anExistingLink ifNil: [
				anExistingLink := self
					immediateLinkFrom: aPaneElement paneModel
					showing: anObject ].
			anExistingLink
				ifNotNil: [
					^ self
						expandAndFocus: anExistingLink
						from: aPaneElement ]
				ifNil: [
					^ self
						spawnPreservingActiveBranchFrom: anElement
						pane: aPaneElement
						object: anObject ] ]
		ifNone: [
			^ anElement phlow spawnObject: anObject ]
]

{ #category : 'api - navigating' }
CFMaPhlowNavigation class >> navigateNewBranchFrom: anElement to: anObject [
	self
		treePagerPaneContaining: anElement
		ifFound: [ :aPaneElement |
			self ensureTreePagerPolicyIn: aPaneElement navigationContext pagerElement.

			"GT spawnPane: replaces the active following link. Inactivate it first
			so Alt-navigation creates a sibling branch and makes that new branch active."
			aPaneElement paneModel inactivateLink.
			^ anElement phlow spawnObject: anObject ]
		ifNone: [
			^ anElement phlow spawnObject: anObject ]
]

{ #category : 'private - navigating' }
CFMaPhlowNavigation class >> selectPreservingActiveBranchFrom: anElement pane: aPaneElement object: anObject [
	| anActiveLink |
	anActiveLink := aPaneElement paneModel activeLink.

	"GT selectPane: replaces an active following link. Temporarily remove
	activation so the hidden selection is added alongside the current branch."
	aPaneElement paneModel inactivateLink.
	anElement phlow selectObject: anObject.

	"Selection must not choose a branch. Restore exactly the activation state
	that existed before the selection."
	anActiveLink
		ifNotNil: [ anActiveLink activate ]
		ifNil: [ aPaneElement paneModel inactivateLink ]
]

{ #category : 'private - navigating' }
CFMaPhlowNavigation class >> spawnPreservingActiveBranchFrom: anElement pane: aPaneElement object: anObject [
	| anActiveLink |
	anActiveLink := aPaneElement paneModel activeLink.

	"GT spawnPane: replaces an active following link. Temporarily remove
	activation so the new inspector is added as a sibling instead."
	aPaneElement paneModel inactivateLink.
	anElement phlow spawnObject: anObject.

	"Normal navigation must not choose a branch. Restore exactly the activation
	state that existed before the spawn."
	anActiveLink
		ifNotNil: [ anActiveLink activate ]
		ifNil: [ aPaneElement paneModel inactivateLink ]
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
CFMaPhlowNavigation class >> expandAndFocus: aLink from: aPaneElement [
	| aChildPaneModel |
	aChildPaneModel := aLink paneModel.

	"An existing immediate child is navigation identity, not a request to
	spawn another inspector. Expand it if needed without changing which
	following link is active."
	aLink expand.

	"Tree Pager updates its pane elements asynchronously after link-state
	changes. Enqueue after expansion so GT performs its own model->UI update
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
