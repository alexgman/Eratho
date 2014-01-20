USE [CRM_Staging]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
If  Object_ID('[dbo].[OrderException]') IS NOT NULL

DROP TABLE [dbo].[OrderException]
GO
BEGIN
CREATE TABLE [dbo].[OrderException]
(
[createdby] [uniqueidentifier],
[createdon] [datetime],
[createdonutc] [datetime],
[createdonbehalfby] [uniqueidentifier],
[importsequencenumber] [int],
[modifiedby] [uniqueidentifier],
[modifiedon] [datetime],
[modifiedonutc] [datetime],
[modifiedonbehalfby] [uniqueidentifier],
[overriddencreatedon] [datetime],
[overriddencreatedonutc] [datetime],
[ownerid] [uniqueidentifier],
[owneriddsc] [int],
[owneridtype] [int],
[owningbusinessunit] [uniqueidentifier],
[owningteam] [uniqueidentifier],
[owninguser] [uniqueidentifier],
[statecode] [int],
[statuscode] [int],
[timezoneruleversionnumber] [int],
[utcconversiontimezonecode] [int],
[versionnumber] [timestamp],
[vth_cleared] [bit],
[vth_description] [nvarchar](200),
[vth_name] [nvarchar](200),
[vth_orderexceptionid] [uniqueidentifier] null,
[vth_orderid] [uniqueidentifier],
[vth_VerathonRefId][int]
















)END