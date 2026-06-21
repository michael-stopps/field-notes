------------------------
---CREATE NOTE WINDOW---
------------------------

local NoteFrame = CreateFrame("Frame", "FieldNotesFrame", UIParent, "BasicFrameTemplate")
NoteFrame:SetSize(600,400)
NoteFrame:SetPoint("CENTER",UIParent,"CENTER")
NoteFrame:Hide()
tinsert(UISpecialFrames, "FieldNotesFrame")

NoteFrame:SetMovable(true)
NoteFrame:EnableMouse(true)
NoteFrame:RegisterForDrag("LeftButton")
NoteFrame:SetScript("OnDragStart", NoteFrame.StartMoving)
NoteFrame:SetScript("OnDragStop", NoteFrame.StopMovingOrSizing)

NoteFrame:SetScript("OnShow", function()
    PlaySound(SOUNDKIT.IG_QUEST_LOG_OPEN, "SFX")
end)

NoteFrame:SetScript("OnHide", function()
    PlaySound(SOUNDKIT.IG_QUEST_LOG_CLOSE, "SFX")
end)

NoteFrame.TitleText:SetText("Field Notes")

-----------------------
---SLASH COMMANDS---
-----------------------

SLASH_FIELDNOTES1 = "/note"
SLASH_FIELDNOTES2 = "/notes"
SlashCmdList["FIELDNOTES"] = function(msg)
    if NoteFrame:IsShown() then
        NoteFrame:Hide()
    else
        NoteFrame:Show()
    end
end

-----------------
---TEXT EDITOR---
-----------------

local EditorBackground = CreateFrame("Frame", "FieldNotesEditorBackground", NoteFrame, "BackdropTemplate")
EditorBackground:SetPoint("TOPRIGHT", NoteFrame, "TOPRIGHT", -15, -35)
EditorBackground:SetPoint("BOTTOMRIGHT", NoteFrame, "BOTTOMRIGHT", -15, 45)
EditorBackground:SetWidth(380)

EditorBackground:SetBackdrop({
    bgFile = "Interface\\AchievementFrame\\UI-Achievement-Parchment-Horizontal", 
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", 
    tile = true, tileSize = 256, edgeSize = 16, 
    insets = { left = 4, right = 4, top = 4, bottom = 4 }
})

local EditorScroll = CreateFrame("ScrollFrame", "FieldNotesEditorScroll", EditorBackground, "UIPanelScrollFrameTemplate")
EditorScroll:SetPoint("TOPLEFT", EditorBackground, "TOPLEFT", 8, -8)
EditorScroll:SetPoint("BOTTOMRIGHT", EditorBackground, "BOTTOMRIGHT", -27, 8)

local EditorBox = CreateFrame("EditBox", "FieldNotesEditorBox", EditorScroll)
EditorBox:SetMultiLine(true)
EditorBox:SetFontObject("MailTextFontNormal")
EditorBox:SetWidth(345)
EditorBox:SetAutoFocus(false)
EditorBox:SetTextInsets(15, 15, 10, 10)
EditorScroll:SetScrollChild(EditorBox)

-----------------
---TAB CONTROL---
-----------------

local currentTab = "note"
local currentNoteType = "note"

local TabNotes = CreateFrame("Button", "FieldNotesTabNotes", NoteFrame, "UIPanelButtonTemplate")
TabNotes:SetSize(80, 22)
TabNotes:SetPoint("TOPLEFT", NoteFrame, "TOPLEFT", 15, -30)
TabNotes:SetText("Notes")

local TabTranscripts = CreateFrame("Button", "FieldNotesTabTranscripts", NoteFrame, "UIPanelButtonTemplate")
TabTranscripts:SetSize(90, 22)
TabTranscripts:SetPoint("LEFT", TabNotes, "RIGHT", 5, 0)
TabTranscripts:SetText("Transcripts")

---------------
---NOTE LIST---
---------------

local ListBackground = CreateFrame("Frame", "FieldNotesListBackground", NoteFrame, "BackdropTemplate")
ListBackground:SetPoint("TOPLEFT", NoteFrame, "TOPLEFT", 15, -55) 
ListBackground:SetPoint("BOTTOMRIGHT", EditorBackground, "BOTTOMLEFT", -15, 0)

ListBackground:SetBackdrop({
    bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 }
})
ListBackground:SetBackdropColor(0,0,0,0.5)

local ListScrollFrame = CreateFrame("ScrollFrame", "FieldNotesListScroll", ListBackground, "UIPanelScrollFrameTemplate")
ListScrollFrame:SetPoint("TOPLEFT", ListBackground, "TOPLEFT", 4, -4)
ListScrollFrame:SetPoint("BOTTOMRIGHT", ListBackground, "BOTTOMRIGHT", -27, 4)

local ListContainer = CreateFrame("Frame", "FieldNotesListContainer", ListScrollFrame)
ListContainer:SetSize(140, 1)
ListScrollFrame:SetScrollChild(ListContainer)

---------------------
---BUTTON CONTROLS---
---------------------

local tooltipTimer = nil

local function AddDelayedTooltip(button, tooltipText)
    button:SetScript("OnEnter", function(self)
        if tooltipTimer then
            tooltipTimer:Cancel()
        end
        tooltipTimer = C_Timer.NewTimer(1,function()
            GameTooltip:SetOwner(self, "ANCHOR_TOP")
            GameTooltip:SetText(tooltipText)
            GameTooltip:Show()
        end)
    end)
    button:SetScript("OnLeave", function()
        if tooltipTimer then
            tooltipTimer:Cancel()
        end
        GameTooltip:Hide()        
    end)
end

local AddButton = CreateFrame("Button", nil, NoteFrame, "UIPanelButtonTemplate")
AddButton:SetSize(30,30)
AddButton:SetPoint("BOTTOMLEFT", NoteFrame, "BOTTOMLEFT", 15, 10)
AddButton:SetText("+")
AddDelayedTooltip(AddButton, "Add New Note")

local SaveButton = CreateFrame("Button", nil, NoteFrame, "UIPanelButtonTemplate")
SaveButton:SetSize(30,30)
SaveButton:SetPoint("LEFT", AddButton, "RIGHT", 5, 0)
SaveButton:SetText("S")
AddDelayedTooltip(SaveButton,"Manually Save and Reload")

local DeleteButton = CreateFrame("Button", nil, NoteFrame, "UIPanelButtonTemplate")
DeleteButton:SetSize(30,30)
DeleteButton:SetPoint("LEFT",SaveButton,"RIGHT",5,0)
DeleteButton:SetText("-")
AddDelayedTooltip(DeleteButton, "Delete Selected Note")

local ShareButton = CreateFrame("Button", nil, NoteFrame, "UIPanelButtonTemplate")
ShareButton:SetSize(30,30)
ShareButton:SetPoint("LEFT",DeleteButton,"RIGHT",5,0)
ShareButton:SetText("^")
AddDelayedTooltip(ShareButton, "Share Note to Chat")

local ToolbarDivider = NoteFrame:CreateTexture(nil, "ARTWORK")
ToolbarDivider:SetColorTexture(0, 0, 0, 0)
ToolbarDivider:SetPoint("TOPLEFT", EditorBackground, "BOTTOMLEFT", 0, -5)
ToolbarDivider:SetPoint("BOTTOMRIGHT", EditorBackground, "BOTTOMRIGHT", 0, -30)

local BulletButton = CreateFrame("Button", nil, NoteFrame, "UIPanelButtonTemplate")
BulletButton:SetSize(30, 30)
BulletButton:SetPoint("LEFT", ToolbarDivider, "LEFT", 0, 0)
BulletButton:SetText("-")
AddDelayedTooltip(BulletButton, "Insert Bullet")

local TaskButton = CreateFrame("Button", nil, NoteFrame, "UIPanelButtonTemplate")
TaskButton:SetSize(40, 30)
TaskButton:SetPoint("LEFT", BulletButton, "RIGHT", 5, 0)
TaskButton:SetText("[ ]")
AddDelayedTooltip(TaskButton, "Insert Task")

local TaskDoneButton = CreateFrame("Button", nil, NoteFrame, "UIPanelButtonTemplate")
TaskDoneButton:SetSize(40, 30)
TaskDoneButton:SetPoint("LEFT", TaskButton, "RIGHT", 5, 0)
TaskDoneButton:SetText("[x]")
AddDelayedTooltip(TaskDoneButton, "Insert Completed Task")

------------------------------
---WAYPOINT SCANNER SYSTEM----
------------------------------

local WaypointAnchor = CreateFrame("Frame", nil, NoteFrame)
WaypointAnchor:SetSize(1, 30)
WaypointAnchor:SetPoint("RIGHT", ToolbarDivider, "RIGHT", 0, 0)

local wpButtons = {}

local function UpdateWaypoints(text)
    -- Hide all existing buttons first
    for _, btn in ipairs(wpButtons) do 
        btn:Hide() 
    end
    
    local cmds = {}
    for wpCmd in string.gmatch(text, "(/way[^\n\r]*%d+%.?%d*%s+%d+%.?%d*)") do
        table.insert(cmds, wpCmd)
        if #cmds == 10 then break end
    end
    
    local totalPins = #cmds
    
    for i = 1, totalPins do
        if not wpButtons[i] then
            local btn = CreateFrame("Button", nil, NoteFrame)
            btn:SetSize(22, 22) 
            
            btn.Icon = btn:CreateTexture(nil, "ARTWORK")
            btn.Icon:SetAllPoints()
            btn.Icon:SetAtlas("Waypoint-MapPin-Tracked")
            
            local highlight = btn:CreateTexture(nil, "HIGHLIGHT")
            highlight:SetAllPoints()
            highlight:SetAtlas("Waypoint-MapPin-Tracked")
            highlight:SetBlendMode("ADD")
            highlight:SetAlpha(0.4)
            
            btn:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_TOP")
                GameTooltip:SetText("Add Pin")
                GameTooltip:AddLine(self.cmd, 1, 1, 1, true)
                GameTooltip:Show()
            end)
            btn:SetScript("OnLeave", function() GameTooltip:Hide() end)
            
            wpButtons[i] = btn
        end
        
        local btn = wpButtons[i]
        btn.cmd = cmds[i] 
        
        btn:SetScript("OnClick", function(self)
            local editBox = ChatEdit_ChooseBoxForSend()
            editBox:SetText(self.cmd)
            ChatEdit_SendText(editBox, 0)
        end)
        
        local xOffset = -((totalPins - i) * 24)
        
        btn:SetPoint("RIGHT", WaypointAnchor, "LEFT", xOffset, 0)
        btn:Show()
    end
end

----------------------
---NOTE LIST UPDATE---
----------------------

local currentNoteID = nil
local noteButtons = {} 

local function UpdateListDisplay()
    for _, btn in ipairs(noteButtons) do
        btn:Hide()
    end

    local yOffset = -5 
    local buttonIndex = 1

    for id, noteData in pairs(FieldNotesDB) do
        local nType = noteData.type or "note"

        if nType == currentTab then
            local btn = noteButtons[buttonIndex]
            
            if not btn then 
                btn = CreateFrame("Button", nil, ListContainer)
                btn:SetSize(130, 20) 
                
                local btnText = btn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
                btnText:SetPoint("LEFT", btn, "LEFT", 5, 0)
                btnText:SetPoint("RIGHT", btn, "RIGHT", -5, 0) 
                btnText:SetJustifyH("LEFT")
                btnText:SetWordWrap(false)
                btn:SetFontString(btnText)

                btn:SetHighlightFontObject("GameFontHighlight") 
                local hoverHighlight = btn:CreateTexture(nil, "HIGHLIGHT")
                hoverHighlight:SetAllPoints(btn)
                hoverHighlight:SetTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight")
                hoverHighlight:SetBlendMode("ADD")

                local selectedBg = btn:CreateTexture(nil, "BACKGROUND")
                selectedBg:SetAllPoints(btn)
                selectedBg:SetTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight")
                selectedBg:SetBlendMode("ADD")
                selectedBg:Hide() 
                btn.selectedBg = selectedBg 

                noteButtons[buttonIndex] = btn
            end

            btn.noteID = noteData.id 
            btn:SetPoint("TOPLEFT", ListContainer, "TOPLEFT", 5, yOffset)
            btn:SetText(noteData.name)
            
            if currentNoteID == noteData.id then
                btn.selectedBg:Show()
            else
                btn.selectedBg:Hide()
            end

            btn:Show()

            btn:SetScript("OnClick", function()
                currentNoteID = noteData.id
                currentNoteType = nType
                EditorBox:SetText(noteData.text)
                
                if noteData.text ~= nil then
                    UpdateWaypoints(noteData.text)
                end

                for _, b in ipairs(noteButtons) do
                    if b.noteID == currentNoteID then
                        b.selectedBg:Show()
                    else
                        b.selectedBg:Hide()
                    end
                end
            end)

            yOffset = yOffset - 20 
            buttonIndex = buttonIndex + 1
        end
    end

    ListContainer:SetHeight(math.abs(yOffset))
end

TabNotes:SetScript("OnClick", function()
    currentTab = "note"
    UpdateListDisplay()
end)

TabTranscripts:SetScript("OnClick", function()
    currentTab = "transcription"
    UpdateListDisplay()
end)

--------------------
---BUTTON SCRIPTS---
--------------------

StaticPopupDialogs["FIELDNOTES_CONFIRM_FORCESAVE"] = {
    text = "Manually save and reload?",
    button1 = "Yes",
    button2 = "No",
    OnAccept = function()
        ReloadUI()
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 4,
}

SaveButton:SetScript("OnClick", function()
    StaticPopup_Show("FIELDNOTES_CONFIRM_FORCESAVE")
end)

EditorBox:SetScript("OnTextChanged",function(self,isUserInput)
    if not isUserInput then return end
    local content = self:GetText()
    
    if content ~= nil then
        UpdateWaypoints(content)
    end
    
    if content == "" or content == nil then return end

    local noteName = string.sub(content, 1, 15) 
    if string.len(content) > 15 then
        noteName = noteName .. "..."
    end
    
    if currentNoteID == nil then 
        currentNoteID = time()
    end

    FieldNotesDB[currentNoteID] = { 
        name = noteName,
        text = content,
        id = currentNoteID,
        type = currentNoteType 
    }

    UpdateListDisplay()
end)

AddButton:SetScript("OnClick", function()
    currentNoteID = nil
    currentNoteType = currentTab
    EditorBox:SetText("")
    EditorBox:SetFocus()
    UpdateListDisplay()
end)

StaticPopupDialogs["FIELDNOTES_CONFIRM_DELETE"] = {
    text = "Are you sure you want to delete this note?",
    button1 = "Yes",
    button2 = "No",
    OnAccept = function()
        if currentNoteID ~= nil then
            FieldNotesDB[currentNoteID] = nil
            currentNoteID = nil
            EditorBox:SetText("")
            UpdateListDisplay()
        end
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
}

DeleteButton:SetScript("OnClick", function()
    if currentNoteID ~= nil then
        StaticPopup_Show("FIELDNOTES_CONFIRM_DELETE")
    end
end)

ShareButton:SetScript("OnClick", function()
    if currentNoteID ~= nil then
        local playerName, playerRealm = UnitName("player")
        local fullName = playerName
        if playerRealm and playerRealm ~= "" then
            fullName = playerName .. "-" .. playerRealm
        end
        
        local safeName = FieldNotesDB[currentNoteID].name
        safeName = string.gsub(safeName, "[\n\r]", " ")
        
        local plainTextTag = string.format("{FN:%s:%d:%s}", fullName, currentNoteID, safeName)
        
        C_Timer.After(0.1, function()
            local editBox = ChatEdit_ChooseBoxForSend()
            ChatEdit_ActivateChat(editBox)
            editBox:Insert(plainTextTag)
        end)
    end
end)

BulletButton:SetScript("OnClick", function()
    EditorBox:Insert("- ")
    EditorBox:SetFocus()
end)

TaskButton:SetScript("OnClick", function()
    EditorBox:Insert("[ ] ")
    EditorBox:SetFocus()
end)

TaskDoneButton:SetScript("OnClick", function()
    EditorBox:Insert("[x] ")
    EditorBox:SetFocus()
end)

------------------------------
---OBJECTIVE TRACKER BUTTON---
------------------------------

local TrackerButton = CreateFrame("Button", "FieldNotesTrackerButton", UIParent)
TrackerButton:SetSize(20, 20)
TrackerButton:SetFrameLevel(10)
TrackerButton:SetPoint("RIGHT", ObjectiveTrackerFrame.Header.MinimizeButton, "LEFT", -5, 0)
TrackerButton.Icon = TrackerButton:CreateTexture(nil, "ARTWORK")
TrackerButton.Icon:SetAllPoints()
TrackerButton.Icon:SetTexture("Interface\\Icons\\inv_misc_book_09")
TrackerButton:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square")
TrackerButton:GetHighlightTexture():SetBlendMode("ADD")

TrackerButton:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText("Field Notes")
    GameTooltip:AddLine("Click to open", 1, 1, 1)
    GameTooltip:Show()
end)

TrackerButton:SetScript("OnLeave", function() 
    GameTooltip:Hide() 
end)

TrackerButton:SetScript("OnClick", function()
    if NoteFrame:IsShown() then
        NoteFrame:Hide()
    else
        NoteFrame:Show()
    end
end)

------------------------------
---AUTO TRANSCRIBER SYSTEM----
------------------------------

local TranscribeBtn = CreateFrame("Button", "FieldNotesTranscribeBtn", ItemTextFrame, "UIPanelButtonTemplate")
TranscribeBtn:SetSize(90, 22)
TranscribeBtn:SetPoint("BOTTOMRIGHT", ItemTextFrame, "TOPRIGHT", 0, 0)
TranscribeBtn:SetText("Transcribe")
TranscribeBtn:SetFrameLevel(ItemTextFrame:GetFrameLevel() + 10)

local isTranscribing = false
local tempTranscription = ""
local transcriptionTitle = ""
local TranscriberCore = CreateFrame("Frame")
TranscriberCore:RegisterEvent("ITEM_TEXT_READY")
TranscriberCore:RegisterEvent("ITEM_TEXT_CLOSED")

TranscriberCore:SetScript("OnEvent", function(self, event, ...)
    if event == "ITEM_TEXT_CLOSED" then
        isTranscribing = false
    elseif event == "ITEM_TEXT_READY" and isTranscribing then
        tempTranscription = tempTranscription .. "\n\n" .. ItemTextGetText()
        if ItemTextHasNextPage() then
            ItemTextNextPage()
        else
            isTranscribing = false
            local id = time()
            FieldNotesDB[id] = {
                name = transcriptionTitle,
                text = tempTranscription,
                id = id,
                type = "transcription"
            }
            if NoteFrame:IsShown() and currentTab == "transcription" then
                UpdateListDisplay()
            end
        end
    end
end)

TranscribeBtn:SetScript("OnClick", function()
    if isTranscribing then return end
    isTranscribing = true
    transcriptionTitle = ItemTextGetItem() or "Unknown Text"
    tempTranscription = ItemTextGetText()
    if ItemTextHasNextPage() then
        ItemTextNextPage()
    else
        isTranscribing = false
        local id = time()
        FieldNotesDB[id] = {
            name = transcriptionTitle,
            text = tempTranscription,
            id = id,
            type = "transcription"
        }
        if NoteFrame:IsShown() and currentTab == "transcription" then
            UpdateListDisplay()
        end
    end
end)

------------------------------
---CHAT LINK FILTER SYSTEM----
------------------------------

local function FieldNotesChatFilter(self, event, msg, author, ...)
    if msg and msg:find("{FN:") then
        msg = msg:gsub("{FN:([^:]+):(%d+):([^}]*)}", function(pName, nID, nName)
            return string.format("|cff00ccff|Hfieldnotereq:%s:%s|h[Field Notes: %s]|h|r", pName, nID, nName)
        end)
    end
    return false, msg, author, ...
end

local chatEvents = {
    "CHAT_MSG_SAY", "CHAT_MSG_YELL", "CHAT_MSG_GUILD", "CHAT_MSG_OFFICER",
    "CHAT_MSG_PARTY", "CHAT_MSG_PARTY_LEADER", "CHAT_MSG_RAID", "CHAT_MSG_RAID_LEADER",
    "CHAT_MSG_WHISPER", "CHAT_MSG_WHISPER_INFORM", "CHAT_MSG_INSTANCE_CHAT", "CHAT_MSG_INSTANCE_CHAT_LEADER"
}

for _, event in ipairs(chatEvents) do
    ChatFrame_AddMessageEventFilter(event, FieldNotesChatFilter)
end

--------------------------------
---NETWORKING & SHARE SYSTEM----
--------------------------------

local AddonPrefix = "FLDNOTES"
C_ChatInfo.RegisterAddonMessagePrefix(AddonPrefix)
local incomingBuffer = {}

local function TransmitNote(targetPlayer, note)
    local maxPayload = 200 
    local textLen = string.len(note.text)
    local totalChunks = math.ceil(textLen / maxPayload)
    local metaStr = string.format("META:%d:%d:%s:%s", note.id, totalChunks, note.type or "note", note.name)
    C_ChatInfo.SendAddonMessage(AddonPrefix, metaStr, "WHISPER", targetPlayer)

    for i = 1, totalChunks do
        local startPos = ((i - 1) * maxPayload) + 1
        local endPos = i * maxPayload
        local chunkText = string.sub(note.text, startPos, endPos)
        local chunkStr = string.format("CHUNK:%d:%d:%s", note.id, i, chunkText)
        C_ChatInfo.SendAddonMessage(AddonPrefix, chunkStr, "WHISPER", targetPlayer)
    end
end

local CommFrame = CreateFrame("Frame")
CommFrame:RegisterEvent("CHAT_MSG_ADDON")
CommFrame:SetScript("OnEvent", function(self, event, prefix, text, channel, sender)
    if prefix ~= AddonPrefix then return end
    local senderName = Ambiguate(sender, "none")
    if senderName == UnitName("player") then return end 

    local command, payload = string.split(":", text, 2)

    if command == "REQ" then
        local requestedID = tonumber(payload)
        local note = FieldNotesDB[requestedID]
        if note then
            TransmitNote(senderName, note)
        end
    elseif command == "META" then
        local noteIDStr, totalChunksStr, noteType, noteName = string.split(":", payload, 4)
        local noteID = tonumber(noteIDStr)
        local totalChunks = tonumber(totalChunksStr)

        incomingBuffer[noteID] = {
            name = noteName,
            type = noteType,
            totalChunks = totalChunks,
            chunks = {},
            received = 0
        }
    elseif command == "CHUNK" then
        local noteIDStr, chunkIndexStr, textData = string.split(":", payload, 3)
        local noteID = tonumber(noteIDStr)
        local chunkIndex = tonumber(chunkIndexStr)

        if incomingBuffer[noteID] then
            incomingBuffer[noteID].chunks[chunkIndex] = textData
            incomingBuffer[noteID].received = incomingBuffer[noteID].received + 1

            if incomingBuffer[noteID].received == incomingBuffer[noteID].totalChunks then
                local fullText = ""
                for i = 1, incomingBuffer[noteID].totalChunks do
                    fullText = fullText .. (incomingBuffer[noteID].chunks[i] or "")
                end

                local newID = time()
                FieldNotesDB[newID] = {
                    id = newID,
                    name = incomingBuffer[noteID].name,
                    type = incomingBuffer[noteID].type,
                    text = fullText
                }

                incomingBuffer[noteID] = nil

                if NoteFrame:IsShown() then
                    UpdateListDisplay()
                end
                print("|cFF00FF00FieldNotes:|r Received new note from " .. senderName)
            end
        end
    end
end)

local function RequestNoteFromPlayer(targetPlayer, noteID)
    local myName, myRealm = UnitName("player")
    local myFullName = myName
    if myRealm and myRealm ~= "" then 
        myFullName = myName .. "-" .. myRealm 
    end

    if targetPlayer == myName or targetPlayer == myFullName then
        print("|cFFFFFF00FieldNotes:|r You already have this note in your database.")
        return
    end

    C_ChatInfo.SendAddonMessage(AddonPrefix, "REQ:"..noteID, "WHISPER", targetPlayer)
    print("|cFFFFFF00FieldNotes:|r Requesting note from " .. targetPlayer .. "...")
end

hooksecurefunc("SetItemRef", function(link, text, button, chatFrame)
    local linkType, targetPlayer, noteID = string.split(":", link)
    if linkType == "fieldnotereq" then
        RequestNoteFromPlayer(targetPlayer, noteID)
    end
end)

-------------------
---LOAD ON LOGIN---
-------------------

local loaderFrame = CreateFrame("Frame")
loaderFrame:RegisterEvent("ADDON_LOADED")
loaderFrame:SetScript("OnEvent",function(self,event,addonName)
    if addonName == "field-notes" then
        if FieldNotesDB == nil then
            FieldNotesDB = {}
        end
        UpdateListDisplay()
    end
end)