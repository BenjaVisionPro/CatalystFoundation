"
I am an example Behaviour that records every CFMotionEvaluation I receive. I have no presentation property and therefore require no coordinator ownership claim.
"
Class {
	#name : 'CFMotionEvaluationRecorder',
	#superclass : 'CFMotionBehaviour',
	#instVars : [ 'evaluations' ],
	#category : 'BVC-Foundation-Motion-Examples',
	#package : 'BVC-Foundation-Motion-Examples'
}

{ #category : 'evaluating' }
CFMotionEvaluationRecorder >> evaluate: anEvaluation [
	evaluations add: anEvaluation
]

{ #category : 'accessing' }
CFMotionEvaluationRecorder >> evaluations [
	^ evaluations asArray
]

{ #category : 'initialization' }
CFMotionEvaluationRecorder >> initialize [
	super initialize.
	evaluations := OrderedCollection new
]
