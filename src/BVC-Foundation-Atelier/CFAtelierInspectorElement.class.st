"I am Atelier's shared inspector browser surface.

I host a real GT Tree Pager and keep its presentation policy outside client presentations. A requested root page is prepared with the caller's existing Foundation memento before the pager changes. While a replacement prepares, the current pager remains authoritative and visible."
Class {
	#name : 'CFAtelierInspectorElement',
	#superclass : 'BrFrame',
	#instVars : [
		'pagerElement',
		'pendingTool'
	],
	#category : 'BVC-Foundation-Atelier-UI',
	#package : 'BVC-Foundation-Atelier',
	#tag : 'UI'
}

{ #category : 'initialization' }
CFAtelierInspectorElement >> initialize [
	super initialize.
	self
		background: Color transparent;
		opacity: 0.0;
		preventMeAndChildrenMouseEvents;
		hExact: 300;
		vMatchParent;
		clipChildren: false;
		constraintsDo: [ :c |
			c frame horizontal alignRight.
			c frame vertical alignTop ];
		addAptitude: CFGlassSurfaceAptitude new
]

{ #category : 'accessing' }
CFAtelierInspectorElement >> pagerElement [
	^ pagerElement
]

{ #category : 'inspecting' }
CFAtelierInspectorElement >> clearInspector [
	pendingTool := nil.
	pagerElement := nil.
	self
		removeChildren;
		opacity: 0.0;
		preventMeAndChildrenMouseEvents
]

{ #category : 'inspecting' }
CFAtelierInspectorElement >> inspectObject: anObject memento: aMemento [
	^ self
		inspectObject: anObject
		memento: aMemento
		presentationDo: nil
]

{ #category : 'inspecting' }
CFAtelierInspectorElement >> inspectObject: anObject memento: aMemento presentationDo: aPresentationBlock [
	| tool |
	tool := CFMaMementoTool object: anObject memento: aMemento.
	aPresentationBlock ifNotNil: [ tool presentationDo: aPresentationBlock ].
	pendingTool := tool.
	self enqueueTask: (BlTaskAction new action: [
		pendingTool == tool ifTrue: [
			tool prepareElementDo: [ :aPreparedTool |
				self installPreparedTool: aPreparedTool ] ] ]).
	^ tool
]

{ #category : 'private - inspecting' }
CFAtelierInspectorElement >> installPreparedTool: aTool [
	| previousPager incomingPager transaction |
	pendingTool == aTool ifFalse: [ ^ self ].
	pendingTool := nil.
	previousPager := pagerElement.
	incomingPager := GtTreePager createWrappedOn: aTool.
	incomingPager
		background: Color transparent;
		hMatchParent;
		vMatchParent.
	incomingPager pagerModel settings numberOfVisibleColumns: 1.
	incomingPager opacity: 0.0.
	self addChild: incomingPager.
	pagerElement := incomingPager.
	self
		opacity: 1.0;
		allowMeAndChildrenMouseEvents.

	(previousPager isNil or: [ self isAttachedToSceneGraph not ]) ifTrue: [
		previousPager ifNotNil: [ previousPager removeFromParent ].
		incomingPager opacity: 1.0.
		^ self ].

	transaction := CFMotionLayoutTransaction on: self.
	transaction
		affecting: { incomingPager };
		mutate: [ previousPager removeFromParent ];
		fadeIn: incomingPager;
		play
]
