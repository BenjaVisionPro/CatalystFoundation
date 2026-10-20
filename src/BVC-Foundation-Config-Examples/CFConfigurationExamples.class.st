Class {
	#name : 'CFConfigurationExamples',
	#superclass : 'Object',
	#category : 'BVC-Foundation-Config-Examples',
	#package : 'BVC-Foundation-Config-Examples'
}

{ #category : 'configurations' }
CFConfigurationExamples class >> developmentConfiguration [
	<cfConfiguration>
	<return: #CFMyConfigExample>
	^ CFMyConfigExample new
		label: 'Development endpoint';
		endpoint: 'http://localhost:8080';
		yourself
]

{ #category : 'configurations' }
CFConfigurationExamples class >> developmentConfigurationWithoutTypeHint [
	<cfConfiguration>
	^ CFMyConfigExample new
		label: 'Development endpoint without type hint';
		endpoint: 'http://localhost:8081';
		yourself
]

{ #category : 'configurations' }
CFConfigurationExamples class >> emptyConfigurationGroup [
	<cfConfiguration>
	<return: #CFMyConfigurationGroupExample>
	^ CFMyConfigurationGroupExample new
		label: 'Empty configuration group';
		yourself
]

{ #category : 'configurations' }
CFConfigurationExamples class >> emptyConfigurationHolder [
	^ CFMyConfigurationHolderExample new
		label: 'Empty configuration holder';
		yourself
]

{ #category : 'configurations' }
CFConfigurationExamples class >> invalidConfiguration [
	^ CFMyConfigExample new
		label: 'Missing endpoint';
		yourself
]

{ #category : 'examples - Atelier preview' }
CFConfigurationExamples >> atelierLibraryPreviewCancelsPendingMotionOnRemoval [
	<gtExample>
	| preview item transaction memento childMementos stagedItems |
	preview := self atelierLibraryPreviewUsesStagedRootAndMotion.
	memento := preview editingContext.
	childMementos := memento allChildMementos copy.
	stagedItems := memento readUsing: memento model descriptionConfigurations.
	item := preview palette items detect: [ :each | each materialize selector = #developmentConfiguration ].
	preview previewItem: item.
	transaction := preview motionTransaction.
	self assert: transaction isAwaitingLayout.
	preview removeFromParent.
	self assert: transaction isCancelled.
	self assert: preview motionTransaction isNil.
	self assert: preview assessment isNil.
	self assert: preview editingContext == memento.
	self assert: (memento readUsing: memento model descriptionConfigurations) == stagedItems.
	self assert: memento allChildMementos equals: childMementos.
	^ preview
]

{ #category : 'examples - Atelier preview' }
CFConfigurationExamples >> atelierLibraryPreviewReassessesAndRejectsInvalidCandidate [
	<gtExample>
	| preview validItem invalidItem asset firstProjection memento childMemento child |
	preview := self atelierLibraryPreviewUsesStagedRootAndMotion.
	memento := preview editingContext.
	childMemento := memento allChildMementos first.
	child := childMemento model.
	asset := CFConfigurationLibrary discovered assets detect: [ :each | each selector = #developmentConfiguration ].
	validItem := CFAtelierPaletteItem label: asset label provider: (CFAtelierExistingObjectProvider object: asset).
	preview previewItem: validItem.
	firstProjection := preview projectedConfiguration.
	childMemento write: 'https://changed-after-preview.example' using: child descriptionEndpoint.
	preview previewItem: validItem.
	self assert: preview projectedConfiguration ~~ firstProjection.
	self assert: preview projectedConfiguration configurations first endpoint equals: 'https://changed-after-preview.example'.
	self assert: firstProjection configurations first endpoint equals: 'https://staged.example'.
	asset := CFConfigurationMethodAsset new
		sourceClass: self class;
		selector: #invalidConfiguration;
		configurationClass: CFMyConfigExample;
		yourself.
	invalidItem := CFAtelierPaletteItem label: 'Invalid' provider: (CFAtelierExistingObjectProvider object: asset).
	preview previewItem: invalidItem.
	self assert: preview assessment targetChoices isEmpty.
	self assert: preview assessment diagnostics isEmpty not.
	self assert: preview motionTransaction isNil.
	self assert: preview editingContext == memento.
	self assert: memento allChildMementos first == childMemento.
	self assert: child endpoint equals: 'http://localhost:8080'.
	preview cancelPreview.
	self assert: (childMemento readUsing: child descriptionEndpoint) equals: 'https://changed-after-preview.example'.
	^ preview
]

{ #category : 'examples - Atelier preview' }
CFConfigurationExamples >> atelierLibraryPreviewUsesStagedRootAndMotion [
	<gtExample>
	| configuration child atelier memento childMemento element preview space item transaction |
	configuration := self class emptyConfigurationGroup.
	child := self class developmentConfiguration.
	child parent: configuration.
	configuration configurations add: child.
	atelier := configuration asAtelier.
	memento := atelier mementoFuture wait.
	childMemento := memento childMementoFor: child inRelation: configuration descriptionConfigurations.
	childMemento write: 'https://staged.example' using: child descriptionEndpoint.
	element := atelier asElement.
	atelier initializeForm: element formElement forMemento: memento.
	preview := element children detect: [ :each | each isKindOf: CFConfigurationPlacementPreviewElement ].
	"Exercise the real configured palette in a space without attaching text editors
	to the example worker process. Interactive authoring uses the ordinary UI host."
	preview removeFromParent.
	space := BlSpace new.
	space root addChild: preview.
	space pulse.
	item := atelier palette items detect: [ :each | each materialize selector = #developmentConfiguration ].
	preview previewItem: item.
	transaction := preview motionTransaction.
	self assert: preview editingContext == memento.
	self assert: preview projectedConfiguration configurations first endpoint equals: 'https://staged.example'.
	self assert: preview assessment targetChoices isEmpty not.
	self assert: preview assessment targetChoices first placement memento model == preview projectedConfiguration.
	space pulse.
	self assert: transaction motion notNil.
	self assert: preview structureElement children size equals: 2.
	self assert: configuration configurations size equals: 1.
	self assert: configuration configurations first == child.
	self assert: child endpoint equals: 'http://localhost:8080'.
	self assert: memento allChildMementos first == childMemento.
	self assert: (childMemento readUsing: child descriptionEndpoint) equals: 'https://staged.example'.
	preview cancelPreview.
	self assert: preview assessment isNil.
	self assert: preview structureElement children isEmpty.
	self assert: preview motionTransaction isNil.
	self assert: memento allChildMementos first == childMemento.
	self assert: (childMemento readUsing: child descriptionEndpoint) equals: 'https://staged.example'.
	^ preview
]

{ #category : 'examples - Atelier preview' }
CFConfigurationExamples >> configurationAtelierLibraryPreview [
	<gtExample>
	"Open the returned Atelier in its Live view on the GT UI process.
	Hover a library row for assessed Motion feedback, leave to cancel.
	Click reassesses; no row starts a drag or offers Apply."
	^ self class emptyConfigurationGroup asAtelier asElement
]

{ #category : 'examples - atelier' }
CFConfigurationExamples >> configurationOpensAsAtelierWithDetail [
	<gtExample>
	| configuration atelier memento presentation form element |
	configuration := self class emptyConfigurationGroup.
	atelier := configuration asAtelier.
	self assert: atelier class equals: CFAtelierViewModel.
	memento := CFMaMemento model: configuration.
	atelier presentationDo: [ :aPresentation | presentation := aPresentation ].
	element := atelier asElement.
	form := element formElement.
	"Build synchronously with the known transaction to check Atelier's hooks,
	without relying on asynchronous UI scheduling in this example."
	atelier initializeForm: form forMemento: memento.
	self assert: form class equals: CFMaFormRootElement.
	self assert: presentation class equals: CFMaDetailPresentation.
	self assert: presentation memento == memento.
	self assert: presentation actionMemento == memento.
	self assert: element class equals: CFAtelierElement.
	^ element
]

{ #category : 'examples - simulation' }
CFConfigurationExamples >> editingProjectionExcludesRemovedNestedConfiguration [
	<gtExample>
	| configuration child rootMemento childMemento relationDescription projectedConfiguration |
	configuration := self class emptyConfigurationGroup.
	child := self class developmentConfiguration.
	child parent: configuration.
	configuration configurations add: child.
	relationDescription := configuration descriptionConfigurations.
	rootMemento := CFMaMemento model: configuration.
	childMemento := rootMemento childMementoFor: child inRelation: relationDescription.
	childMemento write: 'https://removed.example' using: child descriptionEndpoint.
	rootMemento write: OrderedCollection new using: relationDescription.
	projectedConfiguration := CFConfigurationGraphCopier new copyEditingContext: rootMemento.
	self assert: projectedConfiguration configurations isEmpty.
	self assert: configuration configurations first == child.
	self assert: child parent == configuration.
	self assert: rootMemento allChildMementos first == childMemento.
	self assert: (childMemento readUsing: child descriptionEndpoint) equals: 'https://removed.example'.
	rootMemento reset.
	self assert: (rootMemento readUsing: relationDescription) first == child.
	^ projectedConfiguration
]

{ #category : 'examples - simulation' }
CFConfigurationExamples >> editingProjectionIncludesNestedStagedValuesWithoutApplying [
	<gtExample>
	| configuration child rootMemento childMemento relationDescription endpointDescription projectedConfiguration projectedChild |
	configuration := self class emptyConfigurationGroup.
	child := self class developmentConfiguration.
	child parent: configuration.
	configuration configurations add: child.
	relationDescription := configuration descriptionConfigurations.
	endpointDescription := child descriptionEndpoint.
	rootMemento := CFMaMemento model: configuration.
	childMemento := rootMemento childMementoFor: child inRelation: relationDescription.
	childMemento write: 'https://preview.example' using: endpointDescription.
	projectedConfiguration := CFConfigurationGraphCopier new copyEditingContext: rootMemento.
	projectedChild := projectedConfiguration configurations first.
	self assert: projectedConfiguration ~~ configuration.
	self assert: projectedConfiguration configurations ~~ configuration configurations.
	self assert: projectedChild ~~ child.
	self assert: projectedChild parent == projectedConfiguration.
	self assert: projectedChild endpoint equals: 'https://preview.example'.
	self assert: child endpoint equals: 'http://localhost:8080'.
	self assert: child parent == configuration.
	self assert: (childMemento readUsing: endpointDescription) equals: 'https://preview.example'.
	self assert: rootMemento allChildMementos size equals: 1.
	self assert: childMemento allChildMementos isEmpty.
	rootMemento reset.
	self assert: (childMemento readUsing: endpointDescription) equals: child endpoint.
	self assert: projectedChild endpoint equals: 'https://preview.example'.
	^ projectedConfiguration
]

{ #category : 'examples' }
CFConfigurationExamples >> editingProjectionIncludesStagedInsertionWithoutApplying [
	<gtExample>
	| configuration candidate rootMemento relationDescription operation projectedConfiguration |
	configuration := self class emptyConfigurationGroup.
	candidate := (CFConfigurationLibrary discovered assets
		detect: [ :asset | asset selector = #developmentConfiguration ]) materialize.
	rootMemento := CFMaMemento model: configuration.
	relationDescription := configuration descriptionConfigurations.
	operation := CFAtelierInsert
		object: candidate
		memento: rootMemento
		description: relationDescription
		at: 1.
	self assert: operation apply isApplicable.
	projectedConfiguration := CFConfigurationGraphCopier new copyEditingContext: rootMemento.
	self assert: projectedConfiguration configurations size equals: 1.
	self assert: projectedConfiguration configurations first ~~ candidate.
	self assert: projectedConfiguration configurations first parent == projectedConfiguration.
	self assert: configuration configurations isEmpty.
	self assert: candidate parent isNil.
	self assert: rootMemento allChildMementos isEmpty.
	self assert: (rootMemento readUsing: relationDescription) first == candidate.
	rootMemento reset.
	self assert: (rootMemento readUsing: relationDescription) isEmpty.
	self assert: configuration configurations isEmpty.
	self assert: projectedConfiguration configurations size equals: 1.
	^ projectedConfiguration
]

{ #category : 'examples - simulation' }
CFConfigurationExamples >> editingProjectionPreservesNormalMagritteCommit [
	<gtExample>
	| configuration child rootMemento childMemento relationDescription projectedConfiguration |
	configuration := self class emptyConfigurationGroup.
	child := self class developmentConfiguration.
	child parent: configuration.
	configuration configurations add: child.
	relationDescription := configuration descriptionConfigurations.
	rootMemento := CFMaMemento model: configuration.
	childMemento := rootMemento childMementoFor: child inRelation: relationDescription.
	childMemento write: 'https://committed.example' using: child descriptionEndpoint.
	projectedConfiguration := CFConfigurationGraphCopier new copyEditingContext: rootMemento.
	self assert: child endpoint equals: 'http://localhost:8080'.
	rootMemento commit.
	self assert: child endpoint equals: 'https://committed.example'.
	self assert: configuration configurations first == child.
	self assert: child parent == configuration.
	self assert: projectedConfiguration configurations first ~~ child.
	self assert: projectedConfiguration configurations first endpoint equals: child endpoint.
	self assert: (rootMemento childMementoFor: child inRelation: relationDescription) == childMemento.
	^ projectedConfiguration
]

{ #category : 'examples' }
CFConfigurationExamples >> invalidConfigurationHasStructuredIssue [
	<gtExample>
	| configuration result issue |
	configuration := CFMyConfigExample new
		label: 'Missing endpoint';
		yourself.
	result := CFConfigurationValidator new validate: configuration.
	self assert: result isValid not.
	issue := result errors first.
	self assert: issue code equals: #magritteValidation.
	self assert: issue subject == configuration.
	self assert: issue path equals: #(endpoint).
	^ result
]

{ #category : 'examples' }
CFConfigurationExamples >> methodLibraryDiscoversOptionalTypeHints [
	<gtExample>
	| library hintedAsset unhintedAsset |
	library := CFConfigurationLibrary discovered.
	hintedAsset := library assets
		detect: [ :each | each selector = #developmentConfiguration ].
	unhintedAsset := library assets
		detect: [ :each | each selector = #developmentConfigurationWithoutTypeHint ].
	self assert: hintedAsset configurationClass equals: CFMyConfigExample.
	self assert: unhintedAsset configurationClass isNil.
	self assert: hintedAsset materialize class equals: CFMyConfigExample.
	self assert: unhintedAsset materialize class equals: CFMyConfigExample.
	^ library
]

{ #category : 'examples - atelier' }
CFConfigurationExamples >> nestedConfigurationAtelierStagesAndResetsSharedTransaction [
	<gtExample>
	| configuration child rootMemento childMemento relationDescription endpointDescription atelier inspector tool childPresentation |
	configuration := self class emptyConfigurationGroup.
	child := self class developmentConfiguration.
	child parent: configuration.
	configuration configurations: { child }.
	relationDescription := configuration descriptionConfigurations.
	endpointDescription := child descriptionEndpoint.
	rootMemento := CFMaMemento model: configuration.
	atelier := configuration asAtelier.
	atelier preparedElementForMemento: rootMemento.
	childMemento := rootMemento childMementoFor: child inRelation: relationDescription.
	inspector := CFAtelierInspectorElement new.
	tool := inspector
		inspectObject: child
		memento: childMemento
		presentationDo: [ :aPresentation |
			childPresentation := aPresentation.
			aPresentation transactionMemento: rootMemento ].
	tool newPreparedElement.
	self assert: childPresentation class equals: CFMaDetailPresentation.
	self assert: tool memento == childMemento.
	self assert: childPresentation memento == childMemento.
	self assert: childPresentation actionMemento == rootMemento.
	self assert: childMemento rootMemento == rootMemento.
	self assert: childMemento parentMemento == rootMemento.
	childMemento write: 'https://staged.example' using: endpointDescription.
	self assert: (childMemento readUsing: endpointDescription) equals: 'https://staged.example'.
	self assert: child endpoint equals: 'http://localhost:8080'.
	self assert: child parent == configuration.
	childPresentation actionMemento reset.
	self assert: (childMemento readUsing: endpointDescription) equals: child endpoint.
	self assert: (rootMemento childMementoFor: child inRelation: relationDescription) == childMemento.
	self assert: configuration configurations first == child.
	self assert: child parent == configuration.
	^ tool
]

{ #category : 'examples' }
CFConfigurationExamples >> plannerAppliesToManyPlan [
	<gtExample>
	| configuration asset assessment appliedConfiguration |
	configuration := self class emptyConfigurationGroup.
	asset := CFConfigurationLibrary discovered assets
		detect: [ :each | each selector = #developmentConfiguration ].
	assessment := CFConfigurationPlanner new
		assessAsset: asset
		in: configuration.
	appliedConfiguration := (CFConfigurationPlan
		asset: asset
		targetChoice: assessment targetChoices first
		planner: CFConfigurationPlanner new) apply.
	self assert: configuration configurations size equals: 1.
	self assert: configuration configurations first == appliedConfiguration.
	self assert: appliedConfiguration parent == configuration.
	^ configuration
]

{ #category : 'examples' }
CFConfigurationExamples >> plannerAppliesToOneReplacementPlan [
	<gtExample>
	| configuration asset assessment appliedConfiguration planner |
	configuration := self class emptyConfigurationHolder.
	asset := CFConfigurationLibrary discovered assets
		detect: [ :each | each selector = #developmentConfiguration ].
	planner := CFConfigurationPlanner new.
	assessment := planner assessAsset: asset in: configuration.
	appliedConfiguration := (CFConfigurationPlan
		asset: asset
		targetChoice: assessment targetChoices first
		planner: planner) apply.
	self assert: configuration configuration == appliedConfiguration.
	self assert: appliedConfiguration parent == configuration.
	^ configuration
]

{ #category : 'examples' }
CFConfigurationExamples >> plannerAssessesProjectedEditingValuesWithoutApplying [
	<gtExample>
	| configuration child rootMemento childMemento relationDescription endpointDescription projectedConfiguration projectedChild asset assessment |
	configuration := self class emptyConfigurationGroup.
	child := self class developmentConfiguration.
	child parent: configuration.
	configuration configurations add: child.
	relationDescription := configuration descriptionConfigurations.
	endpointDescription := child descriptionEndpoint.
	rootMemento := CFMaMemento model: configuration.
	childMemento := rootMemento childMementoFor: child inRelation: relationDescription.
	childMemento write: 'https://planner-preview.example' using: endpointDescription.
	projectedConfiguration := CFConfigurationGraphCopier new copyEditingContext: rootMemento.
	projectedChild := projectedConfiguration configurations first.
	asset := CFConfigurationLibrary discovered assets
		detect: [ :each | each selector = #developmentConfiguration ].
	assessment := CFConfigurationPlanner new assessAsset: asset in: projectedConfiguration.
	self assert: assessment targetChoices isEmpty not.
	self assert: assessment targetChoices first placement memento model == projectedConfiguration.
	self assert: projectedConfiguration configurations size equals: 1.
	self assert: projectedChild ~~ child.
	self assert: projectedChild parent == projectedConfiguration.
	self assert: projectedChild endpoint equals: 'https://planner-preview.example'.
	self assert: configuration configurations first == child.
	self assert: child parent == configuration.
	self assert: child endpoint equals: 'http://localhost:8080'.
	self assert: (rootMemento readUsing: relationDescription) first == child.
	self assert: (childMemento readUsing: endpointDescription) equals: 'https://planner-preview.example'.
	self assert: rootMemento allChildMementos size equals: 1.
	self assert: rootMemento allChildMementos first == childMemento.
	self assert: childMemento allChildMementos isEmpty.
	rootMemento reset.
	self assert: (childMemento readUsing: endpointDescription) equals: child endpoint.
	self assert: projectedChild endpoint equals: 'https://planner-preview.example'.
	^ assessment
]

{ #category : 'examples' }
CFConfigurationExamples >> plannerFindsNestedPlacements [
	<gtExample>
	| configuration nestedConfiguration asset assessment |
	configuration := self class emptyConfigurationGroup.
	nestedConfiguration := self class emptyConfigurationGroup.
	nestedConfiguration
		label: 'Nested configuration group';
		parent: configuration.
	configuration configurations add: nestedConfiguration.
	asset := CFConfigurationLibrary discovered assets
		detect: [ :each | each selector = #developmentConfiguration ].
	assessment := CFConfigurationPlanner new
		assessAsset: asset
		in: configuration.
	self assert: assessment targetChoices size equals: 2.
	self assert: (assessment targetChoices anySatisfy: [ :each |
		each placement memento model == nestedConfiguration ]).
	self assert: configuration configurations size equals: 1.
	^ assessment
]

{ #category : 'examples' }
CFConfigurationExamples >> plannerFindsToManyPlacement [
	<gtExample>
	| configuration asset assessment targetChoice |
	configuration := self class emptyConfigurationGroup.
	asset := CFConfigurationLibrary discovered assets
		detect: [ :each | each selector = #developmentConfiguration ].
	assessment := CFConfigurationPlanner new
		assessAsset: asset
		in: configuration.
	self assert: assessment hasSingleTargetChoice.
	targetChoice := assessment targetChoices first.
	self assert: targetChoice placement memento model == configuration.
	self assert: targetChoice placement isAddition.
	self assert: targetChoice willProduceValidConfiguration.
	self assert: configuration configurations isEmpty.
	^ assessment
]

{ #category : 'examples' }
CFConfigurationExamples >> plannerFindsToOneReplacementPlacement [
	<gtExample>
	| configuration asset assessment targetChoice |
	configuration := self class emptyConfigurationHolder.
	asset := CFConfigurationLibrary discovered assets
		detect: [ :each | each selector = #developmentConfiguration ].
	assessment := CFConfigurationPlanner new
		assessAsset: asset
		in: configuration.
	self assert: assessment hasSingleTargetChoice.
	targetChoice := assessment targetChoices first.
	self assert: targetChoice placement isReplacement.
	self assert: targetChoice willProduceValidConfiguration.
	self assert: configuration configuration isNil.
	^ assessment
]

{ #category : 'examples' }
CFConfigurationExamples >> plannerRejectsPlacementThatAddsValidationErrors [
	<gtExample>
	| configuration asset assessment |
	configuration := self class emptyConfigurationGroup.
	asset := CFConfigurationMethodAsset new
		sourceClass: self class;
		selector: #invalidConfiguration;
		configurationClass: CFMyConfigExample;
		yourself.
	assessment := CFConfigurationPlanner new
		assessAsset: asset
		in: configuration.
	self assert: assessment targetChoices isEmpty.
	self assert: assessment diagnostics size equals: 1.
	^ assessment
]

{ #category : 'examples' }
CFConfigurationExamples >> plannerRejectsStaleNestedPlan [
	<gtExample>
	| configuration nestedConfiguration asset assessment targetChoice plan wasRejected |
	configuration := self class emptyConfigurationGroup.
	nestedConfiguration := self class emptyConfigurationGroup.
	nestedConfiguration parent: configuration.
	configuration configurations add: nestedConfiguration.
	asset := CFConfigurationLibrary discovered assets
		detect: [ :each | each selector = #developmentConfiguration ].
	assessment := CFConfigurationPlanner new
		assessAsset: asset
		in: configuration.
	targetChoice := assessment targetChoices
		detect: [ :each | each placement memento model == nestedConfiguration ].
	plan := CFConfigurationPlan
		asset: asset
		targetChoice: targetChoice
		planner: CFConfigurationPlanner new.
	configuration configurations remove: nestedConfiguration.
	wasRejected := false.
	[ plan apply ] on: Error do: [ :anError | wasRejected := true ].
	self assert: wasRejected.
	self assert: configuration configurations isEmpty.
	^ configuration
]

{ #category : 'examples' }
CFConfigurationExamples >> serializationRoundTrip [
	<gtExample>
	| configuration decoded |
	configuration := self class developmentConfiguration.
	decoded := CFConfigurationCodec fromString: (CFConfigurationCodec toStringPretty: configuration).
	self assert: decoded class equals: CFMyConfigExample.
	self assert: decoded label equals: configuration label.
	self assert: decoded endpoint equals: configuration endpoint.
	^ decoded
]

{ #category : 'examples' }
CFConfigurationExamples >> serializationRoundTripRestoresConfigurationParents [
	<gtExample>
	| configuration decoded child |
	configuration := self class emptyConfigurationGroup.
	configuration configurations add: self class developmentConfiguration.
	decoded := CFConfigurationCodec fromString: (CFConfigurationCodec toStringPretty: configuration).
	child := decoded configurations first.
	self assert: child parent == decoded.
	^ decoded
]

{ #category : 'examples' }
CFConfigurationExamples >> validConfiguration [
	<gtExample>
	| configuration result |
	configuration := self class developmentConfiguration.
	result := CFConfigurationValidator new validate: configuration.
	self assert: result isValid.
	^ configuration
]
