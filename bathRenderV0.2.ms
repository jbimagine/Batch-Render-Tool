fn checkDialog = (
	local hwnd = dialogMonitorOps.getWindowHandle()
	local dialogTitle = uiAccessor.getWindowText hwnd
	if (dialogTitle == "Warning") then (
		uiAccessor.pressButtonByName "ok"
	)
	true
)
dialogMonitorOps.interactive = false
dialogMonitorOps.unregisterNotification id:#test
dialogMonitorOps.registerNotification checkDialog id:#test
dialogMonitorOps.enabled = true

maxFileFolder = getSavepath()
objFileFolder = maxFileFolder + "/objFiles/"
--makeDir objFileFolder
maxFiles = getFilesRecursive maxFileFolder "*.max"
for i=1 to maxFiles.count do
(
  loadMaxFile maxFiles[i] quiet:true
 
----------------------------------------------------------- -- MAKE SOME SCRIPTED CHANGES TO THE SCENE HERE... -----------------------------------------------------------

-----MERGES THE INTIAL PROP INTO ONE MESH.  MAIN REASON BEHIND THIS IS BECAUSE GROUPS IN MAX ARE A PAIN IN THE $%$------
/* $propSelect.pos.x = 0
$propSelect.pos.y = 0 */

max select all

explodeGroup selection

max select all

selection.pivot = selection.center

(
max create mode
disableSceneRedraw()
with undo off
(

local sel = for o in selection where superclassOf o == geometryClass collect o
local meshO = sel[1]
deleteItem sel (findItem sel meshO)

convertToMesh meshO

for o in sel do attach meshO o

)
enableSceneRedraw()
)


------RENAMES THE SELECTION TO PROPSELECT-------
max select all

sel=selection as array

for s in sel do s.name ="propSelect"



-----CREATES A REF BOX BASED OFF OF THE BOUNDING BOX SIZE OF THE PROP------

propDepthY = $propSelect.max.y - $propSelect.min.y
propWidthX = $propSelect.max.x - $propSelect.min.x
propHeightZ = $propSelect.max.z - $propSelect.min.z

refBox = box length: propDepthY width: propWidthX height: propHeightZ

-----LINKS THE PROP TO THE REF BOX------
select $propSelect

$.parent = refBox

-----MAKE THE REFBOX UNRENDERABLE-----
refBox.renderable = false
refBox.boxmode = on ---

----IMPORT THE RENDER ENVIRONMENT-----
mergeMaxFile "M:\LIBRARY\Scripts\Render_Batch\NaturalLightTurntable\NaturalLightTurntable.max"


----WE WILL USE THE DIMENSIONS OF THE REF BOX TO GET THE BOUNDING BOX----
refDepthY = refBox.max.y - refBox.min.y
refWidthX = refBox.max.x - refBox.min.x
refHeightZ = refBox.max.z - refBox.min.z

 ----ROTATE PROPS A PREDERTIMINED AMOUNT OF DEGREES IF A CERTAIN DEPTH IS DETECTED
rotProp = eulerangles -5 0 0

if refDepthY <= 40 do
(
	rotate refBox rotProp
	)

----ALIGNS THE PROP TO THE WALL
pl = $dumyPlane001
sp = refBox

sp.pos.x = 0 --sets the x position to 0

sp.pos.y = pl.center.y

selectObj = sp.max.y
targetObj = pl.max.y
selectMinObj = sp.min.y

 sp.pos.y = targetObj - selectObj
 
 sp.pos.y = sp.pos.y + pl.pos.y


-----RENDER THE PROP TO A SPECIFIC CAMERA BASED OFF OF THE PROPS SCALE


--LOADS THE RENDER PRESET
renderPresets.LoadAll 0 "M:\LIBRARY\Scripts\Render_Batch\RenderPreset\NightLifeTurntable_preset.rps"  --production render settings
 --renderPresets.LoadAll 0 "C:\Users\Joe\Desktop\Modsy\Render_Batch\RenderPreset\TestNightLifeTurntable_preset.rps" --this is only for testing

--LongShot camera only used for tall bookcases, large sofas, dining tables
if propHeightZ >= 1500 then
(
pnRenderDest = "M:\LIBRARY\Scripts\Render_Batch\BatchRenders\NaturalLight_longShot_" -- output directory
pnRenderImage = pnRenderDest + (getFilenameFile maxFilename) + ".jpg"
cRenderCam = $MDY_Prop_Longshot -- name of your camera
undisplay (render camera:cRenderCam outputfile:pnRenderImage)

)

--topSHot camera only used for rugs
if propHeightZ <= 40 and propHeightZ >= 3 then
(
pnRenderDest = "M:\LIBRARY\Scripts\Render_Batch\BatchRenders\NaturalLight_topShot_" -- output directory
pnRenderImage = pnRenderDest + (getFilenameFile maxFilename) + ".jpg"
cRenderCam = $MDY_Prop_Topshot -- name of your camera
undisplay (render camera:cRenderCam outputfile:pnRenderImage)

)

--medShot camera only used for 2 seater sofa's, credenza, tables, floor lamps
if propHeightZ <= 1400 and propHeightZ >= 900 and propDepthy >= 100 then
(
pnRenderDest = "M:\LIBRARY\Scripts\Render_Batch\BatchRenders\NaturalLight_medShot_" -- output directory
pnRenderImage = pnRenderDest + (getFilenameFile maxFilename) + ".jpg"
cRenderCam = $MDY_Prop_Medshot -- name of your camera
undisplay (render camera:cRenderCam outputfile:pnRenderImage)

)

if propHeightZ <= 1200 and propHeightZ >= 1150 and propWidthX >= 1000 then
(
pnRenderDest = "M:\LIBRARY\Scripts\Render_Batch\BatchRenders\NaturalLight_medShot_" -- output directory
pnRenderImage = pnRenderDest + (getFilenameFile maxFilename) + ".jpg"
cRenderCam = $MDY_Prop_Medshot -- name of your camera
undisplay (render camera:cRenderCam outputfile:pnRenderImage)

)

--closeUp camera only used for artwork, dining chair, stools, night stands, table lamsps etc
if propDepthy <= 80  then
(
pnRenderDest = "M:\LIBRARY\Scripts\Render_Batch\BatchRenders\NaturalLight_closeUp_" -- output directory
pnRenderImage = pnRenderDest + (getFilenameFile maxFilename) + ".jpg"
cRenderCam = $MDY_Prop_Closeup -- name of your camera
undisplay (render camera:cRenderCam outputfile:pnRenderImage)

)

--closeUp camera only used for artwork, dining chair, stools, night stands, table lamsps etc
if propDepthy <= 900 and propHeightZ <= 900 and propWidthX <= 900 then
(
pnRenderDest = "M:\LIBRARY\Scripts\Render_Batch\BatchRenders\NaturalLight_closeUp_" -- output directory
pnRenderImage = pnRenderDest + (getFilenameFile maxFilename) + ".jpg"
cRenderCam = $MDY_Prop_Closeup -- name of your camera
undisplay (render camera:cRenderCam outputfile:pnRenderImage)

) 

    --saveMaxFile f --save the file back to disk

  resetMaxFile #noPrompt --at the end, you can reset
)
