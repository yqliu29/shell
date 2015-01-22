#!/usr/bin/env python2
import urllib2
import sys
import termios

def showData():
	stocks = 'sh000001,sz399101,sz399006,sh600718,sz002232,sz002362,sz000997,sz002412,sz002727'
	response = urllib2.urlopen('http://qt.gtimg.cn/q=' + stocks)
	allinfo = response.read()
	stock_list = allinfo.split(';')

	for stock in stock_list:
		if stock.strip()=='':
			break
		# parse info
		slist = stock[1:-3]
		slist = slist.split('~')

		# show info
		print '%s: ' % (slist[2][2:7]),;
		print 'Cur: %5s ' % (slist[3]),;
		print 'Inc: %5s ' % (slist[31]),;
		print 'Rat: %%%5s ' % (slist[32]),;
		print 'Hig: %5s ' % (slist[33]),;
		print 'Low: %5s ' % (slist[34]),;
		print 'Tot: %8s'%(slist[37]),;
		print '/%s' % (slist[45]);

	print '-------------------------------------------------------------------------------------------'

fd = sys.stdin.fileno()
old = termios.tcgetattr(fd)
new = termios.tcgetattr(fd)
new[3] = new[3] & ~termios.ICANON
termios.tcsetattr(fd, termios.TCSADRAIN, new)

while 1:
	showData()
	cmd = sys.stdin.read(1)
	print ''
	if cmd == 'q':
		break
