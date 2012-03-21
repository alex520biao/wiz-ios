//
//  CTempIndex.h
//  Wiz
//
//  Created by dong yishuiliunian on 11-12-30.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#include <string>
#include <vector>
#import "CppSQLite3.h"
#ifndef Wiz_tempIndex_h
#define Wiz_tempIndex_h

struct WIZABSTRACT
{
    std::string guid;
    std::string text;
    unsigned char* imageData;
    int imageDataLength;
    //
    WIZABSTRACT()
    : imageData(NULL)
    , imageDataLength(0)
    {
        
        
    }
    ~WIZABSTRACT()
    {
        if (imageData)
        {
            delete [] imageData;
            imageData = NULL;
        }
    }
    //
    void setData(const unsigned char* p, int len)
    {
        if (imageData != NULL) {
            delete [] imageData;
            imageData = NULL;
        }
        imageData = new unsigned char[len];
        if (imageData == NULL) {
            return;
        }
        memcpy(imageData, p, len);
        
    }
    
};

class CTempIndex {
public:
	CTempIndex();
	~CTempIndex();
private:
	CppSQLite3DB m_db;
	std::string m_strFileName;
private:
	bool InitDB();
	bool checkTable(const char* lpszTableName, const char* lpszTableSQL);
    bool UpdateAbstract(const WIZABSTRACT& lpszAbstract,const char* type);
    bool AbstractFromGUID(const char* guid, WIZABSTRACT& lpszAbstract,const char* type);
    bool AbstractIsExist(const char* guid,const char* type);
public:
	bool Open(const char* lpszFileName);
	void Close();
	bool IsOpened();
    bool UpdatePadAbstract(const WIZABSTRACT &lpszAbstract);
    bool UpdateIphoneAbstract(const WIZABSTRACT &lpszAbstract);
    bool PhoneAbstractFromGUID(const char* guid, WIZABSTRACT& lpszAbstract);
    bool PadAbstractFromGUID(const char* guid, WIZABSTRACT& lpszAbstract);
    bool DeleteAbstractByGUID(const char* guid);
    bool PhoneAbstractExist(const char* guid);
    bool PadAbstractExist(const char* guid);
};

#endif
