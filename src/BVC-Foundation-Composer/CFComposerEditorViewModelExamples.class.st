Class {
	#name : 'CFComposerEditorViewModelExamples',
	#superclass : 'Object',
	#category : 'BVC-Foundation-Composer-Examples',
	#package : 'BVC-Foundation-Composer',
	#tag : 'Examples'
}

{ #category : 'examples' }
CFComposerEditorViewModelExamples >> composerEditorUsesAStandardRootMemento [
	<gtExample>
	| aViewModel |
	aViewModel := CFComposerEditorViewModel
		forObject: CFMagritteEditorExample exampleDefault.

	self assert: aViewModel mementoFuture isAsyncFuture.
	^ aViewModel
]

{ #category : 'examples' }
CFComposerEditorViewModelExamples >> foundationMagritteViewRemainsTheDefaultForm [
	<gtExample>
	| aViewModel |
	aViewModel := CFMagritteEditorExample exampleDefault asGtMagritteViewModel.

	self assert: aViewModel class equals: CFMaViewModel.
	^ aViewModel
]

{ #category : 'examples' }
CFComposerEditorViewModelExamples >> ordinaryMagritteObjectCanUseComposer [
	<gtExample>
	| aModel aViewModel |
	aModel := CFComposerExampleModel new.
	aViewModel := CFComposerEditorViewModel forObject: aModel.

	self assert: aModel hasMagritteDescription.
	self assert: aViewModel mementoFuture isAsyncFuture.
	^ aViewModel
]
