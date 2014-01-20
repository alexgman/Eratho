CrmSvcUtil.exe ^
/codewriterfilter:"Microsoft.Crm.Sdk.Samples.FilteringService, GeneratePicklistEnums" ^
/codecustomization:"Microsoft.Crm.Sdk.Samples.CodeCustomizationService, GeneratePicklistEnums" ^
/namingservice:"Microsoft.Crm.Sdk.Samples.NamingService, GeneratePicklistEnums" ^
/url:http://bocp-d-crm0.testdev.dxu.com/VerathonDev/XRMServices/2011/Organization.svc ^
/namespace:"Verathon.Crm.OptionSets" /out:OptionSets.cs /username:"testdev\testken" /password:"Password1"