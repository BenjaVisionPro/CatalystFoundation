Class {
	#name : 'CFConfigurationPlanner',
	#superclass : 'Object',
	#instVars : [
		'graphCopier',
		'validator'
	],
	#category : 'BVC-Foundation-Config-Planner',
	#package : 'BVC-Foundation-Config-Planner'
}

{ #category : 'planning' }
CFConfigurationPlanner >> assessAsset: anAsset in: aConfiguration [
	^ self assessConfiguration: anAsset materialize in: aConfiguration
]

{ #category : 'planning' }
CFConfigurationPlanner >> assessConfiguration: anAssetConfiguration in: aConfiguration [
	| assessment originalValidationResult |
	assessment := CFConfigurationPlanningAssessment new.
	originalValidationResult := self validator validate: aConfiguration.
	(self placementsFor: anAssetConfiguration in: aConfiguration) do: [ :each |
		self
			assessPlacement: each
			with: anAssetConfiguration
			in: aConfiguration
			originalValidationResult: originalValidationResult
			on: assessment ].
	^ assessment
]

{ #category : 'private - planning' }
CFConfigurationPlanner >> assessPlacement: aPlacement with: anAssetConfiguration in: aConfiguration originalValidationResult: originalValidationResult on: anAssessment [
	| candidate candidateMemento candidateAsset candidateValidationResult candidatePlacement |
	candidate := self graphCopier copy: aConfiguration.
	candidateMemento := MAStraightMemento model: (self graphCopier copyOf: aPlacement memento model).
	candidateAsset := self graphCopier copyDetached: anAssetConfiguration.
	candidatePlacement := CFConfigurationPlacement
		memento: candidateMemento
		description: aPlacement description
		operationKind: aPlacement operationKind.
	candidatePlacement insertionIndex: aPlacement insertionIndex.
	candidatePlacement apply: candidateAsset.
	candidateValidationResult := self validator validate: candidate.
	(self introducesErrorsIn: candidateValidationResult comparedTo: originalValidationResult)
		ifTrue: [
			anAssessment addDiagnostic: candidateValidationResult.
			^ self ].
	anAssessment addTargetChoice: (CFConfigurationTargetChoice
		placement: aPlacement
		validationResult: candidateValidationResult)
]

{ #category : 'accessing' }
CFConfigurationPlanner >> graphCopier [
	^ graphCopier ifNil: [ graphCopier := CFConfigurationGraphCopier new ]
]

{ #category : 'private - planning' }
CFConfigurationPlanner >> introducesErrorsIn: aCandidateResult comparedTo: anOriginalResult [
	^ aCandidateResult errors anySatisfy: [ :each |
		(self occurrencesOfIssue: each in: aCandidateResult errors)
			> (self occurrencesOfIssue: each in: anOriginalResult errors) ]
]

{ #category : 'private - planning' }
CFConfigurationPlanner >> issue: anIssue isEquivalentTo: anotherIssue [
	^ anIssue code = anotherIssue code
		and: [ anIssue message = anotherIssue message
		and: [ anIssue path = anotherIssue path ] ]
]

{ #category : 'private - planning' }
CFConfigurationPlanner >> placementsFor: anAssetConfiguration in: aConfiguration [
	| placements visitedConfigurations |
	placements := OrderedCollection new.
	visitedConfigurations := IdentitySet new.
	self
		placementsFor: anAssetConfiguration
		inMemento: (MAStraightMemento model: aConfiguration)
		visited: visitedConfigurations
		into: placements.
	^ placements
]

{ #category : 'private - planning' }
CFConfigurationPlanner >> placementsFor: anAssetConfiguration inMemento: aMemento visited: visitedConfigurations into: placements [
	| model |
	model := aMemento model.
	(visitedConfigurations includes: model) ifTrue: [ ^ self ].
	visitedConfigurations add: model.
	aMemento magritteDescription do: [ :each |
		(each isKindOf: MARelationDescription) ifTrue: [
			(each classes anySatisfy: [ :aClass | anAssetConfiguration isKindOf: aClass ]) ifTrue: [
				placements add: (CFConfigurationPlacement
					memento: aMemento
					description: each
					operationKind: (each isMultiple ifTrue: [ #add ] ifFalse: [ #replace ])) ].
			self
				placementsForConfigurationsIn: (aMemento readUsing: each)
				asset: anAssetConfiguration
				visited: visitedConfigurations
				into: placements ] ]
]

{ #category : 'private - planning' }
CFConfigurationPlanner >> placementsForConfigurationsIn: aValue asset: anAssetConfiguration visited: visitedConfigurations into: placements [
	aValue ifNil: [ ^ self ].
	(aValue isCollection and: [ aValue isString not ])
		ifTrue: [
			aValue do: [ :each |
				self
					placementsForConfigurationsIn: each
					asset: anAssetConfiguration
					visited: visitedConfigurations
					into: placements ].
			^ self ].
	(aValue isKindOf: CFConfiguration) ifTrue: [
		self
			placementsFor: anAssetConfiguration
			inMemento: (MAStraightMemento model: aValue)
			visited: visitedConfigurations
			into: placements ]
]

{ #category : 'planning' }
CFConfigurationPlanner >> targetChoiceForPlacement: aPlacement in: anAssessment [
	^ anAssessment targetChoices
		detect: [ :each | each placement matches: aPlacement ]
		ifNone: [ nil ]
]

{ #category : 'private - planning' }
CFConfigurationPlanner >> occurrencesOfIssue: anIssue in: aCollection [
	^ (aCollection select: [ :each |
		self issue: each isEquivalentTo: anIssue ]) size
]

{ #category : 'accessing' }
CFConfigurationPlanner >> validator [
	^ validator ifNil: [ validator := CFConfigurationValidator new ]
]
