EXEC dbo.Users_Import
GO

-- products and pricelists
EXEC dbo.Product_Import
GO
EXEC dbo.Pricelist_Import
GO
EXEC dbo.PricelistItem_Import
GO
EXEC dbo.PricelistItemDetail_Import
GO

-- onyx
EXEC dbo.Company_Import
GO
EXEC dbo.Contact_Import
GO
EXEC dbo.CustomerAddress_Import
GO
EXEC dbo.Opportunity_Import
GO
EXEC dbo.Incident_Import
GO
EXEC dbo.Territory_Import
GO
EXEC dbo.CompanyTerritory_Import
GO
EXEC dbo.SalesLiterature_Import
GO
EXEC dbo.CustomerLiterature_Import
GO
EXEC dbo.CutsomerLiteratureItem_Import
GO
EXEC dbo.Department_Import
GO
EXEC dbo.CompanyDepartment_Import
GO
EXEC dbo.Warranty_Import
GO
EXEC dbo.Quote_Import
GO
EXEC dbo.QuoteProduct_Import
GO
EXEC dbo.Campaign_Import
GO
EXEC dbo.MarketingList_Import
GO
EXEC dbo.ListMembers_Import
GO
EXEC dbo.MarketSector_Import
GO
EXEC dbo.CompanyMarketSector_Import
GO
EXEC dbo.Competitor_Import
GO
EXEC dbo.OpportunityCompetitor_Import
GO
EXEC dbo.OpportunityProduct_Import
GO
EXEC dbo.Note_Import
GO


-- portal orders
EXEC dbo.Order_Import
GO
EXEC dbo.OrderProduct_Import
GO
EXEC dbo.OrderException_Import
GO
EXEC dbo.CustomerProduct_Import
GO
EXEC dbo.Task_Import
GO
EXEC dbo.Tracking_Import
