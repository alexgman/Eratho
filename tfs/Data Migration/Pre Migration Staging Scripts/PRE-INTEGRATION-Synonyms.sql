
/* This script creates synonyms */

/* Create synonyms for CRM tables */    

IF EXISTS (SELECT 1 FROM sys.objects Where type = 'SN' and name = 'CRM_SalesorderBase')
	DROP SYNONYM CRM_SalesOrderBase
CREATE SYNONYM CRM_SalesOrderBase FOR CRMTestDB.DM1_MSCRM.dbo.SalesOrderBase
GO
IF EXISTS (SELECT 1 FROM sys.objects Where type = 'SN' and name = 'CRM_BusinessUnitBase')
	DROP SYNONYM CRM_BusinessunitBase
CREATE SYNONYM CRM_BusinessUnitBase FOR CRMTestDB.DM1_MSCRM.dbo.BusinessUnitBase
GO

IF EXISTS (SELECT 1 FROM sys.objects Where type = 'SN' and name = 'CRM_SalesorderExtensionBase')
	DROP SYNONYM CRM_SalesOrderExtensionBase
CREATE SYNONYM CRM_SalesOrderExtensionBase FOR CRMTestDB.DM1_MSCRM.dbo.SalesOrderExtensionBase
GO

IF EXISTS (SELECT 1 FROM sys.objects Where type = 'SN' and name = 'CRM_SalesorderDetailBase')
	DROP SYNONYM CRM_SalesOrderDetailBase
CREATE SYNONYM CRM_SalesOrderDetailBase FOR CRMTestDB.DM1_MSCRM.dbo.SalesOrderDetailBase
GO
IF EXISTS (SELECT 1 FROM sys.objects Where type = 'SN' and name = 'CRM_SalesorderDetailExtensionBase')
	DROP SYNONYM CRM_SalesOrderDetailExtensionBase
CREATE SYNONYM CRM_SalesOrderDetailExtensionBase FOR CRMTestDB.DM1_MSCRM.dbo.SalesOrderDetailExtensionBase
GO

IF EXISTS (SELECT 1 FROM sys.objects Where type = 'SN' and name = 'CRM_QuoteBase')
	DROP SYNONYM CRM_QuoteBase
CREATE SYNONYM CRM_QuoteBase FOR CRMTestDB.DM1_MSCRM.dbo.QuoteBase
GO
IF EXISTS (SELECT 1 FROM sys.objects Where type = 'SN' and name = 'CRM_QuoteDetailBase')
	DROP SYNONYM CRM_QuoteDetailBase
CREATE SYNONYM CRM_QuoteDetailBase FOR CRMTestDB.DM1_MSCRM.dbo.QuoteDetailBase
GO
IF EXISTS (SELECT 1 FROM sys.objects Where type = 'SN' and name = 'CRM_QuoteExtensionBase')
	DROP SYNONYM CRM_QuoteExtensionBase
CREATE SYNONYM CRM_QuoteExtensionBase FOR CRMTestDB.DM1_MSCRM.dbo.QuoteExtensionBase
GO

IF EXISTS (SELECT 1 FROM sys.objects Where type = 'SN' and name = 'CRM_QuoteDetailExtensionBase')
	DROP SYNONYM CRM_QuoteDetailExtensionBase
CREATE SYNONYM CRM_QuoteDetailExtensionBase FOR CRMTestDB.DM1_MSCRM.dbo.QuoteDetailExtensionBase
GO

IF EXISTS (SELECT 1 FROM sys.objects Where type = 'SN' and name = 'CRM_CampaignBase')
	DROP SYNONYM CRM_CampaignBase
CREATE SYNONYM CRM_CampaignBase FOR CRMTestDB.DM1_MSCRM.dbo.CampaignBase
GO

IF EXISTS (SELECT 1 FROM sys.objects Where type = 'SN' and name = 'CRM_CampaignExtensionBase')
	DROP SYNONYM CRM_CampaignExtensionBase
CREATE SYNONYM CRM_CampaignExtensionBase FOR CRMTestDB.DM1_MSCRM.dbo.CampaignExtensionBase
GO

IF EXISTS (SELECT 1 FROM sys.objects Where type = 'SN' and name = 'CRM_CompetitorBase')
	DROP SYNONYM CRM_CompetitorBase
CREATE SYNONYM CRM_CompetitorBase FOR CRMTestDB.DM1_MSCRM.dbo.CompetitorBase
GO

IF EXISTS (SELECT 1 FROM sys.objects Where type = 'SN' and name = 'CRM_CompetitorExtensionBase')
	DROP SYNONYM CRM_CompetitorExtensionBase
CREATE SYNONYM CRM_CompetitorExtensionBase FOR CRMTestDB.DM1_MSCRM.dbo.CompetitorExtensionBase
GO

IF EXISTS (SELECT 1 FROM sys.objects Where type = 'SN' and name = 'CRM_IncidentBase')
	DROP SYNONYM CRM_IncidentBase
CREATE SYNONYM CRM_IncidentBase FOR CRMTestDB.DM1_MSCRM.dbo.IncidentBase
GO
IF EXISTS (SELECT 1 FROM sys.objects Where type = 'SN' and name = 'CRM_IncidentExtensionBase')
	DROP SYNONYM CRM_IncidentExtensionBase
CREATE SYNONYM CRM_IncidentExtensionBase FOR CRMTestDB.DM1_MSCRM.dbo.IncidentExtensionBase
GO


IF EXISTS (SELECT 1 FROM sys.objects WHERE type = 'SN' AND name = 'CRM_ContactBase')
	DROP SYNONYM CRM_ContactBase
CREATE SYNONYM CRM_ContactBase FOR CRMTestDB.DM1_MSCRM.dbo.ContactBase;
GO
IF EXISTS (SELECT 1 FROM sys.objects WHERE type = 'SN' AND name = 'CRM_ContactExtensionBase')
	DROP SYNONYM CRM_ContactExtensionBase
CREATE SYNONYM CRM_ContactExtensionBase FOR CRMTestDB.DM1_MSCRM.dbo.ContactExtensionBase;
GO
IF EXISTS (SELECT 1 FROM sys.objects WHERE type = 'SN' AND name = 'CRM_CustomerAddressBase')
	DROP SYNONYM CRM_CustomerAddressBase
CREATE SYNONYM CRM_CustomerAddressBase FOR CRMTestDB.DM1_MSCRM.dbo.CustomerAddressBase;
GO
IF EXISTS (SELECT 1 FROM sys.objects WHERE type = 'SN' AND name = 'CRM_CustomerAddressExtensionBase')
	DROP SYNONYM CRM_CustomerAddressExtensionBase
CREATE SYNONYM CRM_CustomerAddressExtensionBase FOR CRMTestDB.DM1_MSCRM.dbo.CustomerAddressExtensionBase;
GO
IF EXISTS (SELECT 1 FROM sys.objects WHERE type = 'SN' AND name = 'CRM_OrganizationBase')
	DROP SYNONYM CRM_OrganizationBase
CREATE SYNONYM CRM_OrganizationBase FOR CRMTestDB.DM1_MSCRM.dbo.OrganizationBase;
GO
IF EXISTS (SELECT 1 FROM sys.objects WHERE type = 'SN' AND name = 'CRM_TransactionCurrencyBase ')
	DROP SYNONYM CRM_TransactionCurrencyBase 
CREATE SYNONYM CRM_TransactionCurrencyBase  FOR CRMTestDB.DM1_MSCRM.dbo.TransactionCurrencyBase;
GO

IF EXISTS (SELECT 1 FROM sys.objects Where type = 'SN' and name = 'CRM_OpportunityBase')
	DROP SYNONYM CRM_OpportunityBase
CREATE SYNONYM CRM_OpportunityBase FOR CRMTestDB.DM1_MSCRM.dbo.OpportunityBase
GO

IF EXISTS (SELECT 1 FROM sys.objects Where type = 'SN' and name = 'CRM_OpportunityExtensionBase')
	DROP SYNONYM CRM_OpportunityExtensionBase
CREATE SYNONYM CRM_OpportunityExtensionBase FOR CRMTestDB.DM1_MSCRM.dbo.OpportunityExtensionBase
GO
IF EXISTS (SELECT 1 FROM sys.objects Where type = 'SN' and name = 'CRM_OrganizationBase')
	DROP SYNONYM CRM_OrganizationBase
CREATE SYNONYM CRM_OrganizationBase FOR CRMTestDB.DM1_MSCRM.dbo.OrganizationBase
GO
IF EXISTS (SELECT 1 FROM sys.objects Where type = 'SN' and name = 'CRM_PriceLevelBase')
	DROP SYNONYM CRM_PriceLevelBase
CREATE SYNONYM CRM_PriceLevelBase FOR CRMTestDB.DM1_MSCRM.dbo.PriceLevelBase
GO
IF EXISTS (SELECT 1 FROM sys.objects Where type = 'SN' and name = 'CRM_PriceLevelExtensionBase')
	DROP SYNONYM CRM_PriceLevelExtensionBase
CREATE SYNONYM CRM_PriceLevelExtensionBase FOR CRMTestDB.DM1_MSCRM.dbo.PriceLevelExtensionBase
GO
IF EXISTS (SELECT 1 FROM sys.objects Where type = 'SN' and name = 'CRM_ProductBase')
	DROP SYNONYM CRM_ProductBase
CREATE SYNONYM CRM_ProductBase FOR CRMTestDB.DM1_MSCRM.dbo.ProductBase
GO
IF EXISTS (SELECT 1 FROM sys.objects Where type = 'SN' and name = 'CRM_ProductExtensionBase')
	DROP SYNONYM CRM_ProductExtensionBase
CREATE SYNONYM CRM_ProductExtensionBase FOR CRMTestDB.DM1_MSCRM.dbo.ProductExtensionBase
GO
IF EXISTS (SELECT 1 FROM sys.objects Where type = 'SN' and name = 'CRM_ProductPriceLevelBase')
	DROP SYNONYM CRM_ProductPriceLevelBase
CREATE SYNONYM CRM_ProductPriceLevelBase FOR CRMTestDB.DM1_MSCRM.dbo.ProductPriceLevelBase
GO

IF EXISTS (SELECT 1 FROM sys.objects Where type = 'SN' and name = 'CRM_SalesLiteratureBase')
	DROP SYNONYM CRM_SalesLiteratureBase
CREATE SYNONYM CRM_SalesLiteratureBase FOR CRMTestDB.DM1_MSCRM.dbo.SalesLiteratureBase
GO
IF EXISTS (SELECT 1 FROM sys.objects Where type = 'SN' and name = 'CRM_SalesLiteratureExtensionBase')
	DROP SYNONYM CRM_SalesLiteratureExtensionBase
CREATE SYNONYM CRM_SalesLiteratureExtensionBase FOR CRMTestDB.DM1_MSCRM.dbo.SalesLiteratureExtensionBase
GO

IF EXISTS (SELECT 1 FROM sys.objects Where type = 'SN' and name = 'CRM_SalesLiteratureItemBase')
	DROP SYNONYM CRM_SalesLiteratureItemBase
CREATE SYNONYM CRM_SalesLiteratureItemBase FOR CRMTestDB.DM1_MSCRM.dbo.SalesLiteratureItemBase
GO

IF EXISTS (SELECT 1 FROM sys.objects Where type = 'SN' and name = 'CRM_TerritoryBase')
	DROP SYNONYM CRM_TerritoryBase
CREATE SYNONYM CRM_TerritoryBase FOR CRMTestDB.DM1_MSCRM.dbo.TerritoryBase
GO

IF EXISTS (SELECT 1 FROM sys.objects Where type = 'SN' and name = 'CRM_vth_account_territoryBase')
	DROP SYNONYM CRM_vth_account_territoryBase
CREATE SYNONYM CRM_vth_account_territoryBase FOR CRMTestDB.DM1_MSCRM.dbo.vth_account_territoryBase
GO
IF EXISTS (SELECT 1 FROM sys.objects Where type = 'SN' and name = 'CRM_vth_account_territoryExtensionBase')
	DROP SYNONYM CRM_vth_account_territoryExtensionBase
CREATE SYNONYM CRM_vth_account_territoryExtensionBase FOR CRMTestDB.DM1_MSCRM.dbo.vth_account_territoryExtensionBase
GO
IF EXISTS (SELECT 1 FROM sys.objects Where type = 'SN' and name = 'CRM_vth_account_vth_departmentBase')
	DROP SYNONYM CRM_vth_account_vth_departmentBase
CREATE SYNONYM CRM_vth_account_vth_departmentBase FOR CRMTestDB.DM1_MSCRM.dbo.vth_account_vth_departmentBase
GO
IF EXISTS (SELECT 1 FROM sys.objects Where type = 'SN' and name = 'CRM_vth_account_vth_departmentExtensionBase')
	DROP SYNONYM CRM_vth_account_vth_departmentExtensionBase
CREATE SYNONYM CRM_vth_account_vth_departmentExtensionBase FOR CRMTestDB.DM1_MSCRM.dbo.vth_account_vth_departmentExtensionBase
GO
IF EXISTS (SELECT 1 FROM sys.objects Where type = 'SN' and name = 'CRM_vth_account_vth_marketsectorBase')
	DROP SYNONYM CRM_vth_account_vth_marketsectorBase
CREATE SYNONYM CRM_vth_account_vth_marketsectorBase FOR CRMTestDB.DM1_MSCRM.dbo.vth_account_vth_marketsectorBase
GO
IF EXISTS (SELECT 1 FROM sys.objects Where type = 'SN' and name = 'CRM_vth_account_vth_marketsectorExtensionBase')
	DROP SYNONYM CRM_vth_account_vth_marketsectorExtensionBase
CREATE SYNONYM CRM_vth_account_vth_marketsectorExtensionBase FOR CRMTestDB.DM1_MSCRM.dbo.vth_account_vth_marketsectorExtensionBase
GO
IF EXISTS (SELECT 1 FROM sys.objects Where type = 'SN' and name = 'CRM_vth_clinicalBase')
	DROP SYNONYM CRM_vth_clinicalBase
CREATE SYNONYM CRM_vth_clinicalBase FOR CRMTestDB.DM1_MSCRM.dbo.vth_clinicalBase
GO
IF EXISTS (SELECT 1 FROM sys.objects Where type = 'SN' and name = 'CRM_vth_clinicalExtensionBase')
	DROP SYNONYM CRM_vth_clinicalExtensionBase
CREATE SYNONYM CRM_vth_clinicalExtensionBase FOR CRMTestDB.DM1_MSCRM.dbo.vth_clinicalExtensionBase
GO
IF EXISTS (SELECT 1 FROM sys.objects Where type = 'SN' and name = 'CRM_vth_commisionrankBase')
	DROP SYNONYM CRM_vth_commisionrankBase
CREATE SYNONYM CRM_vth_commisionrankBase FOR CRMTestDB.DM1_MSCRM.dbo.vth_commisionrankBase
GO
IF EXISTS (SELECT 1 FROM sys.objects Where type = 'SN' and name = 'CRM_vth_commisionrankExtensionBase')
	DROP SYNONYM CRM_vth_commisionrankExtensionBase
CREATE SYNONYM CRM_vth_commisionrankExtensionBase FOR CRMTestDB.DM1_MSCRM.dbo.vth_commisionrankExtensionBase
GO
IF EXISTS (SELECT 1 FROM sys.objects Where type = 'SN' and name = 'CRM_vth_corporateBase')
	DROP SYNONYM CRM_vth_corporateBase
CREATE SYNONYM CRM_vth_corporateBase FOR CRMTestDB.DM1_MSCRM.dbo.vth_corporateBase
GO
IF EXISTS (SELECT 1 FROM sys.objects Where type = 'SN' and name = 'CRM_vth_corporateExtensionBase')
	DROP SYNONYM CRM_vth_corporateExtensionBase
CREATE SYNONYM CRM_vth_corporateExtensionBase FOR CRMTestDB.DM1_MSCRM.dbo.vth_corporateExtensionBase
GO
IF EXISTS (SELECT 1 FROM sys.objects Where type = 'SN' and name = 'CRM_vth_customerliteratureBase')
	DROP SYNONYM CRM_vth_customerliteratureBase
CREATE SYNONYM CRM_vth_customerliteratureBase FOR CRMTestDB.DM1_MSCRM.dbo.vth_customerliteratureBase
GO
IF EXISTS (SELECT 1 FROM sys.objects Where type = 'SN' and name = 'CRM_vth_customerliteratureExtensionBase')
	DROP SYNONYM CRM_vth_customerliteratureExtensionBase
CREATE SYNONYM CRM_vth_customerliteratureExtensionBase FOR CRMTestDB.DM1_MSCRM.dbo.vth_customerliteratureExtensionBase
GO
IF EXISTS (SELECT 1 FROM sys.objects Where type = 'SN' and name = 'CRM_vth_customerliteratureitemBase')
	DROP SYNONYM CRM_vth_customerliteratureitemBase
CREATE SYNONYM CRM_vth_customerliteratureitemBase FOR CRMTestDB.DM1_MSCRM.dbo.vth_customerliteratureitemBase
GO
IF EXISTS (SELECT 1 FROM sys.objects Where type = 'SN' and name = 'CRM_vth_customerliteratureitemExtensionBase')
	DROP SYNONYM CRM_vth_customerliteratureitemExtensionBase
CREATE SYNONYM CRM_vth_customerliteratureitemExtensionBase FOR CRMTestDB.DM1_MSCRM.dbo.vth_customerliteratureitemExtensionBase
GO
IF EXISTS (SELECT 1 FROM sys.objects Where type = 'SN' and name = 'CRM_vth_customerproductBase')
	DROP SYNONYM CRM_vth_customerproductBase
CREATE SYNONYM CRM_vth_customerproductBase FOR CRMTestDB.DM1_MSCRM.dbo.vth_customerproductBase
GO
IF EXISTS (SELECT 1 FROM sys.objects Where type = 'SN' and name = 'CRM_vth_customerproductExtensionBase')
	DROP SYNONYM CRM_vth_customerproductExtensionBase
CREATE SYNONYM CRM_vth_customerproductExtensionBase FOR CRMTestDB.DM1_MSCRM.dbo.vth_customerproductExtensionBase
GO
IF EXISTS (SELECT 1 FROM sys.objects Where type = 'SN' and name = 'CRM_vth_departmentBase')
	DROP SYNONYM CRM_vth_departmentBase
CREATE SYNONYM CRM_vth_departmentBase FOR CRMTestDB.DM1_MSCRM.dbo.vth_departmentBase
GO
IF EXISTS (SELECT 1 FROM sys.objects Where type = 'SN' and name = 'CRM_vth_departmentExtensionBase')
	DROP SYNONYM CRM_vth_departmentExtensionBase
CREATE SYNONYM CRM_vth_departmentExtensionBase FOR CRMTestDB.DM1_MSCRM.dbo.vth_departmentExtensionBase
GO
IF EXISTS (SELECT 1 FROM sys.objects Where type = 'SN' and name = 'CRM_vth_marketsectorBase')
	DROP SYNONYM CRM_vth_marketsectorBase
CREATE SYNONYM CRM_vth_marketsectorBase FOR CRMTestDB.DM1_MSCRM.dbo.vth_marketsectorBase
GO
IF EXISTS (SELECT 1 FROM sys.objects Where type = 'SN' and name = 'CRM_vth_marketsectorExtensionBase')
	DROP SYNONYM CRM_vth_marketsectorExtensionBase
CREATE SYNONYM CRM_vth_marketsectorExtensionBase FOR CRMTestDB.DM1_MSCRM.dbo.vth_marketsectorExtensionBase
GO
IF EXISTS (SELECT 1 FROM sys.objects Where type = 'SN' and name = 'CRM_vth_orderexceptionBase')
	DROP SYNONYM CRM_vth_orderexceptionBase
CREATE SYNONYM CRM_vth_orderexceptionBase FOR CRMTestDB.DM1_MSCRM.dbo.vth_orderexceptionBase
GO
IF EXISTS (SELECT 1 FROM sys.objects Where type = 'SN' and name = 'CRM_vth_orderexceptionExtensionBase')
	DROP SYNONYM CRM_vth_orderexceptionExtensionBase
CREATE SYNONYM CRM_vth_orderexceptionExtensionBase FOR CRMTestDB.DM1_MSCRM.dbo.vth_orderexceptionExtensionBase
GO
IF EXISTS (SELECT 1 FROM sys.objects Where type = 'SN' and name = 'CRM_vth_postalcodeBase')
	DROP SYNONYM CRM_vth_postalcodeBase
CREATE SYNONYM CRM_vth_postalcodeBase FOR CRMTestDB.DM1_MSCRM.dbo.vth_postalcodeBase
GO
IF EXISTS (SELECT 1 FROM sys.objects Where type = 'SN' and name = 'CRM_vth_postalcodeExtensionBase')
	DROP SYNONYM CRM_vth_postalcodeExtensionBase
CREATE SYNONYM CRM_vth_postalcodeExtensionBase FOR CRMTestDB.DM1_MSCRM.dbo.vth_postalcodeExtensionBase
GO
IF EXISTS (SELECT 1 FROM sys.objects Where type = 'SN' and name = 'CRM_vth_pricelistitemdetailBase')
	DROP SYNONYM CRM_vth_pricelistitemdetailBase
CREATE SYNONYM CRM_vth_pricelistitemdetailBase FOR CRMTestDB.DM1_MSCRM.dbo.vth_pricelistitemdetailBase
GO
IF EXISTS (SELECT 1 FROM sys.objects Where type = 'SN' and name = 'CRM_vth_pricelistitemdetailExtensionBase')
	DROP SYNONYM CRM_vth_pricelistitemdetailExtensionBase
CREATE SYNONYM CRM_vth_pricelistitemdetailExtensionBase FOR CRMTestDB.DM1_MSCRM.dbo.vth_pricelistitemdetailExtensionBase
GO
IF EXISTS (SELECT 1 FROM sys.objects Where type = 'SN' and name = 'CRM_vth_sicBase')
	DROP SYNONYM CRM_vth_sicBase
CREATE SYNONYM CRM_vth_sicBase FOR CRMTestDB.DM1_MSCRM.dbo.vth_sicBase
GO
IF EXISTS (SELECT 1 FROM sys.objects Where type = 'SN' and name = 'CRM_vth_sicExtensionBase')
	DROP SYNONYM CRM_vth_sicExtensionBase
CREATE SYNONYM CRM_vth_sicExtensionBase FOR CRMTestDB.DM1_MSCRM.dbo.vth_sicExtensionBase
GO
IF EXISTS (SELECT 1 FROM sys.objects Where type = 'SN' and name = 'CRM_vth_territory_vth_postalcodeBase')
	DROP SYNONYM CRM_vth_territory_vth_postalcodeBase
CREATE SYNONYM CRM_vth_territory_vth_postalcodeBase FOR CRMTestDB.DM1_MSCRM.dbo.vth_territory_vth_postalcodeBase
GO
IF EXISTS (SELECT 1 FROM sys.objects Where type = 'SN' and name = 'CRM_vth_territory_vth_postalcodeExtensionBase')
	DROP SYNONYM CRM_vth_territory_vth_postalcodeExtensionBase
CREATE SYNONYM CRM_vth_territory_vth_postalcodeExtensionBase FOR CRMTestDB.DM1_MSCRM.dbo.vth_territory_vth_postalcodeExtensionBase
GO
IF EXISTS (SELECT 1 FROM sys.objects Where type = 'SN' and name = 'CRM_vth_trackingBase')
	DROP SYNONYM CRM_vth_trackingBase
CREATE SYNONYM CRM_vth_trackingBase FOR CRMTestDB.DM1_MSCRM.dbo.vth_trackingBase
GO
IF EXISTS (SELECT 1 FROM sys.objects Where type = 'SN' and name = 'CRM_vth_trackingExtensionBase')
	DROP SYNONYM CRM_vth_trackingExtensionBase
CREATE SYNONYM CRM_vth_trackingExtensionBase FOR CRMTestDB.DM1_MSCRM.dbo.vth_trackingExtensionBase
GO
IF EXISTS (SELECT 1 FROM sys.objects Where type = 'SN' and name = 'CRM_vth_warrentyBase')
	DROP SYNONYM CRM_vth_warrentyBase
CREATE SYNONYM   CRM_vth_warrentyBase FOR CRMTestDB.DM1_MSCRM.dbo.vth_warrentyBase
GO
IF EXISTS (SELECT 1 FROM sys.objects Where type = 'SN' and name = 'CRM_vth_warrentyExtensionBase')
	DROP SYNONYM CRM_vth_warrentyExtensionBase
CREATE SYNONYM CRM_vth_warrentyExtensionBase FOR CRMTestDB.DM1_MSCRM.dbo.vth_warrentyExtensionBase
GO
IF EXISTS (SELECT 1 FROM sys.objects Where type = 'SN' and name = 'CRM_UoMBase')
	DROP SYNONYM CRM_UoMBase
CREATE SYNONYM CRM_UoMBase FOR CRMTestDB.DM1_MSCRM.dbo.UoMBase
GO
IF EXISTS (SELECT 1 FROM sys.objects Where type = 'SN' and name = 'CRM_ProductDetailBase')
	DROP SYNONYM CRM_ProductDetailBase
CREATE SYNONYM CRM_ProductDetailBase FOR CRMTestDB.DM1_MSCRM.dbo.vth_ProductDetailBase
GO
IF EXISTS (SELECT 1 FROM sys.objects Where type = 'SN' and name = 'CRM_ProductDetailExtensionBase')
	DROP SYNONYM CRM_ProductDetailExtensionBase
CREATE SYNONYM CRM_ProductDetailExtensionBase FOR CRMTestDB.DM1_MSCRM.dbo.vth_ProductDetailExtensionBase
GO
IF EXISTS (SELECT 1 FROM sys.objects Where type = 'SN' and name = 'CRM_SolutionBase')
	DROP SYNONYM CRM_SolutionBase
CREATE SYNONYM CRM_SolutionBase FOR CRMTestDB.DM1_MSCRM.dbo.SolutionBase
GO
IF EXISTS (SELECT 1 FROM sys.objects Where type = 'SN' and name = 'CRM_TeamBase')
	DROP SYNONYM CRM_TeamBase
CREATE SYNONYM CRM_TeamBase FOR CRMTestDB.DM1_MSCRM.dbo.TeamBase
GO
IF EXISTS (SELECT 1 FROM sys.objects Where type = 'SN' and name = 'CRM_TeamExtensionBase')
	DROP SYNONYM CRM_TeamExtensionBase
CREATE SYNONYM CRM_TeamExtensionBase FOR CRMTestDB.DM1_MSCRM.dbo.TeamExtensionBase
GO




IF EXISTS (SELECT 1 FROM sys.objects WHERE type = 'SN' AND name = 'CRM_LocalizedLabel')
	DROP SYNONYM CRM_LocalizedLabel
CREATE SYNONYM CRM_LocalizedLabel FOR CRMTestDB.DM1_MSCRM.MetadataSchema.LocalizedLabel;
GO
IF EXISTS (SELECT 1 FROM sys.objects WHERE type = 'SN' AND name = 'CRM_AttributePicklistValue')
	DROP SYNONYM CRM_AttributePicklistValue
CREATE SYNONYM CRM_AttributePicklistValue FOR CRMTestDB.DM1_MSCRM.MetadataSchema.AttributePicklistValue;
GO
IF EXISTS (SELECT 1 FROM sys.objects WHERE type = 'SN' AND name = 'CRM_OptionSet')
	DROP SYNONYM CRM_OptionSet
CREATE SYNONYM CRM_OptionSet FOR CRMTestDB.DM1_MSCRM.MetadataSchema.OptionSet;
GO
IF EXISTS (SELECT 1 FROM sys.objects WHERE type = 'SN' AND name = 'CRM_Attribute')
	DROP SYNONYM CRM_Attribute
CREATE SYNONYM CRM_Attribute FOR CRMTestDB.DM1_MSCRM.MetadataSchema.Attribute;
GO
IF EXISTS (SELECT 1 FROM sys.objects WHERE type = 'SN' AND name = 'CRM_Entity')
	DROP SYNONYM CRM_Entity
CREATE SYNONYM CRM_Entity FOR CRMTestDB.DM1_MSCRM.MetadataSchema.Entity;
GO
IF EXISTS (SELECT 1 FROM sys.objects WHERE type = 'SN' AND name = 'CRM_PublisherBase')
	DROP SYNONYM CRM_PublisherBase
CREATE SYNONYM CRM_PublisherBase FOR CRMTestDB.DM1_MSCRM.dbo.PublisherBase;
GO
IF EXISTS (SELECT 1 FROM sys.objects WHERE type = 'SN' AND name = 'CRM_SolutionBase')
	DROP SYNONYM CRM_SolutionBase
CREATE SYNONYM CRM_SolutionBase FOR CRMTestDB.DM1_MSCRM.dbo.SolutionBase;
GO

IF EXISTS (SELECT 1 FROM sys.objects WHERE type = 'SN' AND name = 'CRM_SystemUserBase')
	DROP SYNONYM CRM_SystemUserBase
CREATE SYNONYM CRM_SystemUserBase FOR CRMTestDB.DM1_MSCRM.dbo.SystemUserBase;
GO
IF EXISTS (SELECT 1 FROM sys.objects WHERE type = 'SN' AND name = 'CRM_SystemUserExtensionBase')
	DROP SYNONYM CRM_SystemUserExtensionBase
CREATE SYNONYM CRM_SystemUserExtensionBase FOR CRMTestDB.DM1_MSCRM.dbo.SystemUserExtensionBase;
GO

IF EXISTS (SELECT 1 FROM sys.objects WHERE type = 'SN' AND name = 'CRM_AccountBase')
	DROP SYNONYM CRM_AccountBase
CREATE SYNONYM CRM_AccountBase FOR CRMTestDB.DM1_MSCRM.dbo.AccountBase;
GO
IF EXISTS (SELECT 1 FROM sys.objects WHERE type = 'SN' AND name = 'CRM_AccountExtensionBase')
	DROP SYNONYM CRM_AccountExtensionBase
CREATE SYNONYM CRM_AccountExtensionBase FOR CRMTestDB.DM1_MSCRM.dbo.AccountExtensionBase;
GO


IF EXISTS (SELECT 1 FROM sys.objects WHERE type = 'SN' AND name = 'CRM_CustomerAddressBase__keys__')
	DROP SYNONYM CRM_CustomerAddressBase__keys__
CREATE SYNONYM CRM_CustomerAddressBase__keys__ FOR CRMTestDB.DM1_MSCRM.dbo.CustomerAddressBase__keys__;
GO

/*
IF EXISTS (SELECT 1 FROM sys.objects WHERE type = 'SN' AND name = 'CRM_GBS_')
	DROP SYNONYM CRM_GBS_
CREATE SYNONYM CRM_GBS_ FOR CRMTestDB.DM1_MSCRM.dbo.;
GO
*/

/* Create synonyms for CRM views */
IF EXISTS (SELECT 1 FROM sys.objects WHERE type = 'SN' AND name = 'CRM_SystemUser')
	DROP SYNONYM CRM_SystemUser
CREATE SYNONYM CRM_SystemUser FOR CRMTestDB.DM1_MSCRM.dbo.SystemUser;
GO
IF EXISTS (SELECT 1 FROM sys.objects WHERE type = 'SN' AND name = 'CRM_LocalizedLabelView')
	DROP SYNONYM CRM_LocalizedLabelView
CREATE SYNONYM CRM_LocalizedLabelView FOR CRMTestDB.DM1_MSCRM.dbo.LocalizedLabelView;
GO
IF EXISTS (SELECT 1 FROM sys.objects WHERE type = 'SN' AND name = 'CRM_AttributePicklistValueView')
	DROP SYNONYM CRM_AttributePicklistValueView
CREATE SYNONYM CRM_AttributePicklistValueView FOR CRMTestDB.DM1_MSCRM.dbo.AttributePicklistValueView;
GO
IF EXISTS (SELECT 1 FROM sys.objects WHERE type = 'SN' AND name = 'CRM_OptionSetView')
	DROP SYNONYM CRM_OptionSetView
CREATE SYNONYM CRM_OptionSetView FOR CRMTestDB.DM1_MSCRM.dbo.OptionSetView;
GO
IF EXISTS (SELECT 1 FROM sys.objects WHERE type = 'SN' AND name = 'CRM_SystemParameterBase')
	DROP SYNONYM CRM_SystemParameterBase
CREATE SYNONYM CRM_SystemParameterBase FOR CRMTestDB.DM1_MSCRM.dbo.gbs_SystemParameterBase;
GO
IF EXISTS (SELECT 1 FROM sys.objects WHERE type = 'SN' AND name = 'CRM_SystemParameterExtensionBase')
	DROP SYNONYM CRM_SystemParameterExtensionBase
CREATE SYNONYM CRM_SystemParameterExtensionBase FOR CRMTestDB.DM1_MSCRM.dbo.gbs_SystemParameterExtensionBase;
GO
IF EXISTS (SELECT 1 FROM sys.objects WHERE type = 'SN' AND name = 'CRM_LocalTimeToUTC')
	DROP SYNONYM CRM_LocalTimeToUTC
CREATE SYNONYM CRM_LocalTimeToUTC FOR CRMTestDB.DM1_MSCRM.dbo.fn_LocalTimeToUTC;
GO




IF EXISTS (SELECT 1 FROM sys.objects WHERE type = 'SN' AND name = 'CRM_fn_LocalTimeToUTC')
	DROP SYNONYM dbo.CRM_fn_LocalTimeToUTC
CREATE SYNONYM dbo.CRM_fn_LocalTimeToUTC FOR CRMTestDB.DM1_MSCRM.dbo.fn_LocalTimeToUTC;
GO

IF EXISTS (SELECT 1 FROM sys.objects WHERE type = 'SN' AND name = 'CRM_fn_UTCToLocalTime')
	DROP SYNONYM dbo.CRM_fn_UTCToLocalTime
CREATE SYNONYM dbo.CRM_fn_UTCToLocalTime FOR CRMTestDB.DM1_MSCRM.dbo.fn_UTCToLocalTime
GO

GRANT EXECUTE ON OBJECT::dbo.CRM_fn_LocalTimeToUTC TO PUBLIC
GO
GRANT EXECUTE ON OBJECT::dbo.CRM_fn_UTCToLocalTime TO PUBLIC
GO

/*
IF EXISTS (SELECT 1 FROM sys.objects WHERE type = 'SN' AND name = 'CRM_GBS_')
	DROP SYNONYM CRM_GBS_
CREATE SYNONYM CRM_GBS_ FOR CRMTestDB.DM1_MSCRM.dbo.;
GO
*/

--USE [Braves_Stage]
--IF EXISTS (SELECT 1 FROM sys.objects WHERE type = 'SN' AND name = 'dbo.Stage_fn_FormatUnformattedPhone')
--	DROP SYNONYM dbo.Stage_fn_FormatUnformattedPhone
--CREATE SYNONYM dbo.Stage_fn_FormatUnformattedPhone FOR Braves_Stage.dbo.fn_FormatUnformattedPhone;
--GO


IF EXISTS (SELECT 1 FROM sys.objects WHERE type = 'SN' AND name = 'CRM_EmailSearchBase')
	DROP SYNONYM CRM_EmailSearchBase
CREATE SYNONYM CRM_EmailSearchBase FOR CRMTestDB.DM1_MSCRM.dbo.EmailSearchBase;
GO

