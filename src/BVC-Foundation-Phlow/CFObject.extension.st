Extension { #name : 'CFObject' }

{ #category : '*bvc-foundation-phlow' }
CFObject >> cfInspectorToolSelectors [
	^ ((self class methods
		select: [ :aMethod |
			aMethod pragmas anySatisfy: [ :aPragma | aPragma keyword = #cfInspectorTool ] ])
		collect: [ :aMethod | aMethod selector ]) asSortedCollection
]

{ #category : '*bvc-foundation-phlow' }
CFObject >> gtDefaultInspectorTool [
	| inspectorTools compositeTool |
	inspectorTools := self gtInspectorTools.
	inspectorTools ifEmpty: [ ^ super gtDefaultInspectorTool ].
	compositeTool := GtPhlowCompositeTool new.
	inspectorTools do: [ :aTool | compositeTool addTool: aTool ].
	compositeTool addTool: super gtDefaultInspectorTool.
	^ compositeTool
]

{ #category : '*bvc-foundation-phlow' }
CFObject >> gtInspectorTools [
	^ (self cfInspectorToolSelectors
		collect: [ :aSelector | self perform: aSelector ])
		reject: [ :aTool | aTool isNil ]
]
