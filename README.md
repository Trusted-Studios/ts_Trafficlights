# Trafficlight Control

This scripts is basically an updated version of the [https://forum.cfx.re/t/release-smarttrafficlights-server-side-smart-traffic-lights-v1-00/492770](Smart Trafficlights script), but it solves the problem of sync issues and AI not driving when the lights turn green.

## Features:
- Set the waiting time until a light turns green.
- updates in real time for every player on the server
- optimized to be 0.00ms idle & ~0.05 use (only for like 1sec)

## Issues:
- Only the light in front of the player will be affected by changes.
- Lights will only turn green for around 1 second if a player is far away (>80 meters)
- AI somtimes stop again at a green light