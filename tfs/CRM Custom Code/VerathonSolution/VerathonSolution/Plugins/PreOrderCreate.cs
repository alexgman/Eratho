// <copyright file="PreOrderCreate.cs" company="Microsoft">
// Copyright (c) 2012 All Rights Reserved
// </copyright>
// <author>Microsoft</author>
// <date>9/27/2012 8:19:23 PM</date>
// <summary>Implements the PreOrderCreate Plugin.</summary>
// <auto-generated>
//     This code was generated by a tool.
//     Runtime Version:4.0.30319.1
// </auto-generated>
namespace VerathonSolution.Plugins
{
    using System;
    using System.ServiceModel;
    using System.Xml;

    using Microsoft.Xrm.Sdk;
    using Microsoft.Xrm.Sdk.Query;
    using Microsoft.Xrm.Sdk.Messages;
    using Microsoft.Xrm.Sdk.Metadata;

    using Verathon.Crm.Entities;
    using Verathon.Crm.Helper;
    /// <summary>
    /// PreOrderCreate Plugin.
    /// </summary>    
    public class PreOrderCreate: Plugin
    {
        public string unsecureConfig = "";

        /// <summary>
        /// Initializes a new instance of the <see cref="PreOrderCreate"/> class.
        /// </summary>
        /// <param name="unsecure">Contains public (unsecure) configuration information.</param>
        /// <param name="secure">Contains non-public (secure) configuration information. 
        /// When using Microsoft Dynamics CRM for Outlook with Offline Access, 
        /// the secure string is not passed to a plug-in that executes while the client is offline.</param>
        public PreOrderCreate(string unsecure, string secure)
            : base(typeof(PreOrderCreate))
        {
            base.RegisteredEvents.Add(new Tuple<int, string, string, Action<LocalPluginContext>>(20, "Create", "salesorder", new Action<LocalPluginContext>(ExecutePreOrderCreate)));

            // Note : you can register for more events here if this plugin is not specific to an individual entity and message combination.
            // You may also need to update your RegisterFile.crmregister plug-in registration file to reflect any change.


           // TODO: Implement your custom configuration handling.

            //XML will be parsed in the execute if needed.
            unsecureConfig = unsecure;
        }

        /// <summary>
        /// Initializes a new instance of the <see cref="PreOrderCreate"/> class.
        /// </summary>
        public PreOrderCreate()
            : base(typeof(PreOrderCreate))
        {
            base.RegisteredEvents.Add(new Tuple<int, string, string, Action<LocalPluginContext>>(20, "Create", "salesorder", new Action<LocalPluginContext>(ExecutePreOrderCreate)));

            // Note : you can register for more events here if this plugin is not specific to an individual entity and message combination.
            // You may also need to update your RegisterFile.crmregister plug-in registration file to reflect any change.
        }

        /// <summary>
        /// Executes the plug-in.
        /// </summary>
        /// <param name="localContext">The <see cref="LocalPluginContext"/> which contains the
        /// <see cref="IPluginExecutionContext"/>,
        /// <see cref="IOrganizationService"/>
        /// and <see cref="ITracingService"/>
        /// </param>
        /// <remarks>
        /// For improved performance, Microsoft Dynamics CRM caches plug-in instances.
        /// The plug-in's Execute method should be written to be stateless as the constructor
        /// is not called for every invocation of the plug-in. Also, multiple system threads
        /// could execute the plug-in at the same time. All per invocation state information
        /// is stored in the context. This means that you should not use global variables in plug-ins.
        /// </remarks>
        protected void ExecutePreOrderCreate(LocalPluginContext localContext)
        {
            if (localContext == null)
            {
                throw new ArgumentNullException("localContext");
            }

            try
            {
                Entity target = (Entity)localContext.PluginExecutionContext.InputParameters["Target"];
                IOrganizationService service = localContext.OrganizationService;
                
                Entity preImageEntity = null;

                if (target.Contains("vth_originalorderid") || target.Contains("vth_ordertype") || target.Contains("vth_destination"))
                {
                    string strOrderType = "";
                    int intOrderTypeValue = 0;
                    string strDestination = "";
                    int intDestination = 0;
                    string strOrderNumber = "";
                    string strSuffix;

                    Helper.GetOrderNumber(target, service, preImageEntity, out strOrderType, out strDestination, out strOrderNumber, out intOrderTypeValue, out intDestination);

                    if (!target.Contains("vth_originalorderid"))
                    //Generate a new integer order number
                    {                       
                        XmlDocument unsecureXml = new XmlDocument();
                        unsecureXml.LoadXml(unsecureConfig);
                        Guid sequenceId = new Guid(unsecureXml.SelectSingleNode("//gbs_nextidId").InnerText);
                        strOrderNumber = GBSNextId.GetNextIntegerId(sequenceId, localContext.OrganizationService).ToString();
                    }

                   strSuffix = Helper.GetMaxSuffix(target, service, preImageEntity, strOrderNumber, intOrderTypeValue, intDestination);

                    target["vth_ordersuffix"] = strSuffix;
                    target["vth_ordernumber"] = strOrderNumber;
                    target["ordernumber"] = strDestination + strOrderType + strOrderNumber + " - " + strSuffix;
                }

            }
            catch (Exception ex)
            {
                //create the Plug-in Exception Log
                GBSPluginExceptionLog.LogException(localContext.OrganizationService, localContext.PluginExecutionContext, localContext.TracingService, GetType().Module.ScopeName, ex);
            }
        }
    }
}
