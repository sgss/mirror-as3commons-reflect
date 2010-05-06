/*
 * Copyright (c) 2007-2009-2010 the original author or authors
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
	
	import flash.system.ApplicationDomain;
	
	import org.as3commons.lang.ClassNotFoundError;
	import org.as3commons.lang.ClassUtils;
	import org.as3commons.logging.ILogger;
	import org.as3commons.logging.LoggerFactory;
	
	/**
	 * Provides information about the characteristics of a class or an interface.
	 * These are the methods, accessors (getter/setter), variables and constants,
	 * but also if the class is <code>dynamic</code> and <code>final</code>.
	 *
	 * <p>Note that information about an object cannot be retrieved by calling the
	 * <code>Type</code> constructor. Instead use one of the following static
	 * methods:</p>
	 *
	 * <p>In case of an instance:
	 * <code>var type:Type = Type.forInstance(myInstance);</code>
	 * </p>
	 *
	 * <p>In case of a <code>Class</code> variable:
	 * <code>var type:Type = Type.forClass(MyClass);</code>
	 * </p>
	 *
	 * <p>In case of a classname:
	 * <code>var type:Type = Type.forName("MyClass");</code>
	 * </p>
	 *
	 * @author Christophe Herreman
	 * @author Martino Piccinato
	 * @author Andrew Lewisohn
	 */
	public class Type extends MetaDataContainer {
		
		public static const UNTYPED:Type = new Type(ApplicationDomain.currentDomain);
		
		public static const VOID:Type = new Type(ApplicationDomain.currentDomain);
		
		public static const PRIVATE:Type = new Type(ApplicationDomain.currentDomain);
		
		private static var logger:ILogger = LoggerFactory.getClassLogger(Type);
		
		private static var typeProvider:ITypeProvider;
		
		// --------------------------------------------------------------------
		//
		// Static Methods
		//
		// --------------------------------------------------------------------
		
		/**
		 * Returns a <code>Type</code> object that describes the given instance.
		 *
		 * @param instance the instance from which to get a type description
		 */
		public static function forInstance(instance:*, applicationDomain:ApplicationDomain=null):Type {
			applicationDomain = (applicationDomain == null) ? ApplicationDomain.currentDomain : applicationDomain;
			var result:Type;
			var clazz:Class = org.as3commons.lang.ClassUtils.forInstance(instance, applicationDomain);
			
			if (clazz != null) {
				result = Type.forClass(clazz, applicationDomain);
			}
			return result;
		}
		
		/**
		 * Returns a <code>Type</code> object that describes the given classname.
		 *
		 * @param name the classname from which to get a type description
		 */
		public static function forName(name:String, applicationDomain:ApplicationDomain=null):Type {
			applicationDomain = (applicationDomain == null) ? ApplicationDomain.currentDomain : applicationDomain;
			var result:Type;
			
			/*if(name.indexOf("$")!=-1){
			   return Type.PRIVATE;
			 }*/
			switch (name) {
				case "void":
					result = Type.VOID;
					break;
				case "*":
					result = Type.UNTYPED;
					break;
				default:
					try {
						if (getTypeProvider().getTypeCache().contains(name)) {
							result = getTypeProvider().getTypeCache().get(name);
						} else {
							result = Type.forClass(org.as3commons.lang.ClassUtils.forName(name, applicationDomain), applicationDomain);
						}
					} catch (e:ReferenceError) {
						logger.warn("Type.forName error: " + e.message + " The class '" + name + "' is probably an internal class or it may not have been compiled.");
					} catch (e:ClassNotFoundError) {
						logger.warn("The class with the name '{0}' could not be found in the application domain '{1}'", name, applicationDomain);
					}
			}
			return result;
		}
		
		/**
		 * Returns a <code>Type</code> object that describes the given class.
		 *
		 * @param clazz the class from which to get a type description
		 */
		public static function forClass(clazz:Class, applicationDomain:ApplicationDomain=null):Type {
			applicationDomain = (applicationDomain == null) ? ApplicationDomain.currentDomain : applicationDomain;
			var result:Type;
			var fullyQualifiedClassName:String = org.as3commons.lang.ClassUtils.getFullyQualifiedName(clazz);
			
			if (getTypeProvider().getTypeCache().contains(fullyQualifiedClassName)) {
				result = getTypeProvider().getTypeCache().get(fullyQualifiedClassName);
			} else {
				result = getTypeProvider().getType(clazz, applicationDomain);
			}
			
			return result;
		}
		
		/**
		 *  
		 */
		public static function getTypeProvider():ITypeProvider {
			if(typeProvider == null) {
				typeProvider = new TypeXmlParser();
			}
			return typeProvider;
		}
		
		// --------------------------------------------------------------------
		//
		// Constructor
		//
		// --------------------------------------------------------------------
		
		/**
		 * Creates a new <code>Type</code> instance.
		 */
		public function Type(applicationDomain:ApplicationDomain) {
			super();
			initType(applicationDomain);
		}
		
		/**
		 * Initializes the current <code>Type</code> instance.
		 */
		protected function initType(applicationDomain:ApplicationDomain):void {
			_methods = [];
			_accessors = [];
			_staticConstants = [];
			_constants = [];
			_staticVariables = [];
			_variables = [];
			_extendsClasses = [];
			_applicationDomain = applicationDomain;
		}
		
		// --------------------------------------------------------------------
		//
		// Properties
		//
		// --------------------------------------------------------------------
		
		// ----------------------------
		// applicationDomain
		// ----------------------------
		
		private var _applicationDomain:ApplicationDomain;
		/**
		 * The ApplicationDomain which is able to retrieve the object definition for this type. The definition does not
		 * necessarily have to be part of this <code>ApplicationDomain</code>, it could possibly be present in the parent domain as well.
		 */
		public function get applicationDomain():ApplicationDomain {
			return _applicationDomain;
		}
		/**
		 * @private
		 */		
		public function set applicationDomain(value:ApplicationDomain):void {
			_applicationDomain = value;
		}
		
		// ----------------------------
		// name
		// ----------------------------

		private var _alias:String;
		public function get alias():String {
			return _alias;
		}
		public function set alias(value:String):void {
			_alias = value;
		}
		
		// ----------------------------
		// name
		// ----------------------------
		
		private var _name:String;
		
		/**
		 * The name of the type
		 */
		public function get name():String {
			return _name;
		}
		
		/**
		 * @private
		 */
		public function set name(value:String):void {
			_name = value;
		}
		
		// ----------------------------
		// fullName
		// ----------------------------
		
		private var _fullName:String;
		
		/**
		 * The fully qualified name of the type, this includes the namespace
		 */
		public function get fullName():String {
			return _fullName;
		}
		
		/**
		 * @private
		 */
		public function set fullName(value:String):void {
			_fullName = value;
		}
		
		// ----------------------------
		// clazz
		// ----------------------------
		
		private var _class:Class;
		
		/**
		 * The Class of the <code>Type</code>
		 */
		public function get clazz():Class {
			return _class;
		}
		
		/**
		 * @private
		 */
		public function set clazz(value:Class):void {
			_class = value;
		}
		
		// ----------------------------
		// isDynamic
		// ----------------------------
		
		private var _isDynamic:Boolean;
		
		/**
		 * True if the <code>Type</code> is dynamic
		 */
		public function get isDynamic():Boolean {
			return _isDynamic;
		}
		
		/**
		 * @private
		 */
		public function set isDynamic(value:Boolean):void {
			_isDynamic = value;
		}
		
		// ----------------------------
		// isFinal
		// ----------------------------
		
		private var _isFinal:Boolean;
		
		/**
		 * True if the <code>Type</code> is final
		 */
		public function get isFinal():Boolean {
			return _isFinal;
		}
		
		/**
		 * @private
		 */
		public function set isFinal(value:Boolean):void {
			_isFinal = value;
		}
		
		// ----------------------------
		// isStatic
		// ----------------------------
		
		private var _isStatic:Boolean;
		
		/**
		 * True if the <code>Type</code> is static
		 */
		public function get isStatic():Boolean {
			return _isStatic;
		}
		
		/**
		 * @private
		 */
		public function set isStatic(value:Boolean):void {
			_isStatic = value;
		}

		// ----------------------------
		// isInterface
		// ----------------------------

		private var _isInterface:Boolean;

		/**
		 * True if the <code>Type</code> is an interface
		 */
		public function get isInterface():Boolean {
			return _isInterface;
		}

		/**
		 * @private
		 */
		public function set isInterface(value:Boolean):void {
			_isInterface = value;
		}
		
		// ----------------------------
		// constructor
		// ----------------------------
		
		private var _constructor:Constructor;
		
		/**
		 * A reference to a <code>Constructor</code> instance that describes the constructor of the <code>Type</code>
		 * @see org.as3commons.reflect.Constructor Constructor
		 */
		public function get constructor():Constructor {
			return _constructor;
		}
		
		/**
		 * @private
		 */
		public function set constructor(constructor:Constructor):void {
			_constructor = constructor;
		}
		
		// ----------------------------
		// accessors
		// ----------------------------
		
		private var _accessors:Array;
		
		/**
		 * An array of <code>Accessor</code> instances
		 * @see org.as3commons.reflect.Accessor Accessor
		 */
		public function get accessors():Array {
			return _accessors;
		}
		
		/**
		 * @private
		 */
		public function set accessors(value:Array):void {
			_accessors = value;
		}
		
		// ----------------------------
		// methods
		// ----------------------------
		
		private var _methods:Array;
		
		/**
		 * An array of <code>Method</code> instances
		 * @see org.as3commons.reflect.Method Method
		 */
		public function get methods():Array {
			return _methods;
		}
		
		/**
		 * @private
		 */
		public function set methods(value:Array):void {
			_methods = value;
		}
		
		// ----------------------------
		// staticConstants
		// ----------------------------
		
		private var _staticConstants:Array;
		
		/**
		 * An array of <code>IMember</code> instances that describe the static constants of the <code>Type</code>
		 * @see org.as3commons.reflect.IMember IMember
		 */
		public function get staticConstants():Array {
			return _staticConstants;
		}
		
		/**
		 * @private
		 */
		public function set staticConstants(value:Array):void {
			_staticConstants = value;
		}
		
		// ----------------------------
		// constants
		// ----------------------------
		
		private var _constants:Array;
		
		/**
		 * An array of <code>IMember</code> instances that describe the constants of the <code>Type</code>
		 * @see org.as3commons.reflect.IMember IMember
		 */
		public function get constants():Array {
			return _constants;
		}
		
		/**
		 * @private
		 */
		public function set constants(value:Array):void {
			_constants = value;
		}
		
		// ----------------------------
		// staticVariables
		// ----------------------------
		
		private var _staticVariables:Array;
		
		/**
		 * An array of <code>IMember</code> instances that describe the static variables of the <code>Type</code>
		 * @see org.as3commons.reflect.IMember IMember
		 */
		public function get staticVariables():Array {
			return _staticVariables;
		}
		
		/**
		 * @private
		 */
		public function set staticVariables(value:Array):void {
			_staticVariables = value;
		}
		
		// ----------------------------
		// extendsClass
		// ----------------------------
		
		private var _extendsClasses:Array;
		/**
		 * @return An <code>Array</code> of <code>Class</code> instances that represents the inheritance order of the current <code>Type</code>. 
		 * <p>The first item in the <code>Array</code> is the super class of the current <code>Type</code>.</p>
		 */
		public function get extendsClasses():Array {
			return _extendsClasses;
		} 
		/**
		 * @private
		 */
		public function set extendsClasses(value:Array):void {
			_extendsClasses = value;
		} 

		// ----------------------------
		// variables
		// ----------------------------
		
		private var _variables:Array;
		
		/**
		 * An array of <code>IMember</code> instances that describe the variables of the <code>Type</code>
		 * @see org.as3commons.reflect.IMember IMember
		 */
		public function get variables():Array {
			return _variables;
		}
		
		/**
		 * @private
		 */
		public function set variables(value:Array):void {
			_variables = value;
		}
		
		// ----------------------------
		// fields
		// ----------------------------
		
		/**
		 * An array of all the static constants, constants, static variables and variables of the <code>Type</code>
		 * @see org.as3commons.reflect.IMember IMember
		 */
		public function get fields():Array {
			return accessors.concat(staticConstants).concat(constants).concat(staticVariables).concat(variables);
		}

        /**
		 * An array of Field containing all accessors and variables for the type.
         *
		 * @see org.as3commons.reflect.Variable
         * @see org.as3commons.reflect.Accessor
         * @see org.as3commons.reflect.Field
		 */
		public function get properties():Array {
			return accessors.concat(variables);
		}
	
		// --------------------------------------------------------------------
		//
		// Public Methods
		//
		// --------------------------------------------------------------------
		
		/**
		 * Returns the <code>Method</code> object for the method in this type
		 * with the given name.
		 *
		 * @param name the name of the method
		 */
		public function getMethod(name:String):Method {
			var result:Method;
			
			for each (var method:Method in methods) {
				if (method.name == name) {
					result = method;
					break;
				}
			}
			return result;
		}
		
		/**
		 * Returns the <code>Field</code> object for the field in this type
		 * with the given name.
		 *
		 * @param name the name of the field
		 */
		public function getField(name:String):Field {
			var result:Field;
			
			for each (var field:Field in fields) {
				if (field.name == name) {
					result = field;
					break;
				}
			}
			return result;
		}
		
	}
}
import flash.system.ApplicationDomain;

import org.as3commons.lang.ClassUtils;
import org.as3commons.reflect.Accessor;
import org.as3commons.reflect.AccessorAccess;
import org.as3commons.reflect.Constant;
import org.as3commons.reflect.Constructor;
import org.as3commons.reflect.IMember;
import org.as3commons.reflect.IMetaDataContainer;
import org.as3commons.reflect.INamespaceOwner;
import org.as3commons.reflect.ITypeProvider;
import org.as3commons.reflect.MetaData;
import org.as3commons.reflect.MetaDataArgument;
import org.as3commons.reflect.Method;
import org.as3commons.reflect.Parameter;
import org.as3commons.reflect.ReflectionUtils;
import org.as3commons.reflect.Type;
import org.as3commons.reflect.TypeCache;
import org.as3commons.reflect.Variable;
import org.as3commons.reflect.as3commons_reflect;

/**
 * Internal xml parser
 */
internal class TypeXmlParser implements ITypeProvider {

	private static var typeCache:TypeCache = new TypeCache();
	
	public function getTypeCache():TypeCache {
		return typeCache;
	}
	
	public function clearCache():void {
		typeCache.clear();
	}
	
	/**
	 *
	 */
	private function concatMetadata(type:Type, metaDataContainers:Array, propertyName:String):void {
		for each (var container:IMetaDataContainer in metaDataContainers) {
			type[propertyName].some(function(item:Object, index:int, arr:Array):Boolean {
				if (item.name == Object(container).name) {
					var metaDataList:Array = container.metaData;
					var numMetaData:int = metaDataList.length;
					
					for (var j:int = 0; j < numMetaData; j++) {
						item.addMetaData(metaDataList[j]);
					}
					return true;
				}
				return false;
			});
		}
	}
	
	public function getType(cls:Class, applicationDomain:ApplicationDomain):Type {
		var type:Type = new Type(applicationDomain);
		var fullyQualifiedClassName:String = ClassUtils.getFullyQualifiedName(cls);
		
		// Add the Type to the cache before assigning any values to prevent looping.
		// Due to the work-around implemented for constructor argument types
		// in getTypeDescription(), an instance is created, which could also
		// lead to infinite recursion if the constructor uses Type.forName().
		// Therefore it is important to seed the cache before calling
		// getTypeDescription (thanks to Jürgen Failenschmid for reporting this)
		typeCache.put(fullyQualifiedClassName, type);
		var description:XML = ReflectionUtils.getTypeDescription(cls);
		type.fullName = fullyQualifiedClassName;
		type.name = ClassUtils.getNameFromFullyQualifiedName(fullyQualifiedClassName);
		type.clazz = cls;
		type.isDynamic = description.@isDynamic;
		type.isFinal = description.@isFinal;
		type.isStatic = description.@isStatic;
		type.alias = description.@alias;
		type.isInterface = (cls === Object) ? false : (description.factory.extendsClass.length() == 0);
		type.constructor = parseConstructor(type, description.factory.constructor, applicationDomain);
		type.accessors = parseAccessors(type, description);
		type.methods = parseMethods(type, description, applicationDomain);
		type.staticConstants = parseMembers(Constant, description.constant, fullyQualifiedClassName, true);
		type.constants = parseMembers(Constant, description.factory.constant, fullyQualifiedClassName, false);
		type.staticVariables = parseMembers(Variable, description.variable, fullyQualifiedClassName, true);
		type.variables = parseMembers(Variable, description.factory.variable, fullyQualifiedClassName, false);
		type.extendsClasses = parseExtendsClasses(description.factory.extendsClass, type.applicationDomain);
		parseMetaData(description.factory[0].metadata, type);
		
		// Combine metadata from implemented interfaces
		var interfaces:Array = org.as3commons.lang.ClassUtils.getImplementedInterfaces(type.clazz, applicationDomain);
		var numInterfaces:int = interfaces.length;
		
		for (var i:int = 0; i < numInterfaces; i++) {
			var interfaze:Type = Type.forClass(interfaces[i], applicationDomain);
			concatMetadata(type, interfaze.methods, "methods");
			concatMetadata(type, interfaze.accessors, "accessors");
			var interfaceMetaData:Array = interfaze.metaData;
			var numMetaData:int = interfaceMetaData.length;
			
			for (var j:int = 0; j < numMetaData; j++) {
				type.addMetaData(interfaceMetaData[j]);
			}
		}
		
		return type;
	}
	
	/**
	 *
	 */
	private function parseConstructor(type:Type, constructorXML:XMLList, applicationDomain:ApplicationDomain):Constructor {
		if (constructorXML.length() > 0) {
			var params:Array = parseParameters(constructorXML[0].parameter, applicationDomain);
			return new Constructor(type, params);
		} else {
			return new Constructor(type);
		}
	}
	
	/**
	 *
	 */
	private function parseMethods(type:Type, xml:XML, applicationDomain:ApplicationDomain):Array {
		var classMethods:Array = parseMethodsByModifier(type, xml.method, true, applicationDomain);
		var instanceMethods:Array = parseMethodsByModifier(type, xml.factory.method, false, applicationDomain);
		return classMethods.concat(instanceMethods);
	}
	
	/**
	 *
	 */
	private function parseAccessors(type:Type, xml:XML):Array {
		var classAccessors:Array = parseAccessorsByModifier(type, xml.accessor, true);
		var instanceAccessors:Array = parseAccessorsByModifier(type, xml.factory.accessor, false);
		return classAccessors.concat(instanceAccessors);
	}
	
	/**
	 *
	 */
	private function parseMembers(memberClass:Class, members:XMLList, declaringType:String, isStatic:Boolean):Array {
		var result:Array = [];
		
		for each (var m:XML in members) {
			var member:IMember = new memberClass(m.@name, m.@type.toString(), declaringType, isStatic);
			if (member is INamespaceOwner) {
				INamespaceOwner(member).as3commons_reflect::setNamespaceURI(m.@uri);
			}
			parseMetaData(m.metadata, member);
			result.push(member);
		}
		return result;
	}
	
	/**
	 *
	 */
	private function parseExtendsClasses(extendedClasses:XMLList, applicationDomain:ApplicationDomain):Array {
		var result:Array = [];
		for each(var node:XML in extendedClasses) {
			result[result.length] = org.as3commons.lang.ClassUtils.forName(node.@type.toString(), applicationDomain);
		}
		return result;
	}
	
	private function parseMethodsByModifier(type:Type, methodsXML:XMLList, isStatic:Boolean, applicationDomain:ApplicationDomain):Array {
		var result:Array = [];
		
		for each (var methodXML:XML in methodsXML) {
			var params:Array = parseParameters(methodXML.parameter, applicationDomain);
			var method:Method = new Method(type, methodXML.@name, isStatic, params, Type.forName(methodXML.@returnType,applicationDomain));
			method.as3commons_reflect::setNamespaceURI(methodXML.@uri);
			parseMetaData(methodXML.metadata, method);
			result.push(method);
		}
		return result;
	}
	
	private function parseParameters(paramsXML:XMLList, applicationDomain:ApplicationDomain):Array {
		var params:Array = [];
		
		for each (var paramXML:XML in paramsXML) {
			var paramType:Type = Type.forName(paramXML.@type, applicationDomain);
			var param:Parameter = new Parameter(paramXML.@index, paramType, paramXML.@optional == "true" ? true : false);
			params.push(param);
		}
		
		return params;
	}
	
	private function parseAccessorsByModifier(type:Type, accessorsXML:XMLList, isStatic:Boolean):Array {
		var result:Array = [];
		
		for each (var accessorXML:XML in accessorsXML) {
			var accessor:Accessor = new Accessor(accessorXML.@name, AccessorAccess.fromString(accessorXML.@access), accessorXML.@type.toString(), accessorXML.@declaredBy.toString(), isStatic);
			accessor.as3commons_reflect::setNamespaceURI(accessorXML.@uri);
			parseMetaData(accessorXML.metadata, accessor);
			result.push(accessor);
		}
		return result;
	}
	
	/**
	 * Parses MetaData objects from the given metaDataNodes XML data and adds them to the given metaData array.
	 */
	private function parseMetaData(metaDataNodes:XMLList, metaData:IMetaDataContainer):void {
		for each (var metaDataXML:XML in metaDataNodes) {
			var metaDataArgs:Array = [];
			
			for each (var metaDataArgNode:XML in metaDataXML.arg) {
				metaDataArgs.push(new MetaDataArgument(metaDataArgNode.@key, metaDataArgNode.@value));
			}
			metaData.addMetaData(new MetaData(metaDataXML.@name, metaDataArgs));
		}
	}
}
