#!/usr/bin/python

import sqlite3
import os
import urllib
import xml.dom.minidom
from re import escape
import codecs
import random
import string

teams_xml_url='http://ructf.org/e/2011/registration/'
teams_pic_base_url='http://ructf.org/e/2011/registration/logos/'
sql_file='teams.sql'
advstr_filename='advstr.txt'
pics_dir='../scoreboard/img/'

class MakeEncryptError(Exception):
    def __init__(self, text):
	self.text=text

    def __str__(self):
	return repr(self.text)


def parse_teams_xml(teams_file):
    doc=xml.dom.minidom.parse(teams_file)
    teams=[]
    for team in doc.getElementsByTagName("team"):
	name=team.getAttribute("name")
	country=team.getAttribute("country")
	university=team.getAttribute("university")
	poc=team.getAttribute("poc")
	pocemail=team.getAttribute("pocemail")
	pgp=team.getAttribute("pgp")
	filename=team.getAttribute("filename")
	registered=team.getAttribute("registered")
	info=team.getAttribute("info")

	teams.append([name,country,university,poc,pocemail,pgp,filename,registered,info])

    return teams

def get_pic(name,pic,pics_dir):
    out_file=pics_dir + name
    if not os.path.exists(out_file + ".png"):
	print "+" + pic
	urllib.urlretrieve(pic,out_file)

if __name__ == '__main__':
    teams_xml = urllib.urlopen(teams_xml_url)
    teams_from_xml = parse_teams_xml(teams_xml)
    teams_xml.close()

#    f=open(sql_file,'w')
    f=codecs.open(sql_file,'w','utf-8')

#INSERT INTO teams VALUES ( 1, 'Team1', '10.1.0.0/16', '10.1.0.2' );
#INSERT INTO advauths VALUES ( 1, 'soxkeptvlbgalzxcwnzv' );
    num=1
    for team in teams_from_xml:
	name=team[0]
	pic=teams_pic_base_url + team[6]
#	get_pic(name,pic,pics_dir)
#	f.write(u"INSERT INTO teams VALUES ( '%s', '%s', '10.%s.0.0/16', '10.%s.0.2' );\n" % (num,name,num,num))
	print  >>f, u"INSERT INTO teams VALUES ( '%s', E'%s', '10.23.%s.0/24', '10.23.%s.3' );" % (num,escape(name),num,num)
	num+=1
    print >>f, u""
    
#    with codecs.open(advstr_filename,'w',"utf-8") as advstr_fp:
#	num=1
#	for team in teams_from_xml:
#	    name=team[0]
#	    rand_str="".join([random.choice(string.letters) for x in xrange(36)])
#	    print >>f, u"INSERT INTO advauths VALUES ( %s, '%s' );" % (num, rand_str)
#	    print >>advstr_fp, u"%s\t%s\t%s" % (num,name,rand_str)
#	    num+=1
    f.close()
