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
	| aSection aLabel aField |
	aLabel := BrLabel new text: 'Field'.
	aField := BrLabel new text: 'Value'.

	aSection := CFMaGroupSectionElement new
		labelLayout: CFMaInlineLabelLayout new;
		groupName: 'Example group';
		collapsible: true;
		configure;
		yourself.

	aSection addLabel: aLabel field: aField.

	self assert: aSection isExpanded.
	self assert: aSection children isNotEmpty.

	aSection collapse.
	self assert: aSection isCollapsed.

	aSection expand.
	self assert: aSection isExpanded.

	^ aSection
]

{ #category : 'examples' }
CFMaGroupSectionExamples >> groupSectionCanToggle [
	<gtExample>
	| aSection |
	aSection := self collapsibleGroupSection.

	aSection toggleExpanded.
	self assert: aSection isCollapsed.

	aSection toggleExpanded.
	self assert: aSection isExpanded.

	^ aSection
]
