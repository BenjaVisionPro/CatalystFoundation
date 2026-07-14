Class {
	#name : 'CFConfigurationEditorElementExamples',
	#superclass : 'Object',
	#category : 'BVC-Foundation-Config-UI-ConfigurationEditor',
	#package : 'BVC-Foundation-Config-UI-ConfigurationEditor'
}

{ #category : 'examples - placement animation' }
CFConfigurationEditorElementExamples >> overlayPreviewIsNotAPlacementAnimationOrigin [
	<gtExample>
	| editor rootNode items committedNode overlayPreview affectedItems elements |
	editor := CFConfigurationEditorElement new.
	editor removeChildren.
	rootNode := CFConfigurationNodeElement new.
	items := BrVerticalPane new.
	committedNode := CFConfigurationNodeElement new.
	overlayPreview := CFConfigurationNodeElement new.
	editor addChild: rootNode.
	rootNode addChild: items.
	items addChild: committedNode.
	editor addChild: overlayPreview.
	affectedItems := IdentitySet new.
	affectedItems add: items.
	elements := editor
		perform: #placementAnimationElementsInItems:
		with: affectedItems.
	self assert: (elements includes: rootNode).
	self assert: (elements includes: committedNode).
	self deny: (elements includes: overlayPreview).
	self assert: elements size equals: 2.
	^ elements
]

{ #category : 'examples - placement animation' }
CFConfigurationEditorElementExamples >> placementAnimationCombinesAffectedRelationsWithoutDuplicates [
	<gtExample>
	| editor rootNode sourceItems destinationItems sourceNode destinationNode affectedItems elements |
	editor := CFConfigurationEditorElement new.
	editor removeChildren.
	rootNode := CFConfigurationNodeElement new.
	sourceItems := BrVerticalPane new.
	destinationItems := BrVerticalPane new.
	sourceNode := CFConfigurationNodeElement new.
	destinationNode := CFConfigurationNodeElement new.
	editor addChild: rootNode.
	rootNode
		addChild: sourceItems;
		addChild: destinationItems.
	sourceItems addChild: sourceNode.
	destinationItems addChild: destinationNode.
	affectedItems := IdentitySet new.
	affectedItems
		add: sourceItems;
		add: destinationItems.
	elements := editor
		perform: #placementAnimationElementsInItems:
		with: affectedItems.
	self assert: (elements includes: rootNode).
	self assert: (elements includes: sourceNode).
	self assert: (elements includes: destinationNode).
	self assert: (elements occurrencesOf: rootNode) equals: 1.
	self assert: elements size equals: 3.
	^ elements
]

{ #category : 'examples - placement animation' }
CFConfigurationEditorElementExamples >> placementAnimationDoesNotTraverseUnaffectedNestedRelations [
	<gtExample>
	| editor rootNode items directNode nestedItems nestedNode affectedItems elements |
	editor := CFConfigurationEditorElement new.
	editor removeChildren.
	rootNode := CFConfigurationNodeElement new.
	items := BrVerticalPane new.
	directNode := CFConfigurationNodeElement new.
	nestedItems := BrVerticalPane new.
	nestedNode := CFConfigurationNodeElement new.
	editor addChild: rootNode.
	rootNode addChild: items.
	items addChild: directNode.
	directNode addChild: nestedItems.
	nestedItems addChild: nestedNode.
	affectedItems := IdentitySet new.
	affectedItems add: items.
	elements := editor
		perform: #placementAnimationElementsInItems:
		with: affectedItems.
	self assert: (elements includes: rootNode).
	self assert: (elements includes: directNode).
	self deny: (elements includes: nestedNode).
	self assert: elements size equals: 2.
	^ elements
]
