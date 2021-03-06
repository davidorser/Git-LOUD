local TAirUnit = import('/lua/terranunits.lua').TAirUnit
local Weapons2 = import('/mods/BlackOpsUnleashed/lua/BlackOpsweapons.lua')

local TDFGoliathShoulderBeam = Weapons2.TDFGoliathShoulderBeam

XEA3204 = Class(TAirUnit) {

	Weapons = {
       Laser = Class(TDFGoliathShoulderBeam) {},
    },

    Parent = nil,

    SetParent = function(self, parent, podName)
        self.Parent = parent
        self.Pod = podName
    end,
    
    --Make this unit invulnerable
    OnDamage = function()
    end,
    
    OnStopBeingBuilt = function(self, builder, layer)
    
        TAirUnit.OnStopBeingBuilt(self,builder,layer)
        
        --LOG("*AI DEBUG Drone Created")
        
        self:ForkThread(self.HeartBeatDistanceCheck)
    
    end,
    
    HeartBeatDistanceCheck = function(self)
    
        --- Global variable setup
        self.AwayFromCarrier = false

        while self and not self.Dead and not self.Parent:IsDead() do
        
            WaitSeconds(1)
            
            if not self.Dead and not self.Parent:IsDead() then 
            
                local dronePos = self:GetPosition()
                local parentPos = self.Parent:GetPosition()
                local distance = VDist2(dronePos[1], dronePos[3], parentPos[1], parentPos[3])
                
                if distance > 55 and self.AwayFromCarrier == false then
                
                    --- Disables weapons and returns drone to carrier if the drone is past a range of **60***
                    --LOG('*TOO FAR FROM PARENT CARRIER GOING BACK!!')
                    
                    for i = 1, self:GetWeaponCount() do 
                        local wep = self:GetWeapon(i)
                        IssueStop({self}) 
                        IssueClearCommands({self}) 
                        wep:SetWeaponEnabled(false) 
                        wep:AimManipulatorSetEnabled(false)
                    end 
                    
                    self.AwayFromCarrier = true
                    self:ForkThread(self.GuardCarrier)

                elseif distance < 55 and self.AwayFromCarrier == true then
                
                    --- Enables weapons if the drone is in range of the carrier, allowing drone to engage a targets of opportunity
                    --LOG('*BACK WITH IN RANGE OF THE CARRIER')
                    
                    for i = 1, self:GetWeaponCount() do 
                        local wep = self:GetWeapon(i) 
                        wep:SetWeaponEnabled(true) 
                        wep:AimManipulatorSetEnabled(true)
                    end 
                    
                    self.AwayFromCarrier = false

                    -- Resets the speed and turn rates upon returning to the carrier
                    #self:SetSpeedMult(1.0)
   	            	#self:SetAccMult(0.8)
                    #self:SetTurnMult(0.125)
                end
            end
        end
    end,
    
    GuardCarrier = function(self)
    
        if not self.Dead and not self.Parent:IsDead() then
        
            -- Tells the drone to guard the carrier
            IssueClearCommands(self)
            IssueGuard({self}, self.Parent)
        end
    end, 

}

TypeClass = XEA3204