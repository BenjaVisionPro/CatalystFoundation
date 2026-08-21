Class {
	#name : 'CFMaPresentationStencilBuilder',
	#superclass : 'BrStencilBuilder',
	#instVars : [
		'memento'
	],
	#category : 'BVC-Foundation-Magritte-GT',
	#package : 'BVC-Foundation-Magritte-GT'
}

{ #category : 'api - instantiation' }
CFMaPresentationStencilBuilder >> buildDefault [
	<return: #CFMaPresentation>
	^ CFMaPresentation new
]

{ #category : 'accessing' }
CFMaPresentationStencilBuilder >> memento [
	^ memento
]

{ #category : 'accessing' }
CFMaPresentationStencilBuilder >> memento: aMemento [
	memento := aMemento
]

{ #category : 'api - instantiation' }
CFMaPresentationStencilBuilder >> paramsOn: aStencilExecutor [
	super paramsOn: aStencilExecutor.
	aStencilExecutor push: self memento
]

{ #category : 'initialization' }
CFMaPresentationStencilBuilder >> reset [
	memento := nil
]
