JSON = require('dkjson')
db = require('redis')
redis = db.connect('127.0.0.1', 6379)
tdcli = dofile('tdcli.lua')
serpent = require('serpent')
redis:select(2)

function is_sudo(msg)
  local var = false
 -- — Check users id in config
for v,user in pairs(sudo_users) do
   if user == msg.sender_user_id_ then
     var = true
  end
  end
  return var
end

sudo_users = {
  205906514
}

function dl_cb(arg, data)
  vardump(arg)
  vardump(data)
end

function vardump(value)
  print(serpent.block(value, {comment=false}))
end

function vardump2(value)
  return serpent.block(value, {comment=true})
end

function check_contact(extra, result)
local tabchi_id = 200
  if not result.phone_number_ then
    local msg = extra.msg
    local first_name = "" .. (msg.content_.contact_.first_name_ or "-") .. ""
    local last_name = "" .. (msg.content_.contact_.last_name_ or "-") .. ""
    local phone_number = msg.content_.contact_.phone_number_
    local user_id = msg.content_.contact_.user_id_
    tdcli.add_contact(phone_number, first_name, last_name, user_id)
    if redis:get("tabchi:" .. tabchi_id .. ":markread") then
      tdcli.viewMessages(msg.chat_id_, {
        [0] = msg.id_
      })
      if redis:get("tabchi:" .. tabchi_id .. ":addedms") then
        tdcli.sendMessage(msg.chat_id_, msg.id_, 1, "" .. (redis:get("tabchi:" .. tabchi_id .. ":addedmsgtext") or [[
Addi
Bia pv]]) .. "", 1, "md")
      end
    elseif redis:get("tabchi:" .. tabchi_id .. ":addedmsg") then
      tdcli.sendMessage(msg.chat_id_, msg.id_, 1, "" .. (redis:get("tabchi:" .. tabchi_id .. ":addemsgtext") or [[
Addi
Bia pv]]) .. "", 1, "md")
    end
  end
end
function process_links(text_)
  if text_:match("https://telegram.me/joinchat/%S+") then
    local matches = {
      text_:match("(https://telegram.me/joinchat/%S+)")
    }
    tdcli_function({
      ID = "CheckChatInviteLink",
      invite_link_ = matches[1]
    }, check_link, {
      link = matches[1]
    })
  end
end
function add(chat_id_)
local tabchi_id = 200
  local chat_type = chat_type(chat_id_)
  if chat_type == "channel" then
    redis:sadd("tabchi:" .. tabchi_id .. ":channels", chat_id_)
  elseif chat_type == "group" then
    redis:sadd("tabchi:" .. tabchi_id .. ":groups", chat_id_)
  else
    redis:sadd("tabchi:" .. tabchi_id .. ":pvis", chat_id_)
  end
  redis:sadd("tabchi:" .. tabchi_id .. ":all", chat_id_)
end
function rem(chat_id_)
local tabchi_id = 200
  local chat_type = chat_type(chat_id_)
  if chat_type == "channel" then
    redis:srem("tabchi:" .. tabchi_id .. ":channels", chat_id_)
  elseif chat_type == "group" then
    redis:srem("tabchi:" .. tabchi_id .. ":groups", chat_id_)
  else
    redis:srem("tabchi:" .. tabchi_id .. ":pvis", chat_id_)
  end
  redis:srem("tabchi:" .. tabchi_id .. ":all", chat_id_)
end
function tdcli_update_callback(data)
  --vardump(data)
  local tabchi_id = 200
	if (data.ID == "UpdateNewMessage") then
			local msg = data.message_
			local msg = data.message_
			local input = msg.content_.text_
			local chat_id = msg.chat_id_
			local user_id = msg.sender_user_id_
		if msg.text:match('[!/#]echo') and is_sudo(msg) then
			 local text = msg.text:gsub('[!/#]echo', '')
		        tdcli.sendMessage(msg.chat_id_, msg.id_, 0, text, 0, "md")
		end
		if msg.text:match("^[!/#]fwd all$") and msg.reply_to_message_id_ and is_sudo(msg) then
    local all = redis:smembers("tabchi:" .. tabchi_id .. ":all")
    local id = msg.reply_to_message_id_
    for i = 1, #all do
      tdcli_function({
        ID = "ForwardMessages",
        chat_id_ = all[i],
        from_chat_id_ = msg.chat_id_,
        message_ids_ = {
          [0] = id
        },
        disable_notification_ = 0,
        from_background_ = 1
      }, dl_cb, nil)
    end
    return "Sent!"
  end
  if msg.text:match("^[!/#]fwd gps$") and msg.reply_to_message_id_ and is_sudo(msg) then
    local all = redis:smembers("tabchi:" .. tabchi_id .. ":groups")
    local id = msg.reply_to_message_id_
    for i = 1, #all do
      tdcli_function({
        ID = "ForwardMessages",
        chat_id_ = all[i],
        from_chat_id_ = msg.chat_id_,
        message_ids_ = {
          [0] = id
        },
        disable_notification_ = 0,
        from_background_ = 1
      }, dl_cb, nil)
    end
    return "Sent!"
  end
  if msg.text:match("^[!/#]fwd sgps$") and msg.reply_to_message_id_ and is_sudo(msg) then
    local all = redis:smembers("tabchi:" .. tabchi_id .. ":channels")
    local id = msg.reply_to_message_id_
    for i = 1, #all do
      tdcli_function({
        ID = "ForwardMessages",
        chat_id_ = all[i],
        from_chat_id_ = msg.chat_id_,
        message_ids_ = {
          [0] = id
        },
        disable_notification_ = 0,
        from_background_ = 1
      }, dl_cb, nil)
    end
    return "Sent!"
  end
  if msg.text:match("^[!/#]addtoall") and msg.reply_to_message_id_ and is_sudo(msg) then
    tdcli_function({
      ID = "GetMessage",
      chat_id_ = msg.chat_id_,
      message_id_ = msg.reply_to_message_id_
    }, add_to_all, nil)
    return "Adding user to groups..."
  end
  if msg.text:match("^[!/#]fwd users$") and msg.reply_to_message_id_ and is_sudo(msg) then
    local all = redis:smembers("tabchi:" .. tabchi_id .. ":pvis")
    local id = msg.reply_to_message_id_
    for i = 1, #all do
      tdcli_function({
        ID = "ForwardMessages",
        chat_id_ = all[i],
        from_chat_id_ = msg.chat_id_,
        message_ids_ = {
          [0] = id
        },
        disable_notification_ = 0,
        from_background_ = 1
      }, dl_cb, nil)
    end
    return "Sent!"
  end
   if msg.text:match("^[!/#]bc") and is_sudo(msg) then
    local all = redis:smembers("tabchi:" .. tabchi_id .. ":all")
    local matches = {
      msg.text:match("[!/#](bc) (.*)")
    }
    if #matches == 2 then
      for i = 1, #all do
        tdcli_function({
          ID = "SendMessage",
          chat_id_ = all[i],
          reply_to_message_id_ = 0,
          disable_notification_ = 0,
          from_background_ = 1,
          reply_markup_ = nil,
          input_message_content_ = {
            ID = "InputMessageText",
            text_ = matches[2],
            disable_web_page_preview_ = 0,
            clear_draft_ = 0,
            entities_ = {},
            parse_mode_ = {
              ID = "TextParseModeMarkdown"
            }
          }
        }, dl_cb, nil)
      end
    end
  end
  if msg.text:match('^[!/#]setaddedmsg') and is_sudo(msg) then
	text = msg.text:gsub('[!/#]setaddedmsg','')
      redis:set("tabchi:" .. tabchi_id .. ":addedmsgtext", text)
      return [[
New Added Message Set!
Message :
]] .. text
end
if msg.text:match("^[!/#]markread") and is_sudo(msg) then
local mode = msg.text:gsub('[!/#]markread','')
      if mode == "on" then
        redis:set("tabchi:" .. tabchi_id .. ":markread", true)
        return "Markread Turned On"
      elseif mode == "off" then
        redis:del("tabchi:" .. tabchi_id .. ":markread")
        return "Markread Turned Off"
      end
    end
  end
  if msg.text:match('[!/#]panel') and is_sudo(msg) then
  local gps = redis:scard("tabchi:" .. tabchi_id .. ":groups")
      local sgps = redis:scard("tabchi:" .. tabchi_id .. ":channels")
      local pvs = redis:scard("tabchi:" .. tabchi_id .. ":pvis")
      local links = redis:scard("tabchi:" .. tabchi_id .. ":savedlinks")
      local query = gps .. " " .. sgps .. " " .. pvs .. " " .. links
      local inline = function(arg, data)
		local text = [[
*Basic Stats :*
Users : ]] .. pvs .. [[

Groups : ]] .. gps .. [[

SuperGroups : ]] .. sgps .. [[

Saved links : ]] .. links .. '\n Cracked Version By ThinkTeam'
          tdcli.sendMessage(msg.chat_id_, 0, 1, text, 1, "md")
		 end
    if msg.text:match("^[!/#]addsudo") and is_full_sudo(msg) then
	local id = msg.text:gsub('[!/#]addsudo','')
      local text = id .. " Added to *Sudo Users*"
      redis:sadd("tabchi:" .. tabchi_id .. ":sudoers", tonumber(id))
      return text
  end
    if msg.text:match("^[!/#]remsudo") and is_full_sudo(msg) then
      local id = msg.text:gsub('[!/#]remsudo','')
      local text = id .. " Removed From *Sudo Users*"
      redis:srem("tabchi:" .. tabchi_id .. ":sudoers", tonumber(id))
      return text
    end
    if msg.text:match("^[!/#]addedmsg") and is_sudo(msg) then
	local id = msg.text:gsub('[!/#]addedmsg','')
      if id == "on" then
        redis:set("tabchi:" .. tabchi_id .. ":addedmsg", true)
        return "Added Message Turned On"
      elseif id == "off" then
        redis:del("tabchi:" .. tabchi_id .. ":addedmsg")
        return "Added Message Turned Off"
      end
end
  if msg.text:match("^[!/#]addmembers$") and is_sudo(msg) and chat_type(msg.chat_id_) ~= "private" then
    tdcli_function({
      ID = "SearchContacts",
      query_ = nil,
      limit_ = 999999999
    }, add_members, {
      chat_id = msg.chat_id_
    })
    return
  end
	elseif (data.ID == "UpdateOption" and data.name_ == "my_id") then
    tdcli_function ({
      ID="GetChats",
      offset_order_="9223372036854775807",
      offset_chat_id_=0,
      limit_=20
    }, dl_cb, nil)
	end
end
