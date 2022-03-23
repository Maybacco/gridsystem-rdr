# Gridsystem
Marker handling resource for 	~~FiveM~~ RedM

This resource make it easy to handle markers in one single resource. Markers are registered within "chunks" and all the maths is done based on the chunk the player is in.
The first releases only let you use the StandardMode in the prompts, so you can't Mash or Hold. Right now it's also possible to add only a single prompt action.


How to register a marker
=============
First you create a table with the following params
| Field Name     | Description                                                                                                                                                                        | Type           | Required | Default Value                |
|----------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|----------------|----------|------------------------------|
| `name`         | Unique name of the marker                                                                                                                                                          | string         | YES      |                              |
| `pos`          | Position of the marker                                                                                                                                                             | vector3        | YES      |                              |
| `scale`        | Scale of the marker                                                                                                                                                                | vector3        | NO       | ```vector3(1.5, 1.5, 1.5)``` |
| `size`        | Size of the marker, the area where the user can trigger the action centered on pos   | vector3        | NO       | ```vector3(1.5, 1.5, 1.5)``` |
| `msg`          | Message on the top left  when inside the marker                                                                                                                                    | string         | NO       | `NO TEXT PROVIDED`           |
| `drawDistance` | Distance when the marker start rendering                                                                                                                                           | number         | NO       | 15.0                         |
| `control`      | Key to press to perform action                                                                                                                                                     | string  number | NO       | 'G'                          |
| `forceExit`    | If set to true, once you press the control key  inside the marker, you must exit and enter again to be  able to press the control key again.                                       | boolean        | NO       | false                        |
| `show3D`       | Draw a 3D text in the world  instead of top left notification. If set to true overrides drawDistance (if it was specified before) and fields `color`, `type`, `scale` are ignored. | boolean        | NO       | false                        |
| `type`         | Marker type. Full list in markerTypes.lua. It could be a string or a number if you want to use the intellegible name or the direct hex value                                                                                               | number OR string        | NO       | prop_mk_cylinder                           |
| `color`        | Color of the marker in the format `{r = num , g = num, b = num }`                                                                                                                  | table          | NO       | {r = 255, g = 0, b = 0}      |
| `showPrompt`         | Indicates if the marker should show a prompt, default true if show3D is false                                                                                                | boolean         | NO       | false or true if show3D == false                           |
| `promptName`         | The prompt group name                                                                                                | string         | NO       | Empty string                            |
| `hint`         | The prompt control description                                                                                                | string         | NO       | Empty string                            |
| `action`       | Callback function called when control key is pressed                                                                                                                               | function       | NO       | Empty function               |
| `onEnter`      | Callback function called when entering the marker                                                                                                                                  | function       | NO       | None                         |
| `onExit`       | Callback function called when exiting the marker                                                                                                                                   | function       | NO       | None                         |
| `shouldBob`         | Indicates if the marker should bob (jump in place)                                                                                                | boolean         | NO       | false                           |
| `shouldRotate`         | Indicates if the marker should show rotate on itself                                                                                                | boolean         | NO       | false                           |
| `ped`         | Empty by itself, contains model and heading                                                                                                | table         | NO       | nil                           |
| `ped.model`         | Model of the npc to spawn                                                                                                | string         | YES if ped is present       | nil                           |
| `ped.heading`         | The heading of the spawned npc                                                                                                | float         | NO       | 90.0                           |

Example:
```lua
TriggerEvent('gridsystem:registerMarker', {
  name = 'a_unique_name_for_this_marker',
  pos = vector3(0.0, 0.0, 0.0),
  scale = vector3(1.5, 1.5, 1.5),
  msg = 'Press ~INPUT_CONTEXT~ to do something',
  control = 'G',
  type = 'prop_mk_cylinder',
  color = { r = 130, g = 120, b = 110 },
  action = function()
    print('This is executed when you press G in the marker')
  end,
  onEnter = function()
    print('This is executed when you enter a marker')
  end,
  onExit = function()
    print('This is executed when you eixit a marker')
  end
})
```
You can remove a marker by doing
```lua
TriggerEvent('gridsystem:unregisterMarker', 'name_of_the_marker')
```

At the moment is not possible to link a marker to a specific job since
the variety of frameworks that are running on the community.
To only see a specific marker if you have a job you can do something like:

```lua
if (PlayerData.job.name == wanted_job) then 
    TriggerEvent('gridsystem:registerMarker', marker)
end
```

And refreshing the markers every time the player changes job by registering 
some framework events similar to `esx:setJob` on a ESX FiveM gamemode. 

Note
=============
Remember to start this script **BEFORE** other scripts that are triggering the `registerMakrer` event!.
Remember to not restart this script with your server on otherwise all registered marker **WILL BE LOST** and you will have to log in again.
I tried to prevent errors from happening but be aware this code is not 100% error prone. So if you encounter any bug please report the issue/ PR your fix thanks.
