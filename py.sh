#!/usr/bin/env python2
import feedparser
import HTMLParser

rss_url = "http://learningenglish.voanews.com/api/epiqq"
	     
print "checking " + rss_url + "..."
rss = feedparser.parse(rss_url)
html_parser = HTMLParser.HTMLParser()

f = open('htmllist.txt', 'w')
for item in rss['items']:
	print >>f, '%s,%s.mp3' % (unicode(item.link).encode('utf8'),unicode(item.title_detail.value).encode('utf8'))
	print item.title_detail.value
	f1 = open(item.title_detail.value + ".txt", 'w')
	raw = html_parser.unescape(item.summary_detail.value)
	raw2 = unicode(raw).encode('utf8')
	print >>f1, raw2
