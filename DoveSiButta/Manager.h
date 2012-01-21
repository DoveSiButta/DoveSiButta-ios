//
//  Manager.h
//  ElencoServiziCoreData
//
//  Created by Giovanni Maggini on 07/09/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

extern NSString *const kManagerHasCompletedLogon;  //Esecuzione del login standard
extern NSString *const kManagerHasCompletedLogonSilent;  //WIP: Login "in background" quando utente non deve essere informato del login
extern NSString *const KManagerHasFinishedLoadingData;
extern NSString *const KManagerHasFinishedLoadingListOfDocumentsForClass; //Lista di documenti per una classe doc
extern NSString *const kManagerHasFinishedLoadingDocumentDetails; //profilo del documento, allegati, workflow
extern NSString *const kManagerHasFinishedGettingDocumentFile; //file fisico del documento
extern NSString *const kManagerHasFinishedLoadingUserTasks; //carico i task per utente
extern NSString *const kManagerHasFinishedSearching; //eseguo la ricerca dalla tab Ricerca
extern NSString *const kManagerHasFinishedLoadingRubricaCategories; //elenco categorie Rubrica
extern NSString *const kManagerHasFinishedSearchingRubrica; //Ricerca nella rubrica
//extern NSString *const kManagerHasFinishedLoadingFolder; //Caricamento fascicoli
extern NSString *const kManagerHasFinishedLoadingTaskVariables; //caricamento var task
extern NSString *const kManagerHasFinishedLoadingTaskActions; //caricamento esiti task


#import <Foundation/Foundation.h>

@class ARXService;

//Core Data Entities
@class Site;
@class Document;

//Non Core Data Entities
@class NCDDocument;

@interface Manager : NSObject <NSFetchedResultsControllerDelegate>
{

    //variabili per il servizio
    BOOL isLoggedIn;
    Site *site;
    ARXService *service;
    
    NSArray *ArrayDocTypes;
    
    //Core Data
    NSFetchedResultsController *fetchedResultsController;
    NSManagedObjectContext *managedObjectContext;	   
    
}

@property (nonatomic) BOOL isLoggedIn;
@property (nonatomic, retain) Site *site;
@property (nonatomic, retain) ARXService *service;

@property (nonatomic, retain) NSArray *ArrayDocTypes;
@property (nonatomic, retain) NSArray *ArrayDocsList;
@property (nonatomic, retain) NSMutableArray *ArrayUserTasks;
@property (nonatomic, retain) NSArray *ArraySearchResults;
@property (nonatomic, retain) NSMutableArray *ArrayRubricaCategories;
@property (nonatomic, retain) NSMutableArray *ArrayRubricaSearchResults;
@property (nonatomic, retain) NSMutableArray *ArrayFolderItems;
@property (nonatomic, retain) NSString * currentFolder;


//Core Data
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

+(Manager *) sharedManager;
+(Manager *) sharedManagerWithUsername:(NSString*)username andPassword:(NSString*)password andUrl:(NSString*)url;

//Getters
- (NSString*) getCurrentAOO;

-(void) Logon;
-(void) LoadAllUsersForSite;
-(void) LoadAllStatesForSite;
-(void) ListAllDocTypes;
-(void) ListDocumentsForClass:(NSArray*) DocTypes;
-(void) LoadDocumentDetailsForProfile:(NSNumber*) Docnumber;
-(void) DownloadDocumentById:(NSNumber*)Docnumber;
-(void) CancelCurrentConnection;
-(void) LoadTasksForCurrentUser;
-(void) LoadVariablesForTask:(NSInteger) taskNumber;
-(void) LoadOutcomesForTask:(NSInteger) taskNumber;
-(void) SetTaskOutcome:(NSInteger)esitoTask ForTask:(NSInteger) taskNumber;
-(void) SearchForDocumentsWithSearchParameters:(NSArray*)searchParameters ReturnParameters:(NSArray*)returnParameters;
-(void) ListRubricaCategories;
-(void) ListRubricaContactsForCategory:(NSNumber*)categoryID;
-(void) SearchRubricaWithString:(NSString*)searchString andScope:(NSString*)searchScope;
-(NSString*)FileIconForFileName:(NSString*)fileName;
-(void) ListFoldersForPath:(NSString*)path paramsArray:(NSArray*)params withNotification:(NSString*)notificationName;

@end
