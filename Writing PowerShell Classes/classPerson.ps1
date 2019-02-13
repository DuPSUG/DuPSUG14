Enum Gender{
    NotDisclosed = 0
    Male = 1
    Female = 2
}

Class Person{
    [String]$GivenName
    [String]$SurName
    [Int]$age
    [Gender]$Gender

    #Empty Constructor
    Person(){}

    #Constructor with all properties
    Person($gn,$sn,$a,$s){
        $this.GivenName = $gn
        $this.SurName = $sn
        $this.age = $a
        $this.Gender = $s
    }

    #Constructor excluding gender
    Person($gn,$sn,$a){
        $this.GivenName = $gn
        $this.SurName = $sn
        $this.age = $a
    }

    #Overriding default function ToString()

    <#
        By default ToString() will return the class Name value
        Which isn't informative. Override to retun informative data
    #>

    [String]ToString(){
        
        return "{0} {1}" -f $this.GivenName,$this.SurName
    }

    #region Overloading 
    
    <#
        Overloaded methods behave differently depending on the number of
        arguments or the data types of the arguments supplied
    #>

    #Method GetMessage. Use dot annotation to access method
    [String]GetMessage(){
        return "Hi {0}" -f $this.GivenName
    }

    #Method can be accessed without creating an instance.Cannot use $this
    static [String]GetMessage($gn){
        return "Hi {0}" -f $gn
    }
    #endregion
}

#region Demo Person

#instantiate a new Object from class Person

#Overview Constructors
[Person]::New

#Create empty Person Object
[Person]::new()

#create new Person object with properties.
$me = [Person]::new('Irwin', 'Strachan', 39, 'Male')
$me

#Create using Gender enumeration
[Person]::new('Irwin', 'Strachan',39, [Gender]1)
[Person]::new('Irwin', 'Strachan',39, [Gender]'Male')
[Person]::new('Irwin', 'Strachan',39, [Gender]::Male)
#Call method GetMessage from Object
$me.GetMessage()

#Call method GetMessage from person Object Class
[Person]::GetMessage('Urv')
#endregion