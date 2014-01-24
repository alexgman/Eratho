// <copyright file="PreOpportunityUpdate.cs" company="Microsoft">
// Copyright (c) 2012 All Rights Reserved
// </copyright>
// <author>Microsoft</author>
// <date>10/17/2012 10:19:51 PM</date>
// <summary>Implements the PreOpportunityUpdate Plugin.</summary>
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

    using Verathon.Crm.Entities;
    using Verathon.Crm.Helper;

    /// <summary>
    /// PreOpportunityUpdate Plugin.
    /// Fires when the following attributes are updated:
    /// All Attributes
    /// </summary>    
    public class PreOpportunityUpdate: Plugin
    {
        /// <summary>
        /// Alias of the image registered for the snapshot of the 
        /// primary entity's attributes before the core platform operation executes.
        /// The image contains the following attributes:
        /// No Attributes
        /// </summary>
        private readonly string preImageAlias = "preImage";

        /// <summary>
        /// Initializes a new instance of the <see cref="PreOpportunityUpdate"/> class.
        /// </summary>
        public PreOpportunityUpdate()
            : base(typeof(PreOpportunityUpdate))
        {
            base.RegisteredEvents.Add(new Tuple<int, string, string, Action<LocalPluginContext>>(20, "Update", "opportunity", new Action<LocalPluginContext>(ExecutePreOpportunityUpdate)));

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
        protected void ExecutePreOpportunityUpdate(LocalPluginContext localContext)
        {
            if (localContext == null)
            {
                throw new ArgumentNullException("localContext");
            }

            IPluginExecutionContext context = localContext.PluginExecutionContext;

            Entity preImageEntity = (context.PreEntityImages != null && context.PreEntityImages.Contains(this.preImageAlias)) ? context.PreEntityImages[this.preImageAlias] : null;

            try
            {
                IOrganizationService service = localContext.OrganizationService;
                Entity target = (Entity)localContext.PluginExecutionContext.InputParameters["Target"];

                if (target.Contains("vth_probability"))
                {
                    if (target["vth_probability"] != null)
                    {
                        string strProbability = Helper.GetPickListValueOption(service, "opportunity", "vth_probability", (OptionSetValue)target.Attributes["vth_probability"]);
                        switch (strProbability)
                        {
                            case "958560000":
                                target["closeprobability"] = 50;
                                break;
                            case "958560001":
                                target["closeprobability"] = 70;
                                break;
                            case "958560002":
                                target["closeprobability"] = 90;
                                break;
                            case "958560003":
                                target["closeprobability"] = 100;
                                break;
                            default:
                                target["closeprobability"] = 0;
                                break;
                        }
                    }
                    else
                    {
                        target["closeprobability"] = 0;
                    }
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