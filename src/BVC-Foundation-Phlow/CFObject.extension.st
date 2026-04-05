Extension { #name : 'CFObject' }

{ #category : '*bvc-foundation-phlow' }
CFObject >> cfOperationsTool [
	self hasCFOperationsTool ifFalse: [ ^ nil ].
	^ self cfOperationsToolClass forSubject: self
]

{ #category : '*bvc-foundation-phlow' }
CFObject >> cfOperationsToolClass [
	^ CFOperationsTool
]

{ #category : '*bvc-foundation-phlow' }
CFObject >> cfOperationsViewModelClass [
	^ nil
]

{ #category : '*bvc-foundation-phlow' }
CFObject >> gtDefaultInspectorTool [
	self hasCFOperationsTool ifFalse: [ ^ super gtDefaultInspectorTool ].
	^ GtPhlowCompositeTool new
		addTool: self cfOperationsTool;
		addTool: super gtDefaultInspectorTool;
		yourself
]

{ #category : '*bvc-foundation-phlow' }
CFObject >> hasCFOperationsTool [
	^ self cfOperationsViewModelClass notNil
]
