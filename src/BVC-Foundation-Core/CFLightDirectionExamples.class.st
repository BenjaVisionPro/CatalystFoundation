"I exercise Foundation light-direction geometry and time-of-day mapping."
Class {
	#name : 'CFLightDirectionExamples',
	#superclass : 'Object',
	#category : 'BVC-Foundation-Core',
	#package : 'BVC-Foundation-Core'
}

{ #category : 'examples - angle' }
CFLightDirectionExamples >> angleZero [
	<gtExample>
	| direction |
	direction := CFLightDirection fromDegrees: 0.
	self assert: (direction x - 1.0) abs < 0.000001.
	self assert: direction y abs < 0.000001.
	^ direction
]

{ #category : 'examples - angle' }
CFLightDirectionExamples >> angleNinety [
	<gtExample>
	| direction |
	direction := CFLightDirection fromDegrees: 90.
	self assert: direction x abs < 0.000001.
	self assert: (direction y - 1.0) abs < 0.000001.
	^ direction
]

{ #category : 'examples - time of day' }
CFLightDirectionExamples >> evening [
	<gtExample>
	| direction |
	direction := CFLightDirection
		forHour: 18
		minute: 0
		second: 0.
	self assert: (direction x - 1.0) abs < 0.000001.
	self assert: direction y abs < 0.000001.
	^ direction
]

{ #category : 'examples - time of day' }
CFLightDirectionExamples >> midday [
	<gtExample>
	| direction |
	direction := CFLightDirection
		forHour: 12
		minute: 0
		second: 0.
	self assert: direction x abs < 0.000001.
	self assert: (direction y + 1.0) abs < 0.000001.
	^ direction
]

{ #category : 'examples - time of day' }
CFLightDirectionExamples >> midnight [
	<gtExample>
	| direction |
	direction := CFLightDirection
		forHour: 0
		minute: 0
		second: 0.
	self assert: direction x abs < 0.000001.
	self assert: (direction y - 1.0) abs < 0.000001.
	^ direction
]

{ #category : 'examples - time of day' }
CFLightDirectionExamples >> morning [
	<gtExample>
	| direction |
	direction := CFLightDirection
		forHour: 6
		minute: 0
		second: 0.
	self assert: (direction x + 1.0) abs < 0.000001.
	self assert: direction y abs < 0.000001.
	^ direction
]
