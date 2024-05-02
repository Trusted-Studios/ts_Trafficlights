![trusted-banner](https://github.com/Trusted-Studios/ts_Trafficlights/assets/79488475/5054a53d-f5b6-41ea-af5f-800dff563aa2)

<p align="center">
    <a href="https://discord.gg/hmmM89nCdX">
        <img src="https://img.shields.io/discord/1068573047172374634?style=for-the-badge&logo=discord&labelColor=7289da&logoColor=white&color=2c2f33&label=Discord"/>
    </a>
</p>

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

![trafficlights](https://github.com/Trusted-Studios/ts_Trafficlights/assets/79488475/60eccf61-8b8e-46ff-8f7b-0740cbe9f071)
