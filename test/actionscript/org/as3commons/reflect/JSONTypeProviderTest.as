package org.as3commons.reflect {
	import flash.net.registerClassAlias;
	import flash.system.ApplicationDomain;

	import flexunit.framework.TestCase;

	import org.as3commons.reflect.testclasses.FullTestClass;
	import org.as3commons.reflect.testclasses.PublicClass;

	public class JSONTypeProviderTest extends TestCase {

		public function JSONTypeProviderTest(methodName:String = null) {
			super(methodName);
		}

		public function testConstructor():void {
			var td:JSONTypeProvider = new JSONTypeProvider();
		}

		public function testGetType():void {
			var td:JSONTypeProvider = new JSONTypeProvider();
			td.getType(FullTestClass, ApplicationDomain.currentDomain);
		}

	}
}