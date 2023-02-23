# AmbushTrigger

An AmbushTrigger will be active at round start based on *Chance*. On activation the following parameters will be determined:

* *tiPresence* as a random time in the range *[tiPresenceMin, tiPresenceMax]*
* *tiAmbush* as a random time in the range *[tiMin, tiMax]*
* *sizeAmbush* as a random number in the range *[sizeMin, sizeMax]*

In default mode (*TriggerOnRelease* is not set) a timer starts when the first Agent enters the AmbushTrigger. If at least one Agent stays inside it for *tiPresence* it will trigger.

In "reverse" mode (*TriggerOnRelease* is set) it will trigger as soon as the Agent that entered the trigger **first** leaves it.

When tiggering it will:

* activate all AmbushTriggers and Mines matching *Activate*
* deactivate all AmbushTriggers and Mines matching *Deactivate*
* cause *sizeAmbush* (but no more than the number of associated *AISpawnPoints*) AI to spawn after *tiAmbush*
* trigger all associated (and active) *Mines*

An AmbushTrigger can also (re-)activate itself. In this case it will re-trigger after *tiPresence* if *tiPresence* > 5s or after it has been re-occupied after being left.

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
| ~~EntryMessageToFirst~~ | ~~`EntryMessageToFirst=<msg>`~~ | ~~shows `<msg>` to the first agent entering the trigger~~ (deprecated, use `Message=First\|FirstEntry\|<msg>` instead) | none
| ~~DelayedMessageToBluFor~~ | ~~`DelayedMessageToBluFor=<msg>`~~ | ~~shows `<msg>` to all alive BluFor players when the ambush actually spawns~~ (deprecated, use `Message=BluFor\|Ambush\|<msg>` instead) | none
| Message | `Message=<who>\|<when>\|<msg>` | shows `<msg>` to `<who>` at event `<when>`, see description below, may be used multiple times | none
| Group | `Group=<group_name>` | adds all *AISpawnPoints* having the tag `<group_name>` assigned to the pool of spawn points used by the AmbushTrigger | none
| Activate | `Activate=<name_pattern>` | will activate all *AmbushTriggers* and *Mines* matching `<name_pattern>` when triggered, may be used multiple times | none
| Deactivate | `Deactivate=<name_pattern>` | will deactivate all *AmbushTriggers* and *Mines* matching `<name_pattern>` when triggered, may be used multiple times | none
| Mine | `Mine=<name_pattern>` | will trigger all *Mines* matching `<name_pattern>` when triggered, may be used multiple times | none

## Message Definitions

*Messages* can be defined using syntax `Message=<who>|<when>|<msg>` where:

* `<who>` is one of:
  * `First`: The first agent that entered the trigger
  * `BluFor`: Each alive member of team BluFor
* `<when>` is one of the following events:
  * `Activate`: When the trigger is activated, only useful for triggers that get activated by other triggers
  * `Deactivate`: When the trigger is deactivated, only useful for triggers that get deactivated by other triggers
  * `Trigger`: When the trigger gets triggered
  * `Ambush`: When the ambush gets spawned
  * `FirstEntry`: When the the first agent enters the trigger
  * `LastExit`: When the last agent leaves the trigger
* `<msg>` is the message shown to the agent(s)
