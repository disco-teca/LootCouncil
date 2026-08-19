function LootCouncil.UI.Widgets:CreateLabel(parent, options)

    options = options or {}

    local label = parent:CreateFontString(
        nil,
        "OVERLAY",
        options.font or "GameFontHighlight"
    )

    if options.point then

        label:SetPoint(
            options.point,
            options.relativeTo,
            options.relativePoint,
            options.x or 0,
            options.y or 0
        )

    end

    label:SetJustifyH(options.justifyH or "LEFT")
    label:SetJustifyV(options.justifyV or "TOP")

    if options.width then
        label:SetWidth(options.width)
    end

    if options.text then
        label:SetText(options.text)
    end

    return label

end