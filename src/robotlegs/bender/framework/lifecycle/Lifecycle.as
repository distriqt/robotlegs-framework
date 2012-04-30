//------------------------------------------------------------------------------
//  Copyright (c) 2011 the original author or authors. All Rights Reserved. 
// 
//  NOTICE: You are permitted to use, modify, and distribute this file 
//  in accordance with the terms of the license agreement accompanying it. 
//------------------------------------------------------------------------------

package robotlegs.bender.framework.lifecycle
{
	import flash.events.EventDispatcher;
	import flash.utils.Dictionary;

	public class Lifecycle extends EventDispatcher
	{

		/*============================================================================*/
		/* Public Properties                                                          */
		/*============================================================================*/

		private var _state:String = LifecycleState.UNINITIALIZED;

		public function get state():String
		{
			return _state;
		}

		private var _target:Object;

		public function get target():Object
		{
			return _target;
		}

		/*============================================================================*/
		/* Private Properties                                                         */
		/*============================================================================*/

		private const _reversedEventTypes:Dictionary = new Dictionary();

		private var _reversePriority:int;

		private var _initialize:LifecycleTransition;

		private var _suspend:LifecycleTransition;

		private var _resume:LifecycleTransition;

		private var _destroy:LifecycleTransition;

		/*============================================================================*/
		/* Constructor                                                                */
		/*============================================================================*/

		public function Lifecycle(target:Object)
		{
			_target = target;
			configureTransitions();
		}

		/*============================================================================*/
		/* Public Functions                                                           */
		/*============================================================================*/

		public function initialize(callback:Function = null):void
		{
			_initialize.enter(callback);
		}

		public function suspend(callback:Function = null):void
		{
			_suspend.enter(callback);
		}

		public function resume(callback:Function = null):void
		{
			_resume.enter(callback);
		}

		public function destroy(callback:Function = null):void
		{
			_destroy.enter(callback);
		}

		override public function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void
		{
			priority = flipPriority(type, priority);
			super.addEventListener(type, listener, useCapture, priority, useWeakReference);
		}

		/*============================================================================*/
		/* Internal Functions                                                         */
		/*============================================================================*/

		internal function setCurrentState(state:String):void
		{
			if (_state == state)
				return;
			_state = state;
			// todo: dispatch LifecycleEvent.STATE_CHANGE
		}

		internal function addReversedEventTypes(... types):void
		{
			for each (var type:String in types)
				_reversedEventTypes[type] = true;
		}

		/*============================================================================*/
		/* Private Functions                                                          */
		/*============================================================================*/

		private function configureTransitions():void
		{
			_initialize = new LifecycleTransition("initialize", this)
				.fromStates(LifecycleState.UNINITIALIZED)
				.toStates(LifecycleState.INITIALIZING, LifecycleState.ACTIVE)
				.withEvents(LifecycleEvent.PRE_INITIALIZE, LifecycleEvent.INITIALIZE, LifecycleEvent.POST_INITIALIZE);

			_suspend = new LifecycleTransition("suspend", this)
				.fromStates(LifecycleState.ACTIVE)
				.toStates(LifecycleState.SUSPENDING, LifecycleState.SUSPENDED)
				.withEvents(LifecycleEvent.PRE_SUSPEND, LifecycleEvent.SUSPEND, LifecycleEvent.POST_SUSPEND);

			_resume = new LifecycleTransition("resume", this)
				.fromStates(LifecycleState.SUSPENDED)
				.toStates(LifecycleState.RESUMING, LifecycleState.ACTIVE)
				.withEvents(LifecycleEvent.PRE_RESUME, LifecycleEvent.RESUME, LifecycleEvent.POST_RESUME);

			_destroy = new LifecycleTransition("destroy", this)
				.fromStates(LifecycleState.SUSPENDED, LifecycleState.ACTIVE)
				.toStates(LifecycleState.DESTROYING, LifecycleState.DESTROYED)
				.withEvents(LifecycleEvent.PRE_DESTROY, LifecycleEvent.DESTROY, LifecycleEvent.POST_DESTROY);
		}

		private function flipPriority(type:String, priority:int):int
		{
			return (priority == 0 && _reversedEventTypes[type])
				? _reversePriority++
				: priority;
		}
	}
}