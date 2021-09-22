

function match_name(path)

    fn_flag = string.find(path, "\\")
    if fn_flag then
    dest_filename = string.match(path, ".+\\([^\\]*)%.%w+$")
    end
 
    fn_flag = string.find(path, "/")
    if fn_flag then
    dest_filename = string.match(path, ".+/([^/]*)%.%w+$")
    end
    return dest_filename
    
end

count=0

function getArg()

    local item=reaper.GetSelectedMediaItem(0, 0)
    if item==nil then reaper.ShowConsoleMsg("No MediaItem selected") return nil end
    local length= reaper.GetMediaItemInfo_Value( item, "D_LENGTH" )
    local take=reaper.GetActiveTake(item)
    local env=reaper.GetTakeEnvelopeByName(take,"Pitch")
    if env==nil then reaper.ShowConsoleMsg("No Pitch Envelope") return nil end

    local source=reaper.GetMediaItemTake_Source(take)
    local type_= reaper.GetMediaSourceType( source, "" )
    local sampleRate=reaper.GetMediaSourceSampleRate(source)
    local sourcePath = reaper.GetMediaSourceFileName( source, "" )
    local sourceName=match_name(sourcePath)
    local projectPath=reaper.GetProjectPath(0)
    local time = os.date("%Y_%m_%d_%H_%M_%S")

    local duration=0.007
    
    local pitches=""
    for i=0,length,duration do
    local retval, value, dVdS, ddVdS, dddVdS = reaper.Envelope_Evaluate( env, i, 44100, 1 )
    pitches=pitches..tostring(value).." "
    count=count+1
    end
    pitches=string.gsub(pitches, "^[%s]*(.-)[%s]*$", "%1") --trim
    
    local desPath=projectPath.."\\"..sourceName.."_"..time..".wav"

    local arg="duration="..tostring(duration).."%tequila%".."mode=".."1".."%tequila%".."sampleRate="..sampleRate.."%tequila%".."sourcePath="..sourcePath.."%tequila%".."desPath="..desPath.."%tequila%".."pitches="..pitches.."%tequila%"
    

    return arg,desPath,length

end

function detect(path,length)

   

        local file,err=io.open(path)

        if file~=nil then 
            
            local item=reaper.GetSelectedMediaItem(0, 0)
            local take=reaper.AddTakeToMediaItem( item )
            local source=reaper.PCM_Source_CreateFromFile( path )
            local length2, retval = reaper.GetMediaSourceLength( source )
            if length2>length then reaper.SetMediaItemLength( item, length2, false ) end
            reaper.SetMediaItemTake_Source( take, source )
            reaper.UpdateArrange()
            reaper.Main_OnCommand(40441, 0)
            
        end

   

end


function main()
    local tempPath=reaper.GetProjectPath(0).."\\".."Ache_Strecher.temp"
    local exePath=reaper.GetResourcePath().."\\".."Scripts".."\\".."Ache_Scripts".."\\".."Utility".."\\".."Ache_Stretcher.exe"
    local arg,desPath,length=getArg()
    if arg~=nil then 
        reaper.BR_Win32_WritePrivateProfileString(" ", " ",arg,tempPath)
        tempPath=string.format([["%s"]],tempPath)
        os.execute(exePath.." "..tempPath)
        detect(desPath,length)
    end

end

main()
