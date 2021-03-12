#!/usr/bin/env python2

import datetime
import numpy
import sys
import time

from qpython import qconnection
from qpython.qcollection import qlist
from qpython.qtype import QException, QTIME_LIST, QSYMBOL_LIST, QFLOAT_LIST
from numpy import genfromtxt

def read_csv(filename):
        data = genfromtxt(filename, delimiter=',', dtype=("|S10", float, float,int,int), skip_header=1)
        return data

if __name__ == '__main__':
    
    with qconnection.QConnection(host='psclxd00625', port=5011) as q:

        print(q)
        print('IPC version: %s. Is connected: %s' % (q.protocol_version, q.is_connected()))

        for row in read_csv('/home/cruisea/AdvanceQuestions/Q3/API/python/APIQuote.csv'):
  
            tick = [numpy.string_(row[0]),
                    numpy.float_(row[1]),
                    numpy.float_(row[2]),
                    numpy.int_(row[3]),
                    numpy.int_(row[4])] 
            print('Publishing row of tick data')
            print(tick)
            q.sync('.u.upd', numpy.string_('quote'), tick)
            time.sleep(1)
