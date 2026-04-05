Extension { #name : 'CFObject' }

{ #category : '*bvc-foundation-phlow' }
CFObject >> cfPhlowTool [
	self hasCFPhlowTool ifFalse: [ ^ nil ].
	^ self cfPhlowToolClass forSubject: self
]

{ #category : '*bvc-foundation-phlow' }
CFObject >> cfPhlowToolClass [
	^ CFPhlowTool
]

{ #category : '*bvc-foundation-phlow' }
CFObject >> cfPhlowViewModelClass [
	^ nil
]

{ #category : '*bvc-foundation-phlow' }
CFObject >> gtDefaultInspectorTool [
	self hasCFPhlowTool ifFalse: [ ^ super gtDefaultInspectorTool ].
	^ GtPhlowCompositeTool new
		addTool: self cfPhlowTool;
		addTool: super gtDefaultInspectorTool;
		yourself
]

{ #category : '*bvc-foundation-phlow' }
CFObject >> hasCFPhlowTool [
	^ self cfPhlowViewModelClass notNil
]

{ #category : '*bvc-foundation-phlow' }
CFObject >> cfOperationsTool [
	^ self cfPhlowTool
]

{ #category : '*bvc-foundation-phlow' }
CFObject >> cfOperationsToolClass [
	^ CFOperationsTool
]

{ #category : '*bvc-foundation-phlow' }
CFObject >> cfOperationsViewModelClass [
	^ self cfPhlowViewModelClass
]


{ #category : '*bvc-foundation-phlow' }
CFObject >> hasCFOperationsTool [
	^ self cfPhlowToolClass = self cfOperationsToolClass
		and: [ self cfOperationsViewModelClass notNil ]
]
