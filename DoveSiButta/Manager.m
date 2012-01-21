    		//
//  Manager.m
//  ElencoServiziCoreData
//
//  Created by Giovanni Maggini on 07/09/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//




//
//  <string xmlns="http://arxivar.it/"><PROFILE> <DOCUMENT> <DOCNUMBER>12345</DOCNUMBER> <MITTENTE>BENELLI ARMI S.P.A. </MITTENTE> <DESTINATARIO>INDUSTRIAL SERVICE SRL </DESTINATARIO> <CC>BENELLI\luisella</CC> <DATADOC>2011-05-13T00:00:00+02:00</DATADOC> <DATAPROFILO>2011-05-13T15:10:33+02:00</DATAPROFILO> <OGGETTO>Ordine Acquisto n. 11904504 del 13/05/11</OGGETTO> <TIPO1>3</TIPO1> <TIPO2>8</TIPO2> <TIPO3>10</TIPO3> <STATO>Autorizzato</STATO> <ORIGINE>0</ORIGINE> <NUMERO>11/330</NUMERO> <IMPORTANTE>NO</IMPORTANTE> <REVISIONE>0</REVISIONE> <AUTORE>2</AUTORE> <NOMEFILE>ORDACQ201105131029420(0000001).pdf</NOMEFILE> <AOO>BENELLI</AOO> <RISPOSTA>NESSUNA</RISPOSTA> <WEBVISIBLE>1</WEBVISIBLE> <WORKFLOW>2</WORKFLOW> <COMBO38_3>EUR</COMBO38_3> <NUMERIC36_3>62.00</NUMERIC36_3> <TABLE34_3>286254</TABLE34_3> <TESTO35_3 /> <TABLE27_2>41360</TABLE27_2> <TESTO28_2>UFFICIO ACQUISTI</TESTO28_2> <NUMERIC37_6>11904504</NUMERIC37_6> </DOCUMENT> </PROFILE></string> 
//DOCNUMBER
//MITTENTE
//DESTINATARIO
//CC
//DATADOC
//DATAPROFILO
//OGGETTO
//NUMERO
//IMPORTANTE
//REVISIONE
//AUTORE
//NOMEFILE
//AOO
//RISPOSTA
//WEBVISIBLE
//WORKFLOW

#import <CoreData/CoreData.h>
#import "Manager.h"
#import "SynthesizeSingleton.h"
#import "ARXService.h"
#import "XPathQuery.h"
//Per i file in base64
#import "NSData+Base64.h"


//Core Data entities
#import "Site.h"
#import "Document.h"


//Non Core Data Entities
#import "NCDDocument.h"
#import "NCDTaskListItem.h"
#import "NCDRubricaCategory.h"
#import "NCDRubricaContact.h"
#import "NCDFolderItem.h"
#import "NCDTaskOutcome.h"
#import "NCDTaskVariable.h"

//#define DOCNUMBER   DOCNUMBER
//#define MITTENTE    MITTENTE
//#define DESTINATARIO DESTINATARIO
//#define CC          CC
//#define DATADOC     DATADOC
//#define DATAPROFILO DATAPROFILO
//#define OGGETTO     OGGETTO
//#define NUMERO      NUMERO
//#define IMPORTANTE  IMPORTANTE
//#define REVISIONE   REVISIONE
//#define AUTORE      AUTORE
//#define NOMEFILE    NOMEFILE
//#define AOO         AOO
//#define RISPOSTA    RISPOSTA
//#define WEBVISIBLE  WEBVISIBLE
//#define WORKFLOW    WORKFLOW


@implementation Manager
@synthesize isLoggedIn;
@synthesize site, service;
@synthesize ArrayDocTypes;
@synthesize ArrayDocsList;
@synthesize ArrayUserTasks;
@synthesize ArraySearchResults;
@synthesize ArrayRubricaCategories;
@synthesize ArrayRubricaSearchResults;
@synthesize ArrayFolderItems;
@synthesize currentFolder;


//Core Data
@synthesize fetchedResultsController =__fetchedResultsController;
@synthesize managedObjectContext =__managedObjectContext;

SYNTHESIZE_SINGLETON_FOR_CLASS(Manager)


NSString *const kManagerHasCompletedLogon = @"LogonComplete";
NSString *const kManagerHasCompletedLogonSilent = @"LogonCompleteSilent";
NSString *const KManagerHasFinishedLoadingData = @"DataLoadingComplete";
NSString *const KManagerHasFinishedLoadingListOfDocumentsForClass = @"FinishedLoadingListOfDocumentsForClass";
//NSString *const kLocationKey = @"Location";
NSString *const kManagerHasFinishedLoadingDocumentDetails = @"FinishedLoadingDocumentDetails";
NSString *const kManagerHasFinishedGettingDocumentFile = @"FinishedGettingDocumentFile";
NSString *const kManagerHasFinishedLoadingUserTasks = @"FinishedLoadingUserTasks";
NSString *const kManagerHasFinishedSearching = @"FinishedSearching";
NSString *const kManagerHasFinishedLoadingRubricaCategories = @"FinishedLoadingRubricaCategories";
NSString *const kManagerHasFinishedSearchingRubrica = @"FinishedSearchingRubrica";
//NSString *const kManagerHasFinishedLoadingFolder = @"FinishedLoadingFolder"; //Ogni folder ha la sua notifica
NSString *const kManagerHasFinishedLoadingTaskVariables = @"FinishedLoadingTaskVariables";
NSString *const kManagerHasFinishedLoadingTaskActions = @"FinishedLoadingTaskActions";


#pragma mark - Initializations


- (id)init
{
    self = [super init];
    if (self) {
        self.isLoggedIn = NO;
//        service = [ARXService service];
        self.service = [[ARXService alloc] init];
#if DEBUG
        self.service.logging = YES;
#endif
        
        ArrayDocTypes = [[NSArray alloc] init];
        // Initialization code here.
    }
    
    return self;
}


+(Manager*) sharedManagerWithUsername:(NSString *)username andPassword:(NSString *)password andUrl:(NSString *)url
{
    return [[self alloc] init ];
}


#pragma mark - Getters

- (BOOL) managerIsLoggedIn
{
    return self.isLoggedIn;
}

#pragma mark - KVO Observers

-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if(object == self && [keyPath isEqualToString:@"isLoggedIn"])                       
    {   
//        NSLog(@"isLoggedIn Changed %@ \n %@ \n %@ \n ",keyPath,object,change);
        [self removeObserver:self forKeyPath:@"isLoggedIn"];
        [self ListAllDocTypes];
        
    }

}

#pragma mark - Useful Getters

- (NSString*) getCurrentAOO
{
    return site.AOO;
}

#pragma mark - Support



-(void) LoadAllUsersForSite
{
    // Returns NSString*. Funzione che permette l'estrazione di tutti gli utenti di arxivar.Parametro di output: (string) XML informazioni degl'utenti
	[service GetAllUsers:self action:@selector(GetAllUsersHandler:)];

}

-(void) LoadAllStatesForSite
{
    // Returns NSString*. Funzione che permette l'estrazione degli Stati.Parametro di output: (string) XML che contiene l'elenco degli Stati
	[service GetAllState:self action:@selector(GetAllStateHandler:)];
}

-(void) CancelCurrentConnection
{
    [ARXService cancelPreviousPerformRequestsWithTarget:self];
    //TODO: da implementare
}

-(NSString*)FileIconForFileName:(NSString*)fileName
{
    NSString *ext = [[fileName componentsSeparatedByString:@"."] lastObject]; //[fileName lastPathComponent];
    NSString *icon;
    NSLog(@"ext: %@",ext);
    if([ext caseInsensitiveCompare:@"pdf"])
    {
        icon = [NSString stringWithString: @"pdf"];
    }
    else if ([ext caseInsensitiveCompare:@"doc"] || [ext caseInsensitiveCompare:@"docx"] || [ext caseInsensitiveCompare:@"rtf"] || [ext caseInsensitiveCompare:@"txt"])
    {
        icon = [NSString stringWithString: @"doc_rtf"];
    }
    else if([ext caseInsensitiveCompare:@"gif"] || [ext caseInsensitiveCompare:@"psd"]|| [ext caseInsensitiveCompare:@"png"] || [ext caseInsensitiveCompare:@"jpeg"] || [ext caseInsensitiveCompare:@"jpg"])
    {
        icon = [NSString stringWithString: @"psd"];
    }
    else if ([ext caseInsensitiveCompare:@"xls"] || [ext caseInsensitiveCompare:@"xlsx"] )
    {
        icon = [NSString stringWithString: @"xls"];
    }
    else if ([ext caseInsensitiveCompare:@"ppt"] || [ext caseInsensitiveCompare:@"pptx"] )
    {
        icon = [NSString stringWithString: @"ppt"];
    }
    else if ([ext caseInsensitiveCompare:@"htm"] || [ext caseInsensitiveCompare:@"html"] )
    {
        icon = [NSString stringWithString: @"html"];
    }
    else if ([ext caseInsensitiveCompare:@"eml"] || [ext caseInsensitiveCompare:@"emlx"] )
    {
        icon = [NSString stringWithString: @"outlook"];
    }
    else if ([ext caseInsensitiveCompare:@"zip"] || [ext caseInsensitiveCompare:@"rar"] || [ext caseInsensitiveCompare:@"7z"])
    {
        icon = [NSString stringWithString: @"zip"];
    }
    else if ([ext caseInsensitiveCompare:@"avi"] || [ext caseInsensitiveCompare:@"mpg"] || [ext caseInsensitiveCompare:@"mov"])
    {
        icon = [NSString stringWithString: @"avi"];
    }
    else
    {
        icon = [NSString stringWithString: @"default_file"];
    }
    return icon;
}

//Passare un array di NSdictionary che contiene 1-i parametri 2-gli operatori 3- i valori
-(NSString*) MakeSearchStringWithSearchParameters:(NSArray*)searchParameters ReturnParameters:(NSArray*)returnParameters
{
    NSString *searchString = @"<?xml version='1.0' encoding='utf-8'?><RICERCA>";
    for(NSDictionary* searchItem in searchParameters)
    {
        searchString = [searchString stringByAppendingFormat:@"<PARAMSEARCH><NAME>%@</NAME><OPERATOR>LIKE</OPERATOR><VALUE>%@</VALUE></PARAMSEARCH>",[searchItem objectForKey:@"searchName"],[searchItem objectForKey:@"searchValue"]];
        
    }
    
    for(NSDictionary* returnItem in returnParameters)
    {
        searchString =[searchString stringByAppendingFormat:@"<RETURNPARAM>%@</RETURNPARAM>",[returnItem objectForKey:@"returnName"]];
    }
    searchString = [searchString stringByAppendingString:@"</RICERCA>"];

#if DEBUG
    NSLog(@"SearchString: %@",searchString);
#endif
    searchString = [[searchString stringByReplacingOccurrencesOfString:@"<" withString:@"&lt;"] stringByReplacingOccurrencesOfString:@">" withString:@"&gt;"];
    
    return searchString;
    
    //@"<RICERCA><PARAMSEARCH><NAME>DOCNAME</NAME><OPERATOR>LIKE</OPERATOR><VALUE>RDA</VALUE></PARAMSEARCH><RETURNPARAM>DOCNUMBER</RETURNPARAM></RICERCA>";
}

//Passare l'array di classi
-(NSString*) MakeDocsListSearchString:(NSArray*)DocTypes
{
    NSString* searchString = [[NSString alloc] initWithString:@""];
    [searchString retain];
    searchString =   [searchString stringByAppendingString:@"<?xml version='1.0' encoding='utf-8'?><RICERCA>"];    
//    searchString =   [searchString stringByAppendingString:@"<SEARCHPARAMS>"];
    
    for (int i = 0; i<[DocTypes count]; i++) {
        searchString = [searchString stringByAppendingFormat:@"<PARAMSEARCH><NAME>TYPE%d</NAME><OPERATOR>=</OPERATOR><VALUE>%@</VALUE></PARAMSEARCH>",i+1,[DocTypes objectAtIndex:i]];
    }
    
//    searchString = [searchString stringByAppendingString:@"</SEARCHPARAMS>"];
    searchString = [searchString stringByAppendingString:@"<RETURNPARAM>DOCNUMBER</RETURNPARAM><RETURNPARAM>DOCNAME</RETURNPARAM>"];
    searchString = [searchString stringByAppendingString:@"</RICERCA>"];
#if DEBUG
    NSLog(@"SearchString: %@",searchString);
#endif
    searchString = [[searchString stringByReplacingOccurrencesOfString:@"<" withString:@"&lt;"] stringByReplacingOccurrencesOfString:@">" withString:@"&gt;"];
    return searchString;
}

//Ricerca con più parametri //Sostituire con quella sopra
//-(NSString*) MakeSearchStringForParameters:(NSArray*)searchParameters Operators:(NSArray*)operators Values:(NSArray*)values
//{
//    return @"<RICERCA></RICERCA>";
//}

//Effettua una ricerca di documenti per singolo parametro
-(NSString*) MakeDefaultSearchStringForParameter:(NSString*)searchParameter Operator:(NSString*)operator Value:(NSString*)value
{   
    //TODO implementare
    return [[[NSString stringWithFormat:@"<?xml version='1.0' encoding='utf-8'?><RICERCA><PARAMSEARCH><NAME>%@</NAME><OPERATOR>%@</OPERATOR><VALUE>%@</VALUE></PARAMSEARCH><RETURNPARAM>DOCNUMBER</RETURNPARAM><RETURNPARAM>DOCNAME</RETURNPARAM></RICERCA>",searchParameter,operator,value] stringByReplacingOccurrencesOfString:@"<" withString:@"&lt;"] stringByReplacingOccurrencesOfString:@">" withString:@"&gt;"];
}


#pragma mark Rubrica Actions

-(void) ListRubricaCategories
{
    NSLog(@"Carico categorie rubrica");
    [service RubricaCategories:self action:@selector(RubricaCategoriesHandler:) UserId:[site.siteID integerValue]];
}

-(void) ListRubricaContactsForCategory:(NSNumber*)categoryID
{
    //!!! Arxivar non supporta la ricerca per categoria. 
}

-(void) SearchRubricaWithString:(NSString*)searchString andScope:(NSString*)searchScope
{
    
    if([searchScope localizedCompare:@"Name"])
    {
        // Returns NSString*. Funzione che esegue la ricerca di un elemento in rubrica.Parametro di input: (string) testo da ricercare, (string) operatore di ricerca, (int) Identificativo Utente.Parametro di output: (string) XML che contiene l'elenco dei contatti trovati
        [service RubricaSearch:self action:@selector(RubricaSearchHandler:) textSearch: [NSString stringWithFormat:@"%%%@%%", searchString]  operatorSearch: @"LIKE" UserId: [site.siteID integerValue]];
    }
    else
    {
        // Returns NSString*. Funzione che esegue la ricerca di un elemento in rubrica in base al parametro passato.Parametro di input: (enum) campo da ricercare, (string) valore di ricerca, (int) Identificativo Utente.Parametro di output: (string) XML che contiene l'elenco dei contatti trovati
        [service RubricaSearchByField:self action:@selector(RubricaSearchByFieldHandler:) nameToSearch: searchScope valueToSearch: [NSString stringWithFormat:@"%%%@%%", searchString] UserId: [site.siteID integerValue]];
    }
    
}

#pragma mark Folders Actions

-(void) ListFoldersForPath:(NSString*)path paramsArray:(NSArray*)params withNotification:(NSString*)notificationName
{
    
    //Ogni param = NSDictionary con @"NAME", @"OPERATOR", @"VALUE"
/*    
    <RICERCA> <ISSUEPATH>Pubblici\Acquisti\Richieste di Acquisto non-MRP\2011</ISSUEPATH> <PARAMSEARCH>   <NAME>AOO</NAME>   <OPERATOR>=</OPERATOR>   <VALUE>BENELLI</VALUE> </PARAMSEARCH> </RICERCA>
  */  
    
    self.currentFolder = path;
    
    NSString *searchString = [NSString stringWithString:@"<RICERCA>"];
    searchString = [searchString stringByAppendingFormat:@"<ISSUEPATH>%@</ISSUEPATH>",path];
    for(NSDictionary *paramdict in params)
    {
        searchString = [searchString stringByAppendingFormat:@"<PARAMSEARCH>"];
        searchString = [searchString stringByAppendingFormat:@"<NAME>%@</NAME>",[paramdict objectForKey:@"NAME"]];
        searchString = [searchString stringByAppendingFormat:@"<OPERATOR>%@</OPERATOR>",[paramdict objectForKey:@"OPERATOR"]];
        searchString = [searchString stringByAppendingFormat:@"<VALUE>%@</VALUE>",[paramdict objectForKey:@"VALUE"]];
        searchString = [searchString stringByAppendingFormat:@"</PARAMSEARCH>"];
    }
    searchString = [searchString stringByAppendingString:@"</RICERCA>"];
    searchString = [[searchString stringByReplacingOccurrencesOfString:@"<" withString:@"&lt;"] stringByReplacingOccurrencesOfString:@">" withString:@"&gt;"];
    
    
    // Returns NSString*. Funzione che esegue la ricerca del fascicolo.Parametro di input: (string) XML contentente l'informazione di ricerca, (int) Identificativo Utente, (bool) caricamento dei profili.Parametro di output: (string) XML che contiene l'elenco dei documenti
	[service IssueSearch:self action:@selector(IssueSearchHandler:) XMLinfo: searchString UserId: [site.siteID integerValue] AllInformation: YES];
    
}


#pragma mark Tasks Actions

-(void) LoadTasksForCurrentUser
{
	// Returns NSString*. Estrazione dei tasks assegnati all'utente. Parametro di input: (inteto)identificativo dell'utente. Parametro di output: (string) XML che contiene le informazioni richieste.
    NSLog(@"Carico i task per utente %@", site.siteID);
	[service LoadUserTasks:self action:@selector(LoadUserTasksHandler:) UserId: [site.siteID integerValue]];
}

-(void) LoadVariablesForTask:(NSInteger) taskNumber
{
    
	// Returns NSString*. Estrazione delle variabili di un processo. Parametro di input: (inteto)identificativo task, (int) identificativo utente. Parametro di output: (string) XML che contiene le informazioni richieste.
	[service TaskVariablesGet:self action:@selector(TaskVariablesGetHandler:) TaskId: taskNumber UserId: [self.site.siteID integerValue]];

}

-(void) LoadOutcomesForTask:(NSInteger) taskNumber
{
    // Returns NSString*. Estrazione esiti conclusivi di un task. Parametro di input: (inteto)identificativo task. Parametro di output: (string) XML che contiene le informazioni richieste.
	[service GetActionsTask:self action:@selector(GetActionsTaskHandler:) TaskId: taskNumber];
}


-(void) SetTaskOutcome:(NSInteger)esitoTask ForTask:(NSInteger)taskNumber
{
    
}


#pragma mark Document Actions


-(void) GetAttachmentListForDocnumber:(NSInteger) docNumber
{
    // Returns NSString*. Funzione che permette l'estrazione degli allegati di un documento. Parametro di input: (int) identificativo documento. Parametri di output: (string) XML che contiene gli allegati estratti.
	[service GetAttachedByDocument:self action:@selector(GetAttachedByDocumentHandler:) DocumentId: docNumber];
}


-(void) StartWorkflow:(NSInteger)workflowNumber ForDocument:(NSInteger)docnumber
{
    // Returns NSString*. Funzione che permette l'avvio di un workflow. Parametri di input: (intero) identificativo documento, (intero) identificativo processi, (intero) identificativo utente. Parametro di output: (string) XML che contiene codice e descrizione dell'esito
	[service RunWorkflowDocument:self action:@selector(RunWorkflowDocumentHandler:) DocumentId:docnumber ProcessId:workflowNumber  UserId:[site.siteID integerValue]];
    //!!! Non implementata
}


-(void) SearchForDocumentsWithSearchParameters:(NSArray*)searchParameters ReturnParameters:(NSArray*)returnParameters
{
#if DEBUG
    NSLog(@"SearchForDocuments");
#endif
    [service RunRicerca:self action:@selector(RunRicercaWithParametersHandler:) XMLinfo: [self MakeSearchStringWithSearchParameters:searchParameters ReturnParameters:returnParameters] UserId:[site.siteID integerValue]];
}

-(void) DownloadDocumentById:(NSNumber*)Docnumber
{

// Returns NSString*. Funzione che permette l'estrazione del file fisico associato al documento in base al suo identificativo. Parametro di input: (int) identificativo documento. Parametri di output: (string) XML che contiene le informazioni del profilo, Byte[] che contiene lo stream del file.
[service GetFileProfileByDocumentId:self action:@selector(GetFileProfileByDocumentIdHandler:) DocumentId: [Docnumber integerValue]];

    
// Returns NSString*. Funzione che permette l'estrazione dell'informazione di un documento in base al suo identificativo. Parametro di input: (int) identificativo documento. Parametri di output: (string) XML che contiene le informazioni del profilo, Byte[] che contiene lo stream del file.
//[service GetInformationProfileByDocumentId:self action:@selector(GetInformationProfileByDocumentIdHandler:) DocumentId: [Docnumber integerValue]];

}


-(void) LoadDocumentDetailsForProfile:(NSNumber*) Docnumber
{
    // Returns NSString*. Funzione che permette l'estrazione dell'informazione di un documento in base al suo identificativo esterno. Parametro di input: (string) identificativo documento esterno. Parametri di output: (string) XML che contiene le informazioni del profilo
	[service GetProfileById:self action:@selector(GetProfileByIdHandler:) DocumentId: [Docnumber integerValue] ];
}


//Elenca i documenti per una classe documentale (e sottoclassi)
-(void) ListDocumentsForClass:(NSArray *)DocTypes 
{
    if(self.isLoggedIn == YES){
#if DEBUG
        NSLog(@"ListDocumentsForClass %@", DocTypes);
#endif
        [service RunRicerca:self action:@selector(RunRicercaHandler:) XMLinfo: [self MakeDocsListSearchString:DocTypes] UserId:[site.siteID integerValue]];
    }
    else
    {
#if DEBUG
        NSLog(@"ListDocumentsForClass ma Login non eseguito: aggiungo Observer");
#endif
        [self addObserver:self forKeyPath:@"isLoggedIn" options:0 context:nil];
    }

    
}

-(void) ListAllDocTypes
{

    // Returns NSString*. Funzione che permette l'estrazione delle Classi Documentali per la ricerca.Parametro di input:(string) Codice Area Organizzativa, (int) Identificativo Utente.Parametro di output: (string) XML che contiene l'elenco delle Classi
    if(self.isLoggedIn == YES){
#if DEBUG
        NSLog(@"ListAllDocTypes");
#endif
    [service GetClassesToSearch:self action:@selector(GetClassesToSearchHandler:) CodeAoo: site.AOO UserId: [site.siteID integerValue]];
    }
    else
    {
#if DEBUG
        NSLog(@"ListAllDocTypes ma Login non eseguito: aggiungo Observer");
#endif
        [self addObserver:self forKeyPath:@"isLoggedIn" options:0 context:nil];
    }
}

-(void) Logon
{
   // [self.service initWithUsername:site.username andPassword:site.password andUrl:site.url];
//    service.serviceUrl = site.url;
    service.serviceUrl = site.url;
    [service retain];
#if DEBUG
    NSLog(@"username %@",site.username);
    NSLog(@"password %@",site.password);
    NSLog(@"AOO %@",site.AOO);
    NSLog(@"Site url %@",site.url);
    NSLog(@"Service url %@",service.serviceUrl);
#endif
    [service AuthorizedUser:self action:@selector(AuthorizedUserHandler:) UserName:site.username Password:site.password BusinessUnit:site.AOO];

}


#pragma mark - Support Handlers


// Handle the response from GetAllState.

- (void) GetAllStateHandler: (id) value {
    
	// Handle errors
	if([value isKindOfClass:[NSError class]]) {
		NSLog(@"%@", value);
		return;
	}
    
	// Handle faults
	if([value isKindOfClass:[SoapFault class]]) {
		NSLog(@"%@", value);
		return;
	}				
    
    
	// Do something with the NSString* result
    NSString* result = (NSString*)value;
	NSLog(@"GetAllState returned the value: %@", result);
    
    //TODO: finire di implementarla, caricare gli stati in un array di Stati
}


// Handle the response from GetAllUsers.

- (void) GetAllUsersHandler: (id) value {
    
	// Handle errors
	if([value isKindOfClass:[NSError class]]) {
		NSLog(@"%@", value);
		return;
	}
    
	// Handle faults
	if([value isKindOfClass:[SoapFault class]]) {
		NSLog(@"%@", value);
		return;
	}				
    
    
	// Do something with the NSString* result
    NSString* result = (NSString*)value;
	NSLog(@"GetAllUsers returned the value: %@", result);
    
    //TODO: finire di implementarla, caricare gli stati in un array di utenti (per assegnare utente a documento)
}


#pragma mark - Rubrica Handlers

// Handle the response from RubricaSearch.

- (void) RubricaSearchHandler: (id) value {
//    <RICERCA> <RUBRICA> <NAME>SIGECON S.R.L.</NAME> <IDRUBRICA>14494</IDRUBRICA> <IDCONTACT>0</IDCONTACT> </RUBRICA> </RICERCA>
    
	// Handle errors
	if([value isKindOfClass:[NSError class]]) {
		NSLog(@"%@", value);
            [[NSNotificationCenter defaultCenter] postNotificationName:kManagerHasFinishedSearchingRubrica object:self userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:0], @"Result", 0, @"ResultsCount", nil]];
		return;
	}
    
	// Handle faults
	if([value isKindOfClass:[SoapFault class]]) {
		NSLog(@"%@", value);
            [[NSNotificationCenter defaultCenter] postNotificationName:kManagerHasFinishedSearchingRubrica object:self userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:0], @"Result", 0, @"ResultsCount", nil]];
		return;
	}				
    
    
	// Do something with the NSString* result
    NSString* result = (NSString*)value;
	NSLog(@"RubricaSearch returned the value: %@", result);
    
    [ArrayRubricaSearchResults removeAllObjects];
    ArrayRubricaSearchResults = [[NSMutableArray alloc] init];
    NSData *resultData = [result dataUsingEncoding:NSUTF8StringEncoding];
    NSArray *resultArray = PerformXMLXPathQuery(resultData, @"//RUBRICA");
    if([resultArray count] > 0)
    {
        for(NSDictionary *node in resultArray)
        {
            NCDRubricaContact *contact = [[NCDRubricaContact alloc] init];
            NSLog(@"%@",[[[node objectForKey:@"nodeChildArray"] objectAtIndex:0] objectForKey:@"nodeContent"]);
            contact.name = [[[node objectForKey:@"nodeChildArray"] objectAtIndex:0] objectForKey:@"nodeContent"];
            NSLog(@"%@",[[[node objectForKey:@"nodeChildArray"] objectAtIndex:1] objectForKey:@"nodeContent"]);
            contact.idrubrica = [NSNumber numberWithInt:[[[[node objectForKey:@"nodeChildArray"] objectAtIndex:1] objectForKey:@"nodeContent"] integerValue]];
            NSLog(@"%@",[[[node objectForKey:@"nodeChildArray"] objectAtIndex:2] objectForKey:@"nodeContent"]);
            contact.idcontatto = [NSNumber numberWithInt: [[[[node objectForKey:@"nodeChildArray"] objectAtIndex:2] objectForKey:@"nodeContent"] integerValue]];
            
            [ArrayRubricaSearchResults addObject:contact];
        }
        [ArrayRubricaSearchResults retain];
    }
    else
    {
        NSLog(@"Nessun risultato dalla ricerca");
    }
    
//    [resultArray release];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kManagerHasFinishedSearchingRubrica object:self userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:1], @"Result", nil]];

}

// Handle the response from RubricaSearchByField.

- (void) RubricaSearchByFieldHandler: (id) value {
    
	// Handle errors
	if([value isKindOfClass:[NSError class]]) {
		NSLog(@"%@", value);
        [[NSNotificationCenter defaultCenter] postNotificationName:kManagerHasFinishedSearchingRubrica object:self userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:0], @"Result", 0, @"ResultsCount", nil]];
		return;
	}
    
	// Handle faults
	if([value isKindOfClass:[SoapFault class]]) {
		NSLog(@"%@", value);
        [[NSNotificationCenter defaultCenter] postNotificationName:kManagerHasFinishedSearchingRubrica object:self userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:0], @"Result", 0, @"ResultsCount", nil]];
		return;
	}				
    
    
	// Do something with the NSString* result
    NSString* result = (NSString*)value;
	NSLog(@"RubricaSearchByField returned the value: %@", result);
    
    [ArrayRubricaSearchResults removeAllObjects];
    ArrayRubricaSearchResults = [[NSMutableArray alloc] init];
    NSData *resultData = [result dataUsingEncoding:NSUTF8StringEncoding];
    NSArray *resultArray = PerformXMLXPathQuery(resultData, @"//RUBRICA");
    if([resultArray count] > 0)
    {
        for(NSDictionary *node in resultArray)
        {
            NCDRubricaContact *contact = [[NCDRubricaContact alloc] init];
            contact.name = [[[node objectForKey:@"nodeChildArray"] objectAtIndex:0] objectForKey:@"nodeContent"];
            contact.idrubrica = [[[node objectForKey:@"nodeChildArray"] objectAtIndex:1] objectForKey:@"nodeContent"];
            contact.idcontatto = [NSNumber numberWithInt: [[[[node objectForKey:@"nodeChildArray"] objectAtIndex:2] objectForKey:@"nodeContent"] integerValue]];

            [ArrayRubricaSearchResults addObject:contact];
        }
        [ArrayRubricaSearchResults retain];
    }
    else
    {
        NSLog(@"Nessun risultato dalla ricerca");
    }

//    [resultArray release];       
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kManagerHasFinishedSearchingRubrica object:self userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:1], @"Result", nil]];

}

// Handle the response from RubricaCategories.

- (void) RubricaCategoriesHandler: (id) value {
    //!!! Non è testato
	// Handle errors
	if([value isKindOfClass:[NSError class]]) {
		NSLog(@"%@", value);
		return;
	}
    
	// Handle faults
	if([value isKindOfClass:[SoapFault class]]) {
		NSLog(@"%@", value);
		return;
	}				
    
    
	// Do something with the NSString* result
    NSString* result = (NSString*)value;
	NSLog(@"RubricaCategories returned the value: %@", result);
    
    ArrayRubricaCategories = nil;
    ArrayRubricaCategories = [[NSMutableArray alloc] init];
    NSData *resultData = [result dataUsingEncoding:NSUTF8StringEncoding];
    NSArray *resultArray = PerformXMLXPathQuery(resultData, @"//INFORMATION");
    if([resultArray count] > 0)
    {
        for(NSDictionary *node in resultArray)
        {
            NCDRubricaCategory *cat = [[NCDRubricaCategory alloc] init];
            cat.categoryID = [NSNumber numberWithInt: [[[[node objectForKey:@"nodeChildArray"] objectAtIndex:0] objectForKey:@"nodeContent"] integerValue]];
            cat.description = [[[node objectForKey:@"nodeChildArray"] objectAtIndex:1] objectForKey:@"nodeContent"];
            cat.type = [[[node objectForKey:@"nodeChildArray"] objectAtIndex:2] objectForKey:@"nodeContent"];
            [ArrayRubricaCategories addObject:cat];
        }
    }
    else
    {
        NSLog(@"L'utente non visualizza alcuna rubrica");
    }

    [[NSNotificationCenter defaultCenter] postNotificationName:kManagerHasFinishedLoadingRubricaCategories object:self userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:1], @"Result", nil]];
    

//    <INFORMATION> <CATEGORY> <ID>7</ID> <DESCRIPTION>Clienti</DESCRIPTION> <TYPE>Pubblica</TYPE> </CATEGORY> <CATEGORY> <ID>5</ID> <DESCRIPTION>Clienti Estero</DESCRIPTION> <TYPE>Pubblica</TYPE> </CATEGORY> <CATEGORY> <ID>4</ID> <DESCRIPTION>Clienti Italia</DESCRIPTION> <TYPE>Pubblica</TYPE> </CATEGORY> <CATEGORY> <ID>2</ID> <DESCRIPTION>Fornitori</DESCRIPTION> <TYPE>Pubblica</TYPE> </CATEGORY> <CATEGORY> <ID>1</ID> <DESCRIPTION>Generale</DESCRIPTION> <TYPE>Pubblica</TYPE> </CATEGORY> </INFORMATION>
    
}

#pragma mark - Folder Handlers


// Handle the response from IssueSearch.

- (void) IssueSearchHandler: (id) value {
    
    //Esempio di return che contiene sia documenti che issues
//      <string xmlns="http://arxivar.it/"><RICERCA> <DOCUMENT> <DOCNUMBER>31536</DOCNUMBER> </DOCUMENT> <SUBISSUES><NAME>Pubblici\Acquisti\Richieste di Acquisto non-MRP</NAME><NAME>Pubblici\Acquisti\Ordini di Acquisto non-MRP</NAME><NAME>Pubblici\Acquisti\Ordini di Acquisto MRP</NAME><NAME>Pubblici\Acquisti\Fatture Acquisto</NAME></SUBISSUES></RICERCA></string> 
    
	// Handle errors
	if([value isKindOfClass:[NSError class]]) {
		NSLog(@"%@", value);
            [[NSNotificationCenter defaultCenter] postNotificationName:self.currentFolder object:self userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:0], @"Result", nil]];
		return;
	}
    
	// Handle faults
	if([value isKindOfClass:[SoapFault class]]) {
		NSLog(@"%@", value);
            [[NSNotificationCenter defaultCenter] postNotificationName:self.currentFolder object:self userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:0], @"Result", nil]];
		return;
	}				
    
    
	// Do something with the NSString* result
    NSString* result = (NSString*)value;
	NSLog(@"IssueSearch returned the value: %@", result);
    NSData *resultData = [result dataUsingEncoding:NSUTF8StringEncoding];
    NSArray *subissues = PerformXMLXPathQuery(resultData,@"////NAME");
    NSArray *documents = PerformXMLXPathQuery(resultData,@"////DOCNUMBER");
    NSNumber  *subissuesCount = [NSNumber numberWithInt:[subissues count]];
    [subissuesCount retain];
    NSNumber  *documentsCount = [NSNumber numberWithInt:[documents count]];
    [documentsCount retain];
    ArrayFolderItems = [[NSMutableArray alloc] init];
    for (NSDictionary *item in subissues)
    {
        NCDFolderItem *f = [[NCDFolderItem alloc] init];
        f.isFolder = YES;
        f.name = [[[item objectForKey:@"nodeContent"] componentsSeparatedByString:@"\\"] lastObject];
        f.path = self.currentFolder;
        [ArrayFolderItems addObject:f];
        NSLog(@"elemento con nome %@ e path %@", f.name, f.path);
    }
    for (NSDictionary *item in documents)
    {
        NCDFolderItem *f = [[NCDFolderItem alloc] init];
        f.isFolder = NO;
        f.name =[[[item objectForKey:@"nodeContent"] componentsSeparatedByString:@"\\"] lastObject];
        f.path = self.currentFolder;
        [ArrayFolderItems addObject:f];
    }

    [[NSNotificationCenter defaultCenter] postNotificationName:self.currentFolder object:self userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:1], @"Result", nil]];
    
}


#pragma mark - Tasks Handlers


// Handle the response from TaskVariablesGet.

- (void) TaskVariablesGetHandler: (id) value {
    
	// Handle errors
	if([value isKindOfClass:[NSError class]]) {
		NSLog(@"%@", value);
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kManagerHasFinishedLoadingTaskVariables object:self userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:0], @"Result",  nil]];
		return;
	}
    
	// Handle faults
	if([value isKindOfClass:[SoapFault class]]) {
		NSLog(@"%@", value);
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kManagerHasFinishedLoadingTaskVariables object:self userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:0], @"Result",  nil]];
		return;
	}				
    
    
	// Do something with the NSString* result
    NSString* result = (NSString*)value;
	NSLog(@"TaskVariablesGet returned the value: %@", result);
    
    NSData *resultData = [result dataUsingEncoding:NSUTF8StringEncoding];
    NSArray *tableTask = PerformXMLXPathQuery(resultData,@"//VARIABLE");
    NSNumber  *tasksCount = [NSNumber numberWithInt:[tableTask count]];
    [tasksCount retain];
    NSMutableArray *arrayVariables = [[NSMutableArray alloc] init];
    
    for(NSDictionary* node in tableTask)
    {
        NCDTaskVariable *t = [[NCDTaskVariable alloc] init];
        t.variableid = [[[node objectForKey:@"nodeChildArray"] objectAtIndex:0] objectForKey:@"nodeContent"];
        t.name =  [[[node objectForKey:@"nodeChildArray"] objectAtIndex:0] objectForKey:@"nodeContent"];
        t.type = [[[node objectForKey:@"nodeChildArray"] objectAtIndex:0] objectForKey:@"nodeContent"];
      [arrayVariables addObject:t];
    }
    [arrayVariables retain];
    //TODO: NCDTaskItem dovrebbe contenere tra le proprietà anche una di tipo Array che contiene gli esiti
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kManagerHasFinishedLoadingTaskVariables object:self userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:1], @"Result", arrayVariables, @"array",  nil]];
    
}



// Handle the response from GetActionsTask.

- (void) GetActionsTaskHandler: (id) value {
    
//    <string xmlns="http://arxivar.it/"><WORKFLOW> <ACTION> <CODE>Annulla</CODE> </ACTION> <ACTION> <CODE>Procedi</CODE> </ACTION> </WORKFLOW></string> 
    
	// Handle errors
	if([value isKindOfClass:[NSError class]]) {
		NSLog(@"%@", value);
        [[NSNotificationCenter defaultCenter] postNotificationName:kManagerHasFinishedLoadingTaskActions object:self userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:0], @"Result",  nil]];    
		return;
	}
    
	// Handle faults
	if([value isKindOfClass:[SoapFault class]]) {
		NSLog(@"%@", value);
        [[NSNotificationCenter defaultCenter] postNotificationName:kManagerHasFinishedLoadingTaskActions object:self userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:0], @"Result",  nil]];
		return;
	}				
    
    
	// Do something with the NSString* result
    NSString* result = (NSString*)value;
	NSLog(@"GetActionsTask returned the value: %@", result);
    
    NSData *resultData = [result dataUsingEncoding:NSUTF8StringEncoding];
    NSArray *tableTask = PerformXMLXPathQuery(resultData,@"//ACTION");
    NSNumber  *tasksCount = [NSNumber numberWithInt:[tableTask count]];
    [tasksCount retain];
    NSMutableArray *arrayActions = [[NSMutableArray alloc] init];
    
    for(NSDictionary* node in tableTask)
    {
        NCDTaskOutcome *t = [[NCDTaskOutcome alloc] init];
        t.code = [[[node objectForKey:@"nodeChildArray"] objectAtIndex:0] objectForKey:@"nodeContent"];
        [arrayActions addObject:t];
    }
    [arrayActions retain];
    
    //TODO: NCDTaskItem dovrebbe contenere tra le proprietà anche una di tipo Array che contiene gli esiti
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kManagerHasFinishedLoadingTaskActions object:self userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:1], @"Result", arrayActions, @"array", nil]];
    
}


// Handle the response from LoadUserTasks.

- (void) LoadUserTasksHandler: (id) value {
    
	// Handle errors
	if([value isKindOfClass:[NSError class]]) {
		NSLog(@"%@", value);
		return;
	}
    
	// Handle faults
	if([value isKindOfClass:[SoapFault class]]) {
		NSLog(@"%@", value);
		return;
	}				
    
    //No tasks:
//    <?xml version="1.0" encoding="utf-8" ?> 
//    <string xmlns="http://arxivar.it/"><TABLETASK /></string> 
    
//    Tasks:
//    <?xml version="1.0" encoding="utf-8" ?> 
//    <string xmlns="http://arxivar.it/"><TABLETASK> <Table> 
//    <ID>83557</ID> 
//    <ID_WORKFLOW>85897</ID_WORKFLOW> 
//    <ID_PROCESSO>85897</ID_PROCESSO> 
//    <UTENTE>2</UTENTE> 
//    <ID_NODO>129459</ID_NODO> 
//    <Data_inizio_task>2011-11-17T23:36:00+01:00</Data_inizio_task> 
//    <Nome_Task>Task</Nome_Task> <Descrizione_processo>Prova task a utente che avvia</Descrizione_processo> 
//    <Data_scadenza_task>2011-11-18T17:00:00+01:00</Data_scadenza_task> </Table> </TABLETASK></string> 
    
    
//4.6.20
//    <ID>217262</ID>
//    <ID_WORKFLOW>24238</ID_WORKFLOW>
//    <ID_PROCESSO>24238</ID_PROCESSO>
//    <UTENTE>2</UTENTE>
//    <ID_NODO>304279</ID_NODO>
//    <Data_inizio_task>2012-01-17T17:45:17+01:00</Data_inizio_task>
//    <Nome_Task>Approvare documento</Nome_Task>
//    <Descrizione_processo>TEST - Workflow approvazione</Descrizione_processo>
//    <Data_scadenza_task>2012-01-24T17:00:00+01:00</Data_scadenza_task>
//    </Table>
    
	// Do something with the NSString* result
    NSString* result = (NSString*)value;
	NSLog(@"LoadUserTasks returned the value: %@", result);
    NSData *resultData = [result dataUsingEncoding:NSUTF8StringEncoding];
    NSArray *tableTask = PerformXMLXPathQuery(resultData,@"//Table");
    NSNumber  *tasksCount = [NSNumber numberWithInt:[tableTask count]];
    [tasksCount retain];
    ArrayUserTasks = [[NSMutableArray alloc] init];
//    [ArrayUserTasks retain];
    if([tableTask count] > 0)
    {

        for(NSDictionary* node in tableTask)
        {
            NCDTaskListItem *tli = [[NCDTaskListItem alloc] init];
            /*
            //4.6.18
            tli.taskName = @"Task";
            tli.processName = @"Nome processo";
            tli.taskID = [NSNumber numberWithInt: [[[[node objectForKey:@"nodeChildArray"] objectAtIndex:0] objectForKey:@"nodeContent"] integerValue]];
            tli.processID = [NSNumber numberWithInt: [[[[node objectForKey:@"nodeChildArray"] objectAtIndex:2] objectForKey:@"nodeContent"] integerValue]];
            tli.idUtente = [NSNumber numberWithInt: [[[[node objectForKey:@"nodeChildArray"] objectAtIndex:3] objectForKey:@"nodeContent"] integerValue]];
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
            [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss ZZZ"];
            //2011-05-13T00:00:00+02:003
            tli.dataInizio = [dateFormat dateFromString:[[[node objectForKey:@"nodeChildArray"] objectAtIndex:5] objectForKey:@"nodeContent"]];
            tli.dataScadenza = [dateFormat dateFromString:[[[node objectForKey:@"nodeChildArray"] objectAtIndex:6] objectForKey:@"nodeContent"]];
            */
            
//             4.6.20
            tli.taskID = [NSNumber numberWithInt: [[[[node objectForKey:@"nodeChildArray"] objectAtIndex:0] objectForKey:@"nodeContent"] integerValue]];
            tli.processID = [NSNumber numberWithInt: [[[[node objectForKey:@"nodeChildArray"] objectAtIndex:2] objectForKey:@"nodeContent"] integerValue]];
            tli.idUtente = [NSNumber numberWithInt: [[[[node objectForKey:@"nodeChildArray"] objectAtIndex:3] objectForKey:@"nodeContent"] integerValue]];
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
            [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss ZZZ"];
            //2011-05-13T00:00:00+02:003
            //!!! all'index 4 c'è il NODO mentre nella 4.6.19 non c'è
            tli.dataInizio = [dateFormat dateFromString:[[[node objectForKey:@"nodeChildArray"] objectAtIndex:5] objectForKey:@"nodeContent"]];
            tli.taskName = [[[node objectForKey:@"nodeChildArray"] objectAtIndex:6] objectForKey:@"nodeContent"];
            tli.processName = [[[node objectForKey:@"nodeChildArray"] objectAtIndex:7] objectForKey:@"nodeContent"];
            tli.dataScadenza = [dateFormat dateFromString:[[[node objectForKey:@"nodeChildArray"] objectAtIndex:8] objectForKey:@"nodeContent"]];
             
#if DEBUG 

            NSLog(@"%@: %@",[[[node objectForKey:@"nodeChildArray"] objectAtIndex:0] objectForKey:@"nodeName"],[[[node objectForKey:@"nodeChildArray"] objectAtIndex:0] objectForKey:@"nodeContent"]);
            NSLog(@"%@: %@",[[[node objectForKey:@"nodeChildArray"] objectAtIndex:1] objectForKey:@"nodeName"],[[[node objectForKey:@"nodeChildArray"] objectAtIndex:1] objectForKey:@"nodeContent"]);
#endif

            
            [ArrayUserTasks addObject:tli];

        }
        [ArrayUserTasks retain];

    }
    else
    {
        NSLog(@"Non ci sono task per l'utente");
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kManagerHasFinishedLoadingUserTasks object:self userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:1], @"Result", tasksCount, @"NumberOfTasks",  nil]];
    
}

#pragma mark - Document Handlers


// Handle the response from GetAttachedByDocument.

- (void) GetAttachedByDocumentHandler: (id) value {
    
	// Handle errors
	if([value isKindOfClass:[NSError class]]) {
		NSLog(@"%@", value);
		return;
	}
    
	// Handle faults
	if([value isKindOfClass:[SoapFault class]]) {
		NSLog(@"%@", value);
		return;
	}				
    
    
	// Do something with the NSString* result
    NSString* result = (NSString*)value;
	NSLog(@"GetAttachedByDocument returned the value: %@", result);
    
}



// Handle the response from RunWorkflowDocument.

- (void) RunWorkflowDocumentHandler: (id) value {
    
	// Handle errors
	if([value isKindOfClass:[NSError class]]) {
		NSLog(@"%@", value);
		return;
	}
    
	// Handle faults
	if([value isKindOfClass:[SoapFault class]]) {
		NSLog(@"%@", value);
		return;
	}				
    
    
	// Do something with the NSString* result
    NSString* result = (NSString*)value;
	NSLog(@"RunWorkflowDocument returned the value: %@", result);
    //!!! Non implementata
}


// Handle the response from RunRicerca.
- (void) RunRicercaWithParametersHandler: (id) value {
    
    //    Esempio di return di RunRicerca
    //    <soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:arx="http://arxivar.it/">
    //    <soapenv:Header/>
    //    <soapenv:Body>
    //    <arx:RunRicerca>
    //    <!--Optional:-->
    //    <arx:XMLinfo><?xml version='1.0' encoding='utf-8'?><RICERCA><PARAMSEARCH><NAME>DOCNAME</NAME><OPERATOR>LIKE</OPERATOR><VALUE>RDA</VALUE></PARAMSEARCH><RETURNPARAM>DOCNUMBER</RETURNPARAM></RICERCA></arx:XMLinfo>
    //    <arx:UserId>2</arx:UserId>
    //    </arx:RunRicerca>
    //    </soapenv:Body>
    //    </soapenv:Envelope>
    
	// Handle errors
	if([value isKindOfClass:[NSError class]]) {
		NSLog(@"%@", value);
		return;
	}
    
	// Handle faults
	if([value isKindOfClass:[SoapFault class]]) {
		NSLog(@"%@", value);
		return;
	}				
    
    
	// Do something with the NSString* result
    NSString* result = (NSString*)value;
	NSLog(@"RunRicerca returned the value: %@", result);
    
    self.ArraySearchResults = PerformXMLXPathQuery([result dataUsingEncoding:NSUTF8StringEncoding], @"//DOCUMENT");
    /*
#if DEBUG
    for(NSDictionary* node in ArraySearchResults)
    {

        //         NSLog(@"Valore ritornato: %@",node);
        NSLog(@"%@: %@",[[[node objectForKey:@"nodeChildArray"] objectAtIndex:0] objectForKey:@"nodeName"],[[[node objectForKey:@"nodeChildArray"] objectAtIndex:0] objectForKey:@"nodeContent"]);
        NSLog(@"%@: %@",[[[node objectForKey:@"nodeChildArray"] objectAtIndex:1] objectForKey:@"nodeName"],[[[node objectForKey:@"nodeChildArray"] objectAtIndex:1] objectForKey:@"nodeContent"]);
        //        NSLog(@"%@: %@",[[[node objectForKey:@"nodeChildArray"] objectAtIndex:2] objectForKey:@"nodeName"],[[[node objectForKey:@"nodeChildArray"] objectAtIndex:2] objectForKey:@"nodeContent"]);

    }
#endif
     */
    [ArraySearchResults retain];
    [[NSNotificationCenter defaultCenter] postNotificationName:kManagerHasFinishedSearching object:self userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:1], @"Result", nil]];    
}

// Handle the response from GetFileProfileByDocumentId.

- (void) GetFileProfileByDocumentIdHandler: (id) value {
    
	// Handle errors
	if([value isKindOfClass:[NSError class]]) {
		NSLog(@"%@", value);
		return;
	}
    
	// Handle faults
	if([value isKindOfClass:[SoapFault class]]) {
		NSLog(@"%@", value);
		return;
	}				
    
    
    /*
     In caso di errore ritorna il seguente:
    <GetFileProfileByDocumentIdResult>&lt;INFORMATION&gt;
    &lt;ERRORE&gt;
    &lt;CODE&gt;3&lt;/CODE&gt;
    &lt;DESCRIPTION&gt;File non esistente.&lt;/DESCRIPTION&gt;
    &lt;/ERRORE&gt;
    &lt;/INFORMATION&gt;</GetFileProfileByDocumentIdResult></GetFileProfileByDocumentIdResponse>
    */
    
//    @try {
        //TODO: blocco try/catch
        NSDictionary* result = (NSDictionary*)value;
        NSData *fileData =  [NSData dataWithBase64EncodedString:[result objectForKey:@"FileByte"] ];
//        NSLog(@"GetFileProfileByDocumentId returned the file: %@", [result objectForKey:@"FileByte"]);
        NSString *fileprofile = (NSString*)[result objectForKey:@"GetFileProfileByDocumentIdResult"];
        NSLog(@"FileProfile: %@", fileprofile);
        NSArray *fileprofileArr = PerformXMLXPathQuery([fileprofile dataUsingEncoding:NSUTF8StringEncoding],@"//FILENAME");
        NSString *filename = [[fileprofileArr objectAtIndex:0] objectForKey:@"nodeContent"];
        NSLog(@"GetFileProfileByDocumentId returned the filename: %@",  filename);

        
        // Get the Document directory
        NSString *documentDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        // Add your filename to the directory to create your saved pdf location
        NSString *fileLocation = [documentDirectory stringByAppendingPathComponent:filename];
        NSURL *fileURL = [NSURL fileURLWithPath:fileLocation];
        
        // TEMPORARY PDF PATH
        // Get the Caches directory
//        NSString *cachesDirectory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
        // Add your filename to the directory to create your temp pdf location
//        NSString *cacheFileLocation = [cachesDirectory stringByAppendingPathComponent:filename];
  
        [[NSFileManager defaultManager] createFileAtPath:fileLocation contents:nil attributes:nil];
        NSFileHandle *handle = [NSFileHandle fileHandleForWritingAtPath:fileLocation];
//    NSError *writeError = [[NSError alloc] init];
//    NSFileHandle *handle = [NSFileHandle fileHandleForWritingToURL:fileURL error:&writeError];
        
        [handle writeData:fileData];
        [handle closeFile];
//        float f = [fileData length];
//        write([handle fileDescriptor], &f, sizeof(float));
        
//        BOOL myPathIsDir;
//        BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:fileLocation isDirectory: &myPathIsDir];
//        NSLog (myPathIsDir ? @"My path is a directory" : @"My path is a file");
//        NSLog(fileExists ? @"File Exists" : @"File Does not exist");
        
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kManagerHasFinishedGettingDocumentFile object:self userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:1], @"Result", fileLocation, @"FilePath", filename, @"FileName", fileURL,@"FileURL", nil]];

//    }
//    @catch (NSException *exception) {
//        NSLog(@"Errore in GetFileProfileByDocumentIdHandler: %@", exception.reason);
//    }

}

// Handle the response from GetInformationProfileByDocumentId.

//- (void) GetInformationProfileByDocumentIdHandler: (id) value {
//    
//	// Handle errors
//	if([value isKindOfClass:[NSError class]]) {
//		NSLog(@"%@", value);
//		return;
//	}
//    
//	// Handle faults
//	if([value isKindOfClass:[SoapFault class]]) {
//		NSLog(@"%@", value);
//		return;
//	}				
//    
//    
//	// Do something with the NSString* result
//    NSDictionary* result = (NSDictionary*)value;
//	NSLog(@"GetInformationProfileByDocumentId returned the file: %@", [result objectForKey:@"FileByte"]);
//
//}


// Handle the response from GetProfileById.

- (void) GetProfileByIdHandler: (id) value {
    
	// Handle errors
	if([value isKindOfClass:[NSError class]]) {
		NSLog(@"%@", value);
		return;
	}
    
	// Handle faults
	if([value isKindOfClass:[SoapFault class]]) {
		NSLog(@"%@", value);
		return;
	}				
    
    
	// Do something with the NSString* result
    NSString* result = (NSString*)value;
	NSLog(@"GetProfileById returned the value: %@", result);
    
    NSArray *GetProfileByIdErrorArray = PerformXMLXPathQuery([result dataUsingEncoding:NSUTF8StringEncoding], @"//ERROR");
    NSArray *GetProfileByIdArray = PerformXMLXPathQuery([result dataUsingEncoding:NSUTF8StringEncoding], @"//DOCUMENT");
    if([GetProfileByIdErrorArray count] > 0)
    {
        NSLog(@"Si è verificato un errore! Probabilmente docnumber errato! ");
    }
    else
    {
        NSLog(@"Array contenente il profilo: %@", GetProfileByIdArray);
        
        
        /*
        
        //Core Data management start
        
        //        NSArray *properties = Document.properties;
        //        properties = [properties filteredArrayUsingPredicate:
        //                      [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        //            NSDictionary *userInfo = [evaluatedObject userInfo];
        //            id value;
        //            BOOL includeInCopy = (value = [userInfo objectForKey:@"includeInCopy"]) 
        //            && [value boolValue];
        //            BOOL excludeFromTemplate = (value = [userInfo objectForKey:@"excludeFromTemplate"]) 
        //            && [value boolValue];
        //            return includeContent ? includeInCopy : includeInCopy && !excludeFromTemplate;
        //        }]];
        
        NSManagedObjectContext *moc = [self managedObjectContext];
        NSEntityDescription *entityDescription = [NSEntityDescription
                                                  entityForName:@"Document" inManagedObjectContext:moc];
        
        Document *document = [[Document alloc] initWithEntity:entityDescription insertIntoManagedObjectContext:moc];
        BOOL isUnique = [[[document.docnumber userInfo] objectForKey:@"unique"] boolValue];
        if(isUnique)
        {
            
                 

        NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
        [request setEntity:entityDescription];
        // Set example predicate and sort orderings...
        NSNumber *queryDocNumber = [NSNumber numberWithInt:[[[GetProfileByIdArray objectAtIndex:0] objectForKey:@"nodeContent"] integerValue]];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:
                                  @"(docnumber = %@)", queryDocNumber];
        [request setPredicate:predicate];
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]
                                            initWithKey:@"docNumber" ascending:YES];
        [request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];

        [sortDescriptor release];
        NSError *error = nil;
        NSUInteger count = [managedObjectContext countForFetchRequest:request error:&error];     
        
         //Non eseguo il fetch ma solo il countforfetch
        NSArray *array = [moc executeFetchRequest:request error:&error];
        if (array == nil)
        {
            // Deal with error...
        }
         
        [request release];
        if (!error){
//            return count;
            
            //Gestisco la situazione
        }
        else{
            return;
            }
        }
*/


        NCDDocument *profile = [[NCDDocument alloc] init];
        profile.docnumber =  [NSNumber numberWithInt: [[[PerformXMLXPathQuery([result dataUsingEncoding:NSUTF8StringEncoding], @"///DOCNUMBER") objectAtIndex:0]objectForKey:@"nodeContent"] integerValue]];
        profile.mittente =  [[PerformXMLXPathQuery([result dataUsingEncoding:NSUTF8StringEncoding], @"///MITTENTE") objectAtIndex:0]objectForKey:@"nodeContent"];
        profile.destinatario =  [[PerformXMLXPathQuery([result dataUsingEncoding:NSUTF8StringEncoding], @"///DESTINATARIO") objectAtIndex:0]objectForKey:@"nodeContent"];        
        profile.cc = @"";
        if([PerformXMLXPathQuery([result dataUsingEncoding:NSUTF8StringEncoding], @"///CC") count] > 0)
        {
        profile.cc =  [[PerformXMLXPathQuery([result dataUsingEncoding:NSUTF8StringEncoding], @"///CC") objectAtIndex:0]objectForKey:@"nodeContent"];
        }
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss ZZZ"];
        //2011-05-13T00:00:00+02:003
        profile.datadoc = [dateFormat dateFromString: [[PerformXMLXPathQuery([result dataUsingEncoding:NSUTF8StringEncoding], @"///DATADOC") objectAtIndex:0]objectForKey:@"nodeContent"]];
//        NSDate *date = [dateFormat dateFromString:dateStr];
        profile.dataprofilo = [dateFormat dateFromString: [[PerformXMLXPathQuery([result dataUsingEncoding:NSUTF8StringEncoding], @"///DATAPROFILO") objectAtIndex:0]objectForKey:@"nodeContent"]];
   
        profile.oggetto = [[PerformXMLXPathQuery([result dataUsingEncoding:NSUTF8StringEncoding], @"///OGGETTO") objectAtIndex:0]objectForKey:@"nodeContent"];
        profile.numero = [[PerformXMLXPathQuery([result dataUsingEncoding:NSUTF8StringEncoding], @"///NUMERO") objectAtIndex:0]objectForKey:@"nodeContent"];
        NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
        [f setNumberStyle:NSNumberFormatterDecimalStyle];
        profile.importante = [f numberFromString:[[PerformXMLXPathQuery([result dataUsingEncoding:NSUTF8StringEncoding], @"///IMPORTANTE") objectAtIndex:0]objectForKey:@"nodeContent"]];
        profile.revisione = [f numberFromString:[[PerformXMLXPathQuery([result dataUsingEncoding:NSUTF8StringEncoding], @"///REVISIONE") objectAtIndex:0]objectForKey:@"nodeContent"]];
        profile.autore = [f numberFromString:[[PerformXMLXPathQuery([result dataUsingEncoding:NSUTF8StringEncoding], @"///AUTORE") objectAtIndex:0]objectForKey:@"nodeContent"]];
//        //TODO: ottenre la stringa dell'autore in base all'ID
//        profile.autoreString = 
        profile.nomeFile = [[PerformXMLXPathQuery([result dataUsingEncoding:NSUTF8StringEncoding], @"///NOMEFILE") objectAtIndex:0]objectForKey:@"nodeContent"];
        profile.aoo = [[PerformXMLXPathQuery([result dataUsingEncoding:NSUTF8StringEncoding], @"///AOO") objectAtIndex:0]objectForKey:@"nodeContent"];
        profile.risposta = 0;
        if( [PerformXMLXPathQuery([result dataUsingEncoding:NSUTF8StringEncoding], @"///RISPOSTA") count] > 0)
        {
            profile.risposta = [f numberFromString:[[PerformXMLXPathQuery([result dataUsingEncoding:NSUTF8StringEncoding], @"///RISPOSTA") objectAtIndex:0]objectForKey:@"nodeContent"]];
        }
        profile.webvisible = [f numberFromString:[[PerformXMLXPathQuery([result dataUsingEncoding:NSUTF8StringEncoding], @"///WEBVISIBLE") objectAtIndex:0]objectForKey:@"nodeContent"]];
        profile.workflow = 0;
        if( [PerformXMLXPathQuery([result dataUsingEncoding:NSUTF8StringEncoding], @"///WORKFLOW") count] > 0)
        {
            profile.workflow = [f numberFromString:[[PerformXMLXPathQuery([result dataUsingEncoding:NSUTF8StringEncoding], @"///WORKFLOW") objectAtIndex:0]objectForKey:@"nodeContent"]];
        }
//        NSLog(@"Oggetto: %@ ",[[PerformXMLXPathQuery([result dataUsingEncoding:NSUTF8StringEncoding], @"///OGGETTO") objectAtIndex:0]objectForKey:@"nodeContent"]);
  //      document.oggetto = [[PerformXMLXPathQuery([result dataUsingEncoding:NSUTF8StringEncoding], @"//OGGETTO") objectAtIndex:0]objectForKey:@"nodeContent"];
        [f release];
        [dateFormat release];           
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kManagerHasFinishedLoadingDocumentDetails object:self userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:1], @"Result", profile, @"Profile", nil]];

        
    }
    
    
}



// Handle the response from RunRicerca.
- (void) RunRicercaHandler: (id) value {

//    Esempio di return di RunRicerca
//    <soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:arx="http://arxivar.it/">
//    <soapenv:Header/>
//    <soapenv:Body>
//    <arx:RunRicerca>
//    <!--Optional:-->
//    <arx:XMLinfo><?xml version='1.0' encoding='utf-8'?><RICERCA><PARAMSEARCH><NAME>DOCNAME</NAME><OPERATOR>LIKE</OPERATOR><VALUE>RDA</VALUE></PARAMSEARCH><RETURNPARAM>DOCNUMBER</RETURNPARAM></RICERCA></arx:XMLinfo>
//    <arx:UserId>2</arx:UserId>
//    </arx:RunRicerca>
//    </soapenv:Body>
//    </soapenv:Envelope>
    
	// Handle errors
	if([value isKindOfClass:[NSError class]]) {
		NSLog(@"%@", value);
		return;
	}
    
	// Handle faults
	if([value isKindOfClass:[SoapFault class]]) {
		NSLog(@"%@", value);
		return;
	}				
    
    
	// Do something with the NSString* result
    NSString* result = (NSString*)value;
	NSLog(@"RunRicerca returned the value: %@", result);
    
    self.ArrayDocsList = PerformXMLXPathQuery([result dataUsingEncoding:NSUTF8StringEncoding], @"//DOCUMENT");
    for(NSDictionary* node in ArrayDocsList)
    {
#if DEBUG
        //         NSLog(@"Valore ritornato: %@",node);
        NSLog(@"%@: %@",[[[node objectForKey:@"nodeChildArray"] objectAtIndex:0] objectForKey:@"nodeName"],[[[node objectForKey:@"nodeChildArray"] objectAtIndex:0] objectForKey:@"nodeContent"]);
        NSLog(@"%@: %@",[[[node objectForKey:@"nodeChildArray"] objectAtIndex:1] objectForKey:@"nodeName"],[[[node objectForKey:@"nodeChildArray"] objectAtIndex:1] objectForKey:@"nodeContent"]);
//        NSLog(@"%@: %@",[[[node objectForKey:@"nodeChildArray"] objectAtIndex:2] objectForKey:@"nodeName"],[[[node objectForKey:@"nodeChildArray"] objectAtIndex:2] objectForKey:@"nodeContent"]);
#endif
    }
    [ArrayDocsList retain];
    [[NSNotificationCenter defaultCenter] postNotificationName:KManagerHasFinishedLoadingListOfDocumentsForClass object:self userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:1], @"Result", nil]];
    
    
    
}

// Handle the response from GetUserIdentify.

- (void) GetUserIdentifyHandler: (id) value {
    
	// Handle errors
	if([value isKindOfClass:[NSError class]]) {
		NSLog(@"%@", value);
        [[NSNotificationCenter defaultCenter] postNotificationName:kManagerHasCompletedLogon object:self userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:-1],@"LoginResult", [NSNumber numberWithInt:0], @"siteID", nil]];
		return;
	}
    
	// Handle faults
	if([value isKindOfClass:[SoapFault class]]) {
		NSLog(@"%@", value);
        [[NSNotificationCenter defaultCenter] postNotificationName:kManagerHasCompletedLogon object:self userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:-1],@"LoginResult", [NSNumber numberWithInt:0], @"siteID", nil]];
		return;
	}				
    
    
	// Do something with the NSString* result
    NSString* result = (NSString*)value;
#if DEBUG
	NSLog(@"GetUserIdentify returned the value: %@", result);
#endif
    //    HUD.detailsLabelText = result;
    site.siteID =  [NSNumber numberWithInt:[result integerValue]];
#if DEBUG
    NSLog(@"SiteID %@", site.siteID);
#endif
    // you post a notification to the default center
    [[NSNotificationCenter defaultCenter] postNotificationName:kManagerHasCompletedLogon object:self userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:1], @"LoginResult",  site.siteID,  @"siteID", nil]];
    self.isLoggedIn = YES;
}


// Handle the response from AuthorizedUser.

- (void) AuthorizedUserHandler: (id) value {

	// Handle errors
	if([value isKindOfClass:[NSError class]]) {
		NSLog(@"%@", value);
        //     HUD.detailsLabelText = @"NSError";
        //     [HUD hide:YES afterDelay:2];
        [[NSNotificationCenter defaultCenter] postNotificationName:kManagerHasCompletedLogon object:self userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:-1], @"LoginResult", [NSNumber numberWithInt:0], @"siteID", nil]];
		return;
	}
    
	// Handle faults
	if([value isKindOfClass:[SoapFault class]]) {
		NSLog(@"%@", value);
        [[NSNotificationCenter defaultCenter] postNotificationName:kManagerHasCompletedLogon object:self userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:-1], @"LoginResult", [NSNumber numberWithInt:0], @"siteID", nil]];
		return;
	}				
    
    
	// Do something with the NSString* result
    NSString* result = (NSString*)value;
    
	NSLog(@"AuthorizedUser returned the value: %@", result);
    //    HUD.detailsLabelText = result;
    NSArray *nodes = PerformXMLXPathQuery([result dataUsingEncoding:NSUTF8StringEncoding], @"//CODE");
    [nodes retain];
    if(nodes.count > 0){

        NSLog(@"Valore ritornato: %@",[nodes objectAtIndex:0]);
        //Nodes è un NSArray
        //Ogni Nodo di Nodes è un NSDictionary quindi va usato objectForKey
        //        NSLog(@"Is Dictionary: %@", [[nodes objectAtIndex:0] isKindOfClass:[NSDictionary class]]? @"YES":@"NO");
        //        NSLog(@"Is Array: %@", [[nodes objectAtIndex:0] isKindOfClass:[NSArray class]]? @"YES":@"NO");
        
        int res = [ [[nodes objectAtIndex:0] objectForKey:@"nodeContent"] integerValue] ;
#if DEBUG        
        NSLog(@"Valore ritornato: %@",[nodes valueForKey:@"nodeContent"]);
        NSLog(@"Res %@", res );        
#endif
        
        if ( res == 0)
        {
           NSLog(@"Auth Ok");
            //ottengo ID utente
            // Returns NSString*. Funzione che permette l'estrazione dell'identificativo utente.Parametro di input: (string) Nome Utente, (string) Codice Area Oganizzativa.Parametro di output: (string) Identificativo Utente
            NSLog(@"Identify Username %@", site.username);
            NSLog(@"Identify AOO %@", site.AOO);
            [service GetUserIdentify:self action:@selector(GetUserIdentifyHandler:) UserName: site.username CodeAoo: site.AOO];          
        }
    }
    else
    {
#if DEBUG
        NSLog(@"qualcosa è andato storto: nessun valore ritornato");
#endif
        [[NSNotificationCenter defaultCenter] postNotificationName:kManagerHasCompletedLogon object:self userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:-1], @"LoginResult", [NSNumber numberWithInt:0], @"siteID", nil]];
     
    }

}


// Handle the response from GetClassesToSearch.

- (void) GetClassesToSearchHandler: (id) value {
    
	// Handle errors
	if([value isKindOfClass:[NSError class]]) {
        NSLog(@"ERRORE GETCLASSESTOSEARCH");
		NSLog(@"%@", value);
        [[NSNotificationCenter defaultCenter] postNotificationName:KManagerHasFinishedLoadingData object:self userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:-1], @"Result", nil]];
		return;
	}
    
	// Handle faults
	if([value isKindOfClass:[SoapFault class]]) {
		NSLog(@"%@", value);
        [[NSNotificationCenter defaultCenter] postNotificationName:KManagerHasFinishedLoadingData object:self userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:-1], @"Result", nil]];
		return;
	}				
    
    
	// Do something with the NSString* result
    NSString* result = (NSString*)value;
	NSLog(@"GetClassesToSearch returned the value: %@", result);
    
    ArrayDocTypes = PerformXMLXPathQuery([result dataUsingEncoding:NSUTF8StringEncoding], @"//TIPOLOGIE");
    for(NSDictionary* node in ArrayDocTypes)
    {
        //         NSLog(@"Valore ritornato: %@",node);
        NSLog(@"%@: %@",[[[node objectForKey:@"nodeChildArray"] objectAtIndex:0] objectForKey:@"nodeName"],[[[node objectForKey:@"nodeChildArray"] objectAtIndex:0] objectForKey:@"nodeContent"]);
        NSLog(@"%@: %@",[[[node objectForKey:@"nodeChildArray"] objectAtIndex:1] objectForKey:@"nodeName"],[[[node objectForKey:@"nodeChildArray"] objectAtIndex:1] objectForKey:@"nodeContent"]);
        NSLog(@"%@: %@",[[[node objectForKey:@"nodeChildArray"] objectAtIndex:2] objectForKey:@"nodeName"],[[[node objectForKey:@"nodeChildArray"] objectAtIndex:2] objectForKey:@"nodeContent"]);
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:KManagerHasFinishedLoadingData object:self userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:1], @"Result", nil]];
    
}




#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{
    if (__fetchedResultsController != nil)
    {
        return __fetchedResultsController;
    }
    
    /*
     Set up the fetched results controller.
     */
    // Create the fetch request for the entity.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Event" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timeStamp" ascending:NO];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"Root"];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
    [aFetchedResultsController release];
    [fetchRequest release];
    [sortDescriptor release];
    [sortDescriptors release];
    
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error])
    {
	    /*
	     Replace this implementation with code to handle the error appropriately.
         
	     abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
	     */
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    
    return __fetchedResultsController;
}    


#pragma mark -
#pragma mark Utilities

- (NSString *)applicationDocumentsDirectory
{
	return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}


#pragma mark -
#pragma mark View Lifecycle

-(void) dealloc
{
    [super dealloc];

//    [ArrayDocTypes release];
//    [ArrayDocsList release];
//    [site release];
//    [service release];
    
    
    [__fetchedResultsController release];    
    [__managedObjectContext release];
}


@end
