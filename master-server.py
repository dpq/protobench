#!/usr/bin/python
# -*- coding: utf-8 -*-

from gevent import monkey; monkey.patch_all()
from gevent.wsgi import WSGIServer
from math import sqrt

from werkzeug import Request, Response
import logging, os, getopt, sys, new, hmac, hashlib
from urllib import quote_plus as quote, urlencode
from uuid import uuid4
from ConfigParser import ConfigParser

from urllib2 import urlopen
from geventmemcache.client import Memcache
from werkzeug import Local, LocalManager

from simplejson import dumps as tojson, loads as fromjson
import codecs
import umysql
import paramiko
import scp
from tempfile import NamedTemporaryFile

local = Local()
local_manager = LocalManager([local])

clients = ["95.31.18.190", "213.131.1.100", "213.131.9.133", "213.131.1.8"]
proxy = "ec2-54-246-11-57.eu-west-1.compute.amazonaws.com"
protocols = ["ftp", "http", "udt", "gridftp", "torrent"]
servers = [ "ec2-46-51-151-157.eu-west-1.compute.amazonaws.com",
            "ec2-54-246-25-191.eu-west-1.compute.amazonaws.com",
            "ec2-54-246-21-4.eu-west-1.compute.amazonaws.com",
            "ec2-46-137-51-34.eu-west-1.compute.amazonaws.com" ]

my = umysql.Connection()
my.connect("127.0.0.1", 3306, "protobench", "isaevwillbeproud", "protobench")

import os

class MasterServer(object):
  def __init__(self):
    local.application = self

  def __call__(self, env, start_response):
    local.application = self
    req = Request(env)
    resp = Response(status=200)
    start_response('200 OK', [('Content-Type', 'text/plain')])

    if req.path == '/start':
      # Have all arguments been passed?
      if not (req.values.has_key("protocol") and req.values.has_key("ncli") and req.values.has_key("nsrv") and req.values.has_key("rep")):
        resp.status_code = 500
        resp.response = ["One of the mandatory arguments has been omitted [protocol, ncli, nsrv, rep]"]
        return resp(env, start_response)

      # Does protocol have a valid value?
      protocol = req.values["protocol"]
      if protocol not in protocols:
        resp.status_code = 500
        resp.response = ["Protocol specified is not implemented; must be one of [ftp, http, udt, gridftp, torrent]"]
        return resp(env, start_response)

      # Do these arguments have valid numeric values?
      try:
        ncli, nsrv, rep = int(req.values["ncli"]), int(req.values["nsrv"]), int(req.values["rep"])
      except:
        resp.status_code = 500
        resp.response = ["Unable to parse a mandatory numeric argument"]
        return resp(env, start_response)

      # Do the numeric arguments make sense?
      if ncli < 1 or nsrv < 1 or rep < 1:
        resp.status_code = 500
        resp.response = ["Go screw yourself"]
        return resp(env, start_response)
      if ncli > len(clients):
        resp.status_code = 500
        resp.response = ["We don't have that many clients available. Current maximum is %d" % len(clients)]
        return resp(env, start_response)
      if nsrv > len(servers):
        resp.status_code = 500
        resp.response = ["We don't have that many servers available. Current maximum is %d" % len(servers)]
        return resp(env, start_response)

      # Has the previous experiment been finished already? For that, its nclients*replication must be equal to the number of associated measurements
      res = my.query("select max(id) from experiment")
      last_exp_id = res.rows[0][0]
      if last_exp_id:
        res = my.query("select replication, ncli from experiment where id=%s", (last_exp_id,))
        rep_prev, ncli_prev = res.rows[0][0], res.rows[0][1]
        res = my.query("select count(*) from measurement where experiment_id=%s", (last_exp_id,))
        cnt = res.rows[0][0]
        if cnt < rep_prev*ncli_prev:
          resp.status_code = 500
          resp.response = ["Unable to comply, experiment in progress"]
          return resp(env, start_response)

      f = NamedTemporaryFile(delete=False)
      f.write(generatehaproxycfg(nsrv))
      f.close()
      
      local.ssh = paramiko.SSHClient()
      local.ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
      local.ssh.connect(proxy, username='root', key_filename='/home/rumith/.ssh/awskeys.pem')
      local.scp = scp.SCPClient(local.ssh.get_transport())
      local.scp.put(f.name, "/etc/haproxy/haproxy.cfg")
      if protocol == "http":
        stdin, stdout, stderr = local.ssh.exec_command('pkill haproxy; haproxy -f /etc/haproxy/haproxy.cfg')
      local.ssh.close()

      os.unlink(f.name)

      expcount, experiment_id = my.query("insert into experiment (started, protocol, ncli, nsrv, replication) values ((select now()), %s, %s, %s, %s)", (protocol, ncli, nsrv, rep))

      # Copy the required protocol download programs to the clients used and start them
      for i in range(ncli):
        local.ssh = paramiko.SSHClient()
        local.ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        local.ssh.connect(clients[i], username='rumith', key_filename='/home/rumith/.ssh/id_rsa')
        local.scp = scp.SCPClient(local.ssh.get_transport())
        local.scp.put("protocol-%s.sh" % protocol, "/home/protobench")
        if protocol == "http":
          stdin, stdout, stderr = local.ssh.exec_command('cd /home/protobench && ./protocol-%s.sh %s %s 1 > /dev/null 2>&1 &' % (protocol, proxy, experiment_id))
        local.ssh.close()
        
      resp.response = ["Experiment %d x %d [%s] successfully started; replication %d" % (nsrv, ncli, protocol, rep) ]
      return resp(env, start_response)

    elif req.path ==  '/done':
      # Did the client pass all the required arguments?
      if not (req.values.has_key("expid") and req.values.has_key("runid") and req.values.has_key("bw")):
        resp.status_code = 500
        resp.response = ["One of the mandatory arguments has been omitted [expid, runid, bw]"]
        return resp(env, start_response)
      
      # Do they have legal values?
      try:
        expid, runid, bandwidth = int(req.values["expid"]), int(req.values["runid"]), int(req.values["bw"])
      except:
        resp.status_code = 500
        resp.response = ["Unable to parse mandatory arguments"]
        return resp(env, start_response)
        
      # Is there really such an experiment to commit to?      
      res = my.query("select count(*) from experiment where id = %s", (req.values["expid"],))
      expcnt = res.rows[0][0]
      if expcnt == 0:
        resp.status_code = 500
        resp.response = ["No such experiment"]
        return resp(env, start_response)

      # Is this run being reported for the first time from this host?
      res = my.query("select count(*) from measurement where experiment_id = %s and run_id = %s and client_host = %s", (expid, runid, req.remote_addr))
      runcheck = res.rows[0][0]
      if runcheck > 0:
        resp.status_code = 500
        resp.response = ["Such a run already exists"]
        return resp(env, start_response)
      
      # Does bandwidth have a valid value?
      if bandwidth < 0:
        resp.status_code = 500
        resp.response = ["Bad bandwidth value"]
        return resp(env, start_response)    

      # Commit the measurement
      my.query("insert into measurement (experiment_id, run_id, bandwidth, client_host) values (%s, %s, %s, %s)", (expid, runid, bandwidth, req.remote_addr))

      # Do we have enough replication for this host/experiment pair, or should we launch the task again?
      res = my.query("select replication, protocol from experiment where id=%s", (expid,))
      replication, protocol = res.rows[0][0], res.rows[0][1]
      res = my.query("select count(*) from measurement where experiment_id=%s and client_host=%s", (expid, req.remote_addr))
      runcnt = res.rows[0][0] 
      if replication > runcnt:
        local.ssh = paramiko.SSHClient()
        local.ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        local.ssh.connect(req.remote_addr, username='rumith', key_filename='/home/rumith/.ssh/id_rsa')
        if protocol == "http":
          stdin, stdout, stderr = local.ssh.exec_command('cd /home/protobench && ./protocol-%s.sh %s %s %s > /dev/null 2>&1 &' % (protocol, proxy, expid, (runid + 1)))
        local.ssh.close()        
      else:
        # If we have enough replication for this one, maybe we have everything from other clients, too, and can finish the experiment?
        res = my.query("select replication, ncli from experiment where id=%s", (expid,))
        rep, ncli = res.rows[0][0], res.rows[0][1]
        res = my.query("select count(*) from measurement where experiment_id=%s", (expid,))
        cnt = res.rows[0][0]
        if cnt > 0 and cnt == rep*ncli:
          bw = []
          res = my.query("select bandwidth from measurement where experiment_id=%s", (expid,))
          for r in res.rows:
            bw.append(r[0])
          bsum = float(sum(bw)) / rep
          sigma = 0
          for i in range(rep):
            delta = bw[i] - bsum
            sigma += delta**2
          bw, mse = bsum, sqrt(sigma/rep)
          my.query("update experiment set ended=(select now()), bandwidth=%s, mse=%s where id=%s", (bw, mse, expid))
          
      return resp(env, start_response)

    elif req.path == '/status':
      return resp(env, start_response)
    else:
      resp.status_code = 404
      resp.response = ["Invalid request"]
      return resp(env, start_response)

def generatehaproxycfg(nsrv):
  globalsection = """global
    log 127.0.0.1   syslog
    maxconn 15000
    #chroot /usr/share/haproxy
    user haproxy
    group haproxy
    daemon

defaults
    log global
    mode    http
    option  httplog
    option  httpclose
    option  dontlognull
    retries 3
    contimeout  5000
    clitimeout  50000
    srvtimeout  50000"""

  ftpsection = """listen ftp 0.0.0.0:21
    mode tcp
    option tcplog
    balance leastconn"""

  httpsection = """listen nginx 0.0.0.0:80
    balance roundrobin"""

  for i in range(nsrv):
    ftpsection += "\n    server ftp%d %s:21 check" % (i, servers[i])
    httpsection += "\n    server nginx%d %s:80 check" % (i, servers[i])

  return globalsection + "\n\n\n" + ftpsection + "\n\n\n" + httpsection + "\n"


def main():
  master = MasterServer()
  server = WSGIServer(("0.0.0.0", 9090), master)
  try:
    logging.info("Server running on port %s. Ctrl+C to quit" % 9090)
    server.serve_forever()
  except KeyboardInterrupt:
    server.stop()
    logging.info("Server stopped")

if __name__ == "__main__":
    main()
