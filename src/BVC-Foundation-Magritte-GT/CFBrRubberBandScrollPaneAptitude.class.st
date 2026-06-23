Class {
	#name : 'CFBrRubberBandScrollPaneAptitude',
	#superclass : 'BrScrollPaneAptitude',
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

{ #category : #accessing }
CFBrRubberBandScrollPaneAptitude >> scrollable [
	^ scrollable
]
