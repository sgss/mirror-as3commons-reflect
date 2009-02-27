/*
 * Copyright (c) 2007-2009 the original author or authors
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */
package org.as3commons.reflect {

	import org.as3commons.reflect.errors.ClassNotFoundError;

	import flexunit.framework.Reflective;
	import flexunit.framework.Test;
	import flexunit.framework.TestCase;

	/**
	 * @author Christophe Herreman
	 */
	public class ClassUtilsTest extends TestCase {

		public function ClassUtilsTest(methodName:String = null) {
			super(methodName)
		}

		public function testForInstance():void {
			assertEquals(ClassUtilsTest, ClassUtils.forInstance(this));
			assertEquals(String, ClassUtils.forInstance(new String("a")));
			assertEquals(String, ClassUtils.forInstance("b"));
		}

		public function testForName_shouldReturnString():void {
			assertEquals(String, ClassUtils.forName("String"));
		}

		public function testForName_shouldReturnNumber():void {
			assertEquals(Number, ClassUtils.forName("Number"));
		}

		public function testForName_shouldReturnint():void {
			assertEquals(int, ClassUtils.forName("int"));
		}

		public function testForName_shouldReturnUint():void {
			assertEquals(uint, ClassUtils.forName("uint"));
		}

		public function testForName_shouldReturnBoolean():void {
			assertEquals(Boolean, ClassUtils.forName("Boolean"));
		}

		public function testForName_shouldReturnArray():void {
			assertEquals(Array, ClassUtils.forName("Array"));
		}

		public function testForName_shouldReturnDate():void {
			assertEquals(Date, ClassUtils.forName("Date"));
		}

		public function testForName_shouldReturnClass():void {
			assertEquals(Class, ClassUtils.forName("Class"));
		}

		public function testForName_shouldThrowClassNotFoundError():void {
			try {
				assertEquals(String, ClassUtils.forName("string"));
				fail("Calling forName() with unknown class should throw ClassNotFoundError");
			}
			catch (e:ClassNotFoundError){}
		}

		public function testIsSubclassOf():void {
			var result:Boolean = ClassUtils.isSubclassOf(ClassUtilsTest, TestCase);
			assertTrue(result);
		}

		public function testIsSubclassOf2():void {
			var result:Boolean = ClassUtils.isSubclassOf(ClassUtilsTest, String);
			assertFalse(result);
		}

		public function testGetSuperClass():void {
			var clazz:Class = ClassUtilsTest;
			var parentClass:Class = ClassUtils.getSuperClass(clazz);
			assertEquals(TestCase, parentClass);
		}

		public function testGetSuperClassWithString():void {
			assertEquals(Object, ClassUtils.getSuperClass(String));
		}

		public function testGetSuperClassWithObject():void {
			assertEquals(null, ClassUtils.getSuperClass(Object));
		}

		public function testGetName():void {
			var result:String = ClassUtils.getName(ClassUtilsTest);
			assertEquals("ClassUtilsTest", result);
		}

		public function testGetFullyQualifiedName():void {
			var result:String = ClassUtils.getFullyQualifiedName(ClassUtilsTest);
			assertEquals("org.as3commons.reflect::ClassUtilsTest", result);
		}

		public function testGetFullyQualifiedNameWithReplaceColons():void {
			var result:String = ClassUtils.getFullyQualifiedName(ClassUtilsTest, true);
			assertEquals("org.as3commons.reflect.ClassUtilsTest", result);
		}

		public function testGetSuperClassName():void {
			var result:String = ClassUtils.getSuperClassName(ClassUtilsTest);
			assertEquals("TestCase", result);
		}

		public function testGetFullyQualifiedSuperClassName():void {
			var result:String = ClassUtils.getFullyQualifiedSuperClassName(ClassUtilsTest);
			assertEquals("flexunit.framework::TestCase", result);
		}

		public function testGetFullyQualifiedSuperClassNameWithReplaceColons():void {
			var result:String = ClassUtils.getFullyQualifiedSuperClassName(ClassUtilsTest, true);
			assertEquals("flexunit.framework.TestCase", result);
		}

		public function testGetNameFromFullyQualifiedName():void {
			var result:String = ClassUtils.getNameFromFullyQualifiedName("flexunit.framework::Reflective");
			assertEquals("Reflective", result);
		}

		public function testGetNameFromFullyQualifiedName_forArray():void {
			var result:String = ClassUtils.getNameFromFullyQualifiedName("Array");
			assertEquals("Array", result);
		}

		// interface methods
		public function testGetImplementedInterfaceNames():void {
			var result:Array = ClassUtils.getImplementedInterfaceNames(TestCase);
			assertEquals(2, result.length);
			assertTrue(result.indexOf("Reflective") > -1);
			assertTrue(result.indexOf("Test") > -1);
		}

		public function testGetFullyQualifiedImplementedInterfaceNames():void {
			var result:Array = ClassUtils.getFullyQualifiedImplementedInterfaceNames(TestCase);
			assertEquals(2, result.length);
			assertTrue(result.indexOf("flexunit.framework::Reflective") > -1);
			assertTrue(result.indexOf("flexunit.framework::Test") > -1);
		}

		public function testGetFullyQualifiedImplementedInterfaceNames_replaceColons():void {
			var result:Array = ClassUtils.getFullyQualifiedImplementedInterfaceNames(TestCase, true);
			assertEquals(2, result.length);
			assertTrue(result.indexOf("flexunit.framework.Reflective") > -1);
			assertTrue(result.indexOf("flexunit.framework.Test") > -1);
		}

		public function testGetImplementedInterfaces():void {
			var result:Array = ClassUtils.getImplementedInterfaces(TestCase);
			assertEquals(2, result.length);
			assertTrue(result.indexOf(Reflective) > -1);
			assertTrue(result.indexOf(Test) > -1);
		}

		// convertFullyQualifiedName
		public function testConvertFullyQualifiedName():void {
			var result:String = ClassUtils.convertFullyQualifiedName("flexunit.framework::TestCase");
			assertEquals("flexunit.framework.TestCase", result);
		}

	}
}
