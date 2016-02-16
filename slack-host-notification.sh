#!/bin/bash

if [[ $HOSTSTATE == "UP" ]]; then
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

json_escape() {
  echo -n "$1" | python -c 'import json,sys; print json.dumps(sys.stdin.read())'
}
HOSTOUTPUT="$(json_escape "$HOSTOUTPUT")"


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
$emote [$NOTIFICATIONTYPE] *$HOSTALIAS* is $HOSTSTATE!
TEMPLATE
`

payload=`cat <<PAYLOAD
payload= {
  "channel": "#icinga",
  "username": "icingabot",
  "attachments":[
    {
      "fallback": "[$NOTIFICATIONTYPE] *$HOSTALIAS* is $HOSTSTATE $emote",
      "color": "$color",
      "text": "$template",
      "mrkdwn_in": ["text", "pretext", "fields"],
      "fields":[
        {
          "title":"Additional Info",
          "value":"\\\`\\\`\\\`${HOSTOUTPUT:1:-1}\\\`\\\`\\\`",
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


#/usr/bin/printf "%b" "$template" | mail -s "$NOTIFICATIONTYPE - $HOSTDISPLAYNAME is $HOSTSTATE" $USEREMAIL
