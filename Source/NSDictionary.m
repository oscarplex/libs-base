/* NSDictionary - Dictionary object to store key/value pairs
   Copyright (C) 1995, 1996, 1997 Free Software Foundation, Inc.
   
   Written by:  Andrew Kachites McCallum <mccallum@gnu.ai.mit.edu>
   From skeleton by:  Adam Fedor <fedor@boulder.colorado.edu>
   Date: Mar 1995
   
   This file is part of the GNUstep Base Library.
   
   This library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Library General Public
   License as published by the Free Software Foundation; either
   version 2 of the License, or (at your option) any later version.
   
   This library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Library General Public License for more details.
   
   You should have received a copy of the GNU Library General Public
   License along with this library; if not, write to the Free
   Software Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
   */

#include <Foundation/NSDictionary.h>
#include <Foundation/NSGDictionary.h>
#include <Foundation/NSArray.h>
#include <Foundation/NSUtilities.h>
#include <gnustep/base/NSString.h>
#include <gnustep/base/NSException.h>
#include <assert.h>

@interface NSDictionaryNonCore : NSDictionary
@end
@interface NSMutableDictionaryNonCore: NSMutableDictionary
@end

@implementation NSDictionary 

static Class NSDictionary_concrete_class;
static Class NSMutableDictionary_concrete_class;

+ (void) _setConcreteClass: (Class)c
{
  NSDictionary_concrete_class = c;
}

+ (void) _setMutableConcreteClass: (Class)c
{
  NSMutableDictionary_concrete_class = c;
}

+ (Class) _concreteClass
{
  return NSDictionary_concrete_class;
}

+ (Class) _mutableConcreteClass
{
  return NSMutableDictionary_concrete_class;
}

+ (void) initialize
{
  if (self == [NSDictionary class])
    {
      NSDictionary_concrete_class = [NSGDictionary class];
      NSMutableDictionary_concrete_class = [NSGMutableDictionary class];
      behavior_class_add_class (self, [NSDictionaryNonCore class]);
    }
}

+ allocWithZone: (NSZone*)z
{
  return NSAllocateObject([self _concreteClass], 0, z);
}

/* This is the designated initializer */
- initWithObjects: (id*)objects
	  forKeys: (NSObject**)keys
	    count: (unsigned)count
{
  [self subclassResponsibility:_cmd];
  return 0;
}

- (unsigned) count
{
  [self subclassResponsibility:_cmd];
  return 0;
}

- objectForKey: (NSObject*)aKey
{
  [self subclassResponsibility:_cmd];
  return 0;
}

- (NSEnumerator*) keyEnumerator
{
  [self subclassResponsibility:_cmd];
  return nil;
}

- (NSEnumerator*) objectEnumerator
{
  [self subclassResponsibility:_cmd];
  return nil;
}

@end

@implementation NSDictionaryNonCore

+ dictionary
{
  return [[[self alloc] init] 
	  autorelease];
}

+ dictionaryWithObjects: (id*)objects 
		forKeys: (NSObject**)keys
		  count: (unsigned)count
{
  return [[[self alloc] initWithObjects:objects
			forKeys:keys
			count:count]
	  autorelease];
}

- initWithObjects: (NSArray*)objects forKeys: (NSArray*)keys
{
  int c = [objects count];
  id os[c], ks[c];
  int i;
  
  assert(c == [keys count]); /* Should be NSException instead */
  for (i = 0; i < c; i++)
    {
      os[i] = [objects objectAtIndex:i];
      ks[i] = [keys objectAtIndex:i];
    }
  return [self initWithObjects:os forKeys:ks count:c];
}

+ dictionaryWithObjectsAndKeys: (id)firstObject, ...
{
  va_list ap;
  int capacity = 16;
  int num_pairs = 0;
  id *objects;
  id *keys;
  id arg;
  int argi = 1;

  va_start (ap, firstObject);
  /* Gather all the arguments in a simple array, in preparation for
     calling the designated initializer. */
  OBJC_MALLOC (objects, id, capacity);
  OBJC_MALLOC (keys, id, capacity);
  if (firstObject != nil)
    {
      objects[num_pairs] = firstObject;
      /* Keep grabbing arguments until we get a nil... */
      while ((arg = va_arg (ap, id)))
	{
	  if (num_pairs >= capacity)
	    {
	      /* Must increase capacity in order to fit additional ARG's. */
	      capacity *= 2;
	      OBJC_REALLOC (objects, id, capacity);
	      OBJC_REALLOC (keys, id, capacity);
	    }
	  /* ...and alternately dump them into OBJECTS and KEYS */
	  if (argi++ % 2 == 0)
	    objects[num_pairs] = arg;
	  else
	    {
	      keys[num_pairs] = arg;
	      num_pairs++;
	    }
	}
      NSAssert (argi % 2 == 0, NSInvalidArgumentException);
      return [[[self alloc] initWithObjects: objects forKeys: keys
			    count: num_pairs]
	       autorelease];
    }
  /* FIRSTOBJECT was nil; just return an empty NSDictionary object. */
  return [self dictionary];
}

+ dictionaryWithObjects: (NSArray*)objects forKeys: (NSArray*)keys
{
  return [[[self alloc] initWithObjects:objects forKeys:keys]
	  autorelease];
}

/* Override superclass's designated initializer */
- init
{
  return [self initWithObjects:NULL forKeys:NULL count:0];
}

- initWithDictionary: (NSDictionary*)other
{
  int c = [other count];
  id os[c], ks[c], k, e = [other keyEnumerator];
  int i = 0;

  while ((k = [e nextObject]))
    {
      ks[i] = k;
      os[i] = [other objectForKey:k];
      i++;
    }
  return [self initWithObjects:os forKeys:ks count:c];
}

- initWithContentsOfFile: (NSString*)path
{
  NSString 	*myString;

  myString = [[NSString alloc] initWithContentsOfFile:path];
  if (myString)
    {
      id result = [myString propertyList];
      if ( [result isKindOfClass: [NSDictionary class]] )
	{
	  [self initWithDictionary: result];
	  return self;
	}
    }
  [self autorelease];
  return nil;
}

+ dictionaryWithContentsOfFile:(NSString *)path
{
  return [[[self alloc] initWithContentsOfFile:path] 
	   autorelease];
}

- (BOOL) isEqual: other
{
  if ([other isKindOfClass:[NSDictionary class]])
    return [self isEqualToDictionary:other];
  return NO;
}

- (BOOL) isEqualToDictionary: (NSDictionary*)other
{
  if ([self count] != [other count])
    return NO;
  {
    id k, e = [self keyEnumerator];
    while ((k = [e nextObject]))
      {
	id o1 = [self objectForKey: k];
	id o2 = [other objectForKey: k];
	if (![o1 isEqual: o2])
	  return NO;
	/*
      if (![[self objectForKey:k] isEqual:[other objectForKey:k]])
	return NO; */
      }
  }
  /* xxx Recheck this. */
  return YES;
}

- (NSArray*) allKeys
{
  id e = [self keyEnumerator];
  int i, c = [self count];
  id k[c];

  for (i = 0; i < c; i++)
    {
      k[i] = [e nextObject];
      assert(k[i]);
    }
  assert(![e nextObject]);
  return [[[NSArray alloc] initWithObjects:k count:c]
	  autorelease];
}

- (NSArray*) allValues
{
  id e = [self objectEnumerator];
  int i, c = [self count];
  id k[c];

  for (i = 0; i < c; i++)
    {
      k[i] = [e nextObject];
      assert(k[i]);
    }
  assert(![e nextObject]);
  return [[[NSArray alloc] initWithObjects:k count:c]
	  autorelease];
}

- (NSArray*) allKeysForObject: anObject
{
  id k, e = [self keyEnumerator];
  id a[[self count]];
  int c = 0;

  while ((k = [e nextObject]))
    if ([anObject isEqual: [self objectForKey: k]])
      a[c++] = k;
  return [[[NSArray alloc] initWithObjects: a count: c]
	  autorelease];
}

- (BOOL)writeToFile:(NSString *)path atomically:(BOOL)useAuxiliaryFile
{
  [self notImplemented:_cmd];
  return 0;
}

- copyWithZone: (NSZone*)z
{
  /* a deep copy */
  int count = [self count];
  id objects[count];
  NSObject *keys[count];
  id enumerator = [self keyEnumerator];
  id key;
  int i;

  for (i = 0; (key = [enumerator nextObject]); i++)
    {
      keys[i] = [key copyWithZone:z];
      objects[i] = [[self objectForKey:key] copyWithZone:z];
    }
  return [[[[self class] _concreteClass] alloc] 
	  initWithObjects:objects
	  forKeys:keys
	  count:count];
}

- mutableCopyWithZone: (NSZone*)z
{
  /* a shallow copy */
  return [[[[[self class] _mutableConcreteClass] _mutableConcreteClass] alloc] 
	  initWithDictionary:self];
}

@end

@implementation NSMutableDictionary

+ (void)initialize
{
  if (self == [NSMutableDictionary class])
    {
      behavior_class_add_class (self, [NSMutableDictionaryNonCore class]);
      behavior_class_add_class (self, [NSDictionaryNonCore class]);
    }
}

+ allocWithZone: (NSZone*)z
{
  return NSAllocateObject([self _mutableConcreteClass], 0, z);
}

/* This is the designated initializer */
- initWithCapacity: (unsigned)numItems
{
  [self subclassResponsibility:_cmd];
  return 0;
}

- (void) setObject:anObject forKey:(NSObject *)aKey
{
  [self subclassResponsibility:_cmd];
}

- (void) removeObjectForKey:(NSObject *)aKey
{
  [self subclassResponsibility:_cmd];
}

@end

@implementation NSMutableDictionaryNonCore

+ dictionaryWithCapacity: (unsigned)numItems
{
  return [[[self alloc] initWithCapacity:numItems]
	  autorelease];
}

/* Override superclass's designated initializer */
- initWithObjects: (id*)objects
	  forKeys: (NSObject**)keys
	    count: (unsigned)count
{
  [self initWithCapacity:count];
  while (count--)
    [self setObject:objects[count] forKey:keys[count]];
  return self;
}

- (void) removeAllObjects
{
  id k, e = [self keyEnumerator];
  while ((k = [e nextObject]))
    [self removeObjectForKey:k];
}

- (void) removeObjectsForKeys: (NSArray*)keyArray
{
  int c = [keyArray count];
  while (c--)
    [self removeObjectForKey:[keyArray objectAtIndex:c]];
}

- (void) addEntriesFromDictionary: (NSDictionary*)other
{
  id k, e = [other keyEnumerator];
  while ((k = [e nextObject]))
    [self setObject:[other objectForKey:k] forKey:k];
}


@end
