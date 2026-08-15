"I provide executable examples for Foundation Magritte group sections."

Class {
	#name : 'CFMaGroupSectionExamples',
	#superclass : 'Object',
	#category : 'BVC-Foundation-Magritte-GT-Examples',
	#package : 'BVC-Foundation-Magritte-GT',
	#tag : 'Examples'
}

{ #category : 'examples' }
CFMaGroupSectionExamples >> collapsibleGroupSection [
	<gtExample>
	| aSection |
	aSection := CFMaGroupSectionElement new
		labelLayout: CFMaInlineLabelLayout new;
		groupName: 'Example group';
		collapsible: true;
		yourself.

	self assert: aSection isExpanded.
	aSection collapse.
	self assert: aSection isCollapsed.
	aSection expand.
	self assert: aSection isExpanded.

	^ aSection
]
