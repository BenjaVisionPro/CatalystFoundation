Class {
	#name : 'CFMagritteEditorExampleOperationsElement',
	#superclass : 'CFOperationsElement',
	#category : 'BVC-Foundation-Phlow',
	#package : 'BVC-Foundation-Phlow'
}

{ #category : 'instance creation' }
CFMagritteEditorExampleOperationsElement class >> newContentElementForViewModel: aViewModel [
	^ (super newContentElementForViewModel: aViewModel)
		addChild: (BrLabel new
			aptitude: (BrGlamorousLabelAptitude new foreground: (Color black alpha: 0.55));
			text: 'Custom operations content can be introduced by adding another <cfInspectorTool> method for a different tool.';
			hMatchParent;
			yourself);
		yourself
]
