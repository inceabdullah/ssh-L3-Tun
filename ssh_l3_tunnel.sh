#!/bin/bash

REMOTE_IP=$1

autossh -M 0 -f -N -w0:1 $REMOTE_IP
