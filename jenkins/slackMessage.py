import os
from slackclient import SlackClient
import argparse
import json
import logging
import sys

api_token = 'xoxb-313978814983-514011267477-U1J6wkdyA1lSRmTakKQ27R8e'

slack_token = api_token
sc = SlackClient(slack_token)

message = sys.argv[1]

sc.api_call(
    "chat.postMessage",
    channel="DF3JVL43W",
    #text="Hello from Python! :tada:"
    text=message
)
