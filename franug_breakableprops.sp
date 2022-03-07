/*  SM Franug Breakable Props
 *
 *  Copyright (C) 2022 Francisco 'Franc1sco' García
 *
 * This program is free software: you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by the Free
 * Software Foundation, either version 3 of the License, or (at your option)
 * any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with
 * this program. If not, see http://www.gnu.org/licenses/.
 */

#pragma semicolon 1
#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

#define PLUGIN_VERSION "0.2"

Handle hTimer;

public Plugin myinfo =
{
	name = "SM Franug Breakable Props",
	author = "Franc1sco franug",
	description = "",
	version = PLUGIN_VERSION,
	url = "http://steamcommunity.com/id/franug"
};

public void OnPluginStart()
{
	HookEvent("round_start", Event_RoundStart);
}

public void OnMapStart()
{
	PrecacheSound("physics/metal/metal_box_break1.wav");
	PrecacheSound("physics/metal/metal_box_break2.wav");
}

public Event_RoundStart(Handle event, const char[] name, bool dontBroadcast)
{
	delete hTimer;
	hTimer = CreateTimer(2.0, HookDamage);
}

public Action HookDamage(Handle timer)
{
	hTimer = null;
	hookEntities();
}

void hookEntities()
{
	int entity;
	entity = -1;
	while((entity = FindEntityByClassname(entity, "func_physbox")) != -1)
	{
		SetEntProp(entity, Prop_Data, "m_takedamage", 2, 1);
		SetEntProp(entity, Prop_Data, "m_iHealth", GetRandomInt(1, 500));
		SDKHook(entity, SDKHook_OnTakeDamage, OnTakeDamage);
	}
	
	entity = -1;
	while((entity = FindEntityByClassname(entity, "prop_physics")) != -1)
	{
		SetEntProp(entity, Prop_Data, "m_takedamage", 2, 1);
		SetEntProp(entity, Prop_Data, "m_iHealth", GetRandomInt(1, 500));
		SDKHook(entity, SDKHook_OnTakeDamage, OnTakeDamage);
	}
	
	entity = -1;
	while((entity = FindEntityByClassname(entity, "prop_physics_override")) != -1)
	{
		SetEntProp(entity, Prop_Data, "m_takedamage", 2, 1);
		SetEntProp(entity, Prop_Data, "m_iHealth", GetRandomInt(1, 500));
		SDKHook(entity, SDKHook_OnTakeDamage, OnTakeDamage);
	}
	
	entity = -1;
	while((entity = FindEntityByClassname(entity, "prop_physics_multiplayer")) != -1)
	{
		SetEntProp(entity, Prop_Data, "m_takedamage", 2, 1);
		SetEntProp(entity, Prop_Data, "m_iHealth", GetRandomInt(1, 500));
		SDKHook(entity, SDKHook_OnTakeDamage, OnTakeDamage);
	}
}

public void OnEntityDestroyed(int entity)
{
	if(!IsValidEdict(entity) || !IsValidEntity(entity)) return;
	
	char classname[32];
	GetEdictClassname(entity, classname, 32);
	if(StrEqual(classname, "func_physbox") || StrEqual(classname, "prop_physics") || StrEqual(classname, "prop_physics_override") || StrEqual(classname, "prop_physics_multiplayer")) 
	{
		//Declare:
		float fPos[3];
		float dir[3];

		//Initulize:
		GetEntPropVector(entity, Prop_Send, "m_vecOrigin", fPos);

		//Create Temp Ent:
		TE_SetupSparks(fPos, dir, 8, 3);

		//Sent Effect:
		TE_SendToAll();
	}
}

public bool IsValidClient( int client ) 
{ 
    if ( !( 1 <= client <= MaxClients ) || !IsClientInGame(client) ) 
        return false; 
     
    return true; 
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (IsValidEdict(victim))
	{
		if (IsValidClient(attacker))
		{
			decl String:szWeapon[32];
			GetClientWeapon(attacker, szWeapon, 32);
			if (StrContains(szWeapon, "knife", true) == -1 && StrContains(szWeapon, "bayonet", true) == -1)
			{
				damage = 0.0;
				return Plugin_Changed;
			}
			int remaining = GetEntProp(victim, Prop_Data, "m_iHealth") - RoundToNearest(damage);
			if(remaining > 0) PrintCenterText(attacker, "Prop health remaining: %i",remaining);
			else PrintCenterText(attacker, "Prop health remaining: broken");
		}
		int damagedsound = GetRandomInt(1, 2);
		switch (damagedsound)
		{
			case 1:
			{
				float pos[3];
				GetEntPropVector(victim, Prop_Send, "m_vecOrigin", pos);
				EmitSoundToAll("physics/metal/metal_box_break1.wav", SOUND_FROM_WORLD, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, pos);
			}
			case 2:
			{
				float pos[3];
				GetEntPropVector(victim, Prop_Send, "m_vecOrigin", pos);
				EmitSoundToAll("physics/metal/metal_box_break2.wav", SOUND_FROM_WORLD, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, pos);
			}
		}
	}
	return Plugin_Continue;
}