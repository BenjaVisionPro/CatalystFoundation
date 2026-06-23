Class {
	#name : 'CFBrRubberBandScrollPaneAptitude',
	#superclass : 'BrAptitude',
	#instVars : [
		'scrollable'
	],
	#category : 'BVC-Foundation-Magritte-GT',
	#package : 'BVC-Foundation-Magritte-GT'
}

{ #category : #initialization }
CFBrRubberBandScrollPaneAptitude >> initialize [
	super initialize.

	scrollable := CFBlRubberBandScrollableElement new.
	scrollable vertical.
	self add: (BrLayoutResizerAptitude new inherit: scrollable).

	self addChangeAddChildAs: #(content scrollable) with: [ scrollable ].

	self
		addChangeProperty: #(widgetContent layout)
		with: [ BlLinearLayout vertical ]
]

{ #category : #initialization }
CFBrRubberBandScrollPaneAptitude >> initializeListeners [
	super initializeListeners.
	
	self when: BrScrollableContentChanged do: [ :anEvent | self onContentChanged: anEvent contentStencil ].
	self when: BrScrollByWish do: [ :anEvent | self onScrollBy: anEvent ].
	self when: BrScrollToItemWish do: [ :anEvent | self onScrollToChild: anEvent ]
]

{ #category : #initialization }
CFBrRubberBandScrollPaneAptitude >> initializeRequests [
	super initializeRequests.
	
	self request: BrScrollableContentRequest new
]

{ #category : #'private - hooks' }
CFBrRubberBandScrollPaneAptitude >> onContentChanged: aContentStencil [
	| aContentElement |
	
	aContentElement := aContentStencil asElement.
	aContentElement removeFromParent.
	
	scrollable scrolledElementDo: [ :aPreviousContent | aPreviousContent removeFromParent ].
	scrollable addChildFirst: aContentElement
]

{ #category : #'private - hooks' }
CFBrRubberBandScrollPaneAptitude >> onScrollBy: aScrollByWish [
	aScrollByWish smooth
		ifTrue: [ scrollable smoothScrollBy: aScrollByWish delta ]
		ifFalse: [ scrollable scrollBy: aScrollByWish delta ]
]

{ #category : #'private - hooks' }
CFBrRubberBandScrollPaneAptitude >> onScrollToChild: aScrollToItemWish [
	
]

{ #category : #accessing }
CFBrRubberBandScrollPaneAptitude >> scrollable [
	^ scrollable
]
