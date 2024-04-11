local playerPed = GetPlayerPed(-1)

function displayHint(text)
    SetTextComponentFormat("STRING")
    AddTextComponentString(text)
    DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end

-- create blips
Citizen.CreateThread(
    function()
        for _,item in pairs(Config.Locations) do
            item.blip = AddBlipForCoord(item.x, item.y, item.z)
            SetBlipSprite(item.blip, item.id)
            SetBlipDisplay(item.blip, 2)
            SetBlipScale(item.blip, 1.0)
            SetBlipColour(item.blip, item.colour)
            SetBlipAsShortRange(item.blip, true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(item.title)
            EndTextCommandSetBlipName(item.blip)
        end
    end
)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(10)
        local playerCoords = GetEntityCoords(playerPed)
        for i in pairs(Config.Locations) do

           local distance = Vdist2(playerCoords.x, playerCoords.y, playerCoords.z, Config.Locations[i].x, Config.Locations[i].y, Config.Locations[i].z)

           if distance <= 150.0 then
                local playerCar = GetVehiclePedIsIn(playerPed, false)
                local vehicleEntity = GetEntityModel(playerCar)
                local speed = GetEntitySpeed(playerCar) * 3.6 -- m/s to km/h

                if speed > Config.Locations[i].maxKmh and GetPedInVehicleSeat(playerCar, -1) == playerPed  
                -- TODO: check vehicle is Thruster
                -- Thruster uçak olması lazım ama ara galiba araba olarak geçiyor. Thruster'ı da kontrol mekanizmasına eklenmesi gerek.
                -- TODO: check vehicle is a police or military or sheriff vehicle
                and ( IsThisModelACar(vehicleEntity)
                or IsThisModelABike(vehicleEntity) 
                or IsThisModelAQuadbike(vehicleEntity) 
                or IsThisModelAnAmphibiousCar(vehicleEntity) 
                or IsThisModelAnAmphibiousQuadbike(vehicleEntity) )
                    then
                        displayHint("You are speeding! Slow down!")         
                        Citizen.Wait(2000)         
                end
            end
        end
    end
end)
