LootCouncil.MessageBus = {}

local Bus = LootCouncil.MessageBus

---------------------------------------------------
-- State
---------------------------------------------------

Bus.handlers = {}

Bus.transportHandlers = {}

---------------------------------------------------
-- Initialize
---------------------------------------------------

function Bus:Initialize()

end

---------------------------------------------------
-- Register
---------------------------------------------------

function Bus:Register(

    command,

    owner,

    callback

)

    ---------------------------------------------------
    -- Validation
    ---------------------------------------------------

    if type(command) ~= "string" then

        error(

            "MessageBus:Register() - command must be a string."

        )

    end

    if type(callback) ~= "function" then

        error(

            "MessageBus:Register() - callback must be a function."

        )

    end

    ---------------------------------------------------
    -- Create Bucket
    ---------------------------------------------------

    if not self.handlers[command] then

        self.handlers[command] = {}

    end

    ---------------------------------------------------
    -- Register
    ---------------------------------------------------

    table.insert(

        self.handlers[command],

        {

            owner = owner,

            callback = callback

        }

    )

end

---------------------------------------------------
-- Register Transport
---------------------------------------------------

function Bus:RegisterTransport(

    owner,

    callback

    )

    if type(callback) ~= "function" then

        error(

            "MessageBus:RegisterTransport() - callback must be a function."

        )

    end

    table.insert(

        self.transportHandlers,

        {

            owner = owner,

            callback = callback

        }

    )

end

---------------------------------------------------
-- Unregister
---------------------------------------------------

function Bus:Unregister(

    command,

    owner

)

    local handlers =

        self.handlers[command]

    if not handlers then
        return
    end

    for i = #handlers, 1, -1 do

        if handlers[i].owner == owner then

            table.remove(

                handlers,

                i

            )

        end

    end

    if #handlers == 0 then

        self.handlers[command] = nil

    end

end

---------------------------------------------------
-- Publish
---------------------------------------------------

function Bus:Publish(
    message,
    sender
)

    if not message then
        return
    end

    local command = message:GetCommand()

    local handlers = self.handlers[command]

    if not handlers then
        return
    end

    for _, listener in ipairs(handlers) do
        listener.callback(
            listener.owner,
            message,
            sender
        )
    end

end

---------------------------------------------------
-- Transport
---------------------------------------------------

function Bus:Transport(

    message,

    sender

)

    ---------------------------------------------------
    -- Transport
    ---------------------------------------------------

    for _, listener in ipairs(

        self.transportHandlers

    ) do

        listener.callback(

            listener.owner,

            message,

            sender

        )

    end

end

---------------------------------------------------
-- Broadcast
---------------------------------------------------

function Bus:Broadcast(

    message,

    sender

)

    self:Transport(

        message,

        sender

    )

end

---------------------------------------------------
-- Route
---------------------------------------------------

function Bus:Route(

    message,

    sender

)

    self:Transport(

        message,

        sender

    )

    self:Publish(

        message,

        sender

    )

end

---------------------------------------------------
-- Has Handlers
---------------------------------------------------

function Bus:HasHandlers(

    command

)

    local handlers =

        self.handlers[command]

    return

        handlers ~= nil

        and

        #handlers > 0

end