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
CFConfigurationExamples >> validConfiguration [
	<gtExample>
	| configuration result |
	configuration := self class developmentConfiguration.
	result := CFConfigurationValidator new validate: configuration.
	self assert: result isValid.
	^ configuration
]
