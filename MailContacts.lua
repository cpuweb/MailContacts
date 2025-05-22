MailContactsDB = MailContactsDB or {}

local dropdownShown = false
local dropdownFrame

function MailContacts_OnLoad()
    DEFAULT_CHAT_FRAME:AddMessage("MailContacts loaded.")
    MailContactsArrowButton:SetText("C")
    MailContactsArrowButton:SetScript("OnEnter", function()
        GameTooltip:SetOwner(MailContactsArrowButton, "ANCHOR_RIGHT")
        GameTooltip:SetText("Show saved contacts", 1, 1, 1)
        GameTooltip:Show()
    end)
    MailContactsArrowButton:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    -- Hook into the Send button
    MailContacts_HookSendButton()
end

function MailContacts_HookSendButton()
    local originalSendMail = SendMailMailButton:GetScript("OnClick")
    SendMailMailButton:SetScript("OnClick", function()
        local name = SendMailNameEditBox:GetText()
        if name and name ~= "" then
            MailContactsDB[name] = true
        end
        UIDropDownMenu_Initialize(MailContactsDropdown, MailContacts_InitDropdown)

        -- Call the original function
        if originalSendMail then
            originalSendMail()
        end
    end)
end

function MailContacts_ToggleDropdown()
    if dropdownShown then
        MailContacts_HideDropdown()
    else
        MailContacts_ShowDropdown()
    end
end

function MailContacts_ShowDropdown()
    dropdownShown = true

    if not dropdownFrame then
        dropdownFrame = CreateFrame("Frame", "MailContactsCustomDropdown", MailContactsArrowButton)
        dropdownFrame:SetBackdrop({
            bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
            edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
            tile = true, tileSize = 16, edgeSize = 16,
            insets = { left = 4, right = 4, top = 4, bottom = 4 }
        })
        dropdownFrame:SetWidth(140)
        dropdownFrame:SetHeight(100)
        dropdownFrame:SetPoint("TOPLEFT", MailContactsArrowButton, "BOTTOMLEFT", 0, -2)
        dropdownFrame:EnableMouse(true)
        dropdownFrame:SetFrameStrata("DIALOG")
    end

    -- Clear any previous buttons
    if dropdownFrame.buttons then
        for _, button in ipairs(dropdownFrame.buttons) do
            button:Hide()
            button:SetParent(nil)
        end
    end
    dropdownFrame.buttons = {}

    local sortedNames = {}
    for name in pairs(MailContactsDB) do
        table.insert(sortedNames, name)
    end
    table.sort(sortedNames)

    for i, name in ipairs(sortedNames) do
        local btn = CreateFrame("Button", nil, dropdownFrame, "UIPanelButtonTemplate")
        btn:SetWidth(120)
        btn:SetHeight(20)
        btn:SetPoint("TOPLEFT", dropdownFrame, "TOPLEFT", 10, -((i - 1) * 22) - 10)
        btn:SetText(name)
        btn:SetScript("OnClick", function()
            SendMailNameEditBox:SetText(name)
            MailContacts_HideDropdown()
        end)
        table.insert(dropdownFrame.buttons, btn)
    end
end

function MailContacts_HideDropdown()
    dropdownShown = false
    if dropdownFrame then dropdownFrame:Hide() end
end