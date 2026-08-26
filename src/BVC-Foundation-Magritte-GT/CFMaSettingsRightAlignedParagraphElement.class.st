Class {
	#name : 'CFMaSettingsRightAlignedParagraphElement',
	#superclass : 'BrTextEditorParagraphElement',
	#category : 'BVC-Foundation-Magritte-GT-Elements',
	#package : 'BVC-Foundation-Magritte-GT',
	#tag : 'Elements'
}


{ #category : 'defaults' }
CFMaSettingsRightAlignedParagraphElement >> defaultSelectionColor [
	^ CFMaDetailColours textSelection
]

{ #category : 'private - alignment' }
CFMaSettingsRightAlignedParagraphElement >> alignedRectangle: aRectangle paragraph: aParagraph [
	^ aRectangle translateBy:
		((self alignmentOffsetForY: aRectangle center y paragraph: aParagraph) @ 0)
]

{ #category : 'private - alignment' }
CFMaSettingsRightAlignedParagraphElement >> alignmentOffsetForLine: aLineIndex paragraph: aParagraph [
	| aContentWidth |
	aContentWidth := (self measuredWidth - self padding width) max: 0.
	^ (aContentWidth - (aParagraph lineWidthAt: aLineIndex)) max: 0
]

{ #category : 'private - alignment' }
CFMaSettingsRightAlignedParagraphElement >> alignmentOffsetForY: aY paragraph: aParagraph [
	^ self
		alignmentOffsetForLine: (self lineIndexForY: aY paragraph: aParagraph)
		paragraph: aParagraph
]

{ #category : 'api - cursor' }
CFMaSettingsRightAlignedParagraphElement >> cursorRectangleForCharacter: anOffset [
	^ paragraph
		valueDo: [ :aParagraph |
			self
				alignedRectangle: (aParagraph cursorRectangleForCharacter: anOffset)
				paragraph: aParagraph ]
]

{ #category : 'drawing' }
CFMaSettingsRightAlignedParagraphElement >> drawChildrenOnSpartaCanvas: aCanvas [
	aCanvas clip
		when: [ self clipChildren ]
		by: [ self geometry pathOnSpartaCanvas: aCanvas of: self ]
		during: [
			paragraph
				valueDo: [ :aParagraph |
					self
						paintParagraph: aParagraph
						on: aCanvas
						at: self padding topLeft ]
				ifNone: [ self requestLayout ].

			self drawSelectionOnSpartaCanvas: aCanvas.

			self children sortedByElevation do: [ :anElement |
				(self canAddTextToParagraph: anElement)
					ifFalse: [ anElement fullDrawOnSpartaCanvas: aCanvas ] ] ]
]

{ #category : 'drawing' }
CFMaSettingsRightAlignedParagraphElement >> drawSelectionOnSpartaCanvas: aCanvas [
	| aPathBuilder |
	aPathBuilder := aCanvas path.

	paragraph valueDo: [ :aParagraph |
		selection do: [ :eachMonotoneSelection |
			(aParagraph
				rectanglesForChars: (eachMonotoneSelection from to: eachMonotoneSelection to)
				width: SkiaParagraphRectWidthStyle Max
				height: SkiaParagraphRectHeightStyle Max)
				do: [ :eachRectangle |
					| anAlignedRectangle |
					anAlignedRectangle := self
						alignedRectangle: eachRectangle
						paragraph: aParagraph.
					aPathBuilder
						moveTo: anAlignedRectangle topLeft;
						lineTo: anAlignedRectangle topRight;
						lineTo: anAlignedRectangle bottomRight;
						lineTo: anAlignedRectangle bottomLeft;
						lineTo: anAlignedRectangle topLeft;
						close ] ] ].

	aCanvas fill
		path: aPathBuilder build;
		paint: self defaultSelectionColor;
		draw
]

{ #category : 'accessing' }
CFMaSettingsRightAlignedParagraphElement >> handleMouseEvent: anEvent paragraph: aParagraph [
	| theAttributes aCharOffsetInParagraph anEditorElement aPoint |
	anEditorElement := self
		allParentsDetect: [ :anElement | anElement isKindOf: BrEditorElement ]
		ifFound: #yourself
		ifNone: [ ^ self ].

	aPoint := self
		pointInParagraphFromAlignedPoint: anEvent localPosition - self padding topLeft
		paragraph: aParagraph.
	aCharOffsetInParagraph := aParagraph charOffsetForPoint: aPoint.
	theAttributes := (self text attributesAt: aCharOffsetInParagraph)
		select: #isEventHandler.

	self
		createSyntheticLeaveEventsForEvent: anEvent
		attributes: theAttributes
		in: anEditorElement.

	^ theAttributes
		select: [ :anAttribute | anAttribute wantsEvent: anEvent ]
		thenDo: [ :anAttribute |
			anAttribute
				handleEvent: anEvent
				in: anEditorElement editor
				on: self segment ]
]

{ #category : 'private - alignment' }
CFMaSettingsRightAlignedParagraphElement >> lineIndexForY: aY paragraph: aParagraph [
	| aTop |
	aTop := 0.
	1 to: aParagraph lineCount do: [ :anIndex |
		| aHeight |
		aHeight := aParagraph lineHeightAt: anIndex.
		aY <= (aTop + aHeight) ifTrue: [ ^ anIndex ].
		aTop := aTop + aHeight ].
	^ aParagraph lineCount
]

{ #category : 'private - drawing' }
CFMaSettingsRightAlignedParagraphElement >> lineTopAt: aLineIndex paragraph: aParagraph [
	| aTop |
	aTop := 0.
	1 to: aLineIndex - 1 do: [ :anIndex |
		aTop := aTop + (aParagraph lineHeightAt: anIndex) ].
	^ aTop
]

{ #category : 'private - drawing' }
CFMaSettingsRightAlignedParagraphElement >> lineVerticalBoundsAt: aLineIndex paragraph: aParagraph [
	| aTop aBottom |
	aTop := self lineTopAt: aLineIndex paragraph: aParagraph.
	aBottom := aLineIndex = aParagraph lineCount
		ifTrue: [ aParagraph height ]
		ifFalse: [ self lineTopAt: aLineIndex + 1 paragraph: aParagraph ].

	^ BlBounds
		origin: 0 @ aTop
		extent: 0 @ ((aBottom - aTop) max: 0)
]

{ #category : 'layout' }
CFMaSettingsRightAlignedParagraphElement >> measureCursors: aCollectionOfCursorElements paragraph: aParagraph [
	aCollectionOfCursorElements do: [ :eachCursor |
		| aTextPosition eachCursorRectangle |
		aTextPosition := eachCursor textPosition.
		eachCursorRectangle := self
			alignedRectangle: (aParagraph cursorRectangleForCharacter: aTextPosition)
			paragraph: aParagraph.
		eachCursorRectangle := eachCursorRectangle expandBy: 0.5 @ 0.
		eachCursorRectangle := eachCursorRectangle
			translateBy: ((eachCursorRectangle left min: 0) abs @ 0).
		eachCursorRectangle := eachCursorRectangle
			translateBy: ((self measuredWidth - eachCursorRectangle right) min: 0) @ 0.

		eachCursor measuredBounds
			extent: eachCursorRectangle extent;
			position: eachCursorRectangle origin + self padding topLeft ]
]

{ #category : 'drawing' }
CFMaSettingsRightAlignedParagraphElement >> paintChildrenOn: aCompositorPainter offset: anOffset [
	paragraph
		valueDo: [ :aParagraph |
			self
				paintParagraph: aParagraph
				on: aCompositorPainter canvas
				at: anOffset + self padding topLeft ]
		ifNone: [ self requestLayout ].

	self
		paintSelectionOn: aCompositorPainter
		offset: anOffset + self padding topLeft.

	aCompositorPainter
		pushChildren: self children sortedByElevation
		offset: anOffset
		compositing: self compositingMode
		thenPaint: [ :aChildElement :aChildPainter :aChildOffset |
			(self canAddTextToParagraph: aChildElement)
				ifFalse: [ aChildElement fullPaintOn: aChildPainter offset: aChildOffset ] ]
]

{ #category : 'private - drawing' }
CFMaSettingsRightAlignedParagraphElement >> paintParagraph: aParagraph on: aCanvas at: anOrigin [
	| aContentWidth |
	aContentWidth := (self measuredWidth - self padding width) max: 0.

	1 to: aParagraph lineCount do: [ :anIndex |
		| aVerticalBounds anOffset aClipBounds aClipHeight |
		aVerticalBounds := self
			lineVerticalBoundsAt: anIndex
			paragraph: aParagraph.
		anOffset := self
			alignmentOffsetForLine: anIndex
			paragraph: aParagraph.
		aClipHeight := anIndex = aParagraph lineCount
			ifTrue: [ (aCanvas bounds bottom - (anOrigin y + aVerticalBounds origin y)) max: aVerticalBounds height ]
			ifFalse: [ aVerticalBounds height ].
		aClipBounds := BlBounds
			origin: anOrigin + (0 @ aVerticalBounds origin y)
			extent: aContentWidth @ aClipHeight.
		aCanvas clip
			by: aClipBounds
			during: [
				aParagraph
					paintOn: aCanvas
					at: anOrigin + (anOffset @ 0) ] ]
]

{ #category : 'private - alignment' }
CFMaSettingsRightAlignedParagraphElement >> pointInParagraphFromAlignedPoint: aPoint paragraph: aParagraph [
	| anOffset |
	anOffset := self alignmentOffsetForY: aPoint y paragraph: aParagraph.
	^ (aPoint x - anOffset) @ aPoint y
]

{ #category : 'api - cursor' }
CFMaSettingsRightAlignedParagraphElement >> screenToCursor: aTransformation of: anEditorElement at: aCursorInEditorPosition [
	| theBoundsInLocal aCharOffsetInParagraph |
	paragraph valueDo: [ :aParagraph |
		| aPoint |
		theBoundsInLocal := self
			globalBoundsToMine: (BlBounds origin: aCursorInEditorPosition extent: 0 @ 0)
			fromParent: anEditorElement.
		aPoint := self
			pointInParagraphFromAlignedPoint: theBoundsInLocal center - self padding topLeft
			paragraph: aParagraph.
		aCharOffsetInParagraph := aParagraph charOffsetForPoint: aPoint.
		aTransformation transformed:
			(self positionWithinSegmentOf: aCharOffsetInParagraph) + self segment textStart ]
]
