DERMATEXT  = {SELECTOR_DIALOGTITLE = "Do you want kick player?",
			VK_DIALOGTITLE = "VoteKick", VK_DIALOGCONTENT = "KickPlayer: ",
			VK_LABEL_PRESSKEY_YES = "Press F1 to Vote YES", VK_LABEL_PRESSKEY_NO = "Press F2 to Vote NO"}
ERRORS = {NOTSELECT = "Please select you want kick player."}
KEYS   = {VOTE_YES = KEY_F1 , VOTE_NO = KEY_F2}
COLOR  = {WHITE = Color(255, 255, 255, 255)}

print("clientside lua is loaded.")
print("ScrW:" .. ScrW() .. "\nScrH:" .. ScrH())


function init()
	surface.CreateFont("KickPlayerFont", {
	font      = "Roboto",
	size      = 26,
	weight    = 500,
	blursize  = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic    = false,
	strikeout = false,
	symbol    = false,
	rotary    = false,
	shadow    = false,
	additive  = false,
	outline   = false,
	})

	User_Vote = nil
	VoteLock = false
	VoteReady = false

	print("cl_votekick - Initialize complete")
end
init()

function kickplayer_selector(ply, text)
	voteby = net.ReadString()
	playersname = net.ReadTable()

	DialogCreate("selector")
end

function votekick_IsStart()
	if dlvselect != nil then
		print(dlvselect)
		df:Close()
		votekick(dlvselect, voteby)
	else
		Entity(1):PrintMessage(HUD_PRINTTALK, ERRORS["NOTSELECT"])
	end
end

function votekick(kickplayer)
	-- Variables
	kickplayer_str = tostring(kickplayer)
	vk_dialogcontent = DERMATEXT["VK_DIALOGCONTENT"] .. kickplayer_str .. " ?"
	votetime = 60
	local textsizeMAX = 311
	local textsizeMIN = 311
	-- text width size check. 1 character = 13
	surface.SetFont("KickPlayerFont")
	dllvkttextwidth = surface.GetTextSize(DERMATEXT["VK_DIALOGTITLE"])
	dllvkmtextwidth = surface.GetTextSize(vk_dialogcontent)

	-- if text size is over
	if dllvkmtextwidth > textsizeMAX then
		local onecharactor = 13
		local width = dllvkmtextwidth + 39
		local minuscounter = 0

		repeat
			width = width - onecharactor
			minuscounter = minuscounter + 1
		until width <= textsizeMAX

		local subtext = string.sub(kickplayer_str, string.len(kickplayer_str) - minuscounter, string.len(kickplayer_str))
		kickplayer_str = string.gsub(kickplayer_str, subtext, "") .. "..."
		dllvkmtextwidth = surface.GetTextSize(DERMATEXT["VK_DIALOGCONTENT"] .. kickplayer_str .. " ?")
		vk_dialogcontent = DERMATEXT["VK_DIALOGCONTENT"] .. kickplayer_str .. " ?"

	elseif dllvkmtextwidth < textsizeMIN then
		dllvkmtextwidth = textsizeMIN
	end

	DialogCreate("voting")
	timer.Create("vk_timer", 1, 0, vote_countdown)

	surface.PlaySound( "garrysmod/ui_click.wav" )
	VoteReady = true
end

function voting()
	if VoteReady == true and input.IsKeyDown(KEYS["VOTE_YES"]) and VoteLock == false then
		User_Vote = "YES"
		VoteLock = true

		votedimg = vgui.Create("DImage")
		DSetPosSizeParent(votedimg, 0, 0, dllvkmtextwidth + 10, 169, dpvk)
		votedimg:SetImage("votekick/select_yes.png", "vgui/avatar_default")

		net.Start("VOTED")
			net.WriteString("YES")
			net.WriteInt(1, 4)
		net.SendToServer()
	elseif VoteReady == true and input.IsKeyDown(KEYS["VOTE_NO"]) and VoteLock == false then
		User_Vote = "NO"
		VoteLock = true

		votedimg = vgui.Create("DImage")
		DSetPosSizeParent(votedimg, 0, 0, dllvkmtextwidth + 10, 169, dpvk)
		votedimg:SetImage("votekick/select_no.png", "vgui/avatar_default")

		net.Start("VOTED")
			net.WriteString("NO")
			net.WriteInt(1, 4)
		net.SendToServer()
	end
end

function vote_countdown()
	if votetime <= 0 then
		VoteReady = false
	else
		votetime = votetime - 1
		local str = tostring(votetime)
		if string.len(str) == 1 then
			str = "0" .. str
		end
		dlltimer:SetText("00:" .. str)
	end
end

-- votekick display update
function vkdisplay_update()
	dllvkYcount_Text = tostring(net.ReadInt(4))
	dllvkNcount_Text = tostring(net.ReadInt(4))
	dllvkYcount:SetText(dllvkYcount_Text)
	dllvkNcount:SetText(dllvkNcount_Text)
end








-- Util
-- DermaCreate
function DialogCreate(selector_or_voting)
	if selector_or_voting == "selector" then
		-- Frame
		df = vgui.Create("DFrame")
		DSetPosSizeParent(df, ScrW() / 2, ScrH() / 2, 350, 250)
		df:Center()
		df:SetTitle(DERMATEXT["SELECTOR_DIALOGTITLE"])
		df:SetDraggable(true)
		df:MakePopup()
		-- Panel
		dp = vgui.Create("DPanel")
		DSetPosSizeParent(dp, 5, 28, 340, 217, df)
		-- ListView
		dlv = vgui.Create("DListView")
		DSetPosSizeParent(dlv, 5, 5, 330, 170, dp)
		dlv:SetMultiSelect(false)
		dlv:AddColumn("Player")
		for i, n in pairs(playersname) do
			local playername = string.sub(tostring(playersname[i]), 12, string.find(tostring(playersname[i]), "]", 11, true) - 1)
			--if playername != voteby then
			dlv:AddLine(playername)
			--end
		end
		dlvselect = nil
		dlv.OnRowSelected = function( panel , index )
			dlvselect = panel:GetLine(index):GetValue(1)
		end
		-- Button
		db = vgui.Create("DButton")
		DSetPosSizeParent(db, 5, 179, 330, 35, dp)
		db:SetText("votekick")
		db:SetFont("DermaLarge")
		db.DoClick = votekick_IsStart
	elseif selector_or_voting == "voting" then
		-- Frame
		dfvk = vgui.Create("DFrame")
		DSetPosSizeParent(dfvk, ScrW() - ScrW(), (ScrH() - ScrH()) + 300, dllvkmtextwidth + 20, 200)
		dfvk:SetTitle("Vote by: " .. tostring(voteby))
		--dfvk:ShowCloseButton(false)
		-- Panel
		dpvk = vgui.Create("DPanel")
		DSetPosSizeParent(dpvk, 5, 27, dllvkmtextwidth + 10, 169, dfvk)
		-- Image
		divk = vgui.Create("DImage")
		DSetPosSizeParent(divk, 0, 0, dllvkmtextwidth + 10, 169, dpvk)
		divk:SetImage("votekick/texture.png", "vgui/avatar_default")
		-- Label Title
		dllvkt = vgui.Create("DLabel")
		DSetPosSizeParent(dllvkt, (dllvkmtextwidth / 2) - (dllvkttextwidth / 2), -3, 120, 50, dpvk)
		dllvkt:SetTextColor(COLOR["WHITE"])
		dllvkt:SetFont("DermaLarge")
		dllvkt:SetText(DERMATEXT["VK_DIALOGTITLE"])
		-- Label Content
		dllvkm = vgui.Create("DLabel")
		DSetPosSizeParent(dllvkm, 5, 35, dllvkmtextwidth, 50, dpvk)
		dllvkm:SetTextColor(COLOR["WHITE"])
		dllvkm:SetFont("KickPlayerFont")
		dllvkm:SetText(vk_dialogcontent)
		-- Label pressf1_yes
		dllvky = vgui.Create("DLabel")
		DSetPosSizeParent(dllvky, 5, 65, 300, 50, dpvk)
		dllvky:SetTextColor(Color(0, 200, 0, 255))
		dllvky:SetFont("KickPlayerFont")
		dllvky:SetText(DERMATEXT["VK_LABEL_PRESSKEY_YES"])
		-- Label pressf2_no
		dllvkn = vgui.Create("DLabel")
		DSetPosSizeParent(dllvkn, 5, 92, 300, 50, dpvk)
		dllvkn:SetTextColor(Color(200, 0, 0, 255))
		dllvkn:SetFont("KickPlayerFont")
		dllvkn:SetText(DERMATEXT["VK_LABEL_PRESSKEY_NO"])
		-- Label Vote Yes Counting
		dllvkYcount_Text = "0"
		dllvkYcount = vgui.Create("DLabel")
		DSetPosSizeParent(dllvkYcount, 60, 125, 300, 50, dpvk)
		dllvkYcount:SetTextColor(Color(0, 255, 0, 255))
		dllvkYcount:SetFont("KickPlayerFont")
		dllvkYcount:SetText(dllvkYcount_Text)
		-- Label Vote No Counting
		dllvkNcount_Text = "0"
		dllvkNcount = vgui.Create("DLabel")
		DSetPosSizeParent(dllvkNcount, 165, 125, 300, 50, dpvk)
		dllvkNcount:SetTextColor(Color(255, 0, 0, 255))
		dllvkNcount:SetFont("KickPlayerFont")
		dllvkNcount:SetText(dllvkNcount_Text)
		--Label timer
		dlltimer = vgui.Create("DLabel")
		DSetPosSizeParent(dlltimer, 235, 125, 300, 50, dpvk)
		dlltimer:SetTextColor(COLOR["WHITE"])
		dlltimer:SetFont("KickPlayerFont")
		dlltimer:SetText("01:00")
	end
end
-- DermaSetting
function DSetPosSizeParent(anyDerma, Px, Py, Sx, Sy, ParentDerma)
	anyDerma:SetPos(Px, Py)
	-- Location Set?
	if Sx != nil and Sy != nil then
		anyDerma:SetSize(Sx, Sy)
	end
	-- Parent Set?
	if ParentDerma != nil then
		anyDerma:SetParent(ParentDerma)
	end
end


net.Receive("name_sendtoclient", kickplayer_selector)
net.Receive("VoteCountedReturn", vkdisplay_update)
hook.Add("Think", "Accept Keys", voting)
-- Debug
hook.Add("OnPlayerChat", "Debugging", votekick)
concommand.Add("init_cl", init)