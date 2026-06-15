Class {
	#name : 'CFMaFormStencilBuilder',
	#superclass : 'GtMagritteFormStencilBuilder',
	#category : 'BVC-Foundation-Magritte-GT',
	#package : 'BVC-Foundation-Magritte-GT'
}

{ #category : 'api - instantiation' }
CFMaFormStencilBuilder >> buildDefault [
	| aFormElement aHeaderElement aBodyElement aBodyViewportElement aBodyScrollableElement aTopShadowElement aBottomShadowElement aFooterElement |
	aFormElement := CFMaFormElement new.
	aHeaderElement := CFMaFormHeaderElement new
		memento: memento;
		yourself.
	aBodyElement := CFMaFormBodyElement new.
	aBodyScrollableElement := self newBodyScrollableElementFor: aBodyElement.
	aTopShadowElement := self newTopBodyScrollShadowElement.
	aBottomShadowElement := self newBottomBodyScrollShadowElement.
	aBodyViewportElement := self
		newBodyViewportElementWithScrollable: aBodyScrollableElement
		topShadow: aTopShadowElement
		bottomShadow: aBottomShadowElement.
	self
		installScrollShadowUpdatesFor: aBodyScrollableElement
		content: aBodyElement
		topShadow: aTopShadowElement
		bottomShadow: aBottomShadowElement.
	aFooterElement := CFMaFormFooterElement new.

	aFormElement
		addChild: aHeaderElement as: #header;
		addChild: aBodyViewportElement as: #body;
		addChild: aFooterElement as: #footer.

	aFormElement
		addChild: ((CFMaFormLayoutDebugOverlayElement forTarget: aFormElement)
			zIndex: 1000;
			yourself)
		as: #layoutDebugOverlay.

	^ aFormElement
]


{ #category : 'private - scrolling' }
CFMaFormStencilBuilder >> bottomBodyScrollShadowBackground [
	^ BlLinearGradientPaint vertical
		stops: {
			0 -> Color transparent.
			1 -> (Color black alpha: 0.12) }
]

{ #category : 'private - scrolling' }
CFMaFormStencilBuilder >> installScrollShadowUpdatesFor: aScrollableElement content: aContentElement topShadow: aTopShadowElement bottomShadow: aBottomShadowElement [
	| anUpdateBlock |
	anUpdateBlock := [
		self
			updateScrollShadowsFor: aScrollableElement
			topShadow: aTopShadowElement
			bottomShadow: aBottomShadowElement ].
	aScrollableElement
		when: BlElementScrolledEvent
		do: [ :anEvent | anUpdateBlock value ];
		when: BlElementExtentChangedEvent
		do: [ :anEvent | anUpdateBlock value ].
	aContentElement
		when: BlElementExtentChangedEvent
		do: [ :anEvent | anUpdateBlock value ].
	anUpdateBlock value
]

{ #category : 'private - scrolling' }
CFMaFormStencilBuilder >> newBodyScrollableElementFor: aBodyElement [
	^ BlScrollableElement new
		addChild: aBodyElement;
		constraintsDo: [ :c |
			c horizontal matchParent.
			c vertical matchParent.
			c frame horizontal weight: 1.
			c frame vertical weight: 1 ];
		yourself
]

{ #category : 'private - scrolling' }
CFMaFormStencilBuilder >> newBodyScrollShadowElement [
	^ BlElement new
		preventMouseEvents;
		opacity: 0;
		constraintsDo: [ :c |
			c ignoreByLayout.
			c horizontal matchParent.
			c vertical exact: self scrollShadowHeight ];
		yourself
]

{ #category : 'private - scrolling' }
CFMaFormStencilBuilder >> newBodyViewportElementWithScrollable: aScrollableElement topShadow: aTopShadowElement bottomShadow: aBottomShadowElement [
	^ BrFrame new
		hMatchParent;
		vMatchParent;
		constraintsDo: [ :c |
			c linear weight: 1.
			c frame horizontal weight: 1.
			c frame vertical weight: 1 ];
		addChild: aScrollableElement as: #bodyScroller;
		addChild: aTopShadowElement as: #topScrollShadow;
		addChild: aBottomShadowElement as: #bottomScrollShadow;
		yourself
]

{ #category : 'private - scrolling' }
CFMaFormStencilBuilder >> newBottomBodyScrollShadowElement [
	^ self newBodyScrollShadowElement
		background: self bottomBodyScrollShadowBackground;
		constraintsDo: [ :c |
			c frame vertical alignBottom ];
		yourself
]

{ #category : 'private - scrolling' }
CFMaFormStencilBuilder >> newTopBodyScrollShadowElement [
	^ self newBodyScrollShadowElement
		background: self topBodyScrollShadowBackground;
		constraintsDo: [ :c |
			c frame vertical alignTop ];
		yourself
]

{ #category : 'private - scrolling' }
CFMaFormStencilBuilder >> scrollShadowHeight [
	^ 10
]

{ #category : 'private - scrolling' }
CFMaFormStencilBuilder >> topBodyScrollShadowBackground [
	^ BlLinearGradientPaint vertical
		stops: {
			0 -> (Color black alpha: 0.12).
			1 -> Color transparent }
]

{ #category : 'private - scrolling' }
CFMaFormStencilBuilder >> updateScrollShadowsFor: aScrollableElement topShadow: aTopShadowElement bottomShadow: aBottomShadowElement [
	| anOffset anExtent aRange |
	anOffset := aScrollableElement computeVerticalScrollOffset.
	anExtent := aScrollableElement computeVerticalScrollExtent.
	aRange := aScrollableElement computeVerticalScrollRange.
	aTopShadowElement opacity: (anOffset > 0 ifTrue: [ 1 ] ifFalse: [ 0 ]).
	aBottomShadowElement opacity: ((anOffset + anExtent) < (aRange - 1) ifTrue: [ 1 ] ifFalse: [ 0 ])
]
