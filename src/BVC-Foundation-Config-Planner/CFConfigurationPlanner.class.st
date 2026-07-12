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
	| assessment assetConfiguration originalValidationResult |
	assessment := CFConfigurationPlanningAssessment new.
	assetConfiguration := anAsset materialize.
	originalValidationResult := self validator validate: aConfiguration.
	(self placementsFor: assetConfiguration in: aConfiguration) do: [ :each |
		self
			assessPlacement: each
			with: assetConfiguration
			in: aConfiguration
			originalValidationResult: originalValidationResult
			on: assessment ].
	^ assessment
]

{ #category : 'private - planning' }
CFConfigurationPlanner >> assessPlacement: aPlacement with: anAssetConfiguration in: aConfiguration originalValidationResult: originalValidationResult on: anAssessment [
	| candidate candidateOwner candidateAsset candidateValidationResult |
	candidate := self graphCopier copy: aConfiguration.
	candidateOwner := self graphCopier copyOf: aPlacement owner.
	candidateAsset := self graphCopier copyDetached: anAssetConfiguration.
	aPlacement apply: candidateAsset to: candidateOwner.
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
		inConfiguration: aConfiguration
		visited: visitedConfigurations
		into: placements.
	^ placements
]

{ #category : 'private - planning' }
CFConfigurationPlanner >> placementsFor: anAssetConfiguration inConfiguration: aConfiguration visited: visitedConfigurations into: placements [
	(visitedConfigurations includes: aConfiguration) ifTrue: [ ^ self ].
	visitedConfigurations add: aConfiguration.
	(aConfiguration magritteDescription
		select: [ :each |
			(each isKindOf: MARelationDescription) and: [ each cfConfigurationEmbedded ] ])
		do: [ :each |
			(each classes anySatisfy: [ :aClass | anAssetConfiguration isKindOf: aClass ]) ifTrue: [
				placements add: (CFConfigurationPlacement
					owner: aConfiguration
					description: each
					operationKind: (each isMultiple ifTrue: [ #add ] ifFalse: [ #replace ])) ].
			self
				placementsForConfigurationsIn: (aConfiguration readUsing: each)
				asset: anAssetConfiguration
				visited: visitedConfigurations
				into: placements ]
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
			inConfiguration: aValue
			visited: visitedConfigurations
			into: placements ]
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
