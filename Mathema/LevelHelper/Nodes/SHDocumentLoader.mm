//  This file was generated by LevelHelper
//  http://www.levelhelper.org
//
//  LevelHelperLoader.mm
//  Created by Bogdan Vladu
//  Copyright 2011 Bogdan Vladu. All rights reserved.
////////////////////////////////////////////////////////////////////////////////
//
//  This software is provided 'as-is', without any express or implied
//  warranty.  In no event will the authors be held liable for any damages
//  arising from the use of this software.
//  Permission is granted to anyone to use this software for any purpose,
//  including commercial applications, and to alter it and redistribute it
//  freely, subject to the following restrictions:
//  The origin of this software must not be misrepresented; you must not
//  claim that you wrote the original software. If you use this software
//  in a product, an acknowledgment in the product documentation would be
//  appreciated but is not required.
//  Altered source versions must be plainly marked as such, and must not be
//  misrepresented as being the original software.
//  This notice may not be removed or altered from any source distribution.
//  By "software" the author refers to this code file and not the application 
//  that was used to generate this file.
//
////////////////////////////////////////////////////////////////////////////////

#import "SHDocumentLoader.h"
#import "LevelHelperLoader.h"

//------------------------------------------------------------------------------
@interface SHSceneNode : NSObject {
    NSMutableDictionary* sheets; //key sheetName - object NSDictionary
    NSMutableDictionary* animations; //key animName - object NSDictionary
}
+(id)SHSceneNodeWithContentOfFile:(NSString*)sceneFile;// sheetName:(NSString*)sheetName;
-(NSDictionary*)infoForSpriteNamed:(NSString*)name inSheetNamed:(NSString*)sheetName;
-(NSDictionary*)infoForSheetNamed:(NSString*)sheetName;
-(NSDictionary*)infoForAnimationNamed:(NSString*)animName;
@end
//------------------------------------------------------------------------------
@implementation SHSceneNode

-(void)dealloc{
#ifndef LH_ARC_ENABLED
	[sheets release];
    [animations release];
	[super dealloc];
#endif
}
//------------------------------------------------------------------------------
-(id)initWithContentOfFile:(NSString*)sceneFile{// sheetName:(NSString*)sheetName{

    NSString *path = [[NSBundle mainBundle] pathForResource:[sceneFile stringByDeletingPathExtension] ofType:@"pshs" inDirectory:nil]; 
	    
    if(nil == path)
    {
        NSString* errorMessage = [NSString stringWithFormat:@"SpriteHelper document \"%@\" could not be found. Please add it to the resource folder.", sceneFile];
        NSLog(@"%@",errorMessage);
        NSAssert(nil!=path, @"");
    }
    
    self = [super init];
	if (self != nil) {
        sheets = [[NSMutableDictionary alloc] init];
        animations = [[NSMutableDictionary alloc] init];
        
        NSDictionary *dictionary = [NSDictionary dictionaryWithContentsOfFile:path];

        NSArray* sheetsList = [dictionary objectForKey:@"SHEETS_INFO"];
        
        for(NSDictionary* dic in sheetsList){
            [sheets setObject:dic forKey:[dic objectForKey:@"SheetName"]];
        }
        
        NSArray* animList = [dictionary objectForKey:@"SH_ANIMATIONS_LIST"];
        
        for(NSDictionary* dic in animList){
            [animations setObject:dic forKey:[dic objectForKey:@"UniqueName"]];
        }
	}
	return self;
}
//------------------------------------------------------------------------------
+(id)SHSceneNodeWithContentOfFile:(NSString*)sceneFile{// sheetName:(NSString*)sheetName{
    #ifndef LH_ARC_ENABLED
    return [[[SHSceneNode alloc] initWithContentOfFile:sceneFile/* sheetName:sheetName*/] autorelease];
    #else
    return [[SHSceneNode alloc] initWithContentOfFile:sceneFile/* sheetName:sheetName*/];
    #endif  
}
//------------------------------------------------------------------------------
-(NSDictionary*)infoForSpriteNamed:(NSString*)name inSheetNamed:(NSString*)sheetName{
    NSDictionary* sheetsInfo = [sheets objectForKey:sheetName];
    
    if(sheetsInfo){
        
        NSDictionary* spritesInfo = [sheetsInfo objectForKey:@"Sheet_Sprites_Info"];
        NSDictionary* sprInfo = [spritesInfo objectForKey:name];
        
        if(sprInfo)
            return sprInfo;
        
        NSLog(@"Info for sprite named %@ could not be found in sheet named %@", name, sheetName);
        return nil;
    }
    NSLog(@"Could not find sheet named %@", sheetName);
        
    return nil;
}
//------------------------------------------------------------------------------
-(NSDictionary*)infoForSheetNamed:(NSString*)sheetName{
    return [sheets objectForKey:sheetName];
}
//------------------------------------------------------------------------------
-(NSDictionary*)infoForAnimationNamed:(NSString*)animName{
    return [animations objectForKey:animName];    
}
//------------------------------------------------------------------------------
@end
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
@implementation SHDocumentLoader
+ (SHDocumentLoader*)sharedInstance{
	static id sharedInstance = nil;
	if (sharedInstance == nil){
		sharedInstance = [[SHDocumentLoader alloc] init];
	}
    return sharedInstance;
}
//------------------------------------------------------------------------------
-(void)dealloc
{
#ifndef LH_ARC_ENABLED
	[scenes release];
	[super dealloc];
#endif
}
//------------------------------------------------------------------------------
- (id)init
{
	self = [super init];
	if (self != nil) {
        scenes = [[NSMutableDictionary alloc] init];
	}
	return self;
}
//------------------------------------------------------------------------------
-(SHSceneNode*)sceneNodeForSHDocument:(NSString*)shDocument
{
    //will create the node if it does not exit
    SHSceneNode* sceneNode = [scenes objectForKey:shDocument];
    
    if(sceneNode == nil){
        sceneNode = [SHSceneNode SHSceneNodeWithContentOfFile:shDocument/* sheetName:sheetName*/];
        [scenes setObject:sceneNode forKey:shDocument];
    }
    return sceneNode;
}
//------------------------------------------------------------------------------
-(NSDictionary*)dictionaryForSpriteNamed:(NSString*)spriteName 
                            inSheetNamed:(NSString*)sheetName
                              inDocument:(NSString*)spriteHelperDocument
{
    SHSceneNode* shNode = [self sceneNodeForSHDocument:spriteHelperDocument/* andSheetName:sheetName*/];
    if(nil != shNode)
    {
        NSDictionary* info = [shNode infoForSpriteNamed:spriteName inSheetNamed:sheetName];
        if(info){
            return info;
        }
        else {
            NSLog(@"Could not find info for sprite named %@ in sheet name %@ in document name %@", spriteName, sheetName, spriteHelperDocument);
        }
    }
    
    return nil;
}
//------------------------------------------------------------------------------
-(NSDictionary*)dictionaryForSheetNamed:(NSString*)sheetName
                             inDocument:(NSString*)spriteHelperDocument{
    SHSceneNode* shNode = [self sceneNodeForSHDocument:spriteHelperDocument/* andSheetName:sheetName*/];
    if(nil != shNode)
    {
        NSDictionary* info = [shNode infoForSheetNamed:sheetName];
        if(info){
            return info;
        }
        else {
            NSLog(@"Could not find info for sheet named %@ in document name %@", sheetName, spriteHelperDocument);
        }
    }
    
    return nil;
}

-(NSDictionary*)dictionaryForAnimationNamed:(NSString*)animName
                                 inDocument:(NSString*)spriteHelperDocument
{
    SHSceneNode* shNode = [self sceneNodeForSHDocument:spriteHelperDocument/* andSheetName:sheetName*/];
    if(nil != shNode)
    {
        NSDictionary* info = [shNode infoForAnimationNamed:animName];
        if(info){
            return info;
        }
        else {
            NSLog(@"Could not find info for animation named %@ in document name %@", animName, spriteHelperDocument);
        }
    }
    
    return nil;
    
}


@end