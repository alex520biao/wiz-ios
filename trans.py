import codecs
import os
import traceback
import sys
reload(sys)
sys.setdefaultencoding('utf-8')
outPutDir = '/Users/wiz/WizDzIos/wiz-ios/English.lproj/'
sourceDir = '/Users/wiz/WizDzIos/wiz-ios/Classes'
dicFile = 'zh.txt'
def genstrings(level, path):
	for i in os.listdir(path):
		if os.path.isdir(path+'/'+i):
			x = 'genstrings -a -o '+ outPutDir+' ' +path + '/'+i+'/*.m'
			print x
			os.system(x)
			os.system('genstrings -a -o '+ outPutDir+' ' +path + '/'+i+'/*.h')
			os.system('genstrings -a -o '+ outPutDir+' ' +path + '/'+i+'/*.mm')
			genstrings(level+1,path+'/'+i)
genstrings(0,sourceDir)
transFile = codecs.open(dicFile,'r','utf-8')
transLines = transFile.readlines()
transDic = {}
for line in transLines:
	if(len(line)==0):
		continue
	strr = line.split('=')
	if(len(strr) == 1):
		continue
	en = strr[0]
	en = en[en.index('"')+1:len(en)]
	en = en[0:en.index('"')]
	zh = strr[1]
	zh = zh[zh.index('"')+1:len(zh)]
	zh = zh[0:zh.index('"')]
	transDic[en]=zh;
needFile = codecs.open(outPutDir+'/Localizable.strings','rw','utf-16')
needTransDic = {}
def sortDict(adict):
	items = adict.items()
	items.sort()
	return [value for key, value in items]
for line in needFile.readlines():
	try:
		if(len(line)==0):
			continue
		strr = line.split('=')
		if(len(strr) == 1):
			continue
		en = strr[0]
		en = en[en.index('"')+1:len(en)]
		en = en[0:en.index('"')]
		print needTransDic[en]
		print en + '\n'
	except KeyError:
		strr = line.split('=')
		en = strr[0]
		en = en[en.index('"')+1:len(en)]
		en = en[0:en.index('"')]
		zh=''
		needTransDic[en]=zh
print 'need trans dic len is'
print  len(needTransDic)
needTransDic = sortDict(needTransDic)
print needTransDic
print 'dic len is'
print len(transDic)
for key in needTransDic.keys():
	try:
		needTransDic[key] = transDic[key]
	except KeyError,e:
		continue
for key in needTransDic.keys():
	if (cmp(needTransDic[key],'')==0):
		transilation = raw_input('please input the translation of ***'+key+'*****:')
		print transilation
		needTransDic[key]=transilation
outFile = codecs.open('result.txt','w','utf-8')
ooutEnglishFile = cdecs.open(outPutDir+'/Localizable.strings','w','utf-16')
needTransDic = sortDict(needTransDic)
print needTransDic
for key in needTransDic.keys():
	try:
		outFile.write('"'+key+'"="'+needTransDic[key]+'";\n')
		outEnglishFile.write('"'+key+'"="'+key+'";\n')
	except UnicodeDecodeError,e:
		continue
