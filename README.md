# Trafficlight Control

This scripts is basically an updated version of the [Smart Trafficlights script](https://forum.cfx.re/t/release-smarttrafficlights-server-side-smart-traffic-lights-v1-00/492770), but it solves the problem of sync issues and AI not driving when the lights turn green.

## Features:
- Every light around an intersection will be affected by changes
- AI will stop / drive at red / green lights
- Set the waiting time until a light turns green
- updates in real time for every player on the server
- optimized to be 0.00ms idle & ~0.03 use (only for like 0.5sec)

## Issues:
- Lights will only turn green for around 1 second if a player is far away (>80 meters)