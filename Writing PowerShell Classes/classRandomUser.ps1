#Requires -Modules AzureRM.Resources
Add-Type -AssemblyName System.web

class RandomUser {

    [String]$GivenName
    [String]$SurName
    [MailAddress]$Email
    [String]$UserName
    [GUID]$UUID
    [String]$Password
    Hidden [HashTable]$paramAADAccount
    Hidden [String]$upnSuffix = '<yourTenantSuffix>.onmicrosoft.com'

    # Constructor: Creates a new empty RandomUser object
    RandomUser(){}

    # Constructor: Create a new RandomUSer object filled in
    RandomUser($gn,$sn,$m,$un,$id,$pw){
        $this.GivenName = $gn
        $this.SurName = $sn
        $this.Email = $m
        $this.UserName = $un
        $this.UUID = $id
        $this.Password = $pw
     }

    [PSCustomObject]CreateAADAccount(){
        $displayName = '{0} {1}'-f $this.GivenName, $this.SurName
        $paramAADUser = @{}

        try{
            if(!$(Get-AzureRmADUser -DisplayName $displayName)) {
                $paramAADuser.displayName = $displayName
                $paramAADuser.mailNickName = ($this.Email -split '@')[0]
                $paramAADUser.passWord = ConvertTo-SecureString -String $this.Password -AsPlainText -Force
                $paramAADUSer.ForceChangePasswordNextLogin = $true
                $paramAADuser.userPrincipalName = '{0}@{1}' -f ($this.Email -split '@')[0],$this.upnSuffix
                
                $result = New-AzureRmADUser @paramAADuser

                #Save parameters in Hidden property paramAADAccount
                $this.paramAADAccount = $paramAADuser

                #Update UUID to reflect created Id
                $this.UUID = $result.Id             
            }
            else{
                Write-Warning "Seems '$($displayName)' has already been created"
            }
        }
        catch{
            Write-Warning "Something went wrong creating AAD account with DisplayName: '$($displayName)'"
        }

        return [PSCustomObject]$paramAADuser
    }

    [Void]DeleteAADAccount(){
        $displayName = '{0} {1}'-f $this.GivenName, $this.SurName
        try{
            if(Get-AzureRmADUser -DisplayName $displayName){
                Remove-AzureRmADUser -DisplayName $displayName -Confirm:$false -Force
                $this.paramAADAccount = $null
                Write-Host "Deleted AADAccount '$($displayName)'" -ForegroundColor Red
            }
            else{
                Write-Warning "Seems AAD account with DisplayName: $($displayName) doesn't exist"
            }
        }
        catch{
            Write-Warning "Something went wrong deleting AAD account with DisplayName: '$($displayName)'"
        }
    }

    static [void]DeleteAADAccount($dn){
        try{     
            if(Get-AzureRmADUser -DisplayName $dn){
                Remove-AzureRmADUser -DisplayName $dn -Confirm:$false -Force
                Write-Host "Deleted AADAccount '$($dn)'" -ForegroundColor Red
            }
            else{
                Write-Warning "Seems AAD account with DisplayName: $($dn) doesn't exist"
            }
        }
        catch{
            Write-Warning "Something went wrong deleting AAD account with DisplayName: '$($dn)'"
        }
    }

    #Called without creating an instance
    static [RandomUser]GetRandomUser() {
        # Set properties for RandomUser class
        $result = (Invoke-RestMethod -Uri 'https://randomuser.me/api?nat=gb&?password=special,upper,lower,number,12' -Method Get).results
        
        $gn = $result.Name.First
        $sn = $result.Name.Last
        $m  = $result.Email
        $un = $result.Login.username
        $id = $result.Login.uuid
        $pw = [System.Web.Security.Membership]::GeneratePassword(12,2)
          
        return [RandomUser]::New($gn,$sn,$m,$un,$id,$pw)
    }
    
    [PSObject]GetAADAccount(){
        $displayName = '{0} {1}'-f $this.GivenName, $this.SurName
        $result = Get-AzureRmADUser -DisplayName $displayName

        if(!$result){
            Write-Warning "Seems AAD account with DisplayName: $($displayName) doesn't exist"
        }

        return $result
    }

    static [PSObject]GetAADAccount([String]$dn){
        $result = Get-AzureRmADUser -DisplayName $dn

        if(!$result){
            Write-Warning "Seems AAD account with DisplayName: '$($dn)' doesn't exist"
        }

        return $result
    }
    
    static [PSObject]GetAADAccount([GUID]$Id){
        $result = Get-AzureRmADUser -ObjectId $Id

        if(!$result){
            Write-Warning "Seems AAD account with ObjectId: '$($Id)' doesn't exist"
        }

        return $result
    }

    [String]ToString(){

        $formatInput = @(
            $this.GivenName
            $this.SurName
            $this.Email
            $this.UUID
        )

        $toString = "DisplayName: {0} {1}`nEmail: {2}`nId: {3}" -f $formatInput
        return $toString
    }
}

Connect-AzureRmAccount -TenantId '<YouTenantID>'

#region static methods

#Get the overloaddefinitions 
[Randomuser]::New

#GetAADAccount using DisplayName
[RandomUser]::GetAADAccount('April Coppoolse')
[RandomUser]::GetAADAccount('63240157-dfc9-42f8-948f-e149caa069e4')       #Fails because it's just a string
[RandomUser]::GetAADAccount([GUID]'63240157-dfc9-42f8-948f-e149caa069e4') #Passes because correctly typecast

#endregion

#region Create Empty Random User
$singleUser = [RandomUser]::New()
$singleUser

$singleUser.Email = 'urv@dupsug.com'
$singleUser.GivenName = 'Urv'$singleUser.SurName = 'Dupsug'
$singleUser.Password = 'Welcome@DuP5U9'
$singleUser.UserName = 'urv.dupsug'
$singleUser.UUID = ([Guid]::NewGuid()).Guid

$singleUser.ToString()

#create Account
$singleUser.CreateAADAccount()
[RandomUser]::GetAADAccount('Urv Dupsug')

#endregion

#region single user
$oneUser = [RandomUser]::GetRandomUser()
$oneUser

#create User in AzureAD
$oneUser.CreateAADAccount()
$oneUser.CreateAADAccount()

#region Demo overloading static GetAADAccount

#Get AADAccount using the displayName saved in hidden property paramAADAccount
[RandomUser]::GetAADAccount($oneUser.paramAADAccount.DisplayName)

#Or using the updated property UUID
[RandomUser]::GetAADAccount($oneUser.UUID)

#endregion

#delete User in AzureAD
$oneUser.DeleteAADAccount()
$oneUser.DeleteAADAccount()
#endregion

#region Multiple users
$fiveUsers = 1..5 | ForEach-Object{ [RandomUser]::GetRandomUser()}
$fiveUsers

#create first account
$fiveUsers[0].CreateAADAccount()

#Get all accounts in fiveUsers                                      
$fiveUsers.GetAADAccount()

#create second account                                               
$fiveUsers[1].CreateAADAccount()

#Get all accounts in fiveUsers.This is simple and to the point                                            
$fiveUsers.GetAADAccount() 

#Or using UUID with foreach-object. This is also a valid option
$fiveUsers |
ForEach-Object{
    [RandomUser]::GetAADAccount($_.UUID)
}

#create all remaning account                                               
$fiveUsers.CreateAADAccount()  

#try again                                           
$fiveUsers.CreateAADAccount()

#Delete first account                                            
$fiveUsers[0].DeleteAADAccount()

#try retrieving all account                                             
$fiveUsers.GetAADAccount() 

#Delete last account                                            
$fiveUsers[-1].DeleteAADAccount() 

#try retrieving all account                                             
$fiveUsers.GetAADAccount() 
                                            
#Delete all remaning accounts
$fiveUsers.DeleteAADAccount()

#try retrieving all account                                             
$fiveUsers.GetAADAccount() 

#Recreate the second account                                               
$fiveUsers[1].CreateAADAccount()                                          
$fiveUsers.GetAADAccount()

#Last but not least  delete everything once more
$fiveUsers.DeleteAADAccount()
#endregion