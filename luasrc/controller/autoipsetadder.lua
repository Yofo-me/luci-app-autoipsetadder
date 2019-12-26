module("luci.controller.autoipsetadder",package.seeall)
io     = require "io"
fs=require"nixio.fs"
sys=require"luci.sys"
function index()
	entry({"admin","services","autoipsetadder"},firstchild(),_("autoipsetadder"),30).dependent=true
	entry({"admin","services","autoipsetadder","autoipsetadder"},cbi("autoipsetadder"),_("Base Setting"),1)
    entry({"admin","services","autoipsetadder","status"},call("act_status")).leaf=true
	entry({"admin", "services", "autoipsetadder", "getlog"}, call("get_log"))
	entry({"admin", "services", "autoipsetadder", "dodellog"}, call("do_del_log"))
	entry({"admin", "services", "autoipsetadder", "debugip"}, call("do_debug_ip"))
end

function act_status()
  local e={}
  e.running=luci.sys.call("pgrep -f tail >/dev/null")==0
  luci.http.prepare_content("application/json")
  luci.http.write_json(e)
end
function do_del_log()
nixio.fs.writefile("/tmp/addlist.log","")
luci.http.prepare_content("application/json")
luci.http.write('')
end
function do_debug_ip()
luci.http.prepare_content("text/plain; charset=utf-8")
a=sys.exec("/usr/bin/autoipsetadder/debugip.sh")
if (a=="") then
a="noproblem"
end
luci.http.write(a)
end
function get_log()
	local logfile=uci:get("autoipsetadder","autoipsetadder","logfile") or "/tmp/addlist.log"
	luci.http.prepare_content("text/plain; charset=utf-8")
	local fdp=tonumber(fs.readfile("/var/run/lucilogpos_ipset")) or 0
	local f=io.open(logfile, "r+")
	f:seek("set",fdp)
	local a=f:read(2048000) or ""
	fdp=f:seek()
	fs.writefile("/var/run/lucilogpos_ipset",tostring(fdp))
	f:close()
	luci.http.write(a)
end