package org.as3commons.reflect {

	import flexunit.framework.TestCase;

	/**
	 * Class description
	 *
	 * @author Christophe Herreman
	 * @since 13-jan-2009
	 */
	public class MetaDataArgumentTest extends TestCase {

		/**
		 * Creates a new MetaDataArgumentTest object.
		 */
		public function MetaDataArgumentTest(methodName:String = null) {
			super(methodName);
		}

		public function testNew():void {
			var a:MetaDataArgument = new MetaDataArgument("key", "value");
			assertEquals("key", a.key);
			assertEquals("value", a.value);
		}

		public function testEqualsPass():void {
			var a:MetaDataArgument = new MetaDataArgument("key", "value");
			assertTrue(a.equals(new MetaDataArgument("key", "value")));
		}

		public function testEqualsFail():void {
			var a:MetaDataArgument = new MetaDataArgument("key", "value");
			assertFalse(a.equals(new MetaDataArgument("key", "value2")));
		}
	}
}