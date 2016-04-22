from tkinter import *
from time import sleep
import urllib.request

def update_info():
    allinfo = urllib.request.FancyURLopener({"http":"http://xlv1:Systemd518430@136.18.240.149:83/"}).open(url).read().decode('gb2312')
    stock_list = allinfo.split(';')

    counter = 0
    for stock in stock_list:
        if stock.strip()=='':
            break
    
        slist = stock[1:-3]
        slist = slist.split('~')

        str=slist[2].ljust(7) + slist[3].ljust(8) + slist[31].ljust(7) + slist[32].ljust(7) +  slist[33].ljust(8) + slist[34].ljust(7)
        labels[counter].set(str)
        counter = counter + 1

def create_elements():
    stock_list = stocks.split(',')
    for stock in stock_list:
        s = StringVar()
        w = Label(root, textvariable=s, anchor=W, justify=LEFT)
        w.pack()
        labels.append(s)

def refresh():
    update_info();
    root.after(5000, refresh)

def mouse_move_in(event):
    root.attributes("-alpha", 0.9)

def mouse_move_out(event):
    root.attributes("-alpha", 0.1)
    
root = Tk()
root.title("WIN")
root.call('wm', 'attributes', '.', '-topmost', '1')
root.attributes("-alpha", 0.1)
root.bind("<Enter>", mouse_move_in)
root.bind("<Leave>", mouse_move_out)

fo = open("stocklist.txt")
stocks = fo.read()
fo.close()
labels = []
url = 'http://qt.gtimg.cn/q=' + stocks
create_elements()
refresh()
root.mainloop()

