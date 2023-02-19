# AmbushTrigger

An AmbushTrigger will be active at round start based on *Chance*. On activation the following parameters will be determined:

* *tiPresence* as a random time in the range *[tiPresenceMin, tiPresenceMax]*
* *tiAmbush* as a random time in the range *[tiMin, tiMax]*
* *sizeAmbush* as a random number in the range *[sizeMin, sizeMax]*

In default mode (*TriggerOnRelease* is not set) a timer starts when the first Agent enters the AmbushTrigger. If at least one Agent stays inside it for *tiPresence* it will trigger, activating all other AmbushTriggers matching *Activate* and causing *sizeAmbush* (but no more than the number of associated *AISpawnPoints*) AI to spawn after *tiAmbush*. An AmbushTrigger can also (re-)activate itself. In this case it will re-trigger after *tiPresence* if *tiPresence* > 5s or after it has been re-occupied after being left.

In "reverse" mode (*TriggerOnRelease* is set) it will trigger as soon as the Agent that entered the trigger **first** leaves it.

## Required Tags

| Tag | Syntax | Description
| --- | --- | --- |
| Ambush | `Ambush` | marks a *GameTrigger* object as an AmbushTrigger

## Optional Tags

| Tag | Syntax | Description | Default
| --- | --- | --- | --- |
| Chance | `Chance=<percentage>` | sets the chance for this AmbushTrigger to be active at round start to `<percentage>` | 80
| tiPresenceMin | `tiPresenceMin=<seconds>` | sets the minimum time the AmbushTrigger has to be populated for it to trigger to `<seconds>` | 0
| tiPresenceMax | `tiPresenceMax=<seconds>` | sets the maximum time the AmbushTrigger has to be populated for it to trigger to `<seconds>` | 0
| tiMin | `tiMin=<seconds>` | sets the minimum delay for the ambush to spawn to `<seconds>` | 1
| tiMax | `tiMax=<seconds>` | sets the maximum delay for the ambush to spawn to `<seconds>` | 7
| sizeMin | `sizeMin=<number>` | sets the minimum ambush size to `<number>` | 0
| sizeMax | `sizeMax=<number>` | sets the maximum ambush size to `<number>` | 5
| TriggerOnRelease | `TriggerOnRelease` | trigger when the first one that entered the AmbushTrigger leaves it (reversed logic) | false
| Visible | `Visible` | shows visible outlines when the trigger is active | false
| EntryMessageToFirst | `EntryMessageToFirst=<msg>` | shows `<msg>` to the first agent entering the trigger | none
| DelayedMessageToBluFor | `DelayedMessageToBluFor=<msg>` | shows `<msg>` to all alive BluFor players when the ambush actually spawns (or would spawn) | none
| Group | `Group=<group_name>` | adds all *AISpawnPoints* having the tag `<group_name>` assigned to the pool of spawn points used by the AmbushTrigger | none
| Activate | `Activate=<trigger_name_pattern>` | will activate all *AmbushTriggers* matching `<trigger_name_pattern>` when triggered, may be used multiple times | none
| Mine | `Mine=<mine_name_pattern>` | will trigger all *Mines* matching `<mine_name_pattern>` when triggered, may be used multiple times | none
