#!/bin/bash

if [[ $SERVICESTATE == "OK" ]]; then
  emote=":relieved:"
  icon=":dancing_penguin:"
  color="#2ab27b"
elif [[ "$NOTIFICATIONTYPE" == "ACKNOWLEDGEMENT" ]]; then
  color="#edb431"
  emote=":relieved:"
  icon=":dancing_penguin:"
else
  emote=":scream:"
  icon=":fire:"
  color="#D00000"
fi

if [[ "$NOTIFICATIONTYPE" == "DOWNTIMESTART" ]]; then
  exit 0
elif [[ "$NOTIFICATIONTYPE" == "DOWNTIMEEND" ]]; then
  exit 0
fi

json_escape() {
  echo -n "$1" | python -c 'import json,sys; print json.dumps(sys.stdin.read())'
}
SERVICEOUTPUT="$(json_escape "$SERVICEOUTPUT")"

if [[ $NOTIFICATIONCOMMENT == "" ]]; then
  comment=""
else
  comment=`cat <<EOF
,
        {
          "title":"Comment by $NOTIFICATIONAUTHORNAME",
          "value":">>>$NOTIFICATIONCOMMENT",
          "short":false
        }
EOF
`
fi

template=`cat <<TEMPLATE
$emote [$NOTIFICATIONTYPE] *$HOSTALIAS* - $SERVICEDESC is $SERVICESTATE!
TEMPLATE
`

payload=`cat <<PAYLOAD
payload= {
  "channel": "#icinga",
  "username": "icingabot",
  "attachments":[
    {
      "fallback": "[$NOTIFICATIONTYPE] *$HOSTALIAS* - $SERVICEDESC is $SERVICESTATE $emote",
      "color": "$color",
      "text": "$template",
      "mrkdwn_in": ["text", "pretext", "fields"],
      "fields":[
        {
          "title":"Additional Info",
          "value":"\\\`\\\`\\\`${SERVICEOUTPUT:1:-1}\\\`\\\`\\\`",
          "short":false
        }
$comment
      ]
    }
  ]
}
PAYLOAD
`

curl -X POST --data-urlencode "$payload" https://hooks.slack.com/services/xxxxxxxxx/xxxxxxxxx/xxxxxxxxxxxxxxxxxxxxxxxx



#/usr/bin/printf "%b" "$template" | mail -s "$NOTIFICATIONTYPE - $HOSTDISPLAYNAME - $SERVICEDISPLAYNAME is $SERVICESTATE" $USEREMAIL

