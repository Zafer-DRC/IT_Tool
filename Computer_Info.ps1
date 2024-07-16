class Computer
{
    [string]$computer_name

    Computer([string]$computer_name)
    {
        $this.computer_name = $computer_name
    }

    [void]ChangeComputerName()
    {
        try
        {
            Rename-Computer -NewName "$this.computer_name"
            Write-Host "`n"
            Write-Host "Bilgisayar adı $($this.computer_name) olarak degistirildi. DEGISIKLIGIN UYGULANMASI ICIN LUTFEN BILGISAYARI YENIDEN BASLATIN!"
        }
        catch
        {
            Write-Host "`n"
            Write-Host "Bilgisayar Adi Degistirilirken Bir Hata Olustu! $_"
        }

    }

    [void]BaseBoardInfo()
    {
        try
        {
            [string]$cmd = Get-CimInstance -ClassName Win32_BaseBoard | Select-Object -Property Manufacturer,Model,Name,SerialNumber,SKU,Product
            Write-Host $cmd
        }
        catch
        {
            Write-Host "`n"
            Write-Host "Anakart Bilgileri Alinirken Bir Hata Olustu! $_"
        }
        
    }

    [void]BiosInfo()
    {
        try
        {
            [string]$cmd = Get-CimInstance -ClassName Win32_BIOS | Select-Object -Property SMBIOSBIOSVersion,Manufacturer,Name,SerialNumber,Version
            Write-Host $cmd
        }
        catch
        {
            Write-Host "`n"
            Write-Host "BIOS Bilgileri Alinirken Bir Hata Olustu ! $_"
        }
        
    }
}

class Network
{
    [void] ShowPublicIP()
    {
        try
        {
            $command = Invoke-RestMethod -Uri "http://ifconfig.me/ip"
            Write-Host "Public IP'niz: $command"    
        }
        catch
        {
            Write-Host "Public IP Gosterilirken Bir Hata Olustu!"
        }
    }

    [void] ShowLocalNetworkInfo()
    {
        try
        {
            $command = ipconfig /all
            Write-Host $command
        }
        catch
        {
            Write-Host "`n"
            Write-Host "Local IP Bilgileri Gosterilirken Bir Hata Olustu!"
        }
    }

    [void] ShowMACAddress()
    {
        try
        {
            $command = Get-NetAdapter | Select-Object -Property Name,InterfaceDescription,ifIndex,Status,MacAddress,LinkSpeed
            Write-Host $command | Format-Table -Property Name,InterfaceDescription,ifIndex,Status,MacAddress,LinkSpeed -AutoSize
        }
        catch
        {
            Write-Host "MAC Adresi Gosterilirken Bir Hata Olustu!"
        }
    }

    [void] ShowNetworks()
    {
        try
        {
            $profiles = netsh wlan show profiles
            $networks = @()

            foreach($line in $profiles -split "`n")
            {
                if($line -match "All User Profile\s*: (.+)")
                {
                    $networks += [PSCustomObject]@{SSID = $matches[0].Trim()}
                }
            }

            if($networks.Count -gt 0)
            {
                Write-Host $networks | Format-Table -AutoSize
            }

            else
            {
                Write-Host "`n"
                Write-Host "Ag Bulunamadi."
            }
        }
        catch
        {
            Write-Host "`n"
            Write-Host "Aglari Listelerken Beklenmedik Bir Hata Olustu!: $_"   
        }
    }

    [string] ShowNetworkPass([string]$ssid)
    {
        try
        {
            [string]$pass_info = netsh wlan show profiles name = "$ssid" key = clear
            $pass = $null

            foreach($line in $pass_info -split "`n")
            {
                if($line -match "Key Content\s*: (.+)")
                {
                    $pass = $matches[1].Trim()
                }
            }

            if($pass)
            {
                $output  = [PSCustomObject]@{
                SSID     = $ssid
                Password = $pass
                }
                $output | Format-Table -AutoSize
                return $output
            }

            else
            {
                Write-Host "`n"
                Write-Host "İlgili Ag Sifresi Bulunamadi!"
                return $null
            }

        }
        catch
        {
            Write-Host "`n"
            Write-Host "Ag Sifresini Listelerken Beklenmedik Bir Hata Olustu!: $_"
            return $null
        }


    }


}


function Main
{
    try
    {

        while($true)
        {
            Write-Host "`n"
            Write-Host "Lutfen Yapmak Istediginiz Islemi Seciniz"
            Write-Host "1- Bilgisayar Adini Degistir"
            Write-Host "2- Anakart Bilgilerini Goster"
            Write-Host "3- BIOS Bilgilerini Goster"
            Write-Host "4- Public IP Goster"
            Write-Host "5- Local IP Bilgilerini Goster"
            Write-Host "6- MAC Adresi Goster"
            Write-Host "7- Aglari Listele"
            Write-Host "8- Ag Sifresini Goster"
            Write-Host "0- Cikis Yap"

            $choice = Read-Host
            $computer = [Computer]::new($new_name)
            $network =  [Network]::new()

            switch($choice)
            {
                1
                {
                     Write-Host "`n"
                     Write-Host "Su Anki Bilgisayar Adiniz    : $env:COMPUTERNAME "
                     $new_name  = Read-Host "Yeni Bilgisayar Adini Giriniz:"
                     $computer.ChangeComputerName()
                     break
                }

                2
                {
                    Write-Host "`n"
                    $computer.BaseBoardInfo()
                    break
                }
                3
                {
                    Write-Host "`n"
                    $computer.BiosInfo()
                    break
                }

                4
                {
                    Write-Host "`n"
                    $network.ShowPublicIP()
                    break
                }

                5
                {
                    Write-Host "`n"
                    $network.ShowLocalNetworkInfo()
                    break
                }

                6
                {
                    Write-Host "`n"                    
                    $network.ShowMACAddress()
                    break
                }

                7
                {
                    Write-Host "`n"                    
                    $network.ShowNetworks()
                    break
                }

                8
                {
                    Write-Host "`n"                    
                    $network.ShowNetworks()
                    $selected_network = Read-Host "Sifresini Gormek İstediginiz Agi Seciniz :"
                    $network.ShowNetworkPass($selected_network)
                    break
                }
                
                0
                {
                    Write-Host "`n"
                    Write-Host "Cikis Yapiliyor..."
                    return
                }

                default
                {
                    Write-Host "`n"
                    Write-Host "Lutfen Gecerli Bir Deger Giriniz !"
                    break
                }
            }
        }   
    }
    catch
    {
        Write-Host "`n"
        Write-Host "Beklenmedik Bir Hata Olustu! $_"
    }
    
}

Main