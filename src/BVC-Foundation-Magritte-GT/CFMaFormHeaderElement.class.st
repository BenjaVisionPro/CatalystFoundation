Class {
	#name : 'CFMaFormHeaderElement',
	#superclass : 'BrVerticalPane',
	#traits : 'TGtMagritteWithFieldViewModel',
	#classTraits : 'TGtMagritteWithFieldViewModel classTrait',
	#instVars : [
		'labelElement',
		'checkboxElement',
		'iconElement',
		'breadcrumbElement'
	],
	#category : 'BVC-Foundation-Magritte-GT-Widgets',
	#package : 'BVC-Foundation-Magritte-GT',
	#tag : 'Widgets'
}

{ #category : 'initialization' }
CFMaFormHeaderElement >> initialize [
	super initialize.

	self initializeIconElement.
	self initializeBreadcrumbElement.
	self initializeLabelElement.

	self addChild: iconElement as: #icon.
	self addChild: breadcrumbElement as: #breadcrumb.
	self addChild: labelElement as: #label.

	self
		withAsyncSinkDo: [ :anElementSink | 
			anElementSink
				sink: AsyncPeekSink new;
				whenUpdate: [ :anElement :aSink | self onMagritteValueChanged: aSink value ] ].

	self
		hFitContentLimited;
		vFitContent
]

{ #category : 'initialization' }
CFMaFormHeaderElement >> initializeBreadcrumbElement [
	breadcrumbElement := BrCheckbox new.
	breadcrumbElement
		fitContent;
		aptitude: BrGlamorousCheckboxAptitude;
		margin: (BlInsets
				top: 0
				right: 0
				bottom: GtMagritteBuilderUtility defaultSpaceNumber
				left: 3).

	breadcrumbElement
		whenCheckedDo: [ self writeCheckedMemento ];
		whenUncheckedDo: [ self writeUncheckedMemento ].

	breadcrumbElement constraintsDo: [ :c | 
		c linear vertical alignCenter ]
]

{ #category : 'initialization' }
CFMaFormHeaderElement >> initializeIconElement [
	iconElement := BrEditor new
		beReadOnlyWithSelection;
		aptitude: BrGlamorousRegularEditorAptitude new glamorousRegularFontAndSize.
		
	GtMagritteBuilderUtility styleEditorWidget: iconElement.
				
	iconElement constraintsDo: [ :c | 
		c linear vertical alignCenter ].
		
	iconElement margin: iconElement margin 
		+ (BlInsets left: GtMagritteBuilderUtility defaultSpaceNumber)
]

{ #category : 'initialization' }
CFMaFormHeaderElement >> initializeLabelElement [
	labelElement := BrEditor new
		beReadOnlyWithSelection;
		aptitude: BrGlamorousRegularEditorAptitude new glamorousRegularFontAndSize.
		
	GtMagritteBuilderUtility styleEditorWidget: labelElement.
				
	labelElement constraintsDo: [ :c | 
		c linear vertical alignCenter ].
		
	labelElement margin: labelElement margin 
		+ (BlInsets left: GtMagritteBuilderUtility defaultSpaceNumber)
]

{ #category : 'private - event handling' }
CFMaFormHeaderElement >> onDescriptionPropertyChanged: anAnnouncement [
	self updateLabelElement
]

{ #category : 'api - field view model' }
CFMaFormHeaderElement >> onFieldViewModelChanged [
	"Is sent when a new fieldViewModel is assigned to the receiver.
	Note: #onFieldViewModelChanged is sent before #subscribeToFieldViewModel
	which means that if you perform any operation that triggers an announcement it will be ignored because the receiver
	didn't get a chance to subscribe to any announcement. Override #onPostFieldViewModelChanged if you
	wish to perform an operation that requires an announcement, but keep in mind that this is not the most efficient way"
	
	self inUIProcessDo: [
		self updateHeaderElement ]
]

{ #category : 'private - event handling' }
CFMaFormHeaderElement >> onMagritteValueChanged: aGtMagritteValue [
	self
		updateIcon;
		updateBreadcrumb;
		updateLabel
]

{ #category : 'api - field view model' }
CFMaFormHeaderElement >> onPostFieldViewModelChanged [
	"I am an optional hook method that is sent after #subscribeToFieldViewModel.
	I do nothing by default but allow users to perform update operations when a receiver object is already
	subscribed to announcements."
	
	self withAsyncSinkDo: [ :anElementSink | 
		self observableValue observe: anElementSink ]
]

{ #category : 'api - field view model' }
CFMaFormHeaderElement >> subscribeToFieldViewModel [
	"Is sent after a new fieldViewModel is assigned to the receiver.
	It is required to unsubscribe from the previously subscribed objects by implementing
	#unsubscribeFromFieldViewModel if the receiver subscribes to them"
	
	self fieldViewModel description 
		whenPropertyChangedSend: #onDescriptionPropertyChanged: 
		to: self
]

{ #category : 'api - field view model' }
CFMaFormHeaderElement >> unsubscribeFromFieldViewModel [
	"Is sent before a new fieldViewModel is assigned to the receiver.
	Objects that subscribe to fieldViewModel are required to implement this method."
	
	self fieldViewModel description unsubscribe: self
]

{ #category : 'private - updating' }
CFMaFormHeaderElement >> updateCheckbox: aGtMagritteValue [
	checkboxElement checked: (aGtMagritteValue currentValue ifNil: [ false ])
]

{ #category : 'private - updating' }
CFMaFormHeaderElement >> updateCheckboxElement [
	self observableValue
		ifSome: [ :aValue | self updateCheckbox: aValue ]
		ifNone: [ checkboxElement checked: false ]
]

{ #category : 'private - updating' }
CFMaFormHeaderElement >> updateHeaderElement [
	self updateIconElement.
	self updateBreadcrumbElement.
	self updateLabelElement.
]

{ #category : 'private - updating' }
CFMaFormHeaderElement >> updateIconElement [
	self observableValue
		ifSome: [ :aValue | self updateIcon: aValue ]
		ifNone: [ "Update icon maybe?" iconElement ]
]

{ #category : 'private - updating' }
CFMaFormHeaderElement >> updateLabel: aGtMagritteValue [
	| aLabel |
	aLabel := aGtMagritteValue currentValue.

	labelElement text: aLabel
]

{ #category : 'private - updating' }
CFMaFormHeaderElement >> updateLabelElement [
	self observableValue
		ifSome: [ :aValue |
			self updateLabel: aValue ] 
		ifNone: [
			labelElement text: '' ]
]

{ #category : 'private - event handling' }
CFMaFormHeaderElement >> writeCheckedMemento [
	self hasFieldViewModel ifFalse: [ ^ self ].
	
	GtMagritteBuilderUtility 
		write: true 
		using: self description 
		memento: self memento 
		element: self
]

{ #category : 'private - event handling' }
CFMaFormHeaderElement >> writeUncheckedMemento [
	self hasFieldViewModel ifFalse: [ ^ self ].
	
	GtMagritteBuilderUtility 
		write: false 
		using: self description 
		memento: self memento 
		element: self
]
