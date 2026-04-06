Extension { #name : 'CFMagritteEditorExample' }

{ #category : '*bvc-foundation-phlow' }
CFMagritteEditorExample >> operationsTool [
	<cfInspectorTool>
	^ CFOperationsTool forSubject: self
]
