------------------------
---CREATE NOTE WINDOW---
------------------------

local NoteFrame = CreateFrame("Frame", "FieldNotesFrame", UIParent, "BasicFrameTemplate")
NoteFrame:SetSize(600,400) -- W x H
NoteFrame:SetPoint("CENTER",UIParent,"CENTER") -- Center of screen
NoteFrame:Hide() -- Keep hidden until user types /note
tinsert(UISpecialFrames, "FieldNotesFrame")

-- Drag it
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
EditorScroll:SetPoint("BOTTOMRIGHT", EditorBackground, "BOTTOMRIGHT", -27, 8) -- Leaves room for the scrollbar

local EditorBox = CreateFrame("EditBox", "FieldNotesEditorBox", EditorScroll)
EditorBox:SetMultiLine(true)
EditorBox:SetFontObject("MailTextFontNormal") -- Swapped to dark "ink" font for readability!
EditorBox:SetWidth(345) -- Matches the new inner width of the scroll frame
EditorBox:SetAutoFocus(false)

EditorBox:SetTextInsets(15, 15, 10, 10)

EditorScroll:SetScrollChild(EditorBox)

-----------------
---TAB CONTROL---
-----------------
local currentTab = "note" -- Default tab
local currentNoteType = "note" -- Tracks the type of the currently open note

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
-- Moved down to -55 to make room for the tabs!
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
SaveButton:SetPoint("LEFT", AddButton, "RIGHT", 5, 0) -- Anchor to right of addbutton
SaveButton:SetText("S")
AddDelayedTooltip(SaveButton,"Manually Save and Reload")

local DeleteButton = CreateFrame("Button", nil, NoteFrame, "UIPanelButtonTemplate")
DeleteButton:SetSize(30,30)
DeleteButton:SetPoint("LEFT",SaveButton,"RIGHT",5,0) -- Anchor to right of savebutton
DeleteButton:SetText("-")
AddDelayedTooltip(DeleteButton, "Delete Selected Note")

local ToolbarDivider = NoteFrame:CreateTexture(nil, "ARTWORK")
ToolbarDivider:SetColorTexture(0, 0, 0, 0)
ToolbarDivider:SetPoint("TOPLEFT", EditorBackground, "BOTTOMLEFT", 0, -5)
ToolbarDivider:SetPoint("BOTTOMRIGHT", EditorBackground, "BOTTOMRIGHT", 0, -30)

-- Bullet Button
local BulletButton = CreateFrame("Button", nil, NoteFrame, "UIPanelButtonTemplate")
BulletButton:SetSize(30, 30)
BulletButton:SetPoint("LEFT", ToolbarDivider, "LEFT", 0, 0) -- Anchor to left side of Editor
BulletButton:SetText("-")
AddDelayedTooltip(BulletButton, "Insert Bullet")

-- Task Checkbox Button
local TaskButton = CreateFrame("Button", nil, NoteFrame, "UIPanelButtonTemplate")
TaskButton:SetSize(40, 30)
TaskButton:SetPoint("LEFT", BulletButton, "RIGHT", 5, 0)
TaskButton:SetText("[ ]")
AddDelayedTooltip(TaskButton, "Insert Task")

-- Task Done Button
local TaskDoneButton = CreateFrame("Button", nil, NoteFrame, "UIPanelButtonTemplate")
TaskDoneButton:SetSize(40, 30)
TaskDoneButton:SetPoint("LEFT", TaskButton, "RIGHT", 5, 0)
TaskDoneButton:SetText("[x]")
AddDelayedTooltip(TaskDoneButton, "Insert Completed Task")

----------------------
---NOTE LIST UPDATE---
----------------------

local currentNoteID = nil
local noteButtons = {} 

local function UpdateListDisplay()
    -- Hide all buttons
    for _, btn in ipairs(noteButtons) do
        btn:Hide()
    end

    local yOffset = -5 
    local buttonIndex = 1

    for id, noteData in pairs(FieldNotesDB) do
        -- Backwards compatibility: If no type is set, assume it's a standard note
        local nType = noteData.type or "note"

        -- ONLY display notes that match the current tab
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
                currentNoteType = nType -- Save the type of the note we just opened
                EditorBox:SetText(noteData.text)
                -- print("FieldNotes: Loaded '" .. noteData.name .. "'")

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

-- Tab Click Events
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
    timeout = 0, -- Staysopen until clicked
    whileDead = true, -- Works while dead
    hideOnEscape = true, -- Closes with escape key
    preferredIndex = 4, -- Avoid UI taint errors with blizz frames
}

SaveButton:SetScript("OnClick", function() -- New save functionality acts as a hard save to give the user an option to protect against a hard crash
    StaticPopup_Show("FIELDNOTES_CONFIRM_FORCESAVE")
end)

EditorBox:SetScript("OnTextChanged",function(self,isUserInput)
    if not isUserInput then return end
    local content = self:GetText()
    if content == "" or content == nil then return end

    local noteName = string.sub(content, 1, 15) 
    if string.len(content) > 15 then
        noteName = noteName .. "..."
    end
    
    if currentNoteID == nil then 
        currentNoteID = time()
    end

    -- Save the 'type' variable to the DB!
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
    currentNoteType = currentTab -- New notes take on the type of the tab you are looking at
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

            -- print("FieldNotes: Note deleted.")

            UpdateListDisplay()
        end
    end,
    timeout = 0, -- Staysopen until clicked
    whileDead = true, -- Works while dead
    hideOnEscape = true, -- Closes with escape key
    preferredIndex = 3, -- Avoid UI taint errors with blizz frames
}

DeleteButton:SetScript("OnClick", function()
    if currentNoteID ~= nil then
        StaticPopup_Show("FIELDNOTES_CONFIRM_DELETE")
    end
end)

BulletButton:SetScript("OnClick", function()
    EditorBox:Insert("- ")
    EditorBox:SetFocus() -- Keeps your cursor in the box so you can keep typing!
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
-------------------------------

local TrackerButton = CreateFrame("Button", "FieldNotesTrackerButton", UIParent)
TrackerButton:SetSize(20, 20) -- Made it smaller to fit perfectly on that thin header bar
TrackerButton:SetFrameLevel(10)

-- THE FIX: We changed "HeaderMenu" to "Header" to match the modern WoW API!
TrackerButton:SetPoint("RIGHT", ObjectiveTrackerFrame.Header.MinimizeButton, "LEFT", -5, 0)

-- Set the icon to a nice crisp scroll
TrackerButton.Icon = TrackerButton:CreateTexture(nil, "ARTWORK")
TrackerButton.Icon:SetAllPoints()
TrackerButton.Icon:SetTexture("Interface\\Icons\\inv_misc_book_09")

-- Add a subtle highlight when you hover over it
TrackerButton:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square")
TrackerButton:GetHighlightTexture():SetBlendMode("ADD")

-- Tooltip so people know what this tiny scroll does
TrackerButton:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText("Field Notes")
    GameTooltip:AddLine("Click to open", 1, 1, 1)
    GameTooltip:Show()
end)

TrackerButton:SetScript("OnLeave", function() 
    GameTooltip:Hide() 
end)

-- Click to Open/Close your NoteFrame
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

-- Anchor the TOP-LEFT of our button to the TOP-RIGHT edge of the book.
-- The '5' pushes it 5 pixels outward to the right so it doesn't sit flush on the border.
-- The '-45' moves it down slightly so it aligns nicely with the top of the parchment.
TranscribeBtn:SetPoint("BOTTOMRIGHT", ItemTextFrame, "TOPRIGHT", 0, 0)

TranscribeBtn:SetText("Transcribe")

-- Keep the frame level high just to ensure it stays above any background UI elements
TranscribeBtn:SetFrameLevel(ItemTextFrame:GetFrameLevel() + 10)

local isTranscribing = false
local tempTranscription = ""
local transcriptionTitle = ""

local TranscriberCore = CreateFrame("Frame")
TranscriberCore:RegisterEvent("ITEM_TEXT_READY")
TranscriberCore:RegisterEvent("ITEM_TEXT_CLOSED")

TranscriberCore:SetScript("OnEvent", function(self, event, ...)
    if event == "ITEM_TEXT_CLOSED" then
        isTranscribing = false -- Failsafe to cancel if the player closes the book
    elseif event == "ITEM_TEXT_READY" and isTranscribing then
        -- The server has sent the text for the next page, grab it!
        tempTranscription = tempTranscription .. "\n\n" .. ItemTextGetText()
        
        if ItemTextHasNextPage() then
            ItemTextNextPage() -- Triggers another ITEM_TEXT_READY event
        else
            -- We've reached the end of the book
            isTranscribing = false
            local id = time()
            
            FieldNotesDB[id] = {
                name = transcriptionTitle,
                text = tempTranscription,
                id = id,
                type = "transcription"
            }
            
            -- print("FieldNotes: Successfully transcribed '" .. transcriptionTitle .. "'!")
            
            -- Close the in-game book automatically when done
            -- HideUIPanel(ItemTextFrame)
            
            if NoteFrame:IsShown() and currentTab == "transcription" then
                UpdateListDisplay()
            end
        end
    end
end)

TranscribeBtn:SetScript("OnClick", function()
    if isTranscribing then return end -- Don't run multiple times
    
    isTranscribing = true
    transcriptionTitle = ItemTextGetItem() or "Unknown Text"
    tempTranscription = ItemTextGetText() -- Grab the first page

    -- print("FieldNotes: Transcribing, please wait...")

    if ItemTextHasNextPage() then
        ItemTextNextPage() -- Start the chain reaction
    else
        -- It's a single page document
        isTranscribing = false
        local id = time()
        
        FieldNotesDB[id] = {
            name = transcriptionTitle,
            text = tempTranscription,
            id = id,
            type = "transcription"
        }
        
        -- print("FieldNotes: Successfully transcribed '" .. transcriptionTitle .. "'!")
        
        if NoteFrame:IsShown() and currentTab == "transcription" then
            UpdateListDisplay()
        end
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

        -- print("FieldNotesDB: Notes loaded. Type /note to open.")

    end
end)