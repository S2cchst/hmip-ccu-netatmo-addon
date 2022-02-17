#!/bin/tclsh

load tclrega.so

# Helper procedure to parse commandline arguments into variables
# Arguments:
# arguments source (e. g. argv)
# argumentname (with leading -)
# argument value target
# default value
proc getopt {_argv name {_var ""} {default ""}} {
    upvar 1 $_argv argv $_var var
    set pos [lsearch -regexp $argv ^$name]

    if {$pos >= 0} {
        set to $pos

        if {$_var != ""} {
            set var [lindex $argv [incr to]]
        }

        set argv [lreplace $argv $pos $to]

        return 1
    } else {
        if {[llength [info level 0]] == 5} {
            set var $default
        }

        return 0
    }
}

#---------------------------------------------------------------------------------------------------------------#
#                                                   CONFIG                                                      #
#---------------------------------------------------------------------------------------------------------------#
#  to obtain your own client ID and API key please register a new app here: http://dev.netatmo.com/dev/listapps
# read clientId from commandline (-clientid required)
getopt argv -clientid clientId ""
# read clientSecret from commandline (-clientSecret required)
getopt argv -clientsecret clientSecret ""

#  the following are your normal netatmo credentials (the ones you used to setup your netatmo weather station)
# read username from commandline (-username required)
getopt argv -username username ""
# read password from commandline (-password required)
getopt argv -password password ""

#  the following are MAC addresses of your indoor station and the outside module and rain module
# read mainmodule deviceid from commandline (-deviceid required)
getopt argv -deviceid deviceid ""
# read outdoor moduleid from commandline (-moduleid optional)
getopt argv -moduleid moduleid "XX:XX:XX:XX:XX:XX"
# read rainmoduleid from commandline (-rainid optional)
getopt argv -rainid rainid "XX:XX:XX:XX:XX:XX"
# read windmoduleid from commandline (-windid optional)
getopt argv -windid windid "XX:XX:XX:XX:XX:XX"

# read additional moduleid1 from commandline (-z1moduleid optional)
getopt argv -z1moduleid z1moduleid "XX:XX:XX:XX:XX:XX"
# read additional moduleid2 from commandline (-z2moduleid optional)
getopt argv -z2moduleid z2moduleid "XX:XX:XX:XX:XX:XX"
# read additional moduleid3 from commandline (-z3moduleid optional)
getopt argv -z3moduleid z3moduleid "XX:XX:XX:XX:XX:XX"

if {$clientId == ""} {
    puts "parameter clientId not set"
    exit 1
}

# check if all required arguments are set
if {$clientSecret == ""} {
    puts "parameter clientSecret not set"
    exit 1
}

if {$username == ""} {
    puts "parameter username not set"
    exit 1
}

if {$password == ""} {
    puts "parameter password not set"
    exit 1
}

if {$deviceid == ""} {
    puts "parameter deviceid not set"
    exit 1
}

set ::env(LD_LIBRARY_PATH) "/usr/local/addons/cuxd"
set cfgfile "/tmp/netatmo.dat"
set logtag "netatmo.tcl"
set logfacility "local1"
# 0=panic, 1=alert 2=crit 3=err 4=warn 5=notice 6=info 7=debug
set loglevel 6
#---------------------------------------------------------------------------------------------------------------#

#---------------------------------------------------------------------------------------------------------------#
#                                              GLOBAL VARIABLES                                                 #
#---------------------------------------------------------------------------------------------------------------#
set accesstoken ""
set refreshtoken ""
set tokenexpires 0
#---------------------------------------------------------------------------------------------------------------#

set loglevels {panic alert crit err warn notice info debug}

# write log
# arguments:
# loglevel
# logmessage
proc log {lvl msg} {
    global logtag
    global logfacility
    global loglevel
    global loglevels

    set lvlnum [lsearch $loglevels $lvl]

    if {$lvlnum <= $loglevel} {
        if {$lvlnum <= 3} {
            catch {exec logger -s -t $logtag -p $logfacility.$lvl $msg}
        } else {
            puts "$lvl: $msg"
            catch {exec logger -t $logtag -p $logfacility.$lvl $msg}
        }
    }
}

# refresh expired token
# arguments:
# old token
# clientid
# clientsecret
proc refreshToken {rt ci cs} {
    log debug "refreshing token"
    set url "https://api.netatmo.net/oauth2/token"
    set header "Content-Type: application/x-www-form-urlencoded;charset=UTF-8"
    set parameter "grant_type=refresh_token&refresh_token=$rt&client_id=$ci&client_secret=$cs"

    catch {exec /usr/local/addons/cuxd/curl -k -i -H $header -X POST -d $parameter $url} response
    log debug "response was $response"

    return $response
}

# send token request
# arguments:
# clientid
# clientsecret
# username
# password
proc requestToken {ci cs un pw} {
    log debug "requesting new token"
    set url "https://api.netatmo.net/oauth2/token"
    set header "Content-Type: application/x-www-form-urlencoded;charset=UTF-8"
    set parameter "grant_type=password&client_id=$ci&client_secret=$cs&username=$un&password=$pw"

    catch {exec /usr/local/addons/cuxd/curl -k -i -H $header -X POST -d $parameter $url} response
    log debug "response was $response"

    return $response
}

# parse oauth request response
# arguments:
# oauthresponse
proc parseOAuthResponse {input} {
    log debug "parsing authentification result"
    global accesstoken
    global refreshtoken

    regexp {HTTP/1.1\s(\d*) } $input dummy returncode
    regexp {\"access_token\":\"(.*?)\"} $input dummy accesstoken
    regexp {\"refresh_token\":\"(.*?)\"} $input dummy refreshtoken
    regexp {\"expires_in\":(.*?)\,} $input dummy expiresin

    log debug "returncode is $returncode"
    log debug "access token is $accesstoken"
    log debug "refresh token is $refreshtoken"
    log debug "expires in $expiresin"

    if {[expr $returncode]!=200} {
        log error "Authentification failed with code $returncode and response $input"
        exit 1
    }

    return $expiresin
}

# save retrieved accesstoken
# arguments:
# expirationtimestamp
proc saveAccessToken {expin} {
    global accesstoken
    global refreshtoken
    global tokenexpires
    global cfgfile

    log debug "saving new access token to $cfgfile"

    set fileId [open $cfgfile "w"]

    set now [clock seconds]
    set tokenexpires [expr $now + $expin]

    puts $fileId $accesstoken
    puts $fileId $refreshtoken
    puts $fileId $tokenexpires
    close $fileId
}

# load accesstoken
proc loadAccessToken {} {
    global accesstoken
    global refreshtoken
    global tokenexpires
    global cfgfile

    log debug "loading stored credentials from $cfgfile"

    set fp [open $cfgfile r]
    set file_data [read $fp]
    close $fp

    log debug "file data is: $file_data"

    set data [split $file_data "\n"]

    set accesstoken [lindex $data 0]
    set refreshtoken [lindex $data 1]
    set tokenexpires [lindex $data 2]
}

log debug "script has started"

# load or request accesstoken to retrieve moduledata
if { [file exists $cfgfile] == 1} {
    log info "found stored credentials"
    loadAccessToken
    set now [clock seconds]
    log debug "current time is [clock format $now -format "%Y-%m-%dT%H:%M:%S"], token is valid until [clock format $tokenexpires -format "%Y-%m-%dT%H:%M:%S"]"
    if {[expr $now >= $tokenexpires] == 1} {
        log notice "token has already expired"
        saveAccessToken [parseOAuthResponse [refreshToken $refreshtoken $clientId $clientSecret]]
        log notice "oauth token successfully refreshed"
    } else {
        log info "token is still valid"
    }
} else {
    log warn "no stored credentials found"
    saveAccessToken [parseOAuthResponse [requestToken $clientId $clientSecret $username $password]]
    log notice "oauth token successfully initialized"
}

# polling mainmodule data
log debug "polling main module..."
set url "https://api.netatmo.net/api/getmeasure?access_token=$accesstoken&device_id=$deviceid&scale=max&type=Temperature,Humidity,CO2,Pressure,Noise&date_end=last"
log debug "querying $url"
catch {exec /usr/local/addons/cuxd/curl -k -# $url} response
log debug "response is: $response"

regexp {\"value\":\[\[(.*?),(.*?),(.*?),(.*?),(.*?)\]} $response dummy itemp ihum ico2 ipressure inoise

log info "LogI is $response"
log info "Inside temperature is $itemp"
log info "Inside humidity is $ihum"
log info "Inside CO2 level is $ico2"
log info "Inside pressure is $ipressure"
log info "Inside noise level is $inoise"

# polling outdoor module data if moduleid is set
if {$moduleid != "XX:XX:XX:XX:XX:XX"} {
    log debug "polling outdoor module..."
    set url "https://api.netatmo.net/api/getmeasure?access_token=$accesstoken&device_id=$deviceid&module_id=$moduleid&scale=max&type=Temperature,Humidity&date_end=last"
    log debug "querying $url"
    catch {exec /usr/local/addons/cuxd/curl -k -# $url} response
    log debug "response is: $response"

    regexp {\"value\":\[\[(.*?),(.*?)\]} $response dummy otemp ohum

    log info "LogO is $response"
    log info "Outside temperature is $otemp"
    log info "Outside humidity is $ohum"
}

# polling rainmodule data if rainid is set
if {$rainid != "XX:XX:XX:XX:XX:XX"} {
    log debug "polling rain module..."
    set url "https://api.netatmo.net/api/getmeasure?access_token=$accesstoken&device_id=$deviceid&module_id=$rainid&scale=1day&type=sum_rain&date_end=last"
    log debug "querying $url"
    catch {exec /usr/local/addons/cuxd/curl -k -# $url} response
    log debug "response is: $response"

    regexp {\"value\":\[\[(.*?)\]} $response dummy rain1d

    log info "LogR is $response"
    log info "Outside rain1d is $rain1d"

    log debug "polling rain module... 30min"
    set url "https://api.netatmo.net/api/getmeasure?access_token=$accesstoken&device_id=$deviceid&module_id=$rainid&scale=30min&type=Rain,sum_rain&date_end=last"
    log debug "querying $url"
    catch {exec /usr/local/addons/cuxd/curl -k -# $url} response
    log debug "response is: $response"

    regexp {\"value\":\[\[(.*?),(.*?)\]} $response dummy rain2 rain30min

    log info "LogR2 is $response"
    log info "Outside rain30min is $rain30min"
}

# polling windmodule data if windid is set
if {$windid != "XX:XX:XX:XX:XX:XX"} {
    log debug "polling wind module..."
    set url "https://api.netatmo.net/api/getmeasure?access_token=$accesstoken&device_id=$deviceid&module_id=$windid&scale=max&type=WindAngle,WindStrength,GustAngle,GustStrength&date_end=last"
    log debug "querying $url"
    catch {exec /usr/local/addons/cuxd/curl -k -# $url} response
    log debug "response is: $response"

    regexp {\"value\":\[\[(.*?),(.*?),(.*?),(.*?)\]} $response dummy windangle windstrength gustangle guststrength

    log info "LogW is $response"
    log info "Outside windAngle is $windangle"
    log info "Outside windStrength is $windstrength"
    log info "Outside gustAngle is $gustangle"
    log info "Outside gustStrength is $guststrength"
}

# polling first additional module data if z1moduleid is set
if {$z1moduleid != "XX:XX:XX:XX:XX:XX"} {
    log debug "polling additional module1..."
    set url "https://api.netatmo.net/api/getmeasure?access_token=$accesstoken&device_id=$deviceid&module_id=$z1moduleid&scale=max&type=Temperature,Humidity,CO2&date_end=last"
    log debug "querying $url"
    catch {exec /usr/local/addons/cuxd/curl -k -# $url} response
    log debug "response is: $response"

    regexp {\"value\":\[\[(.*?),(.*?),(.*?)\]} $response dummy z1itemp z1ihum z1ico2

    log info "LogZ1 is $response"
    log info "Inside additional temperature is $z1itemp"
    log info "Inside additional humidity is $z1ihum"
    log info "Inside additional CO2 level is $z1ico2"
}

# polling second additional module data if z2moduleid is set
if {$z2moduleid != "XX:XX:XX:XX:XX:XX"} {
    log debug "polling additional module2..."
    set url "https://api.netatmo.net/api/getmeasure?access_token=$accesstoken&device_id=$deviceid&module_id=$z2moduleid&scale=max&type=Temperature,Humidity,CO2&date_end=last"
    log debug "querying $url"
    catch {exec /usr/local/addons/cuxd/curl -k -# $url} response
    log debug "response is: $response"

    regexp {\"value\":\[\[(.*?),(.*?),(.*?)\]} $response dummy z2itemp z2ihum z2ico2

    log info "LogZ2 is $response"
    log info "Inside additional temperature is $z2itemp"
    log info "Inside additional humidity is $z2ihum"
    log info "Inside additional CO2 level is $z2ico2"
}

# polling third additional module data if z3moduleid is set
if {$z3moduleid != "XX:XX:XX:XX:XX:XX"} {
    log debug "polling additional module3..."
    set url "https://api.netatmo.net/api/getmeasure?access_token=$accesstoken&device_id=$deviceid&module_id=$z3moduleid&scale=max&type=Temperature,Humidity,CO2&date_end=last"
    log debug "querying $url"
    catch {exec /usr/local/addons/cuxd/curl -k -# $url} response
    log debug "response is: $response"

    regexp {\"value\":\[\[(.*?),(.*?),(.*?)\]} $response dummy z3itemp z3ihum z3ico2

    log info "LogZ3 is $response"
    log info "Inside additional temperature is $z3itemp"
    log info "Inside additional humidity is $z3ihum"
    log info "Inside additional CO2 level is $z3ico2"
}

#
# set ReGaHss variables
#

# register mainmodule data target
set rega_cmd ""
append rega_cmd "var ITemp = dom.GetObject('CUxD.CUX9002001:1.SET_TEMPERATURE');"
append rega_cmd "var IHumi = dom.GetObject('CUxD.CUX9002001:1.SET_HUMIDITY');"
append rega_cmd "var IPress = dom.GetObject('Luftdruck');"
append rega_cmd "var ICO2 = dom.GetObject('CO2');"
append rega_cmd "var INoise = dom.GetObject('Sonometer');"

# register outdoor module data target if moduleid is set
if {$moduleid != "XX:XX:XX:XX:XX:XX"} {
    append rega_cmd "var OTemp = dom.GetObject('CUxD.CUX9002002:1.SET_TEMPERATURE');"
    append rega_cmd "var OHumi = dom.GetObject('CUxD.CUX9002002:1.SET_HUMIDITY');"
}

# register rainmodule data target if rainid is set
if {$rainid != "XX:XX:XX:XX:XX:XX"} {
    append rega_cmd "var Rain1 = dom.GetObject('Regenmenge_30min');"
    append rega_cmd "var Rain2 = dom.GetObject('Regenmenge_1d');"
    append rega_cmd "var Rain3 = dom.GetObject('Regenmenge_aktuell');"
}

# register windmodule data target if windid ís set
if {$windid != "XX:XX:XX:XX:XX:XX"} {
    append rega_cmd "var windA = dom.GetObject('Windrichtung');"
    append rega_cmd "var windS = dom.GetObject('Windstaerke');"
    append rega_cmd "var gustA = dom.GetObject('Gustangle');"
    append rega_cmd "var gustS = dom.GetObject('Guststaerke');"
}

# register first additional module data target if z1moduleid is set
if {$z1moduleid != "XX:XX:XX:XX:XX:XX"} {
    append rega_cmd "var Z1ITemp = dom.GetObject('CUxD.CUX9002003:1.SET_TEMPERATURE');"
    append rega_cmd "var Z1IHumi = dom.GetObject('CUxD.CUX9002003:1.SET_HUMIDITY');"
    append rega_cmd "var Z1ICO2 = dom.GetObject('Z1_CO2');"
}

# register second additional module data target if z2moduleid is set
if {$z2moduleid != "XX:XX:XX:XX:XX:XX"} {
    append rega_cmd "var Z2ITemp = dom.GetObject('CUxD.CUX9002004:1.SET_TEMPERATURE');"
    append rega_cmd "var Z2IHumi = dom.GetObject('CUxD.CUX9002004:1.SET_HUMIDITY');"
    append rega_cmd "var Z2ICO2 = dom.GetObject('Z2_CO2');"
}

# register third additional module data target if z3moduleid is set
if {$z3moduleid != "XX:XX:XX:XX:XX:XX"} {
    append rega_cmd "var Z3ITemp = dom.GetObject('CUxD.CUX9002005:1.SET_TEMPERATURE');"
    append rega_cmd "var Z3IHumi = dom.GetObject('CUxD.CUX9002005:1.SET_HUMIDITY');"
    append rega_cmd "var Z3ICO2 = dom.GetObject('Z3_CO2');"
}

# set mainmodule data for push
append rega_cmd "ITemp.State('$itemp');"
append rega_cmd "IHumi.State('$ihum');"
append rega_cmd "IPress.State('$ipressure');"
append rega_cmd "ICO2.State('$ico2');"
append rega_cmd "INoise.State('$inoise');"

# set outdoor module data for push if moduleid is set
if {$moduleid != "XX:XX:XX:XX:XX:XX"} {
    append rega_cmd "OTemp.State('$otemp');"
    append rega_cmd "OHumi.State('$ohum');"
}

# set rainmodule data for push if rainid is set
if {$rainid != "XX:XX:XX:XX:XX:XX"} {
    append rega_cmd "Rain1.State('$rain30min');"
    append rega_cmd "Rain2.State('$rain1d');
    append rega_cmd "Rain3.State('$rain2');
}

# set windmodule data for push if windid is set
if {$windid != "XX:XX:XX:XX:XX:XX"} {
    append rega_cmd "windA.State('$windaangle');"
    append rega_cmd "windS.State('$windstrength');"
    append rega_cmd "gustA.State('$gustangle');"
    append rega_cmd "gustS.State('$guststrength');"
}

# set first additional module data for push if z1moduleid is set
if {$z1moduleid != "XX:XX:XX:XX:XX:XX"} {
    append rega_cmd "Z1ITemp.State('$z1itemp');"
    append rega_cmd "Z1IHumi.State('$z1ihum');"
    append rega_cmd "Z1ICO2.State('$z1ico2');"
}

# set second additional module data for push if z2moduleid is set
if {$z2moduleid != "XX:XX:XX:XX:XX:XX"} {
    append rega_cmd "Z2ITemp.State('$z2itemp');"
    append rega_cmd "Z2IHumi.State('$z2ihum');"
    append rega_cmd "Z2ICO2.State('$z2ico2');"
}

# set third additional module data for push if z3moduleid is set
if {$z3moduleid != "XX:XX:XX:XX:XX:XX"} {
    append rega_cmd "Z3ITemp.State('$z3itemp');"
    append rega_cmd "Z3IHumi.State('$z3ihum');"
    append rega_cmd "Z3ICO2.State('$z3ico2');"
}

# push module data to ccu
rega_script $rega_cmd
