#ifndef _INDEX_H_
#define _INDEX_H_

#include "CppSQLite3.h"
#include <string>
#include <vector>

int WizStdStringReplace(std::string& str, const char* lpszStringToReplace, const char* lpszNewString);
std::string WizStringToSQLString(const char* lpsz);
std::string WizStringToSQLString(const std::string& str);

bool WizIsSpaceChar(char ch);
std::string WizStdStringTrimLeft(const std::string& str);
std::string WizStdStringTrimRight(const std::string& str);
std::string WizStdStringTrim(const std::string& str);

std::string WizIntToStdString(int n);
std::string WizGetCurrentTimeSQLString();

struct WIZDOCUMENTATTACH
{
    std::string strDocumentGuid;
    std::string strAttachmentGuid;
    std::string strDataMd5;
    std::string strDataModified;
    std::string strAttachmentName;
    std::string strDescription;
    int     serverChanged;
    int     loaclChanged;

};

struct WIZDOCUMENTDATA
{
	std::string strGUID;
	std::string strTitle;
	std::string strLocation;
	std::string strDataMd5;
	std::string strURL;
	std::string strTagGUIDs;
	std::string strDateCreated;
	std::string strDateModified;
	std::string strType;
	std::string strFileType;
	int nAttachmentCount;
	int nServerChanged;
	int nLocalChanged;
    int nProtected;
	//
	WIZDOCUMENTDATA()
    : nAttachmentCount(0)
    , nServerChanged(0)
    , nLocalChanged(0)
    , nProtected(0)
	{
		
	}
};

struct WIZTAGDATA
{
	std::string strName;
	std::string strGUID;
	std::string strParentGUID;
	std::string strDescription;
	std::string strNamePath;
    std::string strDtInfoModified;
    int         localchanged;
};

struct WIZDELETEDGUIDDATA
{
	std::string strGUID;
	std::string strType;
	std::string strDateDeleted;
};


typedef std::vector<std::string> CWizStdStringArray;
typedef std::vector<WIZDOCUMENTDATA> CWizDocumentDataArray;
typedef std::vector<WIZTAGDATA> CWizTagDataArray;
typedef std::vector<WIZDELETEDGUIDDATA> CWizDeletedGUIDDataArray;
typedef std::vector<WIZDOCUMENTATTACH> CWizDocumentAttachmentArray;


class CIndex
{
public:
	CIndex();
	~CIndex();
private:
	CppSQLite3DB m_db;
	std::string m_strFileName;
private:
	bool InitDB();
	bool checkTable(const char* lpszTableName, const char* lpszTableSQL);
    bool dropTable(const char* lpszTableName, const char* lpszTableSql);
public:
	bool Open(const char* lpszFileName);
	void Close();
	bool IsOpened();
    bool upgradeDB();
	//
	bool NewDocument(const char* lpszGUID, const char* lpszTitle, const char* lpszType, const char* lpszFileType, const char* lpszLocation);
	bool NewNote(const char* lpszGUID, const char* lpszTitle, const char* lpszLocation);
	bool NewPhoto(const char* lpszGUID, const char* lpszTitle, const char* lpszLocation);
	bool ChangeDocumentType(const char* lpszGUID, const char* lpszTitle, const char* lpszType, const char* lpszFileType);
	//
	bool IsDocumentExists(const char* lpszGUID);
	bool UpdateDocument(const WIZDOCUMENTDATA& data);
	bool DocumentFromGUID(const char* lpszGUID, WIZDOCUMENTDATA& data); 
	bool SQLToDocuments(const char* lpszSQL, CWizDocumentDataArray& arrayDocument);
	//
	bool GetAllLocations(CWizStdStringArray& arrayLocation);
	bool GetRootLocations(CWizStdStringArray& arrayLocation);
	bool GetChildLocations(const char* lpszParentLocation, CWizStdStringArray& arrayLocation);
	//
	bool IsLocationExists(const char* lpszLocation);
	bool AddLocation(const char* lpszParentLocation, const char* lpszLocationName);
	bool AddLocation(const char* lpszLocation);
	//
	bool IsTagExists(const char* lpszGUID);
	bool UpdateTag(const WIZTAGDATA& data);
	bool GetAllTagsPathForTree(const char* lpszParentGUID, const char* lpszParentTagPath, CWizTagDataArray& arrayTag);
	bool GetAllTagsPathForTree(CWizTagDataArray& arrayTag);
    bool SqlToTags(const char* sql, CWizTagDataArray& array);
    bool TagFromGUID(const char* lpszGUID, WIZTAGDATA& data);
	//
	bool GetDocumentsByLocation(const char* lpszParentLocation, CWizDocumentDataArray& arrayDocument);
	bool GetDocumentsByTag(const char* lpszTagGUID, CWizDocumentDataArray& arrayDocument);
	bool GetDocumentsByKey(const char* lpszKeywords, CWizDocumentDataArray& arrayDocument);
	//
	bool GetRecentDocuments(CWizDocumentDataArray& arrayDocument);
	bool GetDocumentsForUpdate(CWizDocumentDataArray& arrayDocument);
	//
    bool SetDocumentMD5(const char *lpszDocumentGUID, const char *lpszMD5);
	bool SetDocumentLocalChanged(const char* lpszDocumentGUID, int changed);
	bool SetDocumentServerChanged(const char* lpszDocumentGUID, bool changed);
    bool SetDocumentAttachmentCount(const char* lpszDocumentGUID, const char* count);
    bool SetDocumentAttibute(const char* lpszDocumentGUID, const char* lpszDocumentAttibuteName, const char* lpszAttributeValue);
    bool SetDocumentTags(const char* lpszDocumentGUID, const char* lpszTags);
    bool SetDocumentLocation(const char* lpszDocumentGUID, const char* lpszLocation);
    bool SetDocumentModifiedDate(const char* lpszDocumentGUID, const char* lpszModifiedDate);
	//
	bool SQLToStringArray(const char* lpszSQL, CWizStdStringArray& arrayLocation);
	//
    
	bool DeleteDocument(const char* lpszDocumentGUID);
	bool DeleteTag(const char* lpszTagGUID);
    bool DeleteAttachment(const char* lpszAttachGUID);
	//
	bool IsMetaExists(const char* lpszName, const char* lpszKey);
	std::string GetMeta(const char* lpszName, const char* lpszKey);
	bool SetMeta(const char* lpszName, const char* lpszKey, const char* lpszValue);
	//
	bool SQLToDeletedGUIDs(const char* lpszSQL, CWizDeletedGUIDDataArray& arrayGUID);
	bool LogDeletedGUID(const char* lpszGUID, const char* lpszType);
	bool GetAllDeletedGUIDs(CWizDeletedGUIDDataArray& arrayGUID);
	bool RemoveDeletedGUID(const char* lpszGUID);
	bool ClearDeletedGUIDs();
	bool HasDeletedGUIDs();
	//
    bool GetAttachmentForUpload(CWizDocumentAttachmentArray& arrayAttach);
    bool AttachFromGUID(const char* guid, WIZDOCUMENTATTACH& dataExist);
    bool updateAttachment(const WIZDOCUMENTATTACH& attach);
    bool SQLToAttachments(const char* lpszSQL, CWizDocumentAttachmentArray& arratAttach);
    bool AttachmentsFromDocumentGUID(const char* guid, CWizDocumentAttachmentArray& array);
    bool SetAttachmentServerChanged(const char* lpszAttachmentGUID, bool changed);
    bool SetAttachmentLocalChanged(const char* lpszAttachmentGUID, bool changed);
    //
    bool GetTagPostList(CWizTagDataArray& array);
    
    bool AddTagsToDocumentByGuid(const char* documentGuid, const char* tagsGuid);
    //    bool IsDocumentAttacgExists(const char* lpszGUID);
    //	bool DocumentAttachFromGUID(const char* lpszGUID, WIZDOCUMENTATTACH& data); 
    //	bool SQLToDocumentAttachs(const char* lpszSQL, CWizDocumentDataArray& arrayDocument);
    //    bool updateDocumentAttach(const WIZDOCUMENTATTACH& data);
	std::string GetNextDocumentForDownload();
    
    bool fileCountInLocation(const char* lpszLocation, int& count);
    bool fileCountWithChildInlocation(const char* lpszLocation, int& count);
    bool fileCountInTag(const char* lpszTagguid, int& count);
    bool documentsWillDowload(int duration, CWizDocumentDataArray& array);
};	


#endif

