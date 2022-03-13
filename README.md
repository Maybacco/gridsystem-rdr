# Gridsystem
Marker handling resource for FiveM

This resource make it easy to handle markers in one single resource. Markers are registered within "chunks" and all the maths is done based on the chunk the player is in.
It also has a permission system compatible with ESX job system, however you can easily edit the code to support other system/remove it.


How to register a marker
=============
First you create a table with the following params
| Field Name     | Description                                                                                                                                                                        | Type           | Required | Default Value                |
|----------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|----------------|----------|------------------------------|
| `name`         | Unique name of the marker                                                                                                                                                          | string         | YES      |                              |
| `pos`          | Position of the marker                                                                                                                                                             | vector3        | YES      |                              |
| `scale`        | Scale of the marker                                                                                                                                                                | vector3        | NO       | ```vector3(1.5, 1.5, 1.5)``` |
| `msg`          | Message on the top left  when inside the marker                                                                                                                                    | string         | NO       | `NO TEXT PROVIDED`           |
| `drawDistance` | Distance when the marker start rendering                                                                                                                                           | number         | NO       | 15.0                         |
| `control`      | Key to press to perform action                                                                                                                                                     | string  number | NO       | 'E'                          |
| `forceExit`    | If set to true, once you press the control key  inside the marker, you must exit and enter again to be  able to press the control key again.                                       | boolean        | NO       | false                        |
| `show3D`       | Draw a 3D text in the world  instead of top left notification. If set to true overrides drawDistance (if it was specified before) and fields `color`, `type`, `scale` are ignored. | boolean        | NO       | false                        |
| `type`         | Marker type. Full list [Here](https://docs.fivem.net/docs/game-references/markers/)                                                                                                | number         | NO       | 20                           |
| `color`        | Color of the marker in the format `{r = num , g = num, b = num }`                                                                                                                  | table          | NO       | {r = 255, g = 0, b = 0}      |
| `action`       | Callback function called when control key is pressed                                                                                                                               | function       | NO       | Empty function               |
| `onEnter`      | Callback function called when entering the marker                                                                                                                                  | function       | NO       | None                         |
| `onExit`       | Callback function called when exiting the marker                                                                                                                                   | function       | NO       | None                         |

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
