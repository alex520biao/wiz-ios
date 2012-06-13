//
//  tempIndex.cpp
//  Wiz
//
//  Created by dong yishuiliunian on 11-12-30.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#include <iostream>
#include <string>
#include "TempIndex.h"
#include "WizMisc.h"
#include "index.h"
static std::string PAD_TYPE = "PAD";
static std::string PHONE_TYPE = "PHONE";

static const char* lpszAbstractSQL = "CREATE TABLE WIZ_ABSTRACT (\n\
ABSTRACT_GUID                  char(36)                       not null,\n\
ABSTRACT_TYPE                  varchar(50)                     not null ,\n\
ABSTRACT_TEXT                  varchar(3000)                    ,\n\
ABSTRACT_IMAGE                  blob   ,\n\
GROUP_KBGUID                    char(36)            ,\n\
DT_MODIFIED                    char(19),\n\
primary key (ABSTRACT_GUID, ABSTRACT_TYPE)\n\
);";

static const char* lpszAbstractFiledSQL = "ABSTRACT_GUID,ABSTRACT_TYPE,ABSTRACT_TEXT,ABSTRACT_IMAGE,GROUP_KBGUID,DT_MODIFIED";

static const char* lpszAbstractTableName = "WIZ_ABSTRACT";
CTempIndex::CTempIndex()
{
    
}

CTempIndex::~CTempIndex()
{
    
}
bool CTempIndex::Open(const char* lpszFileName)
{
	if (m_db.IsOpened())
		return true;
	//
	try {
		m_db.open(lpszFileName);
		//
		if (!InitDB())
			return false;
		//
		m_strFileName = lpszFileName;
		return true;
	}
	catch (const CppSQLite3Exception& e)
	{
		TOLOG(e.errorMessage());
		return false;
	}
	catch (...) {
		TOLOG("Unknown exception while close DB");
		return false;
	}
}
void CTempIndex::Close()
{
	if (!m_db.IsOpened())
		return;
	//
	try {
		m_db.close();
	}
	catch (const CppSQLite3Exception& e)
	{
		TOLOG(e.errorMessage());
	}
	catch (...) {
		TOLOG("Unknown exception while close DB");
	}
}

bool CTempIndex::IsOpened()
{
	return m_db.IsOpened();
}

bool  CTempIndex::checkTable(const char* lpszTableName, const char* lpszTableSQL)
{
	if (m_db.tableExists(lpszTableName))
		return true;
	//
	try {

		m_db.execDML(lpszTableSQL);
		return true;
	}
	catch (const CppSQLite3Exception& e)
	{
		TOLOG(e.errorMessage());
		return false;
	}
	catch (...) {
		TOLOG("Unknown exception while close DB");
		return false;
	}
}

bool CTempIndex::InitDB()
{
	if (!m_db.IsOpened())
		return false;
	//
	if (!checkTable(lpszAbstractTableName, lpszAbstractSQL))
        return false;
	//
	return true;
}
bool CTempIndex::PadAbstractFromGUID(const char *guid, WIZABSTRACT &lpszAbstract)
{
    return AbstractFromGUID(guid, lpszAbstract, PAD_TYPE.c_str());
}

bool CTempIndex::PhoneAbstractFromGUID(const char *guid, WIZABSTRACT &lpszAbstract)
{
    return AbstractFromGUID(guid, lpszAbstract, PHONE_TYPE.c_str());
}

bool CTempIndex::sqlToAbstract(const char* lpszSql, WIZABSTRACT& lpszAbstract)
{
    if (!m_db.IsOpened()) {
        return false;
    }
    try {
        CppSQLite3Query query = m_db.execQuery(lpszSql);
        while (!query.eof()) {
            lpszAbstract.guid = query.getStringField(0);
            lpszAbstract.guid = query.getStringField(0);
            lpszAbstract.text = query.getStringField(2);
            int length;
            const unsigned char * imageData = query.getBlobField(3, length);
            lpszAbstract.setData(imageData, length);
            lpszAbstract.imageDataLength = length;
            
            lpszAbstract.kbGuid = query.getStringField(4);
            lpszAbstract.dataModified = query.getStringField(5);
            return true;
        }
        return false;
    }
    catch (const CppSQLite3Exception& e)
	{
		TOLOG(e.errorMessage());
		TOLOG(lpszSql);
		return false;
	}
	catch (...) {
		TOLOG("Unknown exception while close DB");
		return false;
	}
}

bool CTempIndex::AbstractFromGUID(const char *guid, WIZABSTRACT &lpszAbstract,const char* type)
{
    if(!m_db.IsOpened())
        return false;
    std::string sql = std::string("select ") + lpszAbstractFiledSQL + " from " +lpszAbstractTableName+" where ABSTRACT_GUID='"
                    +guid+ ("' AND ABSTRACT_TYPE=")
                    +WizStringToSQLString(type)
                    +(";");
    try {
        CppSQLite3Query query = m_db.execQuery(sql.c_str());
        while (!query.eof()) {
            lpszAbstract.guid = query.getStringField(0);
            lpszAbstract.text = query.getStringField(2);
            int length;
            const unsigned char * imageData = query.getBlobField(3, length);
            lpszAbstract.setData(imageData, length);
            lpszAbstract.imageDataLength = length;
            return true;
        }
		return false;
	}
	catch (const CppSQLite3Exception& e)
	{
		TOLOG(e.errorMessage());
		TOLOG(sql.c_str());
		return false;
	}
	catch (...) {
		TOLOG("Unknown exception while close DB");
		return false;
	}
}

bool CTempIndex::UpdatePadAbstract(const WIZABSTRACT &lpszAbstract)
{
    return UpdateAbstract(lpszAbstract,PAD_TYPE.c_str());
}

bool CTempIndex::UpdateIphoneAbstract(const WIZABSTRACT &lpszAbstract)
{
    return UpdateAbstract(lpszAbstract,PHONE_TYPE.c_str() );
}

bool CTempIndex::UpdateAbstract(const WIZABSTRACT &lpszAbstract, const char *type)
{
    if(!m_db.IsOpened())
    {
        return false;
    }
    
    std::string sql;
    WIZABSTRACT abstract;
    if (AbstractFromGUID(lpszAbstract.guid.c_str() ,abstract, type)) {
        std::string whereFiled = std::string("ABSTRACT_GUID=")
                                +WizStringToSQLString(lpszAbstract.guid)
                                +(" AND ABSTRACT_TYPE = ")
                                +WizStringToSQLString(type);
        sql = std::string("update ")+lpszAbstractTableName+ " set ABSTRACT_TEXT" + "=" + WizStringToSQLString(lpszAbstract.text) +
                ", GROUP_KBGUID=" + WizStringToSQLString(lpszAbstract.kbGuid) +
                ", DT_MODIFIED=" + WizStringToSQLString(lpszAbstract.dataModified) +
                " where " + whereFiled;
        try {
            m_db.updateBlob(lpszAbstractTableName, "ABSTRACT_IMAGE",lpszAbstract.imageData , lpszAbstract.imageDataLength, whereFiled.c_str());
            m_db.execDML(sql.c_str());
            return true;
        }
        catch (const CppSQLite3Exception& e)
        {
            TOLOG(e.errorMessage());
            TOLOG(sql.c_str());
            return false;
        }
        catch (...) {
            TOLOG("Unknown exception while update document");
            return false;
        }
    }
    else
    {
        sql = std::string("insert into ") + lpszAbstractTableName + ("(") + lpszAbstractFiledSQL + (")")
            + " values("
        + WizStringToSQLString(lpszAbstract.guid) + (",")
        + WizStringToSQLString(type) + (",")
        + WizStringToSQLString(lpszAbstract.text) + (",?,")
        + WizStringToSQLString(lpszAbstract.kbGuid) + ","
        + WizStringToSQLString(lpszAbstract.dataModified) + ")";
        try {
            m_db.insertBlob(sql.c_str(), lpszAbstract.imageData, lpszAbstract.imageDataLength, 1);
            return true;
        }
        catch (const CppSQLite3Exception& e)
        {
            TOLOG(e.errorMessage());
            TOLOG(sql.c_str());
            return false;
        }
        catch (...) {
            TOLOG("Unknown exception while update document");
            return false;
        }
        
    }
	//
	return true;
    
}

bool CTempIndex::DeleteAbstractByGUID(const char *guid)
{
    std::string sql = std::string("delete from ") + lpszAbstractTableName + " where ABSTRACT_GUID='"+guid+"'";
    try {
        m_db.execDML(sql.c_str());
        return true;
    }
    catch (const CppSQLite3Exception& e)
    {
        TOLOG(e.errorMessage());
        TOLOG(sql.c_str());
        return false;
    }
    catch (...) {
        TOLOG("Unknown exception while update document");
        return false;
    }
}

bool CTempIndex::AbstractIsExist(const char *guid, const char *type)
{
    if(!m_db.IsOpened())
        return false;
    std::string sql = std::string("select ") + "ABSTRACT_GUID" + " from " +lpszAbstractTableName+" where ABSTRACT_GUID='"
    +guid+ ("' AND ABSTRACT_TYPE=")
    +WizStringToSQLString(type)
    +(";");
    try {
        CppSQLite3Query query = m_db.execQuery(sql.c_str());
        while (!query.eof()) {
            return true;
        }
		return false;
	}
	catch (const CppSQLite3Exception& e)
	{
		TOLOG(e.errorMessage());
		TOLOG(sql.c_str());
		return false;
	}
	catch (...) {
		TOLOG("Unknown exception while close DB");
		return false;
	}
}

bool CTempIndex::PhoneAbstractExist(const char *guid)
{
    return AbstractIsExist(guid, PHONE_TYPE.c_str());
}

bool CTempIndex::PadAbstractExist(const char *guid)
{
    return AbstractIsExist(guid, PAD_TYPE.c_str());
}

bool CTempIndex::groupAbstract(const char *kbGuid, WIZABSTRACT &lpszAbstract)
{
    if (!m_db.IsOpened()) {
        return false;
    }
    std::string sql = std::string("select ")+ lpszAbstractFiledSQL +" from WIZ_ABSTRACT where GROUP_KBGUID = "+WizStringToSQLString(kbGuid) +" and  length(ABSTRACT_IMAGE) > 0 order by DT_MODIFIED desc limit 0,1";
    return sqlToAbstract(sql.c_str(), lpszAbstract);
}